class UART_driver extends uvm_driver #(UART_xtn);

  `uvm_component_utils(UART_driver)
  virtual uart_if vif;
  agent_config a_cfg;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern task drive_task(UART_xtn xtn);
  extern task run_phase(uvm_phase phase);
endclass

function UART_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void UART_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info(get_type_name, "In build_phase of driver", UVM_LOW)
  if (!uvm_config_db#(agent_config)::get(this, "", "agent_config", a_cfg))
    `uvm_fatal(get_type_name, "failed to get a_cfg in driver")
endfunction

function void UART_driver::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  `uvm_info(get_type_name, "In the connect phase of driver", UVM_LOW)
  vif = a_cfg.vif;
endfunction

task UART_driver::drive_task(UART_xtn xtn);
  `uvm_info(get_type_name, "Driving task enabled", UVM_LOW)
  `uvm_info("WR_DRIVER", $sformatf("printing from write driver \n %s", xtn.sprint()), UVM_LOW)

  @(vif.wr_cb);
  vif.wr_cb.wb_addr_i <= xtn.wb_addr_i;
  vif.wr_cb.wb_dat_i  <= xtn.wb_dat_i;
  /*NOTE:
 * WB_SEL_I: Byte select signal in Wishbone protocol.
 * For 8-bit data width, only the lowest byte is accessed.
 * In this case, WB_SEL_I = 4'b0001.
 * Each bit in WB_SEL_I corresponds to one byte:
 * - WB_SEL_I[0]: Selects the lowest byte (active in 8-bit systems).
 * - WB_SEL_I[1]: Selects the second byte.
 * - WB_SEL_I[2]: Selects the third byte.
 * - WB_SEL_I[3]: Selects the highest byte.
 * Since the data width is 8 bits, only WB_SEL_I[0] is used.
 */
  vif.wr_cb.wb_sel_i  <= 4'b0001;
  vif.wr_cb.wb_we_i   <= xtn.wb_we_i;
  vif.wr_cb.wb_stb_i  <= 1'b1;
  vif.wr_cb.wb_cyc_i  <= 1'b1;
  wait (vif.wr_cb.wb_ack_o)
    //wait for ack
    vif.wr_cb.wb_stb_i <= 1'b0;
  vif.wr_cb.wb_cyc_i <= 1'b0;

  //NOTE: We are checking if iir is selected by the wishbone master
  if (xtn.wb_addr_i == 2 && xtn.wb_we_i == 0) begin

    wait (vif.wr_cb.int_o)
      //Delay
      @(vif.wr_cb);

    xtn.iir = vif.wr_cb.wb_dat_o;
    $display("the value of iir is :%b ", vif.wr_cb.wb_dat_o);
    seq_item_port.put_response(xtn);
  end
endtask

task UART_driver::run_phase(uvm_phase phase);
  super.run_phase(phase);
  `uvm_info(get_type_name, "In the run phase of driver", UVM_LOW)

  @(vif.wr_cb);
  vif.wr_cb.wb_rst_i <= 1'b1;
  @(vif.wr_cb);
  vif.wr_cb.wb_rst_i <= 1'b0;


  forever begin
    seq_item_port.get_next_item(req);
    drive_task(req);
    seq_item_port.item_done();
  end

endtask
