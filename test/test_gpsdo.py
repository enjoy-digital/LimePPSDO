#!/usr/bin/env python3
#
# This file is part of LimePSB_RPCM_GW.
#
# Copyright (c) 2024-2025 Lime Microsystems.
#
# SPDX-License-Identifier: Apache-2.0
#
# Test script for LimePSB-RPCM board (https://github.com/myriadrf/LimePSB_RPCM_GW)
#

import time
import spidev
import argparse

# Constants ----------------------------------------------------------------------------------------

# Register addresses.
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

# Status bit fields
STATUS_STATE_OFFSET    = 0
STATUS_STATE_SIZE      = 4
STATUS_ACCURACY_OFFSET = 4
STATUS_ACCURACY_SIZE   = 4
STATUS_TPULSE_OFFSET   = 8
STATUS_TPULSE_SIZE     = 1

# Control bit fields
CONTROL_EN_OFFSET      = 0
CONTROL_EN_SIZE        = 1

# Helper function to get a field from a register value.
def get_field(reg_value, offset, size):
    mask = ((1 << size) - 1) << offset
    return (reg_value & mask) >> offset

# Helper function to set a field within a register value.
def set_field(reg_value, offset, size, value):
    mask = ((1 << size) - 1) << offset
    return (reg_value & ~mask) | ((value << offset) & mask)

# GPSDODriver --------------------------------------------------------------------------------------

class GPSDODriver:
    """
    Driver for LimePSB-RPCM GPSDO gpsdocfg registers.

    This driver handles SPI communication to read/write registers and decode values.
    """
    def __init__(self, spi_bus=1, spi_device=1, speed=500000, mode=0):
        self.spi              = spidev.SpiDev()
        self.spi.open(spi_bus, spi_device)
        self.spi.max_speed_hz = speed
        self.spi.mode         = mode

    def read_register(self, address):
        """Read a 16-bit register value."""
        tx_data = [0x00, (address & 0xFF), 0x00, 0x00]
        rx_data = self.spi.xfer2(tx_data)
        value   = (rx_data[2] << 8) | rx_data[3]
        return value

    def write_register(self, address, value):
        """Write a 16-bit value to a register."""
        tx_data = [0x80, (address & 0xFF), (value >> 8) & 0xFF, value & 0xFF]
        self.spi.xfer2(tx_data)

    def get_signed_32bit(self, low_addr, high_addr):
        """Get signed 32-bit value from low/high registers."""
        low   = self.read_register(low_addr)
        high  = self.read_register(high_addr)
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
        status    = self.read_register(REG_STATUS)
        state     = get_field(status, STATUS_STATE_OFFSET, STATUS_STATE_SIZE)
        accuracy  = get_field(status, STATUS_ACCURACY_OFFSET, STATUS_ACCURACY_SIZE)
        tpulse    = get_field(status, STATUS_TPULSE_OFFSET, STATUS_TPULSE_SIZE)
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

    def set_enabled(self, enable):
        """Set enabled bit, preserving other control bits."""
        control = self.read_register(REG_CONTROL)
        control = set_field(control, CONTROL_EN_OFFSET, CONTROL_EN_SIZE, 1 if enable else 0)
        self.write_register(REG_CONTROL, control)

    def close(self):
        """Close the SPI connection."""
        self.spi.close()

# Test Functions -----------------------------------------------------------------------------------

def run_monitoring(driver, num_dumps=0, delay=1.0, banner_interval=10):
    # Header banner
    header = "Dump | Enabled | 1s Error | 10s Error | 100s Error | DAC Value | State        | Accuracy          | TPulse"

    print("Monitoring GPSDO regulation loop (press Ctrl+C to stop):")
    print(header)

    dump_count = 0
    try:
        while num_dumps == 0 or dump_count < num_dumps:
            enabled   = driver.get_enabled()
            error_1s  = driver.get_1s_error()
            error_10s = driver.get_10s_error()
            error_100s = driver.get_100s_error()
            dac       = driver.get_dac_value()
            status    = driver.get_status()

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

