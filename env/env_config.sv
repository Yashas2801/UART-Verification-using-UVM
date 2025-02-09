class env_config extends uvm_object;
  `uvm_object_utils(env_config)

  bit has_agent = 1;
  int no_of_agents;
  byte unsigned i1 = 'b1001_1101;
  byte unsigned i2 = 'b1111_0000;

  bit has_functional_coverage = 0;
  bit has_scoreboard = 1;

  bit is_fd;
  bit is_hd;
  bit is_lb;
  bit is_pe;

  bit has_virtual_sequencer = 1;

  agent_config a_cfg[];

  function new(string name = "env_config");
    super.new(name);
  endfunction

endclass
