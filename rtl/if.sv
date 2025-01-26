interface uart_if (
    input bit clock
);

  /////////////////////// WISHBONE SIGNALS /////////////////////////////////
  logic [4:0] wb_addr_i;  // Wishbone address input
  logic [31:0] wb_dat_i, wb_dat_o;  // Wishbone data input/output
  bit [3:0] wb_sel_i;  // Wishbone select input
  bit wb_we_i, wb_stb_i, wb_cyc_i;  // Wishbone control signals
  bit   wb_ack_o;  // Wishbone acknowledge output
  logic wb_rst_i;  // Wishbone reset input
  bit   wb_clk_i;  // Wishbone clock input

  /////////////////////// UART MODEM SIGNALS ///////////////////////////////
  bit   int_o;  // Interrupt output
  bit   baud_o;  // Baud rate clock output
  bit   stx_pad_o;  // Serial transmit pad output
  bit   srx_pad_i;  // Serial receive pad input
  bit rts_pad_o, cts_pad_i;  // Request-to-send, Clear-to-send
  bit dtr_pad_o, dsr_pad_i;  // Data-terminal-ready, Data-set-ready
  bit ri_pad_i, dcd_pad_i;  // Ring indicator, Data carrier detect

  /////////////////////// CLOCKING BLOCKS //////////////////////////////////
  // Clocking block for driving signals
  clocking wr_cb @(posedge clock);
    default input #1 output #0;
    output wb_addr_i;
    output wb_dat_i;
    output wb_we_i;
    output wb_sel_i;
    output wb_rst_i;
    output wb_cyc_i;
    output wb_stb_i;
    input wb_ack_o;
    input int_o;
    input wb_dat_o;
  endclocking

  // Clocking block for monitoring signals
  clocking wr_mon_cb @(posedge clock);
    default input #1 output #0;
    input wb_addr_i;
    input wb_dat_i;
    input wb_we_i;
    input wb_sel_i;
    input wb_rst_i;
    input wb_cyc_i;
    input wb_stb_i;
    input wb_ack_o;
    input int_o;
    input wb_dat_o;
  endclocking

  /////////////////////// MODPORTS /////////////////////////////////////////
  modport WR_DR(clocking wr_cb);  // Drive signals
  modport WR_MON(clocking wr_mon_cb);  // Monitor signals

endinterface
