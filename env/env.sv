class UART_env extends uvm_env;

  `uvm_component_utils(UART_env)

  env_config e_cfg;
  UART_agent agth  [];

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
endclass

function UART_env::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void UART_env::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info(get_type_name, "In the build_phase of env", UVM_LOW)

  if (!uvm_config_db#(env_config)::get(this, "", "e_cfg", e_cfg))
    `uvm_fatal(get_type_name, "Failed to get e_cfg in env")

  agth = new[e_cfg.no_of_agents];
  foreach (agth[i]) begin
    agth[i] = UART_agent::type_id::create($sformatf("agth[%0d]", i), this);
  end
endfunction
