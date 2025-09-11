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
            led_o = Signal()
            self.leds = LedChaser(
                pads         = led_o,
                sys_clk_freq = sys_clk_freq,
            )
#        self.specials += Instance("SB_IO_OD",
#            p_PIN_TYPE          = "011001",  # Combinatorial output, combinatorial OE, no input (adjust to "101001" if you later need input)
#            p_NEG_TRIGGER       = 0,
#
#            i_PACKAGEPIN      = platform.request("fpga_led_r"),
#            i_LATCHINPUTVALUE = 0,
#            i_CLOCKENABLE     = 0,
#            i_INPUTCLK        = 0,
#            i_OUTPUTCLK       = 0,
#            i_OUTPUTENABLE    = 1,
#            i_DOUT0           = led_o,
#            i_DOUT1           = 0,
#            o_DIN0            = Open(),
#            o_DIN1            = Open(),
#        )

#        self.specials += Instance("SB_RGBA_DRV",
#            p_CURRENT_MODE = "0b1",           # full-current mode
#            p_RGB0_CURRENT = "0b000000",      # unused
#            p_RGB1_CURRENT = "0b000000",      # unused
#            p_RGB2_CURRENT = "0b111111",      # MAX setting (~up to 16 mA sink)
#            i_CURREN     = 1,
#            i_RGBLEDEN   = 1,
#            i_RGB0PWM    = 0,
#            i_RGB1PWM    = 0,
#            i_RGB2PWM    = led_o,             # 1 = sink current = LED on
#            o_RGB0       = Open(),
#            o_RGB1       = Open(),
#            o_RGB2       = platform.request("fpga_led_r"),
#        )

        #self.specials += Instance("SB_IO",
        #    p_PIN_TYPE      = 0b011001,   # comb output, comb OE
        #    p_PULLUP        = 1,
        #    p_IO_STANDARD   = "SB_LVCMOS",
        #    io_PACKAGE_PIN   = platform.request("fpga_led_r"),
        #    i_OUTPUT_ENABLE = 1,
        #    i_D_OUT_0       = ~led_o      # active-low LED
        #)

        self.comb += platform.request("fpga_led_r").eq(1)

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