def dump_registers(driver, num_dumps=1, delay=1.0):
    reg_names = {value: name for name, value in globals().items() if name.startswith("REG_") and isinstance(value, int)}
    max_name_len = max(len(name) for name in reg_names.values())

    print("Dumping gpsdocfg registers:")
    for i in range(num_dumps):
        if i > 0:
            time.sleep(delay)
            print(f"\nDump {i+1}:")

        regs = [
            REG_CONTROL,
            REG_PPS_1S_TARGET_L,
            REG_PPS_1S_TARGET_H,
            REG_PPS_1S_ERR_TOL,
            REG_PPS_10S_TARGET_L,
            REG_PPS_10S_TARGET_H,
            REG_PPS_10S_ERR_TOL,
            REG_PPS_100S_TARGET_L,
            REG_PPS_100S_TARGET_H,
            REG_PPS_100S_ERR_TOL,
            REG_PPS_1S_ERR_L,
            REG_PPS_1S_ERR_H,
            REG_PPS_10S_ERR_L,
            REG_PPS_10S_ERR_H,
            REG_PPS_100S_ERR_L,
            REG_PPS_100S_ERR_H,
            REG_DAC_TUNED_VAL,
            REG_STATUS
        ]

        for addr in regs:
            value    = driver.read_register(addr)
            reg_name = reg_names.get(addr, "UNKNOWN")
            print(f"0x{addr:04X} ({reg_name:{max_name_len}}): 0x{value:04X}")

def reset_gpsdo(driver, reset_delay=2.0):
    print("Resetting GPSDO...")
    driver.set_enabled(False)
    time.sleep(reset_delay)  # Wait for disable to take effect
    driver.set_enabled(True)
    print("GPSDO reset complete (re-enabled).")

def enable_gpsdo(driver):
    # Configure 1s Target and Tolerance.
    driver.write_register(REG_PPS_1S_TARGET_L, 0xC000)
    driver.write_register(REG_PPS_1S_TARGET_H, 0x01D4)
    driver.write_register(REG_PPS_1S_ERR_TOL,  0x0003)

    # Configure 10s Target and Tolerance.
    driver.write_register(REG_PPS_10S_TARGET_L, 0x8000)
    driver.write_register(REG_PPS_10S_TARGET_H, 0x124F)
    driver.write_register(REG_PPS_10S_ERR_TOL,  0x0022)

    # Configure 100s Target and Tolerance.
    driver.write_register(REG_PPS_100S_TARGET_L, 0x0000)
    driver.write_register(REG_PPS_100S_TARGET_H, 0xB71B)
    driver.write_register(REG_PPS_100S_ERR_TOL,  0x0164)

    # Enable.
    driver.write_register(REG_CONTROL, 0x0001)
    print("GPSDO enabled.")

def disable_gpsdo(driver):
    # Disable.
    driver.write_register(REG_CONTROL, 0x0000)
    print("GPSDO disabled.")

# Main ----------------------------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="GPSDO Test Script")
    parser.add_argument("--check",       action="store_true", help="Run monitoring mode")
    parser.add_argument("--dump",        action="store_true", help="Dump registers")
    parser.add_argument("--reset",       action="store_true", help="Reset GPSDO")
    parser.add_argument("--enable",      action="store_true", help="Configure and enable GPSDO")
    parser.add_argument("--disable",     action="store_true", help="Disable GPSDO")
    parser.add_argument("--num",         default=0,    type=int,   help="Number of iterations (for --check: 0 for infinite; for --dump: default 1 if not specified)")
    parser.add_argument("--delay",       default=1.0,  type=float, help="Delay between iterations (seconds, for --check and --dump)")
    parser.add_argument("--banner",      default=10,   type=int,   help="Banner repeat interval (for --check)")
    parser.add_argument("--reset-delay", default=2.0,  type=float, help="Delay after disable before re-enable (seconds, for --reset)")
    args = parser.parse_args()

    driver = GPSDODriver()
    try:

        # Dump.
        if args.dump:
            num_dumps = args.num if args.num > 0 else 1
            dump_registers(driver, num_dumps=num_dumps, delay=args.delay)

        # Enable.
        if args.enable:
            enable_gpsdo(driver)

        # Disable.
        if args.disable:
            disable_gpsdo(driver)

        # Reset.
        if args.reset:
            reset_gpsdo(driver, reset_delay=args.reset_delay)

        # Check.
        if args.check:
            run_monitoring(driver, num_dumps=args.num, delay=args.delay, banner_interval=args.banner)
    finally:
        driver.close()

if __name__ == "__main__":
    main()
