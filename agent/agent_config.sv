class agent_config extends uvm_object;

  `uvm_object_utils(agent_config)

  virtual uart_if vif;
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  static int mon_rcvd_xtn_cnt = 0;
  static int drv_data_sent_cnt = 0;

  function new(string name = "agent_config");
    super.new(name);
  endfunction

endclass
