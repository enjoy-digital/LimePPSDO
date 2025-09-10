#
# This file is part of LimePSB_RPCM_GW.
#
# Copyright (c) 2025 Lime Microsystems.
#
# SPDX-License-Identifier: Apache-2.0
#
# Platform definition for LimePSB-RPCM board (https://github.com/myriadrf/LimePSB_RPCM_GW)
#

from litex.build.generic_platform import *
from litex.build.lattice import LatticeiCE40Platform

# IOs ----------------------------------------------------------------------------------------------
io = [
    # Clks.
    # -----
    ("lmk10_clk_out0",   0, Pins("37"), IOStandard("LVCMOS33")), # 10MHz.
    ("lmkrf_clk_out4",   0, Pins("35"), IOStandard("LVCMOS33")), # 30.72MHz.

    # BOM/HW Version.
    # ---------------
    ("bom_ver",          0, Pins("26"), IOStandard("LVCMOS33")),
    ("bom_ver",          1, Pins("19"), IOStandard("LVCMOS33")),
    ("bom_ver",          2, Pins("18"), IOStandard("LVCMOS33")),
    ("hw_ver",           0, Pins("41"), IOStandard("LVCMOS33")),
    ("hw_ver",           1, Pins("40"), IOStandard("LVCMOS33")),

    # Rpi.
    # ----

    # Sync.
    ("rpi_sync_in",      0, Pins( "2"), IOStandard("LVCMOS33")),
    ("rpi_sync_out",     0, Pins("44"), IOStandard("LVCMOS33")),

    # SPI.
    ("rpi_spi1_sclk",    0, Pins( "6"), IOStandard("LVCMOS33")),
    ("rpi_spi1_mosi",    0, Pins( "9"), IOStandard("LVCMOS33")),
    ("rpi_spi1_miso",    0, Pins("10"), IOStandard("LVCMOS33")),
    ("rpi_spi1_ss1",     0, Pins("11"), IOStandard("LVCMOS33")),
    ("rpi_spi1_ss2",     0, Pins("12"), IOStandard("LVCMOS33")),

    # UART.
    ("rpi_uart0_tx",     0, Pins("36"), IOStandard("LVCMOS33")),
    ("rpi_uart0_rx",     0, Pins("34"), IOStandard("LVCMOS33")),

    # FPGA.
    # -----

    # Config.
    ("fpga_cfg_spi_sck", 0, Pins("15"), IOStandard("LVCMOS33")),
    ("fpga_cfg_spi_si",  0, Pins("17"), IOStandard("LVCMOS33")),
    ("fpga_cfg_spi_so",  0, Pins("14"), IOStandard("LVCMOS33")),
    ("fpga_cfg_spi_csn", 0, Pins("16"), IOStandard("LVCMOS33")),

    # GPIOs.
    ("fpga_gpio",        0, Pins("45"), IOStandard("LVCMOS33")),
    ("fpga_gpio",        1, Pins("21"), IOStandard("LVCMOS33")),

    # I2C.
    ("fpga_i2c_scl",     0, Pins("47"), IOStandard("LVCMOS33")),
    ("fpga_i2c_sda",     0, Pins("48"), IOStandard("LVCMOS33")),

    # Sync.
    ("fpga_rf_sw_tdd",   0, Pins("13"), IOStandard("LVCMOS33")),
    ("fpga_sync_out",    0, Pins("3"),  IOStandard("LVCMOS33")),

    # SPI.
    ("fpga_spi0_sclk",   0, Pins("43"), IOStandard("LVCMOS33")),
    ("fpga_spi0_mosi",   0, Pins("38"), IOStandard("LVCMOS33")),
    ("fpga_spi0_dac_ss", 0, Pins("42"), IOStandard("LVCMOS33")),

    # Led.
    ("fpga_led_r",       0, Pins("39"), IOStandard("LVCMOS33")),

    # GNSS.
    # -----
    ("gnss_extint",      0, Pins("25"), IOStandard("LVCMOS33")),
    ("gnss_reset",       0, Pins("23"), IOStandard("LVCMOS33")),
    ("gnss_ddc_scl",     0, Pins("28"), IOStandard("LVCMOS33")),
    ("gnss_ddc_sda",     0, Pins("27"), IOStandard("LVCMOS33")),
    ("gnss_tpulse",      0, Pins("20"), IOStandard("LVCMOS33")),
    ("gnss_uart_tx",     0, Pins("31"), IOStandard("LVCMOS33")),
    ("gnss_uart_rx",     0, Pins("32"), IOStandard("LVCMOS33")),

    # Misc.
    # -----
    ("pcie_uim",         0, Pins("46"), IOStandard("LVCMOS33")),
    ("en_cm5_usb3",      0, Pins( "4"), IOStandard("LVCMOS33")),
]

# Platform --------------------------------------------------------------------------------------
class Platform(LatticeiCE40Platform):
    default_clk_name   = "lmk10_clk_out0"
    default_clk_period = 1e9/10e9

    def __init__(self, toolchain="icestorm"):
        LatticeiCE40Platform.__init__(self, "ice40-up5k-sg48", io, toolchain=toolchain)

    def create_programmer(self):
        return IceStormProgrammer()

    def do_finalize(self, fragment):
        LatticeiCE40Platform.do_finalize(self, fragment)
        self.add_period_constraint(self.lookup_request("lmk10_clk_out0", loose=True), 1e9/10.00e6)
        self.add_period_constraint(self.lookup_request("lmk10_clk_out4", loose=True), 1e9/30.72e6)
