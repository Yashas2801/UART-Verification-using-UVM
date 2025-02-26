"""
Simulation automation for Mentor's QuestaSim (Questa targets).

This script replicates the functionality of a complex Makefile.
It defines targets for cleaning, compiling (sv_cmp), running various tests,
viewing waveforms, merging coverage reports, and more.

Project Directory Structure (example):
├── agent
├── env
├── rtl
├── sim      <-- This script may reside here or at the project top.
├── test
└── top

Usage:
    python sim.py [target]

For example:
    python sim.py help
    python sim.py run_test
    python sim.py view_wave1
"""

import os
import subprocess
import sys
import argparse

# ========================================
# SECTION: Configuration Variables
# ========================================

SIMULATOR = "Questa"
SEED_NO = "579432340"  # For parity_error_test; can be replaced with 'random'
RTL = "../rtl/*"       # Use shell expansion for wildcards.
work = "work"          # Library name
SVTB1 = "../top/top.sv"
SVTB2 = "../top/UART_pkg.sv"
INC = "+incdir+../top +incdir+../test +incdir+../agent +incdir+../env"
VSIMOPT = ["-vopt", "-voptargs=+acc"]
VSIMCOV = ["-coverage", "-sva"]

# Batch commands for different tests; note these are strings for shell expansion.
VSIMBATCH1 = '-c -do " log -r /* ;coverage save -onexit mem_cov1;run -all; exit"'
VSIMBATCH2 = '-c -do " log -r /* ;coverage save -onexit mem_cov2;run -all; exit"'
VSIMBATCH3 = '-c -do " log -r /* ;coverage save -onexit mem_cov3;run -all; exit"'
VSIMBATCH4 = '-c -do " log -r /* ;coverage save -onexit mem_cov4;run -all; exit"'
VSIMBATCH5 = '-c -do " log -r /* ;coverage save -onexit mem_cov5;run -all; exit"'
VSIMBATCH6 = '-c -do " log -r /* ;coverage save -onexit mem_cov6;run -all; exit"'
VSIMBATCH7 = '-c -do " log -r /* ;coverage save -onexit mem_cov7;run -all; exit"'
VSIMBATCH8 = '-c -do " log -r /* ;coverage save -onexit mem_cov8;run -all; exit"'
VSIMBATCH9 = '-c -do " log -r /* ;coverage save -onexit mem_cov9;run -all; exit"'
VSIMBATCH10 = '-c -do " log -r /* ;coverage save -onexit mem_cov10;run -all; exit"'
VERBOSITY = "+UVM_VERBOSITY=UVM_MEDIUM"

# ========================================
# SECTION: Utility Function
# ========================================

def run_command(cmd, shell=False):
    """
    Runs an external command.
    If 'cmd' is a list, each item is passed separately.
    If 'shell' is True, 'cmd' is run as a single shell command.
    """
    if shell:
        print("Running:", cmd)
    else:
        print("Running:", " ".join(cmd))
    subprocess.check_call(cmd, shell=shell)

# ========================================
# SECTION: QuestaSim Target Functions
# ========================================

def sv_cmp_Questa():
    """
    Create the simulation library, map it, and compile RTL and testbench files.
    """
    run_command("vlib " + work, shell=True)
    run_command("vmap work " + work, shell=True)
    # Use shell=True so that the wildcard in RTL is expanded.
    cmd = f"vlog -work {work} {RTL} {INC} {SVTB2} {SVTB1}"
    run_command(cmd, shell=True)

def run_test_Questa():
    """
    Run the base test (UART_test_base) in batch mode.
    """
    sv_cmp_Questa()
    cmd = (f"vsim -cvgperinstance {' '.join(VSIMOPT)} {' '.join(VSIMCOV)} {VSIMBATCH1} {VERBOSITY} "
           f"-wlf wave_file1.wlf -l test1.log -sv_seed random work.top +UVM_TESTNAME=UART_test_base")
    run_command(cmd, shell=True)
    run_command("vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov", shell=True)

def run_test1_Questa():
    """
    Run full_duplex_test in batch mode.
    """
    sv_cmp_Questa()
    cmd = (f"vsim -cvgperinstance {' '.join(VSIMOPT)} {' '.join(VSIMCOV)} {VSIMBATCH2} {VERBOSITY} "
           f"-wlf wave_file2.wlf -l test2.log -sv_seed random work.top +UVM_TESTNAME=full_duplex_test")
    run_command(cmd, shell=True)
    run_command("vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov", shell=True)

def run_test2_Questa():
    """
    Run half_duplex_test in batch mode.
    """
    sv_cmp_Questa()
    cmd = (f"vsim -cvgperinstance {' '.join(VSIMOPT)} {' '.join(VSIMCOV)} {VSIMBATCH3} {VERBOSITY} "
           f"-wlf wave_file3.wlf -l test3.log -sv_seed random work.top +UVM_TESTNAME=half_duplex_test")
    run_command(cmd, shell=True)
    run_command("vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov", shell=True)

