class virtual_seqs_base extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(virtual_seqs_base)

  env_config e_cfg;

  virtual_sequencer vseqrh;
  UART_sequencer seqrh[];

  UART_sequence_base seqh[];

  full_duplex_seq1 fd_seq1;
  full_duplex_seq2 fd_seq2;

  half_duplex_seq1 hd_seq1;
  half_duplex_seq2 hd_seq2;

  loopback_seq1 lb_seq1;
  loopback_seq2 lb_seq2;

  parity_error_seq1 pe_seq1;
  parity_error_seq2 pe_seq2;

  extern function new(string name = "virtual_seqs_base");
  extern task body;
endclass

function virtual_seqs_base::new(string name = "virtual_seqs_base");
  super.new(name);
endfunction

task virtual_seqs_base::body;
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
  fd_seq1 = full_duplex_seq1::type_id::create("fd_seq1");
  fd_seq2 = full_duplex_seq2::type_id::create("fd_seq2");
  fork
    fd_seq1.start(seqrh[0]);
    fd_seq2.start(seqrh[1]);
  join
endtask

class half_duplex_vseq extends virtual_seqs_base;
  `uvm_object_utils(half_duplex_vseq)
  extern function new(string name = "half_duplex_vseq");
  extern task body;
endclass

function half_duplex_vseq::new(string name = "half_duplex_vseq");
  super.new(name);
endfunction

task half_duplex_vseq::body;
  super.body();
  `uvm_info(get_type_name, "In the body of half_duplex", UVM_LOW)
  hd_seq1 = half_duplex_seq1::type_id::create("hd_seq1");
  hd_seq2 = half_duplex_seq2::type_id::create("hd_seq2");
  begin
    hd_seq1.start(seqrh[0]);
    #10;
    // hd_seq1.hd_event.wait_trigger;
    hd_seq2.start(seqrh[1]);
  end
endtask

class loopback_vseq extends virtual_seqs_base;
  `uvm_object_utils(loopback_vseq)
  extern function new(string name = "loopback_vseq");
  extern task body;
endclass

function loopback_vseq::new(string name = "loopback_vseq");
  super.new(name);
endfunction

task loopback_vseq::body;
  super.body();
  `uvm_info(get_type_name, "In the body of loopback", UVM_LOW)
  lb_seq1 = loopback_seq1::type_id::create("lb_seq1");
  lb_seq2 = loopback_seq2::type_id::create("lb_seq2");
  fork
    lb_seq1.start(seqrh[0]);
    lb_seq2.start(seqrh[1]);
  join
endtask

class parity_error_vseq extends virtual_seqs_base;
  `uvm_object_utils(parity_error_vseq)
  extern function new(string name = "parity_error_vseq");
  extern task body;
endclass

function parity_error_vseq::new(string name = "parity_error_vseq");
  super.new(name);
endfunction

task parity_error_vseq::body;
  super.body();
  `uvm_info(get_type_name, "In the body of parity_error", UVM_LOW)
  pe_seq1 = parity_error_seq1::type_id::create("pe_seq1");
  pe_seq2 = parity_error_seq2::type_id::create("pe_seq2");
  fork
    pe_seq1.start(seqrh[0]);
    pe_seq2.start(seqrh[1]);
  join
endtask
