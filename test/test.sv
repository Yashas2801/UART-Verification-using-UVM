class UART_test_base extends uvm_test;
  `uvm_component_utils(UART_test_base)

  UART_env envh;
  env_config e_cfg;
  agent_config a_cfg[];

  bit has_agent = 1;
  int no_of_agents = 2;

  byte unsigned i1 = 8'b1011_0010;
  byte unsigned i2 = 8'b1111_0000;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void end_of_elaboration_phase(uvm_phase phase);
  extern function void uart_config();
endclass

function UART_test_base::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void UART_test_base::uart_config;
  if (has_agent) begin
    a_cfg = new[no_of_agents];

    foreach (a_cfg[i]) begin
      a_cfg[i] = agent_config::type_id::create($sformatf("a_cfg[%0d]", i));

      if (!uvm_config_db#(virtual uart_if)::get(this, "", $sformatf("vif_%0d", i), a_cfg[i].vif))
        `uvm_fatal(get_type_name, "failed to set vif in test")

      a_cfg[i].is_active = UVM_ACTIVE;
      e_cfg.a_cfg[i] = a_cfg[i];
    end
  end
endfunction


function void UART_test_base::build_phase(uvm_phase phase);
  super.build_phase(phase);

  `uvm_info(get_type_name, "In the build phase of test", UVM_LOW)

  e_cfg = env_config::type_id::create("e_cfg");

  if (has_agent) e_cfg.a_cfg = new[no_of_agents];

  uart_config;

  e_cfg.has_agent = has_agent;
  e_cfg.no_of_agents = no_of_agents;
  e_cfg.i1 = i1;
  e_cfg.i2 = i2;
  uvm_config_db#(env_config)::set(this, "*", "env_config", e_cfg);

  envh = UART_env::type_id::create("envh", this);

endfunction

function void UART_test_base::end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);
  `uvm_info(get_type_name, "In the end_of_elaboration_phase of test", UVM_LOW)
  uvm_top.print_topology;
endfunction
