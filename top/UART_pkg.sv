`timescale 1ns / 10ps
package UART_pkg;

  import uvm_pkg::*;

  `include "uvm_macros.svh"

  `include "xtn.sv"
  `include "env_config.sv"
  `include "sequence.sv"

  `include "driver.sv"
  `include "monitor.sv"
  `include "sequencer.sv"
  `include "agent.sv"

  `include "env.sv"
  `include "test.sv"

endpackage
