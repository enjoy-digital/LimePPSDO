#!/usr/bin/env python3

import os
import sys
import socket
import argparse

from migen import *

from litex.gen import *

from litex.build.generic_platform import *
from litex.build.sim              import SimPlatform
from litex.build.sim.config       import SimConfig
from litex.build.sim.verilator    import verilator_build_args, verilator_build_argdict
from litex.build.vhd2v_converter  import *

from litex.soc.integration.common   import *
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder  import *
from litex.soc.interconnect.csr     import *

from litex.soc.integration.soc import SoCRegion
from litex.soc.interconnect import wishbone

# IOs ----------------------------------------------------------------------------------------------

_io = [
    # Clk / Rst.
    ("sys_clk", 0, Pins(1)),
    ("sys_rst", 0, Pins(1)),

    # Serial.
    ("serial", 0,
        Subsignal("source_valid", Pins(1)),
        Subsignal("source_ready", Pins(1)),
        Subsignal("source_data",  Pins(8)),

        Subsignal("sink_valid",   Pins(1)),
        Subsignal("sink_ready",   Pins(1)),
        Subsignal("sink_data",    Pins(8)),
    ),
]

# Platform -----------------------------------------------------------------------------------------

class Platform(SimPlatform):
    def __init__(self):
        SimPlatform.__init__(self, "SIM", _io)

# Simulation SoC -----------------------------------------------------------------------------------

class SimSoC(SoCCore):
    def __init__(self, test):
        # Platform ---------------------------------------------------------------------------------
        platform     = Platform()
        self.comb += platform.trace.eq(1) # Always enable tracing.
        sys_clk_freq = int(1e6)

        # SoCCore ----------------------------------------------------------------------------------

        SoCCore.__init__(self, platform, sys_clk_freq,
            cpu_type      = None,
            uart_name     = "sim",
        )

        # CRG --------------------------------------------------------------------------------------

        self.crg = CRG(platform.request("sys_clk"))

        # Sim Finish -------------------------------------------------------------------------------
        cycles = Signal(32)
        self.sync += cycles.eq(cycles + 1)
        self.sync += If(cycles == 10000, Finish())


        # VCTCXO Tamer -----------------------------------------------------------------------------

        # GPSDO Config.
        gpsdo_en              = Signal()
        gpsdo_clk_sel         = Signal()
        gpsdo_tpulse_sel      = Signal(2)
        gpsdo_rpi_sync_in_dir = Signal()
        gpsdo_1s_target       = Signal(32)
        gpsdo_1s_tol          = Signal(16)
        gpsdo_10s_target      = Signal(32)
        gpsdo_10s_tol         = Signal(16)
        gpsdo_100s_target     = Signal(32)
        gpsdo_100s_tol        = Signal(16)

        # GPSDO Status.
        gpsdo_1s_error        = Signal(32)
        gpsdo_10s_error       = Signal(32)
        gpsdo_100s_error      = Signal(32)
        gpsdo_dac_tuned_val   = Signal(16)
        gpsdo_accuracy        = Signal(4)
        gpsdo_state           = Signal(4)

        # VCXO Tamer.
        vctcxo_tamer_irq      = Signal()

        # MMAP (Wishbone).
        # ----------------
        vctcxo_tamer_bus = wishbone.Interface(data_width=32, adr_width=32)
        self.bus.add_slave("vctcxo_tamer", vctcxo_tamer_bus, region=SoCRegion(origin=0x2000_000, size=0x100))

        # Instance.
        # ---------
        self.specials += Instance("vctcxo_tamer",
            # Clk/PPS Inputs.
            i_vctcxo_clock       = ClockSignal("sys"),
            i_tune_ref           = 0,

            # Wishbone Interface.
            i_wb_clk_i           = ClockSignal("sys"),
            i_wb_rst_i           = ResetSignal("sys"),
            i_wb_adr_i           = vctcxo_tamer_bus.adr,
            i_wb_dat_i           = vctcxo_tamer_bus.dat_w,
            o_wb_dat_o           = vctcxo_tamer_bus.dat_r,
            i_wb_we_i            = vctcxo_tamer_bus.we,
            i_wb_stb_i           = vctcxo_tamer_bus.stb,
            o_wb_ack_o           = vctcxo_tamer_bus.ack,
            i_wb_cyc_i           = vctcxo_tamer_bus.cyc,
            o_wb_int_o           = vctcxo_tamer_irq,

            # Configuration Inputs.
            i_PPS_1S_TARGET      = gpsdo_1s_target,
            i_PPS_1S_ERROR_TOL   = Cat(Signal(16, reset=0), gpsdo_1s_tol),
            i_PPS_10S_TARGET     = gpsdo_10s_target,
            i_PPS_10S_ERROR_TOL  = Cat(Signal(16, reset=0), gpsdo_10s_tol),
            i_PPS_100S_TARGET    = gpsdo_100s_target,
            i_PPS_100S_ERROR_TOL = Cat(Signal(16, reset=0), gpsdo_100s_tol),

            # Status Output.
            o_pps_1s_error       = gpsdo_1s_error,
            o_pps_10s_error      = gpsdo_10s_error,
            o_pps_100s_error     = gpsdo_100s_error,
            o_accuracy           = gpsdo_accuracy,
            o_state              = gpsdo_state,
            o_dac_tuned_val      = gpsdo_dac_tuned_val
        )

        # VHD2V Conversion.
        # -----------------
        self.vhd2v_converter_vctcxo_tamer = VHD2VConverter(self.platform,
            top_entity     = "vctcxo_tamer",
            flatten_source = False,
            files          = [
                "hdl/vctcxo_tamer/edge_detector_fixed.vhd",
                "hdl/vctcxo_tamer/handshake.vhd",
                "hdl/vctcxo_tamer/pps_counter.vhd",
                "hdl/vctcxo_tamer/reset_synchronizer.vhd",
                "hdl/vctcxo_tamer/synchronizer.vhd",
                "hdl/vctcxo_tamer/vctcxo_tamer.vhd",
            ]
        )

# Build --------------------------------------------------------------------------------------------

def sim_args(parser):
    verilator_build_args(parser)

def main():
    parser = argparse.ArgumentParser(description="VCTCXO Tamer Simulation.")
    parser.add_argument("--test", default="", help="Test to Run.", choices=[""])
    sim_args(parser)
    args = parser.parse_args()

    verilator_build_kwargs = verilator_build_argdict(args)

    sys_clk_freq = int(1e6)
    sim_config   = SimConfig()
    sim_config.add_clocker("sys_clk", freq_hz=sys_clk_freq)
    sim_config.add_module("serial2console", "serial")

    # Build SoC.
    soc = SimSoC(
        # Generic.
        test = args.test,
    )
    builder = Builder(soc, csr_csv="csr.csv")
    builder.build(sim_config=sim_config, **verilator_build_kwargs)

if __name__ == "__main__":
    main()
