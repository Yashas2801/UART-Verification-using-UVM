class UART_test_base extends uvm_test;
  `uvm_component_utils(UART_test_base)

  UART_env envh;
  env_config e_cfg;
  agent_config a_cfg[];

  bit has_agent = 1;
  bit has_virtual_sequencer = 1'b1;
  int no_of_agents = 2;

  bit is_fd;
  bit is_hd;
  bit is_lb;
  bit is_pe;
  bit is_fe;
  bit is_oe;
  bit is_be;

  byte unsigned i1 = 8'b1011_0010;  //'d178
  byte unsigned i2 = 8'b1111_0000;  //'d240

  virtual_seqs_base vseqs_base;
  full_duplex_vseq fd_vseq;
  half_duplex_vseq hd_vseq;
  loopback_vseq lb_vseq;
  parity_error_vseq pe_vseq;
  framing_error_vseq fe_vseq;
  overrun_error_vseq oe_vseq;
  breakinterrupt_error_vseq be_vseq;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void end_of_elaboration_phase(uvm_phase phase);
  extern function void uart_config();
  extern task run_phase(uvm_phase phase);
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

  e_cfg.has_virtual_sequencer = has_virtual_sequencer;
  e_cfg.has_agent = has_agent;
  e_cfg.no_of_agents = no_of_agents;
  e_cfg.i1 = i1;
  e_cfg.i2 = i2;

  e_cfg.is_fd = is_fd;
  e_cfg.is_hd = is_hd;
  e_cfg.is_lb = is_lb;
  e_cfg.is_pe = is_pe;
  e_cfg.is_fe = is_fe;
  e_cfg.is_oe = is_oe;
  e_cfg.is_be = is_be;

  uvm_config_db#(env_config)::set(this, "*", "env_config", e_cfg);

  envh = UART_env::type_id::create("envh", this);

endfunction

function void UART_test_base::end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);
  `uvm_info(get_type_name, "In the end_of_elaboration_phase of test", UVM_LOW)
  uvm_top.print_topology;
endfunction

task UART_test_base::run_phase(uvm_phase phase);
  super.run_phase(phase);
  vseqs_base = virtual_seqs_base::type_id::create("vseqs_base");
  phase.raise_objection(this);
  vseqs_base.start(envh.vseqrh);
  phase.drop_objection(this);
endtask


class full_duplex_test extends UART_test_base;
  `uvm_component_utils(full_duplex_test)

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
endclass

function full_duplex_test::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void full_duplex_test::build_phase(uvm_phase phase);
  is_fd = 1;
  super.build_phase(phase);
  `uvm_info(get_type_name, "In the build_phase of full_duplex_test", UVM_LOW)
endfunction

task full_duplex_test::run_phase(uvm_phase phase);
  fd_vseq = full_duplex_vseq::type_id::create("fd_vseq");
  phase.raise_objection(this);
  fd_vseq.start(envh.vseqrh);
  phase.drop_objection(this);
endtask

class half_duplex_test extends UART_test_base;
  `uvm_component_utils(half_duplex_test)

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
endclass

function half_duplex_test::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void half_duplex_test::build_phase(uvm_phase phase);
  is_hd = 1;
  super.build_phase(phase);
  `uvm_info(get_type_name, "In the build_phase of half_duplex_test", UVM_LOW)
endfunction

task half_duplex_test::run_phase(uvm_phase phase);
  hd_vseq = half_duplex_vseq::type_id::create("hd_vseq");
  phase.raise_objection(this);
  hd_vseq.start(envh.vseqrh);
  phase.drop_objection(this);
endtask

class loopback_test extends UART_test_base;
  `uvm_component_utils(loopback_test)

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
endclass

function loopback_test::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void loopback_test::build_phase(uvm_phase phase);
  is_lb = 1;
  super.build_phase(phase);
  `uvm_info(get_type_name, "In the build_phase of loopback_test", UVM_LOW)
endfunction

task loopback_test::run_phase(uvm_phase phase);
  lb_vseq = loopback_vseq::type_id::create("lb_vseq");
  phase.raise_objection(this);
  lb_vseq.start(envh.vseqrh);
  phase.drop_objection(this);
endtask

class parity_error_test extends UART_test_base;
  `uvm_component_utils(parity_error_test)

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
endclass

function parity_error_test::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void parity_error_test::build_phase(uvm_phase phase);
  is_pe = 1;
  super.build_phase(phase);
  `uvm_info(get_type_name, "In the build_phase of parity_error_test", UVM_LOW)
endfunction

task parity_error_test::run_phase(uvm_phase phase);
  pe_vseq = parity_error_vseq::type_id::create("pe_vseq");
  phase.raise_objection(this);
  pe_vseq.start(envh.vseqrh);
  phase.drop_objection(this);
endtask

class framing_error_test extends UART_test_base;
  `uvm_component_utils(framing_error_test)

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
endclass

function framing_error_test::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void framing_error_test::build_phase(uvm_phase phase);
  is_fe = 1;
  super.build_phase(phase);
  `uvm_info(get_type_name, "In the build_phase of framing_error_test", UVM_LOW)
endfunction

task framing_error_test::run_phase(uvm_phase phase);
  fe_vseq = framing_error_vseq::type_id::create("fe_vseq");
  phase.raise_objection(this);
  fe_vseq.start(envh.vseqrh);
  phase.drop_objection(this);
endtask

class overrun_error_test extends UART_test_base;
  `uvm_component_utils(overrun_error_test)

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
endclass

function overrun_error_test::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void overrun_error_test::build_phase(uvm_phase phase);
  is_oe = 1;
  super.build_phase(phase);
  `uvm_info(get_type_name, "In the build_phase of overrun_error_test", UVM_LOW)
endfunction

task overrun_error_test::run_phase(uvm_phase phase);
  oe_vseq = overrun_error_vseq::type_id::create("oe_vseq");
  phase.raise_objection(this);
  oe_vseq.start(envh.vseqrh);
  phase.drop_objection(this);
endtask

class breakinterrupt_error_test extends UART_test_base;
  `uvm_component_utils(breakinterrupt_error_test)

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
endclass


function breakinterrupt_error_test::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void breakinterrupt_error_test::build_phase(uvm_phase phase);
  is_be = 1;
  super.build_phase(phase);
  `uvm_info(get_type_name, "In the build_phase of breakinterrupt_error_test", UVM_LOW)
endfunction

task breakinterrupt_error_test::run_phase(uvm_phase phase);
  be_vseq = breakinterrupt_error_vseq::type_id::create("be_vseq");
  phase.raise_objection(this);
  be_vseq.start(envh.vseqrh);
  phase.drop_objection(this);
endtask

