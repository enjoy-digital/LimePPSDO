#!/usr/bin/env python3

#
# This file is part of LimePSB_RPCM_GW.
#
# Copyright (c) 2024-2025 Lime Microsystems.
# SPDX-License-Identifier: Apache-2.0
#
# Standalone PPSDO core generator.
#

import os
import argparse

from migen import *

from litex.gen import *

from litex.build.generic_platform  import *
from litex.build.generic_toolchain import *

from litex.soc.integration.soc import SoCRegion
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *

from litex.soc.cores.spi import SPIMaster

from hdl.pps_detector.src.pps_detector import PPSDetector
from hdl.vctcxo_tamer.src.vctcxo_tamer import VCTCXOTamer

# IOs/Interfaces -----------------------------------------------------------------------------------

def get_common_ios():
    return [
        # Sys Clk/Rst.
        ("sys_clk", 0, Pins(1)),
        ("sys_rst", 0, Pins(1)),

        # RF Clk/Rst.
        ("rf_clk", 0, Pins(1)),
        ("rf_rst", 0, Pins(1)),

        # Serial
        ("serial", 0,
            Subsignal("tx", Pins(1)),
            Subsignal("rx", Pins(1)),
        ),

        # Enable Input.
        ("enable", 0, Pins(1)),

        # PPS Input.
        ("pps", 0, Pins(1)),

        # Led.
        ("led", 0, Pins(1)),

        # Config Inputs.
        ("config_1s_target",   0, Pins(32)),
        ("config_1s_tol",      0, Pins(32)),
        ("config_10s_target",  0, Pins(32)),
        ("config_10s_tol",     0, Pins(32)),
        ("config_100s_target", 0, Pins(32)),
        ("config_100s_tol",    0, Pins(32)),

        # Status Outputs.
        ("status_1s_error",      0, Pins(32)),
        ("status_10s_error",     0, Pins(32)),
        ("status_100s_error",    0, Pins(32)),
        ("status_dac_tuned_val", 0, Pins(16)),
        ("status_accuracy",      0, Pins(8)),
        ("status_state",         0, Pins(8)),
        ("status_pps_active",    0, Pins(1)),

        # DAC SPI.
        ("dac_spi", 0,
            Subsignal("sclk",   Pins(1)),
            Subsignal("sync_n", Pins(1)),
            Subsignal("din",    Pins(1)),
        ),
    ]

# Platform -----------------------------------------------------------------------------------------

class Platform(GenericPlatform):
    def __init__(self):
        super().__init__(device="", io=get_common_ios())

    def build(self, fragment, build_dir, build_name, **kwargs):
        os.makedirs(build_dir, exist_ok=True)
        os.chdir(build_dir)
        conv_output = self.get_verilog(fragment, name=build_name)
        conv_output.write(f"{build_name}.v")
        os.chdir(os.path.abspath(os.path.dirname(__file__)))

# CRG ----------------------------------------------------------------------------------------------

class _CRG(LiteXModule):
    def __init__(self, platform):
        self.cd_sys     = ClockDomain()
        self.cd_vctcxo  = ClockDomain()

        # # #

        sys_clk = platform.request("sys_clk")
        sys_rst = platform.request("sys_rst")
        rf_clk  = platform.request("rf_clk")
        rf_rst  = platform.request("rf_rst")

        self.comb += [
            self.cd_sys.clk.eq(sys_clk),
            self.cd_sys.rst.eq(sys_rst),
            self.cd_vctcxo.clk.eq(rf_clk),
            self.cd_vctcxo.rst.eq(rf_rst),
        ]

# PPSDO --------------------------------------------------------------------------------------------

