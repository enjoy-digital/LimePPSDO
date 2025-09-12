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

from litex.build.vhd2v_converter import *

from litex.soc.cores.clock import *
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *

from litex.soc.integration.soc import SoCRegion
from litex.soc.interconnect import wishbone

from litex.soc.cores.led import LedChaser

from limepsb_rpcm_platform import Platform

# CRG ----------------------------------------------------------------------------------------------

# FIXME: Understand why integrated HFOSC divider don't seem to work with Yosys and remove divider.

class _CRG(LiteXModule):
    def __init__(self, platform, sys_clk_freq, use_logic_divider=True):
        self.rst         = Signal()
        self.cd_osc      = ClockDomain()
        self.cd_sys      = ClockDomain()
        self.cd_por      = ClockDomain()
        assert sys_clk_freq in [6e6, 12e6, 24e6, 48e6]

        # Power On Reset.
        # ---------------
        por_count = Signal(16, reset=2**16-1)
        por_done  = Signal()
        self.comb += self.cd_por.clk.eq(self.cd_sys.clk)
        self.comb += por_done.eq(por_count == 0)
        self.sync.por += If(~por_done, por_count.eq(por_count - 1))

        # Internal High Frequency Oscillator.
        # -----------------------------------
        clk_hf_div = {
             6e6 : "0b11",
            12e6 : "0b10",
            24e6 : "0b01",
            48e6 : "0b00",
        }[sys_clk_freq]
        if use_logic_divider:
            clk_hf_div = "0b00" # Force to 48MHz.
        self.specials += Instance("SB_HFOSC",
            p_CLKHF_DIV = clk_hf_div,
            i_CLKHFEN   = 0b1,
            i_CLKHFPU   = 0b1,
            o_CLKHF     = self.cd_osc.clk,
        )

        # Clk Divider.
        # ------------
        div_clk = Signal()
        if use_logic_divider:
            div_count = Signal(4)
            self.sync.osc += div_count.eq(div_count + 1)
            self.comb += div_clk.eq({
                6e6  : div_count[2],
                12e6 : div_count[1],
                24e6 : div_count[0],
                48e6 : self.cd_osc.clk,
            }[sys_clk_freq])
        else:
            self.comb += div_clk.eq(self.cd_osc.clk)

        # Sys Clk Domain.
        # ---------------
        self.comb += self.cd_sys.clk.eq(div_clk)
        self.specials += AsyncResetSynchronizer(self.cd_sys, ~por_done)
        platform.add_period_constraint(self.cd_sys.clk, 1e9 / sys_clk_freq)

