#!/usr/bin/env python3
#
# This file is part of LimePSB_RPCM_GW.
#
# Copyright (c) 2024-2025 Lime Microsystems.
#
# SPDX-License-Identifier: Apache-2.0
#
# Target script for LimePSB-RPCM board (https://github.com/myriadrf/LimePSB_RPCM_GW)
#

import os
import argparse

from migen import *
from migen.genlib.resetsync import AsyncResetSynchronizer

from litex.gen import *

from litex.build.io import SDRTristate
from litex.build.vhd2v_converter import *

from litex.soc.cores.clock import *
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *

from litex.soc.integration.soc import SoCRegion
from litex.soc.interconnect import wishbone
from litex.soc.interconnect.csr import *

from limepsb_rpcm_platform import Platform

# CRG ----------------------------------------------------------------------------------------------

class _CRG(LiteXModule):
    def __init__(self, platform, sys_clk_freq):
        assert sys_clk_freq in [6e6, 12e6, 24e6, 48e6]
        self.rst         = Signal()
        self.cd_sys      = ClockDomain()
        self.cd_por      = ClockDomain()
        self.cd_clk10    = ClockDomain()
        self.cd_clk30p72 = ClockDomain()
        self.cd_vctcxo   = ClockDomain()

        # Power On Reset.
        # ---------------
        por_count = Signal(16, reset=2**16-1)
        por_done  = Signal()
        self.comb += self.cd_por.clk.eq(self.cd_sys.clk)
        self.comb += por_done.eq(por_count == 0)
        self.sync.por += If(~por_done, por_count.eq(por_count - 1))

        # Sys Clk Domain.
        # ---------------
        clk_hf_div = {
             6e6 : "0b11",
            12e6 : "0b10",
            24e6 : "0b01",
            48e6 : "0b00",
        }[sys_clk_freq]
        self.specials += Instance("SB_HFOSC",
            p_CLKHF_DIV = clk_hf_div,
            i_CLKHFEN   = 0b1,
            i_CLKHFPU   = 0b1,
            o_CLKHF     = self.cd_sys.clk,
        )
        self.specials += AsyncResetSynchronizer(self.cd_sys, ~por_done)
        platform.add_period_constraint(self.cd_sys.clk, 1e9 / sys_clk_freq)

        # RF 10MHz/30.72MHz Clk Domains.
        # ------------------------------
        self.comb += [
            self.cd_clk10.clk.eq(    platform.request("lmk10_clk_out0")),
            self.cd_clk30p72.clk.eq( platform.request("lmkrf_clk_out4")),
        ]