def run_test3_Questa():
    """
    Run loopback_test in batch mode.
    """
    sv_cmp_Questa()
    cmd = (f"vsim -cvgperinstance {' '.join(VSIMOPT)} {' '.join(VSIMCOV)} {VSIMBATCH4} {VERBOSITY} "
           f"-wlf wave_file4.wlf -l test4.log -sv_seed random work.top +UVM_TESTNAME=loopback_test")
    run_command(cmd, shell=True)
    run_command("vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov", shell=True)

def run_test4_Questa():
    """
    Run parity_error_test in batch mode.
    """
    sv_cmp_Questa()
    cmd = (f"vsim -cvgperinstance {' '.join(VSIMOPT)} {' '.join(VSIMCOV)} {VSIMBATCH5} {VERBOSITY} "
           f"-wlf wave_file5.wlf -l test5.log -sv_seed {SEED_NO} work.top +UVM_TESTNAME=parity_error_test")
    run_command(cmd, shell=True)
    run_command("vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov", shell=True)

def run_test5_Questa():
    """
    Run framing_error_test in batch mode.
    """
    sv_cmp_Questa()
    cmd = (f"vsim -cvgperinstance {' '.join(VSIMOPT)} {' '.join(VSIMCOV)} {VSIMBATCH6} {VERBOSITY} "
           f"-wlf wave_file6.wlf -l test6.log -sv_seed 1339996228 work.top +UVM_TESTNAME=framing_error_test")
    run_command(cmd, shell=True)
    run_command("vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov", shell=True)

def run_test6_Questa():
    """
    Run overrun_error_test in batch mode.
    """
    sv_cmp_Questa()
    cmd = (f"vsim -cvgperinstance {' '.join(VSIMOPT)} {' '.join(VSIMCOV)} {VSIMBATCH7} {VERBOSITY} "
           f"-wlf wave_file7.wlf -l test7.log -sv_seed 2087349103 work.top +UVM_TESTNAME=overrun_error_test")
    run_command(cmd, shell=True)
    run_command("vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov", shell=True)

def run_test7_Questa():
    """
    Run breakinterrupt_error_test in batch mode.
    """
    sv_cmp_Questa()
    cmd = (f"vsim -cvgperinstance {' '.join(VSIMOPT)} {' '.join(VSIMCOV)} {VSIMBATCH8} {VERBOSITY} "
           f"-wlf wave_file8.wlf -l test8.log -sv_seed 3504803284 work.top +UVM_TESTNAME=breakinterrupt_error_test")
    run_command(cmd, shell=True)
    run_command("vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov", shell=True)

def run_test8_Questa():
    """
    Run timeout_error_test in batch mode.
    """
    sv_cmp_Questa()
    cmd = (f"vsim -cvgperinstance {' '.join(VSIMOPT)} {' '.join(VSIMCOV)} {VSIMBATCH9} {VERBOSITY} "
           f"-wlf wave_file9.wlf -l test9.log -sv_seed 2189750904 work.top +UVM_TESTNAME=timeout_error_test")
    run_command(cmd, shell=True)
    run_command("vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov", shell=True)

def run_test9_Questa():
    """
    Run thr_empty_test in batch mode.
    """
    sv_cmp_Questa()
    cmd = (f"vsim -cvgperinstance {' '.join(VSIMOPT)} {' '.join(VSIMCOV)} {VSIMBATCH10} {VERBOSITY} "
           f"-wlf wave_file10.wlf -l test10.log -sv_seed 1208779359 work.top +UVM_TESTNAME=thr_empty_test")
    run_command(cmd, shell=True)
    run_command("vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov", shell=True)

def view_wave1_Questa():
    run_command("vsim -view wave_file1.wlf", shell=True)

def view_wave2_Questa():
    run_command("vsim -view wave_file2.wlf", shell=True)

def view_wave3_Questa():
    run_command("vsim -view wave_file3.wlf", shell=True)

def view_wave4_Questa():
    run_command("vsim -view wave_file4.wlf", shell=True)

def view_wave5_Questa():
    run_command("vsim -view wave_file5.wlf", shell=True)

def view_wave6_Questa():
    run_command("vsim -view wave_file6.wlf", shell=True)

def view_wave7_Questa():
    run_command("vsim -view wave_file7.wlf", shell=True)

def view_wave8_Questa():
    run_command("vsim -view wave_file8.wlf", shell=True)

def view_wave9_Questa():
    run_command("vsim -view wave_file9.wlf", shell=True)

def view_wave10_Questa():
    run_command("vsim -view wave_file10.wlf", shell=True)

def report_Questa():
    """
    Merge coverage reports from mem_cov1 to mem_cov10 and generate an HTML report.
    """
    merge_cmd = "vcover merge mem_cov mem_cov1 mem_cov2 mem_cov3 mem_cov4 mem_cov5 mem_cov6 mem_cov7 mem_cov8 mem_cov9 mem_cov10"
    run_command(merge_cmd, shell=True)
    report_cmd = "vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov"
    run_command(report_cmd, shell=True)

