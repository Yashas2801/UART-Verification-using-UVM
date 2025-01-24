class UART_sequencer extends uvm_sequencer #(UART_xtn);
  `uvm_component_utils(UART_sequencer)
  extern function new(string name, uvm_component parent);
endclass

function UART_sequencer::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction
