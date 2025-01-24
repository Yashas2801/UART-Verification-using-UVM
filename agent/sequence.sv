class UART_sequence_base extends uvm_sequence #(UART_xtn);
  `uvm_object_utils(UART_sequence_base)
  extern function new(string name = "UART_sequence_base");
  extern task body;
endclass

function UART_sequence_base::new(string name = "UART_sequence_base");
  super.new(name);
endfunction

task UART_sequence_base::body();
  `uvm_info(get_type_name, "In the body of base class", UVM_LOW)
endtask