# BaseSoC ------------------------------------------------------------------------------------------
class BaseSoC(SoCCore):
    def __init__(self, sys_clk_freq=10e6, **kwargs):
        platform = Platform()

        # SoCCore ----------------------------------------------------------------------------------

        kwargs["cpu_type"]             = "serv"
        kwargs["with_timer"]           = False # FIXME? Enable back?
        kwargs["integrated_sram_size"] = 0x100
        kwargs["integrated_rom_size"]  = 0x2000
        kwargs["integrated_rom_init"]  = "firmware/firmware.bin"

        SoCCore.__init__(self, platform, sys_clk_freq, ident="LiteX SoC on LimePSB RPCM Board", **kwargs)

        # CRG --------------------------------------------------------------------------------------

        self.crg = _CRG(platform, sys_clk_freq)

        # BOM/HW Version ---------------------------------------------------------------------------

        # Get BOM/HW Version from IOs.
        bom_version  = Signal(3)
        hw_version   = Signal(2)
        version_pads = platform.request("version")
        self.comb += [
            bom_version.eq(version_pads.bom),
            hw_version.eq(version_pads.hw),
        ]

        # Led --------------------------------------------------------------------------------------

        self.leds = LedChaser(
            pads         = platform.request_all("fpga_led_r"),
            sys_clk_freq = sys_clk_freq
        )

        # TDD Redirection --------------------------------------------------------------------------

        pcie_uim_pad       = platform.request("pcie_uim")
        fpga_rf_sw_tdd_pad = platform.request("fpga_rf_sw_tdd")
        self.comb += [
            fpga_rf_sw_tdd_pad.eq(pcie_uim_pad),
            # On hw_version = 0b01, invert TDD signal.
            If(hw_version == 0b01,
                fpga_rf_sw_tdd_pad.eq(~pcie_uim_pad)
            )
        ]

        # GNSS -------------------------------------------------------------------------------------

        gnss_pads      = platform.request("gnss")
        rpi_uart0_pads = platform.request("rpi_uart0")

        self.comb += [
            # GNSS Unused IOs.
            gnss_pads.extint.eq(0),
            gnss_pads.ddc_scl.eq(1),
            gnss_pads.ddc_sda.eq(1),

            # GNSS Power-up (Active low reset).
            gnss_pads.reset.eq(1),

            # GNSS Time Pulse.
            #platform.request("fpga_gpio", 1).eq(gnss_pads.tpulse),

            # GNSS UART (Connect to RPI UART0).
            rpi_uart0_pads.rx.eq(gnss_pads.uart_tx),
            gnss_pads.uart_rx.eq(rpi_uart0_pads.tx),
        ]

        # Clocks -----------------------------------------------------------------------------------

        lmk10_clk_out0 = Signal()
        lmkrf_clk_out4 = Signal()
        self.comb += [
           lmk10_clk_out0.eq(platform.request("lmk10_clk_out0")),
           lmkrf_clk_out4.eq(platform.request("lmkrf_clk_out4")),
        ]

        # GPSDOCFG ---------------------------------------------------------------------------------

        gpsdocfg_PPS_1S_ERROR_in   = Signal(32, reset=0x12345678)
        gpsdocfg_PPS_10S_ERROR_in  = Signal(32, reset=0x9ABCDEF0)
        gpsdocfg_PPS_100S_ERROR_in = Signal(32, reset=0x55555555)
        gpsdocfg_DAC_TUNED_VAL_in  = Signal(16, reset=0x1234)
        gpsdocfg_ACCURACY_in       = Signal(4, reset=0b0101)
        gpsdocfg_STATE_in          = Signal(4, reset=0b1010)
        gpsdocfg_TPULSE_ACTIVE_in  = Signal(reset=1)

        # Add signals for gpsdocfg outputs
        gpsdocfg_IICFG_EN_out              = Signal()
        gpsdocfg_IICFG_CLK_SEL_out         = Signal()
        gpsdocfg_IICFG_TPULSE_SEL_out      = Signal(2)
        gpsdocfg_IICFG_RPI_SYNC_IN_DIR_out = Signal()
        gpsdocfg_IICFG_1S_TARGET_out       = Signal(32)
        gpsdocfg_IICFG_1S_TOL_out          = Signal(16)
        gpsdocfg_IICFG_10S_TARGET_out      = Signal(32)
        gpsdocfg_IICFG_10S_TOL_out         = Signal(16)
        gpsdocfg_IICFG_100S_TARGET_out     = Signal(32)
        gpsdocfg_IICFG_100S_TOL_out        = Signal(16)

        rpi_spi1_pads  = platform.request("rpi_spi1")

        self.specials += Instance("gpsdocfg",
            # Address and location of this module
            i_maddress                  = 0, # Will be hard wired at the top level
            i_mimo_en                   = 1, # MIMO enable, from TOP SPI (always 1)

            # Serial port IOs
            i_sdin                      = rpi_spi1_pads.mosi,
            i_sclk                      = rpi_spi1_pads.sclk,
            i_sen                       = rpi_spi1_pads.ss1,
            o_sdout                     = rpi_spi1_pads.miso,

            # Signals coming from the pins or top level serial interface
            i_lreset                    = ResetSignal("sys"),
            i_mreset                    = ResetSignal("sys"),

            o_oen                       = Signal(),  # Not connected

            # Inputs (formerly in t_TO_GPSDOCFG)
            i_PPS_1S_ERROR_in           = gpsdocfg_PPS_1S_ERROR_in,
            i_PPS_10S_ERROR_in          = gpsdocfg_PPS_10S_ERROR_in,
            i_PPS_100S_ERROR_in         = gpsdocfg_PPS_100S_ERROR_in,
            i_DAC_TUNED_VAL_in          = gpsdocfg_DAC_TUNED_VAL_in,
            i_ACCURACY_in               = gpsdocfg_ACCURACY_in,
            i_STATE_in                  = gpsdocfg_STATE_in,
            i_TPULSE_ACTIVE_in          = gpsdocfg_TPULSE_ACTIVE_in,

            # Outputs (formerly in t_FROM_GPSDOCFG)
            o_IICFG_EN_out              = gpsdocfg_IICFG_EN_out,
            o_IICFG_CLK_SEL_out         = gpsdocfg_IICFG_CLK_SEL_out,
            o_IICFG_TPULSE_SEL_out      = gpsdocfg_IICFG_TPULSE_SEL_out,
            o_IICFG_RPI_SYNC_IN_DIR_out = gpsdocfg_IICFG_RPI_SYNC_IN_DIR_out,
            o_IICFG_1S_TARGET_out       = gpsdocfg_IICFG_1S_TARGET_out,
            o_IICFG_1S_TOL_out          = gpsdocfg_IICFG_1S_TOL_out,
            o_IICFG_10S_TARGET_out      = gpsdocfg_IICFG_10S_TARGET_out,
            o_IICFG_10S_TOL_out         = gpsdocfg_IICFG_10S_TOL_out,
            o_IICFG_100S_TARGET_out     = gpsdocfg_IICFG_100S_TARGET_out,
            o_IICFG_100S_TOL_out        = gpsdocfg_IICFG_100S_TOL_out
        )

        # TPULSE Selection -------------------------------------------------------------------------

        rpi_sync_pads  = platform.request("rpi_sync")


        tpulse_internal = Signal()

        self.comb += [
            # TPULSE selection based on IICFG_TPULSE_SEL_out
            If(gpsdocfg_IICFG_TPULSE_SEL_out == 0b01,
                tpulse_internal.eq(rpi_sync_pads.o)  # RPI_SYNC_OUT
            ).Elif(gpsdocfg_IICFG_TPULSE_SEL_out == 0b10,
                tpulse_internal.eq(rpi_sync_pads.i)  # RPI_SYNC_IN
            ).Else(
                tpulse_internal.eq(gnss_pads.tpulse)  # GNSS_TPULSE (default)
            ),
        ]

        # Clock Selection --------------------------------------------------------------------------

        vctcxo_clk = Signal()
        self.comb += [
            If(gpsdocfg_IICFG_CLK_SEL_out == 1,
                vctcxo_clk.eq(lmk10_clk_out0)  # LMK10_CLK_OUT0
            ).Else(
                vctcxo_clk.eq(lmkrf_clk_out4)  # LMKRF_CLK_OUT4 (default)
            )
        ]

        # PPS Detector -----------------------------------------------------------------------------

        pps_active = Signal()

        self.specials += Instance("pps_detector",
            i_clk        = ClockSignal("sys"),
            i_reset      = ResetSignal("sys"),
            i_pps        = tpulse_internal,
            o_pps_active = pps_active
        )

        # DAC SPI Sharing Logic --------------------------------------------------------------------

        fpga_spi0_pads = platform.request("fpga_spi0")

        self.comb += [
            # Default to RPI control
            fpga_spi0_pads.sclk.eq(rpi_spi1_pads.sclk),
            fpga_spi0_pads.mosi.eq(rpi_spi1_pads.mosi),
            fpga_spi0_pads.dac_ss.eq(rpi_spi1_pads.ss2),

            # FPGA control when gpsdocfg_IICFG_EN_out is set.
            If(gpsdocfg_IICFG_EN_out,
                fpga_spi0_pads.sclk.eq(0),  # FIXME: Connect.
                fpga_spi0_pads.mosi.eq(0),  # FIXME: Connect.
                fpga_spi0_pads.dac_ss.eq(0) # FIXME: Connect.
            )
        ]

        # FIXME: Handle: RPI_SPI1_MISO sharing.