# BaseSoC ------------------------------------------------------------------------------------------
class BaseSoC(SoCCore):
    def __init__(self, sys_clk_freq=6e6, firmware_path=None, **kwargs):
        platform = Platform()

        # SoCCore ----------------------------------------------------------------------------------

        kwargs["cpu_type"]             = "serv"
        kwargs["with_timer"]           = False
        kwargs["with_ctrl"]            = False
        kwargs["integrated_sram_size"] = 0x100
        kwargs["integrated_rom_size"]  = 0x2000
        kwargs["integrated_rom_init"]  = firmware_path

        SoCCore.__init__(self, platform, sys_clk_freq, ident="LimePSB-RPCM GPSDO SoC", **kwargs)

        # CRG --------------------------------------------------------------------------------------

        self.crg = _CRG(platform, sys_clk_freq)

        # Signals ----------------------------------------------------------------------------------

        # PPS.
        pps                   = Signal()
        pps_active            = Signal()

        # RPi.
        rpi_sync_pads_i       = Signal()

        # GPSDO Config.
        gpsdo_en              = Signal()
        gpsdo_clk_sel         = Signal()
        gpsdo_tpulse_sel      = Signal(2)
        gpsdo_rpi_sync_in_dir = Signal()
        gpsdo_1s_target       = Signal(32)
        gpsdo_1s_tol          = Signal(16)
        gpsdo_10s_target      = Signal(32)
        gpsdo_10s_tol         = Signal(16)
        gpsdo_100s_target     = Signal(32)
        gpsdo_100s_tol        = Signal(16)

        # GPSDO Status.
        gpsdo_1s_error        = Signal(32)
        gpsdo_10s_error       = Signal(32)
        gpsdo_100s_error      = Signal(32)
        gpsdo_dac_tuned_val   = Signal(16)
        gpsdo_accuracy        = Signal(4)
        gpsdo_state           = Signal(4)

        # VCXO Tamer.
        vctcxo_tamer_irq      = Signal()

        # Pads -------------------------------------------------------------------------------------

        # HW/BOM.
        version_pads       = platform.request("version")

        # PCIe.
        pcie_uim_pad       = platform.request("pcie_uim")

        # GNSS.
        gnss_pads          = platform.request("gnss")

        # Rpi.
        rpi_uart0_pads     = platform.request("rpi_uart0")
        rpi_spi1_pads      = platform.request("rpi_spi1")
        rpi_sync_pads      = platform.request("rpi_sync")

        # FPGA.
        fpga_led_r         = platform.request("fpga_led_r")
        fpga_rf_sw_tdd_pad = platform.request("fpga_rf_sw_tdd")
        fpga_spi0_pads     = platform.request("fpga_spi0")
        fpga_sync_out_pads = platform.request("fpga_sync_out")


        # BOM/HW Version ---------------------------------------------------------------------------

        # Get BOM/HW Version from IOs.
        bom_version  = Signal(3)
        hw_version   = Signal(2)
        self.comb += [
            bom_version.eq(version_pads.bom),
            hw_version.eq(version_pads.hw),
        ]

        # Mailbox (SoC <-> CPU Communication) ------------------------------------------------------

        class Mailbox(LiteXModule):
            def __init__(self):
                self.gpsdo_en         = CSRStatus()
                self.vctcxo_tamer_irq = CSRStatus()

                # # #

                self.comb += self.gpsdo_en.status.eq(gpsdo_en)

                self.sync += [
                    If(self.vctcxo_tamer_irq.we,
                        self.vctcxo_tamer_irq.status.eq(vctcxo_tamer_irq)
                    ).Else(
                        self.vctcxo_tamer_irq.status.eq(vctcxo_tamer_irq | self.vctcxo_tamer_irq.status)
                    )
                ]

        self.mailbox = Mailbox()

        # TDD Redirection --------------------------------------------------------------------------

        self.comb += [
            fpga_rf_sw_tdd_pad.eq(pcie_uim_pad),
            # On HW Version = 0b01, invert TDD signal.
            If(hw_version == 0b01,
                fpga_rf_sw_tdd_pad.eq(~pcie_uim_pad)
            )
        ]

        # GNSS -------------------------------------------------------------------------------------

        self.comb += [
            # GNSS Unused IOs.
            gnss_pads.extint.eq(0),
            gnss_pads.ddc_scl.eq(1),
            gnss_pads.ddc_sda.eq(1),

            # GNSS Power-up (Active low reset).
            gnss_pads.reset.eq(1),

            # GNSS UART (Connect to RPI UART0).
            rpi_uart0_pads.rx.eq(gnss_pads.uart_tx),
            gnss_pads.uart_rx.eq(rpi_uart0_pads.tx),
        ]

        # GPSDOCFG ---------------------------------------------------------------------------------

        # Instance.
        # ---------
        self.specials += Instance("gpsdocfg",
            # Config.
            i_maddress                  = 0,
            i_mimo_en                   = 1,

            # SPI.
            i_sdin                      = rpi_spi1_pads.mosi,
            i_sclk                      = rpi_spi1_pads.sclk,
            i_sen                       = rpi_spi1_pads.ss1,
            o_sdout                     = rpi_spi1_pads.miso,

            # Rst/Ctrl.
            i_lreset                    = ResetSignal("sys"),
            i_mreset                    = ResetSignal("sys"),
            o_oen                       = Open(),

            # Inputs.
            i_PPS_1S_ERROR_in           = gpsdo_1s_error,
            i_PPS_10S_ERROR_in          = gpsdo_10s_error,
            i_PPS_100S_ERROR_in         = gpsdo_100s_error,
            i_DAC_TUNED_VAL_in          = gpsdo_dac_tuned_val,
            i_ACCURACY_in               = gpsdo_accuracy,
            i_STATE_in                  = gpsdo_state,
            i_TPULSE_ACTIVE_in          = pps_active,

            # Outputs.
            o_IICFG_EN_out              = gpsdo_en,
            o_IICFG_CLK_SEL_out         = gpsdo_clk_sel,
            o_IICFG_TPULSE_SEL_out      = gpsdo_tpulse_sel,
            o_IICFG_RPI_SYNC_IN_DIR_out = gpsdo_rpi_sync_in_dir,
            o_IICFG_1S_TARGET_out       = gpsdo_1s_target,
            o_IICFG_1S_TOL_out          = gpsdo_1s_tol,
            o_IICFG_10S_TARGET_out      = gpsdo_10s_target,
            o_IICFG_10S_TOL_out         = gpsdo_10s_tol,
            o_IICFG_100S_TARGET_out     = gpsdo_100s_target,
            o_IICFG_100S_TOL_out        = gpsdo_100s_tol
        )

        # VHD2V Conversion.
        # -----------------
        self.vhd2v_converter_gpsdocfg = VHD2VConverter(self.platform,
            top_entity     = "gpsdocfg",
            flatten_source = False,
            files          = [
                "hdl/spi/revisions.vhd",
                "hdl/spi/gpsdocfg.vhd",
                "hdl/spi/mcfg32wm_fsm.vhd",
                "hdl/spi/mem_package.vhd",
            ]
        )
        self.vhd2v_converter_gpsdocfg._ghdl_opts.append("-fsynopsys")

        # PPS Selection ----------------------------------------------------------------------------

        self.comb += Case(gpsdo_tpulse_sel, {
            0b01 : pps.eq(rpi_sync_pads.o),  # RPI_SYNC_OUT.
            0b10 : pps.eq(rpi_sync_pads_i),  # RPI_SYNC_IN.
            0b00 : pps.eq(gnss_pads.tpulse), # GNSS_TPULSE (default).
            0b11 : pps.eq(gnss_pads.tpulse), # GNSS_TPULSE (default).
        })

        # PPS Detection ----------------------------------------------------------------------------

        # Instance.
        # ---------
        self.specials += Instance("pps_detector",
            # Clk/Rst.
            i_clk        = ClockSignal("sys"),
            i_reset      = ResetSignal("sys"),

            # PPS Input/Output.
            i_pps        = pps,
            o_pps_active = pps_active
        )

        # VHD2V Conversion.
        # -----------------
        self.vhd2v_converter_pps_detector = VHD2VConverter(self.platform,
            top_entity     = "pps_detector",
            params         = dict(
                p_CLK_FREQ_HZ = 6000000,
                p_TOLERANCE   = 5000000,
            ),
            flatten_source = False,
            files          = ["hdl/pps_detector/pps_detector.vhd"]
        )
        self.vhd2v_converter_pps_detector._ghdl_opts.append("-fsynopsys")

        # Led --------------------------------------------------------------------------------------

        self.comb += fpga_led_r.eq(~(gnss_pads.tpulse & gpsdo_en))

        # VCTCXO Clk Selection ---------------------------------------------------------------------

        self.comb += Case(gpsdo_clk_sel, {
            0b0 : ClockSignal("vctcxo").eq(ClockSignal("clk30p72")), # VCTCXO Clk from 30.72MHz XO (Default).
            0b1 : ClockSignal("vctcxo").eq(ClockSignal("clk10")),    # VCTCXO Clk from 10MHz XO.
        })

        # SPI DAC Control and Sharing with Rpi -----------------------------------------------------

        # SPI Master (AD5662 DAC).
        # ------------------------
        spi_pads = Record([("clk", 1), ("cs_n", 1), ("mosi", 1), ("miso", 1)])
        self.add_spi_master(name="spi", pads=spi_pads, data_width=24, spi_clk_freq=1e6)

        # SPI Sharing Logic.
        # ------------------
        self.comb += [
            # SPI0 controlled from Rpi.
            If(gpsdo_en == 0b0,
                fpga_spi0_pads.sclk.eq(rpi_spi1_pads.sclk),
                fpga_spi0_pads.mosi.eq(rpi_spi1_pads.mosi),
                fpga_spi0_pads.dac_ss.eq(rpi_spi1_pads.ss2),
            ),

            # SPI0 controlled from CPU.
            If(gpsdo_en == 0b1,
                fpga_spi0_pads.sclk.eq(spi_pads.clk),
                fpga_spi0_pads.mosi.eq(spi_pads.mosi),
                fpga_spi0_pads.dac_ss.eq(spi_pads.cs_n),
            ),
        ]

        # Sync In / Out ----------------------------------------------------------------------------

        # FPGA_SYNC_OUT.
        self.comb += fpga_sync_out_pads.eq(ClockSignal("clk10"))

        # RPI_SYNC_IN.
        self.specials += SDRTristate(
            io  = rpi_sync_pads.i,
            i   = rpi_sync_pads_i,
            o   = gnss_pads.tpulse,
            oe  = ~((gpsdo_rpi_sync_in_dir == 0) | (gpsdo_tpulse_sel == 0b10)),
            clk = ClockSignal("sys"),
        )

        # VCTCXO Tamer -----------------------------------------------------------------------------

        # MMAP (Wishbone).
        # ----------------
        vctcxo_tamer_bus = wishbone.Interface(data_width=32, adr_width=32)
        self.bus.add_slave("vctcxo_tamer", vctcxo_tamer_bus, region=SoCRegion(size=0x1000))

        # Instance.
        # ---------
        self.specials += Instance("vctcxo_tamer",
            # Clk/PPS Inputs.
            i_vctcxo_clock       = ClockSignal("vctcxo"),
            i_tune_ref           = pps,

            # Wishbone Interface.
            i_wb_clk_i           = ClockSignal("sys"),
            i_wb_rst_i           = ResetSignal("sys"),
            i_wb_adr_i           = vctcxo_tamer_bus.adr,
            i_wb_dat_i           = vctcxo_tamer_bus.dat_w,
            o_wb_dat_o           = vctcxo_tamer_bus.dat_r,
            i_wb_we_i            = vctcxo_tamer_bus.we,
            i_wb_stb_i           = vctcxo_tamer_bus.stb,
            o_wb_ack_o           = vctcxo_tamer_bus.ack,
            i_wb_cyc_i           = vctcxo_tamer_bus.cyc,
            o_wb_int_o           = vctcxo_tamer_irq,

            # Configuration Inputs.
            i_PPS_1S_TARGET      = gpsdo_1s_target,
            i_PPS_1S_ERROR_TOL   = gpsdo_1s_tol,
            i_PPS_10S_TARGET     = gpsdo_10s_target,
            i_PPS_10S_ERROR_TOL  = gpsdo_10s_tol,
            i_PPS_100S_TARGET    = gpsdo_100s_target,
            i_PPS_100S_ERROR_TOL = gpsdo_100s_tol,

            # Status Output.
            o_pps_1s_error       = gpsdo_1s_error,
            o_pps_10s_error      = gpsdo_10s_error,
            o_pps_100s_error     = gpsdo_100s_error,
            o_accuracy           = gpsdo_accuracy,
            o_state              = gpsdo_state,
            o_dac_tuned_val      = gpsdo_dac_tuned_val
        )

        # VHD2V Conversion.
        # -----------------
        self.vhd2v_converter_vctcxo_tamer = VHD2VConverter(self.platform,
            top_entity     = "vctcxo_tamer",
            flatten_source = False,
            files          = [
                "hdl/vctcxo_tamer/edge_detector_fixed.vhd",
                "hdl/vctcxo_tamer/handshake.vhd",
                "hdl/vctcxo_tamer/pps_counter.vhd",
                "hdl/vctcxo_tamer/reset_synchronizer.vhd",
                "hdl/vctcxo_tamer/synchronizer.vhd",
                "hdl/vctcxo_tamer/vctcxo_tamer.vhd",
            ]
        )

# Build -------------------------------------------------------------------------------------------
def main():
    from litex.build.parser import LiteXArgumentParser
    parser = LiteXArgumentParser(platform=Platform, description="LiteX SoC on LimePSB RPCM Board.")
    parser.add_argument("--sys-clk-freq", default=6e6, help="System clock frequency (default: 10MHz)")
    args = parser.parse_args()

    # SoC.
    for run in range(2):
        prepare = (run == 0)
        build   = ((run == 1) and (args.build or args.load))
        soc = BaseSoC(
            sys_clk_freq  = int(float(args.sys_clk_freq)),
            firmware_path = None if prepare else "firmware/firmware.bin",
            **soc_core_argdict(args)
        )
        builder = Builder(soc, **parser.builder_argdict)
        builder.build(run=build)
        if prepare:
            ret = os.system("cd firmware && make clean all")
            if ret != 0:
                raise RuntimeError("Firmware build failed")

if __name__ == "__main__":
    main()
