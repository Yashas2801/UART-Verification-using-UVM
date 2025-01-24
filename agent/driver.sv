class UART_driver extends uvm_driver #(UART_xtn);

  `uvm_component_utils(UART_driver)
  virtual UART_interface vif;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
endclass

function UART_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void UART_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info(get_type_name, "In build_phase of driver", UVM_LOW)
endfunction
