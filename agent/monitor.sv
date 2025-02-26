class UART_monitor extends uvm_monitor;

  `uvm_component_utils(UART_monitor)

  virtual uart_if vif;
  agent_config a_cfg;

  UART_xtn xtn;

  uvm_analysis_port #(UART_xtn) ana_port;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task monitor;
endclass

function UART_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void UART_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info(get_type_name, "In the build phase of monitor", UVM_LOW)

  if (!uvm_config_db#(agent_config)::get(this, "", "agent_config", a_cfg))
    `uvm_fatal(get_type_name, "failed to get agent config in monitor")

  xtn = UART_xtn::type_id::create("xtn");
  ana_port = new("ana_port", this);
endfunction

function void UART_monitor::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  `uvm_info(get_type_name, "In the connect phase of monitor", UVM_LOW)
  vif = a_cfg.vif;
endfunction

task UART_monitor::run_phase(uvm_phase phase);
  super.run_phase(phase);
  forever monitor;
endtask

task UART_monitor::monitor();

  `uvm_info(get_type_name, "Monitor task enabled", UVM_LOW)
  @(vif.wr_mon_cb);
  wait (vif.wr_mon_cb.wb_ack_o);
  xtn.wb_rst_i = vif.wr_mon_cb.wb_rst_i;
  xtn.wb_stb_i = vif.wr_mon_cb.wb_stb_i;
  xtn.wb_cyc_i = vif.wr_mon_cb.wb_cyc_i;
  xtn.wb_addr_i = vif.wr_mon_cb.wb_addr_i;
  xtn.wb_dat_i = vif.wr_mon_cb.wb_dat_i;
  xtn.wb_we_i = vif.wr_mon_cb.wb_we_i;
  xtn.int_o = vif.wr_mon_cb.int_o;
  xtn.wb_dat_o = vif.wr_mon_cb.wb_dat_o;

  //NOTE: read buffer
  if (xtn.wb_addr_i == 0 && xtn.wb_we_i == 0 && xtn.lcr[7] == 0)
    xtn.rb.push_back(vif.wr_mon_cb.wb_dat_o);

  //NOTE: transmittor register
  if (xtn.wb_addr_i == 0 && xtn.wb_we_i == 1 && xtn.lcr[7] == 0)
    xtn.thr.push_back(vif.wr_mon_cb.wb_dat_i);

  if (xtn.wb_addr_i == 1 && xtn.wb_we_i == 1) xtn.ier = vif.wr_mon_cb.wb_dat_i;

  if (xtn.wb_addr_i == 2 && xtn.wb_we_i == 0) xtn.iir = vif.wr_mon_cb.wb_dat_i;

  if (xtn.wb_addr_i == 2 && xtn.wb_we_i == 1) xtn.fcr = vif.wr_mon_cb.wb_dat_i;

  if (xtn.wb_addr_i == 3 && xtn.wb_we_i == 1) xtn.lcr = vif.wr_mon_cb.wb_dat_i;

  if (xtn.wb_addr_i == 4 && xtn.wb_we_i == 1) xtn.mcr = vif.wr_mon_cb.wb_dat_i;

  if (xtn.wb_addr_i == 5 && xtn.wb_we_i == 0) xtn.lsr = vif.wr_mon_cb.wb_dat_i;

  if (xtn.wb_addr_i == 6 && xtn.wb_we_i == 1) xtn.msr = vif.wr_mon_cb.wb_dat_i;

  if (xtn.wb_addr_i == 0 && xtn.wb_we_i == 1 && xtn.lcr[7] == 1) xtn.dlb1 = vif.wr_mon_cb.wb_dat_i;

  if (xtn.wb_addr_i == 1 && xtn.wb_we_i == 1 && xtn.lcr[7] == 1) xtn.dlb2 = vif.wr_mon_cb.wb_dat_i;

  `uvm_info("WR_MONITOR", $sformatf("printing from write monitor \n %s", xtn.sprint()), UVM_LOW)

  ana_port.write(xtn);
endtask
