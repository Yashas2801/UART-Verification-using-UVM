class UART_agent extends uvm_agent;
  `uvm_component_utils(UART_agent)

  agent_config a_cfg;

  UART_driver drvh;
  UART_monitor monh;
  UART_sequencer seqrh;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
endclass

function UART_agent::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void UART_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info(get_type_name, "In the build_phase of agent", UVM_LOW)

  if (!uvm_config_db#(agent_config)::get(this, "", "agent_config", a_cfg))
    `uvm_fatal(get_type_name, "Failed to get a_cfg in agent")

  monh = UART_monitor::type_id::create("monh", this);

  if (a_cfg.is_active == UVM_ACTIVE) begin
    drvh  = UART_driver::type_id::create("drvh", this);
    seqrh = UART_sequencer::type_id::create("seqrh", this);
  end
endfunction

function void UART_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  `uvm_info(get_type_name, "In the connect_phase of agent", UVM_LOW)
endfunction