#        # FPGA_SYNC_OUT
#        self.comb += platform.request("fpga_sync_out").eq(lmk10_clk_out0)
#
#        # RPI_SYNC_IN.
#        from litex.build.io import SDRTristate
#        self.specials += SDRTristate(
#            io  = rpi_sync_pads.i,
#            i   = Open(),
#            o   = gnss_pads.tpulse,
#            oe  = ~((gpsdocfg_IICFG_RPI_SYNC_IN_DIR_out == 0) | (gpsdocfg_IICFG_TPULSE_SEL_out == 0b10)),
#            clk = ClockSignal("sys"),
#        )

        # VCXO Tamer -------------------------------------------------------------------------------

        self.vctcxo_tamer_bus = wishbone.Interface(data_width=32, adr_width=32)
        self.bus.add_slave("vcxo_tamer", self.vctcxo_tamer_bus, region=SoCRegion(size=0x100))

        vctcxo_tamer_pps_1s_error    = Signal(32)
        vctcxo_tamer_pps_10s_error   = Signal(32)
        vctcxo_tamer_pps_100s_error  = Signal(32)
        vctcxo_tamer_accuracy        = Signal(4)
        vctcxo_tamer_state           = Signal(4)
        vctcxo_tamer_dac_tuned_val   = Signal(16)
        vctcxo_tamer_wb_int          = Signal()

        self.specials += Instance("vctcxo_tamer",
            # Physical Interface
            i_tune_ref           = tpulse_internal,
            i_vctcxo_clock       = vctcxo_clk,

            # Wishbone Interface (connected to dedicated bus)
            i_wb_clk_i           = ClockSignal("sys"),
            i_wb_rst_i           = ResetSignal("sys"),
            i_wb_adr_i           = self.vctcxo_tamer_bus.adr,
            i_wb_dat_i           = self.vctcxo_tamer_bus.dat_w,
            o_wb_dat_o           = self.vctcxo_tamer_bus.dat_r,
            i_wb_we_i            = self.vctcxo_tamer_bus.we,
            i_wb_stb_i           = self.vctcxo_tamer_bus.stb,
            o_wb_ack_o           = self.vctcxo_tamer_bus.ack,
            i_wb_cyc_i           = self.vctcxo_tamer_bus.cyc,

            # Wishbone Interrupt
            o_wb_int_o           = vctcxo_tamer_wb_int,

            # Configuration inputs from gpsdocfg
            i_PPS_1S_TARGET       = gpsdocfg_IICFG_1S_TARGET_out,
            i_PPS_1S_ERROR_TOL    = Cat(Signal(16, reset=0), gpsdocfg_IICFG_1S_TOL_out),
            i_PPS_10S_TARGET      = gpsdocfg_IICFG_10S_TARGET_out,
            i_PPS_10S_ERROR_TOL   = Cat(Signal(16, reset=0), gpsdocfg_IICFG_10S_TOL_out),
            i_PPS_100S_TARGET     = gpsdocfg_IICFG_100S_TARGET_out,
            i_PPS_100S_ERROR_TOL  = Cat(Signal(16, reset=0), gpsdocfg_IICFG_100S_TOL_out),

            # Status outputs
            o_pps_1s_error       = vctcxo_tamer_pps_1s_error,
            o_pps_10s_error      = vctcxo_tamer_pps_10s_error,
            o_pps_100s_error     = vctcxo_tamer_pps_100s_error,
            o_accuracy           = vctcxo_tamer_accuracy,
            o_state              = vctcxo_tamer_state,
            o_dac_tuned_val      = vctcxo_tamer_dac_tuned_val
        )


