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
class BaseSoC(SoCMini):
    def __init__(self, sys_clk_freq=10e6, **kwargs):
        platform = Platform()

        # SoCCore ----------------------------------------------------------------------------------

        SoCMini.__init__(self, platform, sys_clk_freq, ident="LiteX SoC on LimePSB RPCM Board")

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

        # GPIO Toggling (Debug) --------------------------------------------------------------------

        counter = Signal(16)
        self.sync += counter.eq(counter + 1)
        self.comb += platform.request("rpi_uart0_rx").eq(ClockSignal("sys"))
        #self.comb += platform.request("fpga_gpio", 0).eq(counter[0])
        #self.comb += platform.request("fpga_gpio", 1).eq(counter[1])

        # GNSS -------------------------------------------------------------------------------------

#        gnss_pads = platform.request("gnss")
#        self.comb += [
#            # GNSS Unused IOs.
#            gnss_pads.extint.eq(0),
#            gnss_pads.ddc_scl.eq(1),
#            gnss_pads.ddc_sda.eq(1),
#
#            # GNSS Power-up (Active low reset).
#            gnss_pads.reset.eq(1),
#
#            # GNSS Time Pulse.
#            #gnss_pads.tpulse, # FIXME: Connect.
#
#            # GNSS UART (Connect to RPI UART0).
#            platform.request("rpi_uart0_rx").eq(gnss_pads.uart_tx),
#            gnss_pads.uart_rx.eq(platform.request("rpi_uart0_tx")),
#        ]


         # LimePSB RPCM top ------------------------------------------------------------------------

        self.specials += Instance("LimePSB_RPCM_top",
            i_SYS_CLK           = ClockSignal("sys"),
            i_SYS_RST_N         = ~ResetSignal("sys"),

            # Clocks
            i_LMK10_CLK_OUT0    = platform.request("lmk10_clk_out0"),
            i_LMKRF_CLK_OUT4    = platform.request("lmkrf_clk_out4"),

            # RPI
            io_RPI_SYNC_IN      = platform.request("rpi_sync_in"),
            i_RPI_SYNC_OUT      = platform.request("rpi_sync_out"),
            i_RPI_SPI1_SCLK     = platform.request("rpi_spi1_sclk"),
            i_RPI_SPI1_MOSI     = platform.request("rpi_spi1_mosi"),
            #o_RPI_SPI1_MISO     = platform.request("rpi_spi1_miso"), # FIXME.
            i_RPI_SPI1_SS1      = platform.request("rpi_spi1_ss1"),
            i_RPI_SPI1_SS2      = platform.request("rpi_spi1_ss2"),

            # FPGA
            #o_FPGA_SYNC_OUT     = platform.request("fpga_sync_out"),
            #o_FPGA_SPI0_SCLK    = platform.request("fpga_spi0_sclk"),
            #o_FPGA_SPI0_MOSI    = platform.request("fpga_spi0_mosi"),
            #o_FPGA_SPI0_DAC_SS  = platform.request("fpga_spi0_dac_ss"),

            io_FPGA_GPIO        = Open(),
            io_FPGA_CFG_SPI_SCK = platform.request("fpga_cfg_spi_sck"),
            io_FPGA_CFG_SPI_SI  = platform.request("fpga_cfg_spi_si"),
            io_FPGA_CFG_SPI_SO  = platform.request("fpga_cfg_spi_so"),
            i_FPGA_CFG_SPI_CSN  = platform.request("fpga_cfg_spi_csn"),
            io_FPGA_I2C_SCL     = platform.request("fpga_i2c_scl"),
            io_FPGA_I2C_SDA     = platform.request("fpga_i2c_sda"),
            o_FPGA_SYNC_OUT     = Open(),
            o_FPGA_SPI0_SCLK    = Open(),
            o_FPGA_SPI0_MOSI    = Open(),
            o_FPGA_SPI0_DAC_SS  = Open(),

        )

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
        self.vhd2v_converter_gpsdocfg.add_source("hdl/spi/gpsdocfg_pkg.vhd")
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

        # Neo430 VHD2V Converter.
        # -----------------------
        self.vhd2v_converter_neo430 = VHD2VConverter(self.platform,
            top_entity     = "neo430_top_avm",
            build_dir      = os.path.abspath(os.path.dirname(__file__)),
            work_package   = "work",
            force_convert  = True,
            add_instance   = False,
            flatten_source = False,
            params         = dict(
                # general configuration
                p_CLOCK_SPEED  = 6000000,
                p_IMEM_SIZE    = 5*1024,
                p_DMEM_SIZE    = 2*1024,
                # additional configuration
                #p_USER_CODE    = "0000", # FIXME.
                # module configuration
                p_MULDIV_USE   = False,
                p_WB32_USE     = True,
                p_WDT_USE      = False,
                p_GPIO_USE     = True,
                p_TIMER_USE    = False,
                p_UART_USE     = False,
                p_CRC_USE      = False,
                p_CFU_USE      = False,
                p_PWM_USE      = False,
                p_TWI_USE      = False,
                p_SPI_USE      = True,
                p_TRNG_USE     = False,
                p_EXIRQ_USE    = True,
                p_FREQ_GEN_USE = False,
                # boot configuration
                p_BOOTLD_USE   = False,
                p_IMEM_AS_ROM  = True
            )
        )
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_package.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_sysconfig.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_application_image.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_bootloader_image.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_boot_rom.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_dmem.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_imem.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_reg_file.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_addr_gen.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_alu.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_muldiv.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_control.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_cpu.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_wb_interface.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_gpio.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_timer.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_pwm.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_uart.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_spi.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_twi.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_crc.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_cfu.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_trng.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_wdt.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_exirq.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_freq_gen.vhd")])
        self.vhd2v_converter_neo430.add_libraries([("neo430", "neo430/rtl/core/neo430_top.vhd")])
        self.vhd2v_converter_neo430.add_source("neo430/rtl/top_templates/neo430_top_avm.vhd")

        # LimePSB_RPCM_top VHD2V Converter.
        # ---------------------------------
        self.vhd2v_converter_limepsb_rpcm_top = VHD2VConverter(self.platform,
            top_entity     = "LimePSB_RPCM_top",
            build_dir      = os.path.abspath(os.path.dirname(__file__)),
            work_package   = "work",
            force_convert  = True,
            add_instance   = False,
            flatten_source = False,
            params         = {}
        )
        self.vhd2v_converter_limepsb_rpcm_top.add_source("hdl/spi/gpsdocfg_pkg.vhd")
        self.vhd2v_converter_limepsb_rpcm_top.add_source("hdl/LimePSB_RPCM_top.vhd")
        self.vhd2v_converter_limepsb_rpcm_top._ghdl_opts.append("-fsynopsys")

        self.platform.toolchain._pnr_opts += " --ignore-loops"

# Build --------------------------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="LiteX SoC on LimePSB RPCM Board")
    parser.add_argument("--build",        action="store_true", help="Build bitstream")
    parser.add_argument("--load",         action="store_true", help="Load bitstream")
    parser.add_argument("--sys-clk-freq", default=6e6,         help="System clock frequency (default: 10MHz)")
    builder_args(parser)
    soc_core_args(parser)
    args = parser.parse_args()
    soc = BaseSoC(
        sys_clk_freq = int(float(args.sys_clk_freq)),
        **soc_core_argdict(args)
    )
    builder = Builder(soc, csr_csv="csr.csv")
    builder.build(run=args.build)
    if args.load:
        prog = soc.platform.create_programmer()
        prog.load_bitstream(os.path.join(builder.output_dir, "gateware", soc.build_name + ".bin"))

if __name__ == "__main__":
    main()