class PPSDO(SoCCore):
    def __init__(self, sys_clk_freq=6e6, firmware_path=None, **kwargs):
        platform = Platform()

        # SoCCore ----------------------------------------------------------------------------------

        # Minimal config to reduce resource usage on small FPGAs:
        # - SERV CPU      : Compact RISC-V to minimize logic.
        # - No timer/ctrl : Not needed; saves resources.
        # - SRAM          : Minimal stack/scratchpad.
        # - ROM           : Automatically reduced to used space by LiteX.

        kwargs["cpu_type"]             = "serv"
        kwargs["with_timer"]           = False
        kwargs["with_ctrl"]            = False
        kwargs["integrated_sram_size"] = 0x100
        kwargs["integrated_rom_size"]  = 0x2000
        kwargs["integrated_rom_init"]  = firmware_path

        SoCCore.__init__(self, platform, sys_clk_freq, **kwargs)

        # CRG --------------------------------------------------------------------------------------

        self.crg = _CRG(platform)

        # Pads -------------------------------------------------------------------------------------

        #
        pps                  = platform.request("pps")
        enable               = platform.request("enable")
        led_pad              = platform.request("led")
        dac_spi_pads         = platform.request("dac_spi")

        # Config pads.
        config_1s_target     = platform.request("config_1s_target")
        config_1s_tol        = platform.request("config_1s_tol")
        config_10s_target    = platform.request("config_10s_target")
        config_10s_tol       = platform.request("config_10s_tol")
        config_100s_target   = platform.request("config_100s_target")
        config_100s_tol      = platform.request("config_100s_tol")

        # Status pads.
        status_1s_error      = platform.request("status_1s_error")
        status_10s_error     = platform.request("status_10s_error")
        status_100s_error    = platform.request("status_100s_error")
        status_dac_tuned_val = platform.request("status_dac_tuned_val")
        status_accuracy      = platform.request("status_accuracy")
        status_state         = platform.request("status_state")
        status_pps_active    = platform.request("status_pps_active")

        # LED --------------------------------------------------------------------------------------

        self.comb += led_pad.eq(~(pps & enable))

        # PPS Detector -----------------------------------------------------------------------------

        self.pps_detector = PPSDetector(pps=pps)
        self.comb += status_pps_active.eq(self.pps_detector.pps_active)

        # VCTCXO Tamer -----------------------------------------------------------------------------

        self.vctcxo_tamer = VCTCXOTamer(enable=enable, pps=pps)
        self.bus.add_slave("vctcxo_tamer", self.vctcxo_tamer.bus, region=SoCRegion(size=0x1000))
        self.comb += [
            # Config.
            self.vctcxo_tamer.config_1s_target  .eq(config_1s_target),
            self.vctcxo_tamer.config_1s_tol     .eq(config_1s_tol),
            self.vctcxo_tamer.config_10s_target .eq(config_10s_target),
            self.vctcxo_tamer.config_10s_tol    .eq(config_10s_tol),
            self.vctcxo_tamer.config_100s_target.eq(config_100s_target),
            self.vctcxo_tamer.config_100s_tol   .eq(config_100s_tol),

            # Status.
            status_1s_error      .eq(self.vctcxo_tamer.status_1s_error),
            status_10s_error     .eq(self.vctcxo_tamer.status_10s_error),
            status_100s_error    .eq(self.vctcxo_tamer.status_100s_error),
            status_dac_tuned_val .eq(self.vctcxo_tamer.status_dac_tuned_val),
            status_accuracy      .eq(self.vctcxo_tamer.status_accuracy),
            status_state         .eq(self.vctcxo_tamer.status_state),
        ]

        # SPI DAC Control (always internal, no sharing) --------------------------------------------

        self.spi_dac = spi_dac = SPIMaster(
            pads         = None,
            data_width   = 24,
            sys_clk_freq = sys_clk_freq,
            spi_clk_freq = 1e6,
            with_csr     = False,
        )
        self.comb += [
            # Continuous Update.
            self.spi_dac.start.eq(1),
            self.spi_dac.length.eq(24),
            # Power-down control bits (PD1 PD0).
            self.spi_dac.mosi[16:18].eq(0b00),
            # 16-bit DAC value.
            self.spi_dac.mosi[0:16].eq(self.vctcxo_tamer.status_dac_tuned_val),
            # Connect to pads.
            dac_spi_pads.sclk.eq(~spi_dac.pads.clk),
            dac_spi_pads.sync_n.eq(spi_dac.pads.cs_n),
            dac_spi_pads.din.eq(spi_dac.pads.mosi),
        ]

# Build --------------------------------------------------------------------------------------------

def main():
    from litex.build.parser import LiteXArgumentParser
    parser = LiteXArgumentParser(description="Standalone PPSDO core generator.")
    parser.add_argument("--name",        default="ppsdo_core", help="PPSDO Core Name.")
    parser.add_argument("--build",       action="store_true",  help="Generate Verilog.")
    parser.add_argument("--sys-clk-freq",default=6e6,          help="System clock frequency (default: 6MHz)")
    args = parser.parse_args()

    # SoC.
    for run in range(2):
        prepare = (run == 0)
        build   = ((run == 1) and args.build)
        soc = PPSDO(
            sys_clk_freq  = int(float(args.sys_clk_freq)),
            firmware_path = None if prepare else "firmware/firmware.bin",
        )
        soc.platform.name = args.name
        builder = Builder(soc)
        builder.build(run=True, build_name=args.name)
        if prepare:
            ret = os.system(f"cd firmware && make clean all BUILD_DIR=../build/{args.name}")
            if ret != 0:
                raise RuntimeError("Firmware build failed")

if __name__ == "__main__":
    main()