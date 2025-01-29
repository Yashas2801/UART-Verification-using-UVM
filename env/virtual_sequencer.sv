class virtual_sequencer extends uvm_sequencer #(uvm_sequence_item);
  `uvm_component_utils(virtual_sequencer)

  UART_sequencer seqrh[];
  env_config e_cfg;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
endclass

function virtual_sequencer::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void virtual_sequencer::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info(get_type_name, "In the build_phase of v_seqr", UVM_LOW)

  if (!uvm_config_db#(env_config)::get(this, "", "env_config", e_cfg))
    `uvm_fatal(get_type_name, "failed to get env_config in v_seqr")

  seqrh = new[e_cfg.no_of_agents];

endfunction
