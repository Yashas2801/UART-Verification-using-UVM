class uart_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(uart_scoreboard)

  uvm_tlm_analysis_fifo #(UART_xtn) fifo_wrh[];
  UART_xtn wr_data1, wr_data2;
  env_config m_cfg;

  // Covergroup for Functional Coverage
  covergroup uart_coverage;
    addr_cp: coverpoint wr_data1.wb_addr_i {
      bins control_regs[] = {0, 1, 2, 3};  // DLR, LCR, FCR, IER, THR
    }

    write_enable_cp: coverpoint wr_data1.wb_we_i {bins enabled = {1}; bins disabled = {0};}

    strobe_cp: coverpoint wr_data1.wb_stb_i {bins active = {1}; bins inactive = {0};}

    cycle_cp: coverpoint wr_data1.wb_cyc_i {bins active = {1}; bins inactive = {0};}

    iir_cp: coverpoint wr_data1.iir[3:1] {
      bins rx_interrupt = {3'b010};  // Receiver Buffer Full Interrupt
    }

  endgroup

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern function void check_phase(uvm_phase phase);
endclass

function uart_scoreboard::new(string name, uvm_component parent);
  super.new(name, parent);
  uart_coverage = new();  // Instantiate covergroup
endfunction

function void uart_scoreboard::build_phase(uvm_phase phase);
  if (!uvm_config_db#(env_config)::get(this, "", "env_config", m_cfg))
    `uvm_fatal("CONFIG", "Cannot get() m_cfg from uvm_config_db. Have you set() it?")

  fifo_wrh = new[m_cfg.no_of_agents];

  foreach (fifo_wrh[i]) begin
    fifo_wrh[i] = new($sformatf("fifo_wrh[%0d]", i), this);
  end

  wr_data1 = UART_xtn::type_id::create("wr_data1");
  wr_data2 = UART_xtn::type_id::create("wr_data2");
endfunction

task uart_scoreboard::run_phase(uvm_phase phase);
  fork
    forever begin
      fifo_wrh[0].get(wr_data1);
      fifo_wrh[1].get(wr_data2);
      //      `uvm_info(get_type_name, $sformatf("xtn1 =%s ", wr_data1.sprint()), UVM_LOW)
      //     `uvm_info(get_type_name, $sformatf("xtn2 =%s ", wr_data2.sprint()), UVM_LOW)

      uart_coverage.sample();  // Collect coverage data

    end
  join
endtask

function void uart_scoreboard::check_phase(uvm_phase phase);
  `uvm_info("UART_SCOREBOARD", "Final Check for Full-Duplex Mode", UVM_MEDIUM)

  if ((wr_data1.thr[0] == wr_data2.rb[0]) && (wr_data2.thr[0] == wr_data1.rb[0])) begin
    `uvm_info("FULL_DUPLEX", "Final Check: Full-Duplex Data Match Successful", UVM_MEDIUM)
  end else begin
    `uvm_error("FULL_DUPLEX", "Final Check: Data Mismatch in Full-Duplex Mode")
  end
endfunction