#        # LimePSB RPCM top ------------------------------------------------------------------------
#
#        # Request Pads.
#
#        rpi_sync_pads  = platform.request("rpi_sync")
#        rpi_spi1_pads  = platform.request("rpi_spi1")
#        fpga_cfg_pads  = platform.request("fpga_cfg")
#        fpga_i2c_pads  = platform.request("fpga_i2c")
#        fpga_spi0_pads = platform.request("fpga_spi0")
#
#        # Instance.
#
#        self.specials += Instance("LimePSB_RPCM_top",
#            i_SYS_CLK           = ClockSignal("sys"),
#            i_SYS_RST_N         = ~ResetSignal("sys"),
#
#            # Clocks
#            i_LMK10_CLK_OUT0    = platform.request("lmk10_clk_out0"),
#            i_LMKRF_CLK_OUT4    = platform.request("lmkrf_clk_out4"),
#
#            # RPI
#            io_RPI_SYNC_IN      = rpi_sync_pads.i,
#            i_RPI_SYNC_OUT      = rpi_sync_pads.o,
#            i_RPI_SPI1_SCLK     = rpi_spi1_pads.sclk,
#            i_RPI_SPI1_MOSI     = rpi_spi1_pads.mosi,
#            o_RPI_SPI1_MISO     = rpi_spi1_pads.miso,
#            i_RPI_SPI1_SS1      = rpi_spi1_pads.ss1,
#            i_RPI_SPI1_SS2      = rpi_spi1_pads.ss2,
#
#            # FPGA
#            io_FPGA_GPIO        = Open(),
#            io_FPGA_CFG_SPI_SCK = fpga_cfg_pads.sck,
#            io_FPGA_CFG_SPI_SI  = fpga_cfg_pads.si,
#            io_FPGA_CFG_SPI_SO  = fpga_cfg_pads.so,
#            i_FPGA_CFG_SPI_CSN  = fpga_cfg_pads.csn,
#            io_FPGA_I2C_SCL     = fpga_i2c_pads.scl,
#            io_FPGA_I2C_SDA     = fpga_i2c_pads.sda,
#            o_FPGA_SYNC_OUT     = platform.request("fpga_sync_out"),
#            o_FPGA_SPI0_SCLK    = fpga_spi0_pads.sclk,
#            o_FPGA_SPI0_MOSI    = fpga_spi0_pads.mosi,
#            o_FPGA_SPI0_DAC_SS  = fpga_spi0_pads.dac_ss,
#
#            # GNSS
#            i_GNSS_TPULSE       = gnss_pads.tpulse,
#        )
#
        # PPS Detector VHD2V Converter.
        # -----------------------------
        self.vhd2v_converter_pps_detector = VHD2VConverter(self.platform,
            top_entity     = "pps_detector",
            build_dir      = os.path.abspath(os.path.dirname(__file__)),
            work_package   = "work",
            force_convert  = True,
            add_instance   = False,
            flatten_source = False,
            params         = dict(
                p_CLK_FREQ_HZ = 6000000,
                p_TOLERANCE   = 5000000,
            )
        )
        self.vhd2v_converter_pps_detector.add_source("hdl/pps_detector/pps_detector.vhd")
        self.vhd2v_converter_pps_detector._ghdl_opts.append("-fsynopsys")

        # GPSDOCFG VHD2V Converter.
        # -------------------------
        self.vhd2v_converter_gpsdocfg = VHD2VConverter(self.platform,
            top_entity     = "gpsdocfg",
            build_dir      = os.path.abspath(os.path.dirname(__file__)),
            work_package   = "work",
            force_convert  = True,
            add_instance   = False,
            flatten_source = False,
            params         = {}
        )
        self.vhd2v_converter_gpsdocfg.add_source("hdl/spi/revisions.vhd")
        self.vhd2v_converter_gpsdocfg.add_source("hdl/spi/gpsdocfg.vhd")
        self.vhd2v_converter_gpsdocfg.add_source("hdl/spi/mcfg32wm_fsm.vhd")
        self.vhd2v_converter_gpsdocfg.add_source("hdl/spi/mcfg_components.vhd")
        self.vhd2v_converter_gpsdocfg.add_source("hdl/spi/mem_package.vhd")
        self.vhd2v_converter_gpsdocfg._ghdl_opts.append("-fsynopsys")

        # VCXO Tamer VHD2V Converter.
        # ---------------------------
        self.vhd2v_converter_vctcxo_tamer = VHD2VConverter(self.platform,
            top_entity     = "vctcxo_tamer",
            build_dir      = os.path.abspath(os.path.dirname(__file__)),
            work_package   = "work",
            force_convert  = True,
            add_instance   = False,
            flatten_source = False,
            params         = {}
        )
        self.vhd2v_converter_vctcxo_tamer.add_source("hdl/vctcxo_tamer/edge_detector_fixed.vhd")
        self.vhd2v_converter_vctcxo_tamer.add_source("hdl/vctcxo_tamer/handshake.vhd")
        self.vhd2v_converter_vctcxo_tamer.add_source("hdl/vctcxo_tamer/pps_counter.vhd")
        self.vhd2v_converter_vctcxo_tamer.add_source("hdl/vctcxo_tamer/reset_synchronizer.vhd")
        self.vhd2v_converter_vctcxo_tamer.add_source("hdl/vctcxo_tamer/synchronizer.vhd")
        self.vhd2v_converter_vctcxo_tamer.add_source("hdl/vctcxo_tamer/vctcxo_tamer.vhd")

