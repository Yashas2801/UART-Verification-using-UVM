class UART_monitor extends uvm_monitor;

  `uvm_component_utils(UART_monitor)

  virtual UART_interface vif;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
endclass

function UART_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void UART_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info(get_type_name, "In the build phase of monitor", UVM_LOW)
endfunction
