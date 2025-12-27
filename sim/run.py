#!/usr/bin/env python3
import os
import subprocess
import sys
from datetime import datetime

# ==================================================
# USER CONFIGURATION
# ==================================================
TOP = "uart_top_tb"
WORK_DIR = "work"
LOG_DIR = "logs"
COV_DIR = "coverage"

TESTS = [
    "random_tx_test",
    "directed_tx_test"
]

RTL_FILES = [
    "../rtl/uart_baud_rate_gen_tx.v",
    "../rtl/uart_baud_rate_gen_rx.v",
    "../rtl/uart_tx.v",
    "../rtl/uart_rx.v",
    "../rtl/uart_top.v"
]

TB_FILES = [
    "../tb/uart_if.sv",
    "../tb/uart_uvm_pkg.sv",
    "../tb/uart_top_tb.sv"
]

# ==================================================
# DIRECTORY SETUP
# ==================================================
os.makedirs(LOG_DIR, exist_ok=True)
os.makedirs(COV_DIR, exist_ok=True)

# ==================================================
# HELPER FUNCTION
# ==================================================
def run_cmd(cmd, logfile=None):
    print(f"\n[CMD] {' '.join(cmd)}")
    process = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True
    )

    output = ""
    for line in process.stdout:
        print(line, end="")
        output += line

    process.wait()

    if logfile:
        with open(logfile, "w") as f:
            f.write(output)

    return process.returncode, output

# ==================================================
# CREATE WORK LIBRARY
# ==================================================
if not os.path.exists(WORK_DIR):
    rc, _ = run_cmd(["vlib", WORK_DIR])
    if rc != 0:
        sys.exit("ERROR: vlib failed")

# ==================================================
# COMPILE WITH COVERAGE
# ==================================================
compile_cmd = [
    "vlog",
    "-sv",
    "-work", WORK_DIR,
    "+cover=bcesft"   # Branch, Condition, Expression, State, FSM, Toggle
]

compile_cmd += RTL_FILES
compile_cmd += TB_FILES

rc, _ = run_cmd(compile_cmd)
if rc != 0:
    sys.exit("ERROR: Compilation failed")

print("\n=== COMPILATION PASSED ===")

# ==================================================
# RUN TESTS
# ==================================================
results = {}
ucdb_files = []

for test in TESTS:
    print(f"\n=== RUNNING TEST: {test} ===")

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    logfile = f"{LOG_DIR}/{test}_{timestamp}.log"
    ucdb_file = f"{COV_DIR}/{test}.ucdb"

    sim_cmd = [
        "vsim",
        "-c",
        "-coverage",
        "-work", WORK_DIR,
        TOP,
        f"+UVM_TESTNAME={test}",
        "-do",
        f" run 50ms; coverage save -onexit {ucdb_file}; quit"
    ]

    rc, output = run_cmd(sim_cmd, logfile)

    if "TEST FAILED" in output:
        results[test] = "FAIL"
    else:
        results[test] = "PASS"
        ucdb_files.append(ucdb_file)

# ==================================================
# COVERAGE MERGE
# ==================================================
print("\n=== MERGING COVERAGE DATABASES ===")

merged_ucdb = f"{COV_DIR}/uart_merged.ucdb"
merge_cmd = ["vcover", "merge", merged_ucdb] + ucdb_files

rc, _ = run_cmd(merge_cmd)
if rc != 0:
    sys.exit("ERROR: Coverage merge failed")

# ==================================================
# COVERAGE REPORT GENERATION
# ==================================================
print("\n=== GENERATING COVERAGE REPORT ===")

html_cmd = [
    "vcover", "report",
    "-html", f"{COV_DIR}/cov_html",
    merged_ucdb
]
run_cmd(html_cmd)

text_cmd = [
    "vcover", "report",
    "-details",
    merged_ucdb
]
run_cmd(text_cmd)

# ==================================================
# SUMMARY
# ==================================================
print("\n==============================")
print("        REGRESSION SUMMARY    ")
print("==============================")

for test, result in results.items():
    print(f"{test:25} : {result}")

if "FAIL" in results.values():
    print("\nOVERALL RESULT: FAIL ❌")
    sys.exit(1)
else:
    print("\nOVERALL RESULT: PASS ✅")
    print(f"Coverage HTML: {COV_DIR}/cov_html/index.html")
    sys.exit(0)