#        # LimePSB_RPCM_top VHD2V Converter.
#        # ---------------------------------
#        self.vhd2v_converter_limepsb_rpcm_top = VHD2VConverter(self.platform,
#            top_entity     = "LimePSB_RPCM_top",
#            build_dir      = os.path.abspath(os.path.dirname(__file__)),
#            work_package   = "work",
#            force_convert  = True,
#            add_instance   = False,
#            flatten_source = False,
#            params         = {}
#        )
#        self.vhd2v_converter_limepsb_rpcm_top.add_source("hdl/spi/gpsdocfg_pkg.vhd")
#        self.vhd2v_converter_limepsb_rpcm_top.add_source("hdl/LimePSB_RPCM_top.vhd")
#        self.vhd2v_converter_limepsb_rpcm_top._ghdl_opts.append("-fsynopsys")
#
#        self.platform.toolchain._pnr_opts += " --ignore-loops"

# Build --------------------------------------------------------------------------------------------
def main():
    from litex.build.parser import LiteXArgumentParser
    parser = LiteXArgumentParser(platform=Platform, description="LiteX SoC on LimePSB RPCM Board.")
    parser.add_argument("--sys-clk-freq", default=6e6,         help="System clock frequency (default: 10MHz)")
    args = parser.parse_args()

    # SoC.
    soc = BaseSoC(
        sys_clk_freq = int(float(args.sys_clk_freq)),
        **soc_core_argdict(args)
    )

    # Build.
    builder = Builder(soc, **parser.builder_argdict)
    if args.build:
        builder.build(**parser.toolchain_argdict)

    # Load.
    if args.load:
        prog = soc.platform.create_programmer()
        prog.load_bitstream(os.path.join(builder.output_dir, "gateware", soc.build_name + ".bin"))

if __name__ == "__main__":
    main()
