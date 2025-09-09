#!/usr/bin/env python3

import re
import subprocess
import tempfile
import os

# List of Verilog files from the provided directory listing
# Adjust paths if needed (e.g., if in a subdirectory)
verilog_files = [
    'gpsdocfg.v',
    'LimePSB_RPCM_top.v',
    'neo430_top_avm.v',
    'pps_detector.v',
    'vctcxo_tamer.v'
]

# Function to extract top module name from Verilog file
def extract_top_module(filename):
    with open(filename, 'r') as f:
        content = f.read()
    # Simple regex to find 'module <name>'
    match = re.search(r'\bmodule\s+(\w+)', content)
    if match:
        return match.group(1)
    else:
        raise ValueError(f"No module declaration found in {filename}")

# Function to run Yosys on Verilog file(s) and check for FF legalization error
def check_verilog_file(filename, is_top=False):
    newline = '\n'  # Define outside to avoid backslash in f-string expression
    try:
        top_module = extract_top_module(filename)
    except ValueError as e:
        return f"Skipping {filename}: {str(e)}"

    # If it's the top-level, read all Verilog files; else, just this one
    if is_top:
        read_cmds = [f'read_verilog -sv {f}' for f in verilog_files if os.path.exists(f)]
        read_cmd = newline.join(read_cmds)
    else:
        read_cmd = f'read_verilog -sv {filename}'

    # Yosys script mimicking the LiteX generated script
    ys_script = f"""
verilog_defaults -push
verilog_defaults -add -defer
{read_cmd}
verilog_defaults -pop
attrmap -tocase keep -imap keep="true" keep=1 -imap keep="false" keep=0 -remove keep=0

synth_ice40 -dsp -top {top_module}
"""

    # Create temporary file for the Yosys script
    with tempfile.NamedTemporaryFile(mode='w', suffix='.ys', delete=False) as temp_ys:
        temp_ys.write(ys_script)
        temp_ys_path = temp_ys.name

    try:
        # Run Yosys and capture output
        result = subprocess.run(['yosys', '-s', temp_ys_path], capture_output=True, text=True, timeout=60)

        # Check for the specific error message about async set and reset
        error_keywords = [
            "dffs with async set and reset are not supported",
            "cannot be legalized",
            "_ALDFF_PP_"
        ]
        output = result.stdout + result.stderr
        found_errors = []
        for keyword in error_keywords:
            if keyword in output:
                # Extract relevant error lines
                error_lines = [line.strip() for line in output.splitlines() if keyword in line]
                found_errors.extend(error_lines)

        if found_errors:
            return f"Error detected in {filename}:{newline}{newline.join(found_errors)}"

        if result.returncode != 0:
            # Extract ERROR lines
            error_lines = [line.strip() for line in result.stderr.splitlines() if 'ERROR' in line or 'Error' in line]
            if error_lines:
                return f"Yosys failed for {filename} (return code {result.returncode}):{newline}{newline.join(error_lines)}"
            else:
                return f"Yosys failed for {filename} (return code {result.returncode}):{newline}{result.stderr[:500]}..."  # Truncate long output

        return f"No FF legalization error found in {filename}"
    except subprocess.TimeoutExpired:
        return f"Timeout while processing {filename}"
    except FileNotFoundError:
        return "Yosys not found in PATH. Please install Yosys."
    finally:
        # Clean up temp file
        os.unlink(temp_ys_path)

# Main execution: Check each file and print results
if __name__ == "__main__":
    print("Starting Verilog FF legalization checks...\n")
    for file in verilog_files:
        if os.path.exists(file):
            # Assume 'LimePSB_RPCM_top.v' is the top-level
            is_top = 'LimePSB_RPCM_top' in file
            result = check_verilog_file(file, is_top=is_top)
            print(result)
            print("-" * 80)
        else:
            print(f"File not found: {file}")
            print("-" * 80)
    print("\nChecks complete. If errors are found, inspect the reported file for always blocks with multiple async edges (e.g., posedge clk or posedge rst or posedge set).")