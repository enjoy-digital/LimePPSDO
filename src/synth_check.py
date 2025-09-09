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

    log_filename = f"{os.path.splitext(filename)[0]}_yosys.log"

    try:
        # Run Yosys and capture output, with -l for log
        result = subprocess.run(['yosys', '-l', log_filename, '-s', temp_ys_path], capture_output=True, text=True, timeout=60)
        print(f"Yosys synthesis output dumped to {log_filename}")

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
            # Extract problematic FF names
            ff_names = set()
            ff_pattern = re.compile(r'FF .*?(\$\S+) \(type')
            for line in found_errors:
                matches = ff_pattern.findall(line)
                ff_names.update(matches)

            print(f"Extracted problematic FF names: {', '.join(ff_names)}")

            if ff_names:
                # Run a second Yosys session for analysis: run passes up to before dfflegalize
                analysis_script = f"""
verilog_defaults -push
verilog_defaults -add -defer
read_verilog -lib +/ice40/cells_sim.v
{read_cmd}
verilog_defaults -pop
attrmap -tocase keep -imap keep="true" keep=1 -imap keep="false" keep=0 -remove keep=0

hierarchy -top {top_module} -check
proc
flatten
opt_expr
opt_clean
check -noinit
opt
wreduce
peepopt
opt_clean
share
techmap -map +/techmap.v
opt -fast
memory -nomap
opt -full
fsm
opt -full
memory_map
opt -full
techmap -map +/techmap.v
opt -fast
write_ilang {os.path.splitext(filename)[0]}_debug.ilang
"""

                # For each FF, select the cell (use a: for name matching)
                for ff in ff_names:
                    # Sanitize ff name for filename
                    ff_safe = ff.replace('$', '_').replace('.', '_').replace(':', '_').replace('/', '_')
                    # Escape for Yosys select
                    ff_escaped = ff.replace('$', '\\$').replace('.', '\\.').replace(':', '\\:').replace('/', '\\ /')
                    analysis_script += f"""
select a:name=*{ff_escaped}*
select %ci:* %ci:* %ci:* %ci:*  # Deep trace inputs (depth 4)
dump -outfile {os.path.splitext(filename)[0]}_{ff_safe}_analysis.txt
"""

                with tempfile.NamedTemporaryFile(mode='w', suffix='.ys', delete=False) as temp_analysis_ys:
                    temp_analysis_ys.write(analysis_script)
                    temp_analysis_path = temp_analysis_ys.name

                analysis_result = subprocess.run(['yosys', '-s', temp_analysis_path], capture_output=True, text=True, timeout=60)
                if analysis_result.returncode != 0:
                    print(f"Analysis Yosys run failed: {analysis_result.stderr[:500]}...")
                else:
                    print("Analysis run successful.")

                os.unlink(temp_analysis_path)

                analysis_summary = []
                for ff in ff_names:
                    ff_safe = ff.replace('$', '_').replace('.', '_').replace(':', '_').replace('/', '_')
                    analysis_file = f"{os.path.splitext(filename)[0]}_{ff_safe}_analysis.txt"
                    if os.path.exists(analysis_file):
                        with open(analysis_file, 'r') as af:
                            content = af.read()
                            # Python parsing: Find all unique \src "file:line"
                            src_matches = set(re.findall(r'attribute \\src "([^"]+)"', content))
                            if src_matches:
                                locations = ', '.join(sorted(src_matches))
                                analysis_summary.append(f"For FF {ff}: Inferred from source locations: {locations}")
                                analysis_summary.append("Likely cause: always block with multiple async edges (e.g., posedge clk or posedge rst or posedge set) or non-constant async load. Rewrite as synchronous reset (move reset inside clocked if).")
                            else:
                                analysis_summary.append(f"For FF {ff}: No \src found in chain; trace ports like \ARST, \ASET, \ALOAD in {analysis_file} or grep ILANG for '{ff}' and connected signals to find originating always block.")

                ilang_file = f"{os.path.splitext(filename)[0]}_debug.ilang"
                print(f"ILANG dump saved to {ilang_file}")
                for ff in ff_names:
                    ff_safe = ff.replace('$', '_').replace('.', '_').replace(':', '_').replace('/', '_')
                    print(f"Cell analysis for {ff} dumped to {os.path.splitext(filename)[0]}_{ff_safe}_analysis.txt")

                if analysis_summary:
                    return f"Error detected in {filename}:{newline}{newline.join(found_errors)}{newline}Automated analysis:{newline}{newline.join(analysis_summary)}{newline}To fix: Open flagged file:line, remove async edges from sensitivity list, make resets sync."
                else:
                    return f"Error detected in {filename}:{newline}{newline.join(found_errors)}{newline}No automated source locations found (optimized away); manually grep ILANG for FF name and trace \ARST/\ASET signals to find originating always block."

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
    print("\nChecks complete. If errors are found, the script has analyzed and reported source locations above. Inspect flagged always blocks for async issues.")
