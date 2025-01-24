class UART_test_base extends uvm_test;
  `uvm_component_utils(UART_test_base)

  UART_env   envh;
  env_config e_cfg;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void end_of_elaboration_phase(uvm_phase phase);
endclass

function UART_test_base::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction


function void UART_test_base::build_phase(uvm_phase phase);
  super.build_phase(phase);

  `uvm_info(get_type_name, "In the build phase of test", UVM_LOW)

  e_cfg = env_config::type_id::create("e_cfg");
  e_cfg.is_active = UVM_ACTIVE;
  e_cfg.no_of_agents = 2;

  uvm_config_db#(env_config)::set(this, "*", "env_config", e_cfg);

  envh = UART_env::type_id::create("envh", this);

endfunction

function void UART_test_base::end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);
  `uvm_info(get_type_name, "In the end_of_elaboration_phase of test", UVM_LOW)
  uvm_top.print_topology;
endfunction
