class UART_xtn extends uvm_sequence_item;
  `uvm_object_utils(UART_xtn)
  extern function new(string name = "UART_xtn");
endclass

function UART_xtn::new(string name = "UART_xtn");
  super.new(name);
endfunction
