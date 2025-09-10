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
    def __init__(self, sys_clk_freq=10e6, with_led_chaser=True, **kwargs):
        platform = Platform()

        # SoCCore ----------------------------------------------------------------------------------
        SoCMini.__init__(self, platform, sys_clk_freq, ident="LiteX SoC on LimePSB RPCM Board")

        # CRG --------------------------------------------------------------------------------------
        self.crg = _CRG(platform)

        # LED Chaser -------------------------------------------------------------------------------
        if with_led_chaser:
            led_pads = platform.request("fpga_led_r")
            self.comb += led_pads.eq(0)
            #self.leds = LedChaser(
            #    pads         = led_pads,
            #    sys_clk_freq = sys_clk_freq,
            #)

        counter = Signal(16)
        self.sync += counter.eq(counter + 1)
        self.comb += platform.request("rpi_uart0_rx").eq(ClockSignal("sys"))

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
