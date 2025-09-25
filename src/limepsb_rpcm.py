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
from litex.gen.genlib.misc import WaitTimer

from litex.build.io import SDRTristate

from litex.soc.integration.soc      import SoCRegion
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder  import *

from litex.soc.cores.clock import *
from litex.soc.cores.spi import SPIMaster

from limepsb_rpcm_platform import Platform

from hdl.gpsdocfg.src.gpsdocfg import GPSDOCFG
from hdl.ppsdo.ppsdo           import PPSDO

# CRG ----------------------------------------------------------------------------------------------

class _CRG(LiteXModule):
    def __init__(self, platform, sys_clk_freq):
        assert sys_clk_freq in [6e6, 12e6, 24e6, 48e6]
        self.rst         = Signal()
        self.cd_sys      = ClockDomain()
        self.cd_por      = ClockDomain()
        self.cd_clk10    = ClockDomain()
        self.cd_clk30p72 = ClockDomain()
        self.cd_rf       = ClockDomain()

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
class BaseSoC(SoCMini):
    def __init__(self, sys_clk_freq=6e6, **kwargs):
        platform = Platform()

        # SoCMini ----------------------------------------------------------------------------------

        SoCMini.__init__(self, platform, sys_clk_freq, ident="LimePSB-RPCM GPSDO SoC.")

        # CRG --------------------------------------------------------------------------------------

        self.crg = _CRG(platform, sys_clk_freq)

        # Signals ----------------------------------------------------------------------------------

        # PPS.
        pps              = Signal()

        # Rpi.
        rpi_sync_pads_i  = Signal()

        # Pads -------------------------------------------------------------------------------------

        # HW/BOM.
        version_pads       = platform.request("version")

        # PCIe.
        pcie_uim_pad       = platform.request("pcie_uim")

        # GNSS.
        gnss_pads          = platform.request("gnss")

        # UART.
        uart_pads          = platform.request("uart")

        # SPI DAC.
        spi_dac_pads       = Record([("clk", 1), ("cs_n", 1), ("mosi", 1)])

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

        # Led --------------------------------------------------------------------------------------

        # Blinks on GNSS TPULSE when enabled; off when disabled (active low).
        self.comb += fpga_led_r.eq(~(gnss_pads.tpulse & self.gpsdocfg.config_en))

        # RF Clk Selection -------------------------------------------------------------------------

        self.comb += Case(self.gpsdocfg.config_clk_sel, {
            0b0 : ClockSignal("rf").eq(ClockSignal("clk30p72")), # VCTCXO Clk from 30.72MHz XO (Default).
            0b1 : ClockSignal("rf").eq(ClockSignal("clk10")),    # VCTCXO Clk from 10MHz XO.
        })
        platform.add_period_constraint(self.crg.cd_rf.clk, 1e9/30.72e6)

        # PPS Selection ----------------------------------------------------------------------------

        self.comb += Case(self.gpsdocfg.config_tpulse_sel, {
            0b01      : pps.eq(rpi_sync_pads.o),  # Rpi_Sync Out.
            0b10      : pps.eq(rpi_sync_pads_i),  # Rpi_Sync In.
            "default" : pps.eq(gnss_pads.tpulse), # GNSS TPULSE (default).
        })

        # Sync In / Out ----------------------------------------------------------------------------

        # FPGA Sync Out.
        # --------------

        # 10MHz clock output to external sync (e.g., LMK/FPGA chaining).
        self.comb += fpga_sync_out_pads.eq(ClockSignal("clk10"))

        # Rpi Sync In.
        # ------------

        # Bidirectional: Input mode (dir=0) or GNSS TPULSE passthrough output (dir=1); overrides to
        # input if TPULSE_SEL=10.
        self.specials += SDRTristate(
            io  = rpi_sync_pads.i,
            i   = rpi_sync_pads_i,
            o   = gnss_pads.tpulse,
            oe  = ~((self.gpsdocfg.config_rpi_sync_in_dir == 0) | (self.gpsdocfg.config_tpulse_sel == 0b10)),
            clk = ClockSignal("sys"),
        )

        # PPSDO Core -------------------------------------------------------------------------------

        self.ppsdo = ppsdo = PPSDO()
        self.ppsdo.add_sources()
        self.comb += [
            # Control.
            ppsdo.enable.eq(self.gpsdocfg.config_en),

            # PPS.
            ppsdo.pps.eq(pps),

            # UART.
            ppsdo.uart_rx.eq(uart_pads.rx),
            uart_pads.tx.eq(ppsdo.uart_tx),

            # Core Config.
            ppsdo.config.hundred_s_target.eq(self.gpsdocfg.config_100s_target),
            ppsdo.config.hundred_s_tol   .eq(self.gpsdocfg.config_100s_tol),
            ppsdo.config.ten_s_target    .eq(self.gpsdocfg.config_10s_target),
            ppsdo.config.ten_s_tol       .eq(self.gpsdocfg.config_10s_tol),
            ppsdo.config.one_s_target    .eq(self.gpsdocfg.config_1s_target),
            ppsdo.config.one_s_tol       .eq(self.gpsdocfg.config_1s_tol),

            # Core Status.
            self.gpsdocfg.status_100s_error   .eq(ppsdo.status.hundred_s_error),
            self.gpsdocfg.status_10s_error    .eq(ppsdo.status.ten_s_error),
            self.gpsdocfg.status_1s_error     .eq(ppsdo.status.one_s_error),
            self.gpsdocfg.status_accuracy     .eq(ppsdo.status.accuracy),
            self.gpsdocfg.status_dac_tuned_val.eq(ppsdo.status.dac_tuned_val),
            self.gpsdocfg.status_pps_active   .eq(ppsdo.status.pps_active),
            self.gpsdocfg.status_state        .eq(ppsdo.status.state),

            # SPI DAC.
            spi_dac_pads.clk.eq(ppsdo.spi_clk),
            spi_dac_pads.cs_n.eq(ppsdo.spi_cs_n),
            spi_dac_pads.mosi.eq(ppsdo.spi_mosi),
        ]

        # SPI Sharing Logic.
        # ------------------
        self.comb += Case(self.gpsdocfg.config_en, {
            # When disabled (EN=0): RPI controls FPGA SPI0 (sclk/mosi from RPI SPI1, dac_ss=ss2) for
            # direct DAC access.
             0b0 : [
                fpga_spi0_pads.sclk.eq(rpi_spi1_pads.sclk),
                fpga_spi0_pads.mosi.eq(rpi_spi1_pads.mosi),
                fpga_spi0_pads.dac_ss.eq(rpi_spi1_pads.ss2),
             ],

             # When enabled (EN=1): CPU overrides via dedicated SPI master; DAC inaccessible from
             # RPI/CM4/CM5.
             0b1 : [
                fpga_spi0_pads.sclk.eq(spi_dac_pads.clk),
                fpga_spi0_pads.mosi.eq(spi_dac_pads.mosi),
                fpga_spi0_pads.dac_ss.eq(spi_dac_pads.cs_n),
             ]
        })

# Build -------------------------------------------------------------------------------------------
def main():
    from litex.build.parser import LiteXArgumentParser
    parser = LiteXArgumentParser(platform=Platform, description="LiteX SoC on LimePSB RPCM Board.")
    parser.add_argument("--sys-clk-freq", default=6e6, help="System clock frequency (default: 6MHz)")
    args = parser.parse_args()

    # SoC.
    soc = BaseSoC(
        sys_clk_freq  = int(float(args.sys_clk_freq)),
        **soc_core_argdict(args)
    )
    builder = Builder(soc, **parser.builder_argdict)
    builder.build(run=args.build)

if __name__ == "__main__":
    main()