def regress_Questa():
    """
    Clean, compile, and run all test cases sequentially, then merge coverage reports.
    """
    clean_Questa()
    run_test_Questa()
    run_test1_Questa()
    run_test2_Questa()
    run_test3_Questa()
    run_test4_Questa()
    run_test5_Questa()
    run_test6_Questa()
    run_test7_Questa()
    run_test8_Questa()
    run_test9_Questa()
    report_Questa()

def cov_Questa():
    """
    Open the merged coverage report in Firefox.
    """
    run_command("firefox covhtmlreport/index.html&", shell=True)

def clean_Questa():
    """
    Clean generated simulation files.
    Removes transcript files, log files, waveform files, coverage reports, and the library directory.
    """
    cmd = "rm -rf transcript* *log* fcover* covhtml* mem_cov* *.wlf modelsim.ini " + work
    run_command(cmd, shell=True)
    # Optionally clear the terminal screen.
    run_command("clear", shell=True)

# ========================================
# SECTION: Custom Help Function
# ========================================

def print_custom_help():
    help_text = """
===================================================================================================================
! USAGE           --  python sim.py [target]
!
! Available Targets:
!    help         : Display this help message.
!    clean        : Clean simulation files (logs, waveforms, coverage reports, and the library directory).
!    sv_cmp       : Create library, map it, and compile the RTL and testbench files.
!    run_test     : Clean, compile, and run the simulation for base test (UART_test_base) in batch mode.
!    run_test1    : Clean, compile, and run the simulation for full_duplex_test in batch mode.
!    run_test2    : Clean, compile, and run the simulation for half_duplex_test in batch mode.
!    run_test3    : Clean, compile, and run the simulation for loopback_test in batch mode.
!    run_test4    : Clean, compile, and run the simulation for parity_error_test.
!    run_test5    : Clean, compile, and run the simulation for framing_error_test.
!    run_test6    : Clean, compile, and run the simulation for overrun_error_test.
!    run_test7    : Clean, compile, and run the simulation for breakinterrupt_error_test.
!    run_test8    : Clean, compile, and run the simulation for timeout_error_test.
!    run_test9    : Clean, compile, and run the simulation for thr_empty_test.
!    view_wave1   : View waveform for base test.
!    view_wave2   : View waveform for full_duplex_test.
!    view_wave3   : View waveform for half_duplex_test.
!    view_wave4   : View waveform for loopback_test.
!    view_wave5   : View waveform for parity_error_test.
!    view_wave6   : View waveform for framing_error_test.
!    view_wave7   : View waveform for overrun_error_test.
!    view_wave8   : View waveform for breakinterrupt_error_test.
!    view_wave9   : View waveform for timeout_error_test.
!    view_wave10  : View waveform for thr_empty_test.
!    regress      : Run all test cases sequentially and merge coverage reports.
!    report       : Merge coverage reports for all test cases and convert to HTML.
!    cov          : Open the merged coverage report in Firefox.
===================================================================================================================
"""
    print(help_text)

# ========================================
# SECTION: Command-Line Interface
# ========================================

def main():
    parser = argparse.ArgumentParser(
        description="Simulation automation for Mentor's QuestaSim (Questa targets).",
        add_help=False  # We'll handle help manually.
    )
    # Make the target argument optional (default to help)
    parser.add_argument("target",
                        nargs="?",
                        choices=["help", "clean", "sv_cmp",
                                 "run_test", "run_test1", "run_test2", "run_test3", "run_test4",
                                 "run_test5", "run_test6", "run_test7", "run_test8", "run_test9",
                                 "view_wave1", "view_wave2", "view_wave3", "view_wave4", "view_wave5",
                                 "view_wave6", "view_wave7", "view_wave8", "view_wave9", "view_wave10",
                                 "regress", "report", "cov"],
                        default="help",
                        help="Target to execute (see available targets)"
                       )
    args = parser.parse_args()
    
    target_map = {
        "clean": clean_Questa,
        "sv_cmp": sv_cmp_Questa,
        "run_test": run_test_Questa,
        "run_test1": run_test1_Questa,
        "run_test2": run_test2_Questa,
        "run_test3": run_test3_Questa,
        "run_test4": run_test4_Questa,
        "run_test5": run_test5_Questa,
        "run_test6": run_test6_Questa,
        "run_test7": run_test7_Questa,
        "run_test8": run_test8_Questa,
        "run_test9": run_test9_Questa,
        "view_wave1": view_wave1_Questa,
        "view_wave2": view_wave2_Questa,
        "view_wave3": view_wave3_Questa,
        "view_wave4": view_wave4_Questa,
        "view_wave5": view_wave5_Questa,
        "view_wave6": view_wave6_Questa,
        "view_wave7": view_wave7_Questa,
        "view_wave8": view_wave8_Questa,
        "view_wave9": view_wave9_Questa,
        "view_wave10": view_wave10_Questa,
        "regress": regress_Questa,
        "report": report_Questa,
        "cov": cov_Questa,
        "help": print_custom_help
    }
    
    func = target_map.get(args.target)
    if func:
        func()
    else:
        print_custom_help()

if __name__ == "__main__":
    main()
