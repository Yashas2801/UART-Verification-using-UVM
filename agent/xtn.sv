class UART_xtn extends uvm_sequence_item;
  `uvm_object_utils(UART_xtn)

  rand logic [4:0] wb_addr_i;
  rand logic [7:0] wb_dat_i;
  rand logic wb_we_i;
  rand logic wb_stb_i;
  rand logic wb_cyc_i;
  rand logic wb_sel_i;
  logic wb_rst_i;
  bit int_o;
  bit wb_dat_o;

  bit [7:0] ier;  // INTERRUPT_ENABLE_REGISTER
  bit [7:0] iir;  // INTERRUPT_IDENTIFICATION_REGISTER
  bit [7:0] fcr;  // FIFO_CONTROL_REGISTER
  bit [7:0] mcr;  // MODEM_CONTROL_REGISTER
  bit [7:0] lcr;  // LINE_CONTROL_REGISTER
  bit [7:0] msr;  // MODEM_STATUS_REGISTER
  bit [7:0] thr[$];  // TRANSMITTER_HOLDING_REGISTER
  bit [7:0] dlv;  // DLV_REGISTER
  bit [7:0] rb[$];  // RECEIVER_BUFFER
  bit [7:0] lsr;  // LINE_STATUS_REGISTER
  bit [7:0] dlb1;  // MSB_OF_DLB
  bit [7:0] dlb2;  // LSB_OF_DLB

  extern function new(string name = "UART_xtn");
  extern function void do_print(uvm_printer printer);

endclass

function UART_xtn::new(string name = "UART_xtn");
  super.new(name);
endfunction

function void UART_xtn::do_print(uvm_printer printer);
  super.do_print(printer);

  printer.print_field("wb_dat_i", this.wb_dat_i, 8, UVM_BIN);
  printer.print_field("wb_addr_i", this.wb_addr_i, 5, UVM_DEC);
  printer.print_field("wb_stb_i", this.wb_stb_i, 1, UVM_DEC);
  printer.print_field("wb_we_i", this.wb_we_i, 1, UVM_DEC);
  printer.print_field("wb_rst_i", this.wb_rst_i, 1, UVM_DEC);
  printer.print_field("wb_cyc_i", this.wb_cyc_i, 1, UVM_DEC);
  printer.print_field("lcr", this.lcr, 8, UVM_BIN);
  printer.print_field("fcr", this.fcr, 8, UVM_BIN);
  printer.print_field("lsr", this.lsr, 8, UVM_BIN);
  printer.print_field("mcr", this.mcr, 8, UVM_BIN);
  printer.print_field("iir", this.iir, 8, UVM_BIN);
  printer.print_field("ier", this.ier, 8, UVM_BIN);
  printer.print_field("msr", this.msr, 8, UVM_BIN);
  printer.print_field("dlb1", this.dlb1, 8, UVM_BIN);
  printer.print_field("dlb2", this.dlb2, 8, UVM_BIN);

  foreach (thr[i]) begin
    printer.print_field($sformatf("thr[%0d]", i), this.thr[i], 8, UVM_DEC);
  end

  foreach (rb[i]) begin
    printer.print_field($sformatf("rb[%0d]", i), this.rb[i], 8, UVM_DEC);
  end
endfunction

