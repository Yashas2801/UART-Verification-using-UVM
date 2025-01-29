class virtual_seqs_base extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(virtual_seqs_base)

  env_config e_cfg;

  virtual_sequencer vseqrh;
  UART_sequencer seqrh[];

  UART_sequence_base seqh[];

  extern function new(string name = "virtual_seqs_base");
  extern task body;
endclass

function virtual_seqs_base::new(string name = "virtual_seqs_base");
  super.new(name);
endfunction

task virtual_seqs_base::body;
  `uvm_info(get_type_name, "In the task body of base v_seqs", UVM_LOW)

  if (!uvm_config_db#(env_config)::get(null, get_full_name(), "env_config", e_cfg))
    `uvm_fatal(get_type_name, "failed to get e_cfg in v_seqs")

  seqrh = new[e_cfg.no_of_agents];

  assert ($cast(vseqrh, m_sequencer))
  else `uvm_error(get_type_name, "error while assigning m_sequencer")

  foreach (seqrh[i]) begin
    seqrh[i] = vseqrh.seqrh[i];
  end
endtask

class full_duplex_vseq extends virtual_seqs_base;
  `uvm_object_utils(full_duplex_vseq)
  extern function new(string name = "full_duplex_vseq");
  extern task body;
endclass

function full_duplex_vseq::new(string name = "full_duplex_vseq");
  super.new(name);
endfunction

task full_duplex_vseq::body;
  super.body();
  `uvm_info(get_type_name, "In the body of full_duplex", UVM_LOW)

endtask
