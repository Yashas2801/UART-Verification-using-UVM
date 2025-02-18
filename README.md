# Verification of UART (UVM)

This project demonstrates the verification of a UART (Universal Asynchronous Receiver-Transmitter) design using SystemVerilog and UVM methodology. The verification ensures proper data transmission, reception, and handling of various UART protocols and conditions.

## Features

- **Testbench Environment**: Built using UVM to verify UART functionality, including edge cases.
- **Coverage**: Functional coverage to ensure all possible UART states and transitions are exercised.
- **Simulation**: Run on QuestaSim, with detailed logs and waveform analysis.

## UART Frame Structure (8N1 with Optional Parity)

A UART frame consists of:
  • **A Start Bit** – Always `0` (low), indicating the beginning of a frame.
  • **8 Data Bits** – Transmitted **LSB (least significant bit) first**.
  • **An Optional Parity Bit** – May be included for error checking.
  • **A Stop Bit** – Always `1` (high), indicating the end of a frame.

### **Frame Diagram:**
```
   +---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+
   |  Start  |  Data0  |  Data1  |  Data2  |  Data3  |  Data4  |  Data5  |  Data6  |  Data7  | Parity  |  Stop   |
   |  (0)    |         |         |         |         |         |         |         |         | Optional|  (1)    |
   +---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+
```

### **Timing Diagram Example:**
```
         Clock Signal -->
         __    __    __    __    __    __    __    __    __    __    __    __
clk:  _/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__

         Bit Periods -->
         +---+-------+-------+-------+-------+-------+-------+-------+-------+---------+---+
         | 0 |  D0   |  D1   |  D2   |  D3   |  D4   |  D5   |  D6   |  D7   | Parity  | 1 |
         +---+-------+-------+-------+-------+-------+-------+-------+-------+---------+---+
           ^      ^       ^       ^       ^       ^       ^       ^       ^         ^
           |      |       |       |       |       |       |       |       |         |
         Start  Data   Data    Data    Data    Data    Data    Data    Data   Optional  Stop
          Bit   Bit0   Bit1    Bit2    Bit3    Bit4    Bit5    Bit6    Bit7   Parity Bit
```

### **Explanation:**
- The transmission begins with a **low (`0`) start bit**.
- **Eight data bits** follow, starting with **Data0 (LSB)** and ending with **Data7 (MSB)**.
- An **optional parity bit** may be transmitted after the data bits to assist with **error checking**.
- The frame ends with a **high (`1`) stop bit**.
- The **clock signal** shown on top illustrates the **bit timing**, where each clock cycle corresponds to **one bit period**.

This clear structure ensures proper **synchronization and error checking** in **UART communications** and can be modeled in your **UVM verification environment**.

## Architecture

![UART Architecture](https://github.com/Yashas2801/UART-Verification-using-UVM/blob/1063f55ba8383ab977bc193d106ea2305c672b41/arch1.png)

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
├── rtl
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

### **Note on Seed Numbers**

In the Makefile, fixed seed numbers are used for some test cases. However, these seeds may not work in different versions of QuestaSim due to changes in the randomization algorithm. To ensure compatibility:

1. Replace the seed numbers with `random` in the Makefile.
2. Run each test case and note the seed number generated.
3. If required, use the noted seed number for reproducibility in future runs.

## Scoreboard Overview

The **UART scoreboard** is responsible for checking the correctness of transactions received by the monitor. It compares transmitted and received data to ensure compliance with expected results. The scoreboard also includes functional coverage to track test outcomes and key protocol events.

### Key Features:

- **Test Outcome Tracking**: Uses flags to monitor test pass/fail status for different modes such as Full-Duplex, Half-Duplex, Loopback, and error conditions.
- **Functional Coverage Groups**:
  - `lcr_usage_cg`: Covers the **Line Control Register (LCR)** parameters such as word length, stop bits, and parity settings.
  - `ier_usage_cg`: Tracks **Interrupt Enable Register (IER)** settings for enabling/disabling specific UART interrupts.
  - `fcr_usage_cg`: Captures FIFO-related settings from the **FIFO Control Register (FCR)**, including trigger levels and resets.
  - `mcr_usage_cg`: Checks configurations related to the **Modem Control Register (MCR)**, including loopback mode.
  - `lsr_coverage_cg`: Monitors **Line Status Register (LSR)** conditions, such as data readiness, overrun, parity errors, and framing errors.
  - `iir_coverage_cg`: Covers **Interrupt Identification Register (IIR)**, tracking various interrupt types like transmit buffer empty and receiver data availability.
  - `uart_coverage`: Tracks functional coverage based on UART transactions, including address checks, write enable signals, and protocol activity.
  - `test_outcome_cg`: Captures overall test results, ensuring different UART modes function as expected.

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

For a more detailed specification, refer to the [**UART16550 Core Technical Manual**](https://github.com/Yashas2801/UART-Verification-using-UVM/blob/1b3729900a32548d624ee482b044b819b4f466d3/UART_16550.pdf).

---

This project aims to ensure the UART design is thoroughly verified and functions reliably across different scenarios using UVM.


