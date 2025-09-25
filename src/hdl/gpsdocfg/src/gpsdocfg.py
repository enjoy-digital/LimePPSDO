#!/usr/bin/env python3
#
# This file is part of LimePSB_RPCM_GW.
#
# Copyright (c) 2024-2025 Lime Microsystems.
#
# SPDX-License-Identifier: Apache-2.0

from migen import *

from litex.gen import *

from litex.build.vhd2v_converter import *

# GPSDO CFG Layouts -------------------------------------------------------------------------------

gpsdocfg_config_layout = [
    ("en",                1, DIR_M_TO_S), # Enable signal.
    ("clk_sel",           1, DIR_M_TO_S), # Clock select.
    ("tpulse_sel",        2, DIR_M_TO_S), # Pulse select.
    ("rpi_sync_in_dir",   1, DIR_M_TO_S), # RPI sync input direction.
    ("one_s_target",     32, DIR_M_TO_S), # Target value for 1-second interval.
    ("one_s_tol",        16, DIR_M_TO_S), # Tolerance for 1-second interval.
    ("ten_s_target",     32, DIR_M_TO_S), # Target value for 10-second interval.
    ("ten_s_tol",        16, DIR_M_TO_S), # Tolerance for 10-second interval.
    ("hundred_s_target", 32, DIR_M_TO_S), # Target value for 100-second interval.
    ("hundred_s_tol",    16, DIR_M_TO_S), # Tolerance for 100-second interval.
]

gpsdocfg_status_layout = [
    ("one_s_error",      32, DIR_M_TO_S), # Error value for 1-second interval.
    ("ten_s_error",      32, DIR_M_TO_S), # Error value for 10-second interval.
    ("hundred_s_error",  32, DIR_M_TO_S), # Error value for 100-second interval.
    ("dac_tuned_val",    16, DIR_M_TO_S), # DAC tuned value.
    ("accuracy",          4, DIR_M_TO_S), # Accuracy status.
    ("state",             4, DIR_M_TO_S), # Current state.
    ("pps_active",        1, DIR_M_TO_S), # PPS active status.
]

# GPSDO CFG ----------------------------------------------------------------------------------------

class GPSDOCFG(LiteXModule):
    def __init__(self, spi_pads):
        # Config.
        self.config = Record(gpsdocfg_config_layout)
        # Status.
        self.status = Record(gpsdocfg_status_layout)

        # # #

        # Instance.
        # ---------
        self.specials += Instance("gpsdocfg",
            # Config.
            i_maddress                  = 0,
            i_mimo_en                   = 1,

            # SPI.
            i_sdin                      = spi_pads.mosi,
            i_sclk                      = spi_pads.sclk,
            i_sen                       = spi_pads.ss1,
            o_sdout                     = spi_pads.miso,

            # Rst/Ctrl.
            i_lreset                    = ResetSignal("sys"),
            i_mreset                    = ResetSignal("sys"),
            o_oen                       = Open(),

            # Inputs.
            i_PPS_1S_ERROR_in           = self.status.one_s_error,
            i_PPS_10S_ERROR_in          = self.status.ten_s_error,
            i_PPS_100S_ERROR_in         = self.status.hundred_s_error,
            i_DAC_TUNED_VAL_in          = self.status.dac_tuned_val,
            i_ACCURACY_in               = self.status.accuracy,
            i_STATE_in                  = self.status.state,
            i_TPULSE_ACTIVE_in          = self.status.pps_active,

            # Outputs.
            o_IICFG_EN_out              = self.config.en,
            o_IICFG_CLK_SEL_out         = self.config.clk_sel,
            o_IICFG_TPULSE_SEL_out      = self.config.tpulse_sel,
            o_IICFG_RPI_SYNC_IN_DIR_out = self.config.rpi_sync_in_dir,
            o_IICFG_1S_TARGET_out       = self.config.one_s_target,
            o_IICFG_1S_TOL_out          = self.config.one_s_tol,
            o_IICFG_10S_TARGET_out      = self.config.ten_s_target,
            o_IICFG_10S_TOL_out         = self.config.ten_s_tol,
            o_IICFG_100S_TARGET_out     = self.config.hundred_s_target,
            o_IICFG_100S_TOL_out        = self.config.hundred_s_tol
        )

    def add_sources(self):
        from litex.gen import LiteXContext

        cdir = os.path.abspath(os.path.dirname(__file__))

        self.vhd2v_converter = VHD2VConverter(LiteXContext.platform,
            top_entity     = "gpsdocfg",
            flatten_source = False,
            files          = [
                os.path.join(cdir, "revisions.vhd"),
                os.path.join(cdir, "gpsdocfg.vhd"),
                os.path.join(cdir, "mcfg32wm_fsm.vhd"),
                os.path.join(cdir, "mem_package.vhd"),
            ]
        )
        self.vhd2v_converter._ghdl_opts.append("-fsynopsys")
