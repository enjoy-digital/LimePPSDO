#!/usr/bin/env python3

import spidev
import time
import argparse

# Constants ----------------------------------------------------------------------------------------

# Register addresses (from gpsdocfg documentation)
REG_CONTROL            = 0x0000

# Control bit fields
CONTROL_EN_OFFSET      = 0
CONTROL_EN_SIZE        = 1

# Helper function to set a field within a register value.
def set_field(reg_value, offset, size, value):
    mask = ((1 << size) - 1) << offset
    return (reg_value & ~mask) | ((value << offset) & mask)

# GPSDODriver --------------------------------------------------------------------------------------

class GPSDODriver:
    """
    Driver for LimePSB-RPCM GPSDO gpsdocfg registers.

    This driver handles SPI communication to read/write registers.
    """
    def __init__(self, spi_bus=1, spi_device=1, speed=500000, mode=0):
        self.spi = spidev.SpiDev()
        self.spi.open(spi_bus, spi_device)
        self.spi.max_speed_hz = speed
        self.spi.mode = mode

    def read_register(self, address):
        """Read a 16-bit register value."""
        tx_data = [0x00, (address & 0xFF), 0x00, 0x00]
        rx_data = self.spi.xfer2(tx_data)
        value = (rx_data[2] << 8) | rx_data[3]
        return value

    def write_register(self, address, value):
        """Write a 16-bit value to a register."""
        tx_data = [0x80, (address & 0xFF), (value >> 8) & 0xFF, value & 0xFF]
        self.spi.xfer2(tx_data)

    def get_enabled(self):
        """Get enabled status from control register."""
        control = self.read_register(REG_CONTROL)
        return bool(control & 0x0001)

    def set_enabled(self, enable):
        """Set enabled bit, preserving other control bits."""
        control = self.read_register(REG_CONTROL)
        control = set_field(control, CONTROL_EN_OFFSET, CONTROL_EN_SIZE, 1 if enable else 0)
        self.write_register(REG_CONTROL, control)

    def close(self):
        """Close the SPI connection."""
        self.spi.close()

# Test GPSDO Reset ---------------------------------------------------------------------------------

def test_gpsdo_reset(reset_delay=2.0):
    driver = GPSDODriver()

    print("Resetting GPSDO...")
    driver.set_enabled(False)
    time.sleep(reset_delay)  # Wait for disable to take effect
    driver.set_enabled(True)
    print("GPSDO reset complete (re-enabled).")

    driver.close()

# Main ----------------------------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="GPSDO Reset Script")
    parser.add_argument("--reset-delay", default=2.0, type=float, help="Delay after disable before re-enable (seconds)")
    args = parser.parse_args()

    test_gpsdo_reset(
        reset_delay = args.reset_delay,
    )

if __name__ == "__main__":
    main()