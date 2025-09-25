#!/usr/bin/env python3
#
# This file is part of LimePSB_RPCM_GW.
#
# Copyright (c) 2024-2025 Lime Microsystems.
#
# SPDX-License-Identifier: Apache-2.0

import os

from migen import *

from litex.gen import *

# PPSDO Layouts ------------------------------------------------------------------------------------

ppsdo_uart_layout = [
    ("rx",  1),
    ("tx",  1),
]

ppsdo_spi_layout = [
    ("clk",   1),
    ("cs_n",  1),
    ("mosi",  1),
]

ppsdo_config_layout = [
    ("one_s_target",    32, DIR_M_TO_S),  # Target value for 1-second interval.
    ("one_s_tol",       32, DIR_M_TO_S),  # Tolerance for 1-second interval.
    ("ten_s_target",    32, DIR_M_TO_S),  # Target value for 10-second interval.
    ("ten_s_tol",       32, DIR_M_TO_S),  # Tolerance for 10-second interval.
    ("hundred_s_target",32, DIR_M_TO_S),  # Target value for 100-second interval.
    ("hundred_s_tol",   32, DIR_M_TO_S),  # Tolerance for 100-second interval.
]

ppsdo_status_layout = [
    ("one_s_error",      32, DIR_M_TO_S),  # Error value for 1-second interval.
    ("ten_s_error",      32, DIR_M_TO_S),  # Error value for 10-second interval.
    ("hundred_s_error",  32, DIR_M_TO_S),  # Error value for 100-second interval.
    ("dac_tuned_val",    16, DIR_M_TO_S),  # DAC tuned value.
    ("accuracy",          4, DIR_M_TO_S),  # Accuracy status.
    ("pps_active",        1, DIR_M_TO_S),  # PPS active status.
    ("state",             4, DIR_M_TO_S),  # Current state.
]

# PPSDO --------------------------------------------------------------------------------------------

class PPSDO(LiteXModule):
    def __init__(self, cd_sys="sys", cd_rf="rf"):
        # Control.
        self.enable = Signal()

        # PPS.
        self.pps    = Signal()

        # UART.
        self.uart   = Record(ppsdo_uart_layout)

        # Config.
        self.config = Record(ppsdo_config_layout)

        # Status.
        self.status = Record(ppsdo_status_layout)

        # SPI DAC.
        self.spi    = Record(ppsdo_spi_layout)

        # # #

        # Instance.
        # ---------
        self.specials += Instance("ppsdo",
            # Sys Clk/Rst.
            i_sys_clk              = ClockSignal(cd_sys),
            i_sys_rst              = ResetSignal(cd_sys),

            # RF Clk/Rst.
            i_rf_clk               = ClockSignal(cd_rf),
            i_rf_rst               = ResetSignal(cd_rf),

            # Control.
            i_enable               = self.enable,

            # PPS.
            i_pps                  = self.pps,

            # UART.
            i_uart_rx              = self.uart.rx,
            o_uart_tx              = self.uart.tx,

            # Core Config.
            i_config_1s_target     = self.config.one_s_target,
            i_config_1s_tol        = self.config.one_s_tol,
            i_config_10s_target    = self.config.ten_s_target,
            i_config_10s_tol       = self.config.ten_s_tol,
            i_config_100s_target   = self.config.hundred_s_target,
            i_config_100s_tol      = self.config.hundred_s_tol,

            # Core Status.
            o_status_1s_error      = self.status.one_s_error,
            o_status_10s_error     = self.status.ten_s_error,
            o_status_100s_error    = self.status.hundred_s_error,
            o_status_dac_tuned_val = self.status.dac_tuned_val,
            o_status_accuracy      = self.status.accuracy,
            o_status_pps_active    = self.status.pps_active,
            o_status_state         = self.status.state,

            # SPI DAC.
            o_spi_clk              = self.spi.clk,
            o_spi_cs_n             = self.spi.cs_n,
            o_spi_mosi             = self.spi.mosi,
        )

    def add_sources(self):
        from litex.gen import LiteXContext
        cdir = os.path.abspath(os.path.dirname(__file__))

        # Generate Core.
        # --------------
        os.system(f"cd {cdir} && python3 ppsdo_gen.py --sys-clk-freq={LiteXContext.top.sys_clk_freq}")

        # Import Core Sources.
        # --------------------
        self.import_sources(LiteXContext.platform, f"{cdir}/build/ppsdo/gateware/ppsdo_sources.py")

    def import_sources(self, platform, filename):
        cdir = os.path.abspath(os.path.dirname(__file__))
        namespace = {}
        with open(filename, "r") as f:
            exec(f.read(), namespace)
        files = namespace
        for path in files['include_paths']:
            platform.add_verilog_include_path(path)
        for src in files['sources']:
            path, lang, lib = src
            if not os.path.isabs(path):
                path = os.path.join(cdir, path)
            platform.add_source(path, lang, lib)
