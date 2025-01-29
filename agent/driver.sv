class UART_driver extends uvm_driver #(UART_xtn);

  `uvm_component_utils(UART_driver)
  virtual uart_if vif;
  agent_config a_cfg;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern task drive_task(UART_xtn xtn);
  extern task run_phase(uvm_phase phase);
endclass

function UART_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void UART_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info(get_type_name, "In build_phase of driver", UVM_LOW)
  if (!uvm_config_db#(agent_config)::get(this, "", "agent_config", a_cfg))
    `uvm_fatal(get_type_name, "failed to get a_cfg in driver")
endfunction

function void UART_driver::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  `uvm_info(get_type_name, "In the connect phase of driver", UVM_LOW)
  vif = a_cfg.vif;
endfunction

task UART_driver::drive_task(UART_xtn xtn);
  `uvm_info(get_type_name, "Driving task enabled", UVM_LOW)
endtask

task UART_driver::run_phase(uvm_phase phase);
  super.run_phase(phase);
  `uvm_info(get_type_name, "In the run phase of driver", UVM_LOW)
endtask
