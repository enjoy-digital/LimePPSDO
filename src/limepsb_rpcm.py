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
from migen.genlib.cdc       import MultiReg
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

from hdl.gpsdocfg.src.gpsdocfg import GPSDOCFG

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

        # GPSDOCFG ---------------------------------------------------------------------------------

        self.gpsdocfg = GPSDOCFG(spi_pads=rpi_spi1_pads)
        self.gpsdocfg.add_sources()

        # Mailbox (SoC <-> CPU Communication) ------------------------------------------------------

        class Mailbox(LiteXModule):
            def __init__(self, soc):
                self.gpsdo_en         = CSRStatus()
                self.vctcxo_tamer_irq = CSRStatus()

                # # #

                self.comb += self.gpsdo_en.status.eq(soc.gpsdocfg.config_en)

                self.sync += [
                    If(self.vctcxo_tamer_irq.we,
                        self.vctcxo_tamer_irq.status.eq(vctcxo_tamer_irq)
                    ).Else(
                        self.vctcxo_tamer_irq.status.eq(vctcxo_tamer_irq | self.vctcxo_tamer_irq.status)
                    )
                ]

        self.mailbox = Mailbox(soc=self)

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

        # PPS Selection ----------------------------------------------------------------------------

        rpi_sync_pads_o_resync  = Signal()
        rpi_sync_pads_i_resync  = Signal()
        gnss_pads_tpulse_resync = Signal()
        self.specials += [
            MultiReg(rpi_sync_pads.o,   rpi_sync_pads_o_resync, "vctcxo"),
            MultiReg(rpi_sync_pads_i,   rpi_sync_pads_i_resync, "vctcxo"),
            MultiReg(gnss_pads.tpulse, gnss_pads_tpulse_resync, "vctcxo"),
        ]

        self.comb += Case(self.gpsdocfg.config_tpulse_sel, {
            0b01      : pps.eq(rpi_sync_pads_o_resync),  # RPI_SYNC_OUT.
            0b10      : pps.eq(rpi_sync_pads_i_resync),  # RPI_SYNC_IN.
            "default" : pps.eq(gnss_pads_tpulse_resync), # GNSS_TPULSE (default).
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
                p_CLK_FREQ_HZ = sys_clk_freq,
                p_TOLERANCE   = 5000000,
            ),
            flatten_source = False,
            files          = ["hdl/pps_detector/src/pps_detector.vhd"]
        )
        self.vhd2v_converter_pps_detector._ghdl_opts.append("-fsynopsys")

        # Led --------------------------------------------------------------------------------------

        self.comb += fpga_led_r.eq(~(gnss_pads.tpulse & self.gpsdocfg.config_en))

        # VCTCXO Clk Selection ---------------------------------------------------------------------

        self.comb += Case(self.gpsdocfg.config_clk_sel, {
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
            If(self.gpsdocfg.config_en == 0b0,
                fpga_spi0_pads.sclk.eq(rpi_spi1_pads.sclk),
                fpga_spi0_pads.mosi.eq(rpi_spi1_pads.mosi),
                fpga_spi0_pads.dac_ss.eq(rpi_spi1_pads.ss2),
            ),

            # SPI0 controlled from CPU.
            If(self.gpsdocfg.config_en == 0b1,
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
            oe  = ~((self.gpsdocfg.config_rpi_sync_in_dir == 0) | (self.gpsdocfg.config_tpulse_sel == 0b10)),
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
            i_PPS_1S_TARGET      = self.gpsdocfg.config_1s_target,
            i_PPS_1S_ERROR_TOL   = self.gpsdocfg.config_1s_tol,
            i_PPS_10S_TARGET     = self.gpsdocfg.config_10s_target,
            i_PPS_10S_ERROR_TOL  = self.gpsdocfg.config_10s_tol,
            i_PPS_100S_TARGET    = self.gpsdocfg.config_100s_target,
            i_PPS_100S_ERROR_TOL = self.gpsdocfg.config_100s_tol,

            # Status Output.
            o_pps_1s_error       = self.gpsdocfg.status_1s_error,
            o_pps_10s_error      = self.gpsdocfg.status_10s_error,
            o_pps_100s_error     = self.gpsdocfg.status_100s_error,
            o_accuracy           = self.gpsdocfg.status_accuracy,
            o_state              = self.gpsdocfg.status_state,
            o_dac_tuned_val      = self.gpsdocfg.status_dac_tuned_val
        )

        # VHD2V Conversion.
        # -----------------
        self.vhd2v_converter_vctcxo_tamer = VHD2VConverter(self.platform,
            top_entity     = "vctcxo_tamer",
            flatten_source = False,
            files          = [
                "hdl/vctcxo_tamer/src/edge_detector.vhd",
                "hdl/vctcxo_tamer/src/handshake.vhd",
                "hdl/vctcxo_tamer/src/pps_counter.vhd",
                "hdl/vctcxo_tamer/src/reset_synchronizer.vhd",
                "hdl/vctcxo_tamer/src/synchronizer.vhd",
                "hdl/vctcxo_tamer/src/vctcxo_tamer.vhd",
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
