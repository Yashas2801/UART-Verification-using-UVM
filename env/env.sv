class UART_env extends uvm_env;

  `uvm_component_utils(UART_env)

  env_config e_cfg;
  UART_agent agth[];
  virtual_sequencer vseqrh;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
endclass

function UART_env::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void UART_env::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info(get_type_name, "In the build_phase of env", UVM_LOW)

  if (!uvm_config_db#(env_config)::get(this, "", "env_config", e_cfg))
    `uvm_fatal(get_type_name, "Failed to get e_cfg in env")

  agth = new[e_cfg.no_of_agents];
  //`uvm_info(get_type_name, $sformatf("No of agents in env = %0d ", e_cfg.no_of_agents), UVM_LOW)

  foreach (agth[i]) begin
    agth[i] = UART_agent::type_id::create($sformatf("agth[%0d]", i), this);
    //    `uvm_info(get_type_name, $sformatf("is_active = %s", e_cfg.a_cfg[0].is_active), UVM_LOW)
    uvm_config_db#(agent_config)::set(this, $sformatf("agth[%0d]*", i), "agent_config",
                                      e_cfg.a_cfg[i]);
  end

  vseqrh = virtual_sequencer::type_id::create("vseqrh", this);
endfunction


function void UART_env::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  `uvm_info(get_type_name, "In the connect phase of env", UVM_LOW)

  for (int i = 0; i < e_cfg.no_of_agents; i++) begin
    vseqrh.seqrh[i] = agth[i].seqrh;
  end
endfunction
