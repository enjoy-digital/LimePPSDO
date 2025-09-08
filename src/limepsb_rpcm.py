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

from litex.gen import *

from litex.build.vhd2v_converter import *

from litex.soc.cores.clock import *
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litex.soc.cores.led import LedChaser

from limepsb_rpcm_platform import Platform

# CRG ----------------------------------------------------------------------------------------------
class _CRG(LiteXModule):
    def __init__(self, platform):
        self.cd_sys = ClockDomain()
        self.comb += self.cd_sys.clk.eq(platform.request("lmk10_clk_out0"))

# BaseSoC ------------------------------------------------------------------------------------------
class BaseSoC(SoCMini):
    def __init__(self, sys_clk_freq=10e6, with_led_chaser=True, with_limepsb_rpcm_top=False, **kwargs):
        platform = Platform()

        # SoCCore ----------------------------------------------------------------------------------
        SoCMini.__init__(self, platform, sys_clk_freq, ident="LiteX SoC on LimePSB RPCM Board")

        # CRG --------------------------------------------------------------------------------------
        self.crg = _CRG(platform)

        # LED Chaser -------------------------------------------------------------------------------
        if with_led_chaser:
            led_pads = platform.request("fpga_led_r")
            self.leds = LedChaser(
                pads         = led_pads,
                sys_clk_freq = sys_clk_freq,
            )

        # LimePSB_RPCM Top Instance ----------------------------------------------------------------

        if with_limepsb_rpcm_top:
            self.specials += Instance("LimePSB_RPCM_top",
                # Clocks
                #i_LMK10_CLK_OUT0    = platform.request("lmk10_clk_out0"),
                i_LMK10_CLK_OUT0    = ClockSignal("sys"),
                i_LMKRF_CLK_OUT4    = platform.request("lmkrf_clk_out4"),

                # RPI
                io_RPI_SYNC_IN      = platform.request("rpi_sync_in"),
                i_RPI_SYNC_OUT      = platform.request("rpi_sync_out"),
                i_RPI_SPI1_SCLK     = platform.request("rpi_spi1_sclk"),
                i_RPI_SPI1_MOSI     = platform.request("rpi_spi1_mosi"),
                o_RPI_SPI1_MISO     = platform.request("rpi_spi1_miso"),
                i_RPI_SPI1_SS1      = platform.request("rpi_spi1_ss1"),
                i_RPI_SPI1_SS2      = platform.request("rpi_spi1_ss2"),
                i_RPI_UART0_TX      = platform.request("rpi_uart0_tx"),
                o_RPI_UART0_RX      = platform.request("rpi_uart0_rx"),

                # FPGA
                io_FPGA_GPIO        = platform.request("fpga_gpio"),
                io_FPGA_CFG_SPI_SCK = platform.request("fpga_cfg_spi_sck"),
                io_FPGA_CFG_SPI_SI  = platform.request("fpga_cfg_spi_si"),
                io_FPGA_CFG_SPI_SO  = platform.request("fpga_cfg_spi_so"),
                i_FPGA_CFG_SPI_CSN  = platform.request("fpga_cfg_spi_csn"),
                o_FPGA_RF_SW_TDD    = platform.request("fpga_rf_sw_tdd"),
                io_FPGA_I2C_SCL     = platform.request("fpga_i2c_scl"),
                io_FPGA_I2C_SDA     = platform.request("fpga_i2c_sda"),
                o_FPGA_SYNC_OUT     = platform.request("fpga_sync_out"),
                o_FPGA_SPI0_SCLK    = platform.request("fpga_spi0_sclk"),
                o_FPGA_SPI0_MOSI    = platform.request("fpga_spi0_mosi"),
                o_FPGA_SPI0_DAC_SS  = platform.request("fpga_spi0_dac_ss"),
                o_FPGA_LED_R        = platform.request("fpga_led_r"),

                # GNSS
                o_GNSS_EXTINT       = platform.request("gnss_extint"),
                o_GNSS_RESET        = platform.request("gnss_reset"),
                io_GNSS_DDC_SCL     = platform.request("gnss_ddc_scl"),
                io_GNSS_DDC_SDA     = platform.request("gnss_ddc_sda"),
                i_GNSS_TPULSE       = platform.request("gnss_tpulse"),
                i_GNSS_UART_TX      = platform.request("gnss_uart_tx"),
                o_GNSS_UART_RX      = platform.request("gnss_uart_rx"),

                # MISC
                i_PCIE_UIM          = platform.request("pcie_uim"),
                i_EN_CM5_USB3       = platform.request("en_cm5_usb3"),
                i_BOM_VER           = platform.request("bom_ver"),
                i_HW_VER            = platform.request("hw_ver"),
            )
            vhdl_sources = [
                # Top-level and general sources
                "hdl/LimePSB_RPCM_top.vhd",
                "hdl/general/rgb_io.vhd",

                # PPS detector
                "hdl/pps_detector/pps_detector.vhd",

                # SPI-related sources
                "hdl/spi/gpsdocfg.vhd",
                "hdl/spi/gpsdocfg_pkg.vhd",
                "hdl/spi/mcfg32wm_fsm.vhd",
                "hdl/spi/mcfg_components.vhd",
                "hdl/spi/mem_package.vhd",

                # VCTCXO tamer
                "hdl/vctcxo_tamer/edge_detector.vhd",
                "hdl/vctcxo_tamer/handshake.vhd",
                "hdl/vctcxo_tamer/pps_counter.vhd",
                "hdl/vctcxo_tamer/reset_synchronizer.vhd",
                "hdl/vctcxo_tamer/synchronizer.vhd",
                "hdl/vctcxo_tamer/vctcxo_tamer.vhd",

                # Neo430 core sources
                "neo430/rtl/core/neo430_addr_gen.vhd",
                "neo430/rtl/core/neo430_alu.vhd",
                "neo430/rtl/core/neo430_application_image.vhd",
                "neo430/rtl/core/neo430_boot_rom.vhd",
                "neo430/rtl/core/neo430_bootloader_image.vhd",
                "neo430/rtl/core/neo430_cfu.vhd",
                "neo430/rtl/core/neo430_control.vhd",
                "neo430/rtl/core/neo430_cpu.vhd",
                "neo430/rtl/core/neo430_crc.vhd",
                "neo430/rtl/core/neo430_dmem.vhd",
                "neo430/rtl/core/neo430_exirq.vhd",
                "neo430/rtl/core/neo430_freq_gen.vhd",
                "neo430/rtl/core/neo430_gpio.vhd",
                "neo430/rtl/core/neo430_imem.vhd",
                "neo430/rtl/core/neo430_muldiv.vhd",
                "neo430/rtl/core/neo430_package.vhd",
                "neo430/rtl/core/neo430_pwm.vhd",
                "neo430/rtl/core/neo430_reg_file.vhd",
                "neo430/rtl/core/neo430_spi.vhd",
                "neo430/rtl/core/neo430_sysconfig.vhd",
                "neo430/rtl/core/neo430_timer.vhd",
                "neo430/rtl/core/neo430_top.vhd",
                "neo430/rtl/core/neo430_trng.vhd",
                "neo430/rtl/core/neo430_twi.vhd",
                "neo430/rtl/core/neo430_uart.vhd",
                "neo430/rtl/core/neo430_wb_interface.vhd",
                "neo430/rtl/core/neo430_wdt.vhd",
                "neo430/rtl/top_templates/neo430_top_avm.vhd",
            ]
            for vhdl_source in vhdl_sources:
                self.platform.add_source(vhdl_source)


        # PPS Detector VHD2V Converter.
        self.vhd2v_converter_pps_detector = VHD2VConverter(self.platform,
            top_entity    = "pps_detector",
            build_dir     = os.path.abspath(os.path.dirname(__file__)),
            work_package  = "work",
            force_convert = True,
            add_instance  = False,
            params        = {}
        )
        self.vhd2v_converter_pps_detector.add_source("hdl/pps_detector/pps_detector.vhd")
        self.vhd2v_converter_pps_detector._ghdl_opts.append("-fsynopsys")

# Build --------------------------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="LiteX SoC on LimePSB RPCM Board")
    parser.add_argument("--build",        action="store_true", help="Build bitstream")
    parser.add_argument("--load",         action="store_true", help="Load bitstream")
    parser.add_argument("--sys-clk-freq", default=10e6,        help="System clock frequency (default: 10MHz)")
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
