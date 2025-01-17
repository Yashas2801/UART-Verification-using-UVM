class env_config extends uvm_object;
  `uvm_object_utils(env_config)

  virtual UART_interface vif;
  uvm_active_passive_enum is_active;
  int no_of_agents;

  function new(string name = "env_config");
    super.new(name);
  endfunction

endclass
