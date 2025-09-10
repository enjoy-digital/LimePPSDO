#!/usr/bin/env python3

import spidev
import time
import argparse

# Constants ----------------------------------------------------------------------------------------

# Register addresses (from gpsdocfg documentation)
REG_CONTROL            = 0x0000
REG_PPS_1S_TARGET_L    = 0x0001
REG_PPS_1S_TARGET_H    = 0x0002
REG_PPS_1S_ERR_TOL     = 0x0003
REG_PPS_10S_TARGET_L   = 0x0004
REG_PPS_10S_TARGET_H   = 0x0005
REG_PPS_10S_ERR_TOL    = 0x0006
REG_PPS_100S_TARGET_L  = 0x0007
REG_PPS_100S_TARGET_H  = 0x0008
REG_PPS_100S_ERR_TOL   = 0x0009
REG_PPS_1S_ERR_L       = 0x000A
REG_PPS_1S_ERR_H       = 0x000B
REG_PPS_10S_ERR_L      = 0x000C
REG_PPS_10S_ERR_H      = 0x000D
REG_PPS_100S_ERR_L     = 0x000E
REG_PPS_100S_ERR_H     = 0x000F
REG_DAC_TUNED_VAL      = 0x0010
REG_STATUS             = 0x0011

# GPSDODriver --------------------------------------------------------------------------------------

class GPSDODriver:
    """
    Driver for LimePSB-RPCM GPSDO gpsdocfg registers.

    This driver handles SPI communication to read registers.
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

    def close(self):
        """Close the SPI connection."""
        self.spi.close()

# Test Registers -----------------------------------------------------------------------------------

def test_registers(num_dumps=1, delay=1.0):
    driver = GPSDODriver()

    print("Dumping gpsdocfg registers:")
    for i in range(num_dumps):
        if i > 0:
            time.sleep(delay)
            print(f"\nDump {i+1}:")

        regs = [
            REG_CONTROL, REG_PPS_1S_TARGET_L, REG_PPS_1S_TARGET_H, REG_PPS_1S_ERR_TOL,
            REG_PPS_10S_TARGET_L, REG_PPS_10S_TARGET_H, REG_PPS_10S_ERR_TOL,
            REG_PPS_100S_TARGET_L, REG_PPS_100S_TARGET_H, REG_PPS_100S_ERR_TOL,
            REG_PPS_1S_ERR_L, REG_PPS_1S_ERR_H,
            REG_PPS_10S_ERR_L, REG_PPS_10S_ERR_H,
            REG_PPS_100S_ERR_L, REG_PPS_100S_ERR_H,
            REG_DAC_TUNED_VAL, REG_STATUS
        ]

        for addr in regs:
            value = driver.read_register(addr)
            print(f"0x{addr:04X}: 0x{value:04X}")

    driver.close()

# Main ----------------------------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="GPSDO Register Dump Script")
    parser.add_argument("--num",   default=1,    type=int,   help="Number of dumps")
    parser.add_argument("--delay", default=1.0,   type=float, help="Delay between dumps (seconds)")
    args = parser.parse_args()

    test_registers(
        num_dumps = args.num,
        delay     = args.delay,
    )

if __name__ == "__main__":
    main()
