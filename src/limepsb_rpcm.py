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
