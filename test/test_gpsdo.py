#!/usr/bin/env python3

import spidev
import time
import argparse

# Constants ----------------------------------------------------------------------------------------

# Register addresses (from gpsdocfg documentation)
REG_CONTROL            = 0x0000
REG_PPS_1S_ERR_L       = 0x000A
REG_PPS_1S_ERR_H       = 0x000B
REG_PPS_10S_ERR_L      = 0x000C
REG_PPS_10S_ERR_H      = 0x000D
REG_PPS_100S_ERR_L     = 0x000E
REG_PPS_100S_ERR_H     = 0x000F
REG_DAC_TUNED_VAL      = 0x0010
REG_STATUS             = 0x0011

# Status bit fields
STATUS_STATE_OFFSET    = 0
STATUS_STATE_SIZE      = 4
STATUS_ACCURACY_OFFSET = 4
STATUS_ACCURACY_SIZE   = 4
STATUS_TPULSE_OFFSET   = 8
STATUS_TPULSE_SIZE     = 1

# Helper function to get a field from a register value.
def get_field(reg_value, offset, size):
    mask = ((1 << size) - 1) << offset
    return (reg_value & mask) >> offset

# GPSDODriver --------------------------------------------------------------------------------------

class GPSDODriver:
    """
    Driver for LimePSB-RPCM GPSDO gpsdocfg registers.

    This driver handles SPI communication to read registers and decode values.
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

    def get_signed_32bit(self, low_addr, high_addr):
        """Get signed 32-bit value from low/high registers."""
        low = self.read_register(low_addr)
        high = self.read_register(high_addr)
        value = (high << 16) | low
        if value & (1 << 31):  # Sign extend if negative
            value -= (1 << 32)
        return value

    def get_1s_error(self):
        """Get 1s error as signed 32-bit."""
        return self.get_signed_32bit(REG_PPS_1S_ERR_L, REG_PPS_1S_ERR_H)

    def get_10s_error(self):
        """Get 10s error as signed 32-bit."""
        return self.get_signed_32bit(REG_PPS_10S_ERR_L, REG_PPS_10S_ERR_H)

    def get_100s_error(self):
        """Get 100s error as signed 32-bit."""
        return self.get_signed_32bit(REG_PPS_100S_ERR_L, REG_PPS_100S_ERR_H)

    def get_dac_value(self):
        """Get DAC tuned value."""
        return self.read_register(REG_DAC_TUNED_VAL)

    def get_status(self):
        """Get decoded status: state, accuracy, tpulse_active."""
        status = self.read_register(REG_STATUS)
        state = get_field(status, STATUS_STATE_OFFSET, STATUS_STATE_SIZE)
        accuracy = get_field(status, STATUS_ACCURACY_OFFSET, STATUS_ACCURACY_SIZE)
        tpulse = get_field(status, STATUS_TPULSE_OFFSET, STATUS_TPULSE_SIZE)
        state_str = "Coarse Tune" if state == 0 else "Fine Tune" if state == 1 else f"Unknown ({state})"
        accuracy_str = ['Disabled/Lowest', '1s Tune', '2s Tune', '3s Tune (Highest)'][accuracy] if accuracy < 4 else f"Unknown ({accuracy})"
        return {
            "state": state_str,
            "accuracy": accuracy_str,
            "tpulse_active": bool(tpulse)
        }

    def get_enabled(self):
        """Get enabled status from control register."""
        control = self.read_register(REG_CONTROL)
        return bool(control & 0x0001)

    def close(self):
        """Close the SPI connection."""
        self.spi.close()

# Test GPSDO ---------------------------------------------------------------------------------------

def test_gpsdo(num_dumps=0, delay=1.0, banner_interval=10):
    driver = GPSDODriver()

    # Header banner
    header = "Dump | Enabled | 1s Error | 10s Error | 100s Error | DAC Value | State        | Accuracy          | TPulse"

    print("Monitoring GPSDO regulation loop (press Ctrl+C to stop):")
    print(header)

    dump_count = 0
    try:
        while num_dumps == 0 or dump_count < num_dumps:
            enabled = driver.get_enabled()
            error_1s = driver.get_1s_error()
            error_10s = driver.get_10s_error()
            error_100s = driver.get_100s_error()
            dac = driver.get_dac_value()
            status = driver.get_status()

            # Single-line output
            print(f"{dump_count + 1:4d} | {str(enabled):7} | {error_1s:8d} | {error_10s:9d} | {error_100s:10d} | 0x{dac:04X}    | {status['state']:12} | {status['accuracy']:17} | {str(status['tpulse_active']):6}")

            dump_count += 1

            # Print banner every banner_interval dumps
            if dump_count % banner_interval == 0:
                print(header)

            if num_dumps == 0 or dump_count < num_dumps:
                time.sleep(delay)
    except KeyboardInterrupt:
        print("\nMonitoring stopped.")
    finally:
        driver.close()

# Main ----------------------------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="GPSDO Regulation Monitoring Script")
    parser.add_argument("--num",   default=0,    type=int,   help="Number of dumps (0 for infinite)")
    parser.add_argument("--delay", default=1.0,   type=float, help="Delay between dumps (seconds)")
    parser.add_argument("--banner", default=10,   type=int,   help="Banner repeat interval")
    args = parser.parse_args()

    test_gpsdo(
        num_dumps      = args.num,
        delay          = args.delay,
        banner_interval = args.banner,
    )

if __name__ == "__main__":
    main()