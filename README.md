# Verification of UART (UVM)

This project demonstrates the verification of a UART (Universal Asynchronous Receiver-Transmitter) design using SystemVerilog and UVM methodology. The verification ensures proper data transmission, reception, and handling of various UART protocols and conditions.

## Features

- **Testbench Environment**: Built using UVM to verify UART functionality, including edge cases.
- **Assertions**: Used to check protocol compliance and error handling.
- **Coverage**: Functional coverage to ensure all possible UART states and transitions are exercised.
- **Simulation**: Run on QuestaSim, with detailed logs and waveform analysis.


## Directory Structure

```
├── agent
│   ├── agent_config.sv
│   ├── agent.sv
│   ├── driver.sv
│   ├── monitor.sv
│   ├── sequencer.sv
│   ├── sequence.sv
│   └── xtn.sv
├── env
│   ├── env_config.sv
│   ├── env.sv
│   ├── scoreboard.sv
│   ├── virtual_sequencer.sv
│   └── virtual_sequence.sv
├── README.md
├── rtl
│   ├── if.sv
│   ├── raminfr.v
│   ├── timescale.v
│   ├── uart_debug_if.v
│   ├── uart_defines.v
│   ├── uart_receiver.v
│   ├── uart_regs.v
│   ├── uart_rfifo.v
│   ├── uart_sync_flops.v
│   ├── uart_tfifo.v
│   ├── uart_top.v
│   ├── uart_transmitter.v
│   └── uart_wb.v
├── sim
│   └── Makefile
├── test
│   └── test.sv
└── top
    ├── top.sv
    └── UART_pkg.sv
```

## Simulation and Verification

### Running Tests

#### Tip - Run this command to see available Makefile options:
```sh
cd sim 
make help
```

#### Running tests:
- `make run_test` - Runs `base_test`.
- `make run_test1` - Runs `full_duplex_test`.
- `make run_test2` - Runs `half_duplex_test`.
- `make run_test3` - Runs `loopback_test`.
- `make run_test4` - Runs `parity_error_test`.
- `make run_test5` - Runs `framing_error_test`.
- `make run_test6` - Runs `overrun_error_test`.
- `make run_test7` - Runs `breakinterrupt_error_test`.
- `make run_test8` - Runs `timeout_error_test`.
- `make run_test9` - Runs `thr_empty_test`.

#### Viewing Waveforms
To view the waveform of a specific test, run:
```sh
make view_waveX
```
where `X` corresponds to the test number. For example, to view the waveform of `full_duplex_test`, run:
```sh
make view_wave2
```

#### Running Regression and Coverage Reports
- `make regress` - Runs all tests and generates a combined report.
- `make cov` - Opens the merged coverage report in HTML format.
- `make report` - Merges coverage reports for all test cases and converts them to an HTML format.

## Scoreboard Overview

The **UART scoreboard** is responsible for checking the correctness of transactions received by the monitor. It compares transmitted and received data to ensure compliance with expected results. The scoreboard also includes functional coverage to track test outcomes and key protocol events.

### Key Features:
- **Test Outcome Tracking**: Uses flags to monitor test pass/fail status for different modes such as Full-Duplex, Half-Duplex, Loopback, and error conditions.
- **Coverage Groups**:
  - `test_outcome_cg`: Tracks test success for different conditions.
  - `uart_coverage`: Captures functional coverage based on UART transactions, including address checks, write enable signals, and protocol activity.
- **Data Comparison**:
  - Ensures transmitted and received data match correctly in different operational modes.
  - Checks error conditions like parity errors, framing errors, and overrun conditions.

## Verified UART Details

The verified UART is based on the **UART16550 Core**, which provides industry-standard serial communication capabilities. It supports **WISHBONE** and standard **RS232 protocols**. The design ensures compatibility with the **NS16550A** device while also offering additional debugging features.

### Key Registers:
- **Interrupt Enable Register (IER)** - Controls which interrupts are enabled.
- **Interrupt Identification Register (IIR)** - Indicates the highest priority pending interrupt.
- **FIFO Control Register (FCR)** - Configures FIFO behavior and trigger levels.
- **Line Control Register (LCR)** - Manages data format, parity, and stop bits.
- **Modem Control Register (MCR)** - Controls modem signals.
- **Line Status Register (LSR)** - Provides status information about the transmitter and receiver.
- **Modem Status Register (MSR)** - Displays the current state of the modem control lines.
- **Divisor Latches** - Configures the baud rate for UART communication.

For a more detailed specification, refer to the **[UART16550 Core Technical Manual](https://github.com/Yashas2801/UART-Verification-using-UVM/blob/1b3729900a32548d624ee482b044b819b4f466d3/UART_16550.pdf)**.


