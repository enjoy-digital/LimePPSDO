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

# GPSDO CFG ----------------------------------------------------------------------------------------

class GPSDOCFG(LiteXModule):
    def __init__(self, spi_pads):
        # GPSDO Config.
        self.config_en              = Signal()
        self.config_clk_sel         = Signal()
        self.config_tpulse_sel      = Signal(2)
        self.config_rpi_sync_in_dir = Signal()
        self.config_1s_target       = Signal(32)
        self.config_1s_tol          = Signal(16)
        self.config_10s_target      = Signal(32)
        self.config_10s_tol         = Signal(16)
        self.config_100s_target     = Signal(32)
        self.config_100s_tol        = Signal(16)

        # GPSDO Status.
        self.status_1s_error        = Signal(32)
        self.status_10s_error       = Signal(32)
        self.status_100s_error      = Signal(32)
        self.status_dac_tuned_val   = Signal(16)
        self.status_accuracy        = Signal(4)
        self.status_state           = Signal(4)
        self.status_pps_active      = Signal()

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
            i_PPS_1S_ERROR_in           = self.status_1s_error,
            i_PPS_10S_ERROR_in          = self.status_10s_error,
            i_PPS_100S_ERROR_in         = self.status_100s_error,
            i_DAC_TUNED_VAL_in          = self.status_dac_tuned_val,
            i_ACCURACY_in               = self.status_accuracy,
            i_STATE_in                  = self.status_state,
            i_TPULSE_ACTIVE_in          = self.status_pps_active,

            # Outputs.
            o_IICFG_EN_out              = self.config_en,
            o_IICFG_CLK_SEL_out         = self.config_clk_sel,
            o_IICFG_TPULSE_SEL_out      = self.config_tpulse_sel,
            o_IICFG_RPI_SYNC_IN_DIR_out = self.config_rpi_sync_in_dir,
            o_IICFG_1S_TARGET_out       = self.config_1s_target,
            o_IICFG_1S_TOL_out          = self.config_1s_tol,
            o_IICFG_10S_TARGET_out      = self.config_10s_target,
            o_IICFG_10S_TOL_out         = self.config_10s_tol,
            o_IICFG_100S_TARGET_out     = self.config_100s_target,
            o_IICFG_100S_TOL_out        = self.config_100s_tol
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
