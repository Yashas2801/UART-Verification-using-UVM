class uart_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(uart_scoreboard)

  uvm_tlm_analysis_fifo #(UART_xtn) fifo_wrh[];
  UART_xtn wr_data1, wr_data2;
  env_config m_cfg;
  // Outcome flags for each test mode
  bit test_passed_fd;
  bit test_passed_hd;
  bit test_passed_lb;
  bit test_passed_pe;
  bit test_passed_fe;
  bit test_passed_be;
  bit test_passed_oe;
  bit test_passed_te;
  bit test_passed_thr;

  // Covergroup to track outcome flags
  covergroup test_outcome_cg;
    // For each flag, we create a coverpoint with two bins: pass (1) and fail (0)
    cp_fd: coverpoint test_passed_fd {
      bins pass = {1};
    }
    cp_hd: coverpoint test_passed_hd {bins pass = {1};}
    cp_lb: coverpoint test_passed_lb {bins pass = {1};}
    cp_pe: coverpoint test_passed_pe {bins pass = {1};}
    cp_fe: coverpoint test_passed_fe {bins pass = {1};}
    cp_be: coverpoint test_passed_be {bins pass = {1};}
    cp_oe: coverpoint test_passed_oe {bins pass = {1};}
    cp_te: coverpoint test_passed_te {bins pass = {1};}
    cp_thr: coverpoint test_passed_thr {bins pass = {1};}
  endgroup
  // Covergroup for Functional Coverage
  covergroup uart_coverage;
    addr_cp: coverpoint wr_data1.wb_addr_i {
      bins control_regs[] = {0, 1, 2, 3, 4};  // DLR, LCR, FCR, IER, THR,MCR
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
  test_outcome_cg = new();
  uart_coverage   = new();
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
  if (m_cfg.is_fd) begin

    `uvm_info("UART_SCOREBOARD", "Final Check for Full-Duplex Mode", UVM_MEDIUM)
    if ((wr_data1.thr[0] == wr_data2.rb[0]) && (wr_data2.thr[0] == wr_data1.rb[0])) begin
      `uvm_info("FULL_DUPLEX", "Final Check: Full-Duplex Data Match Successful", UVM_MEDIUM)
      test_passed_fd = 1;
    end else begin
      `uvm_error("FULL_DUPLEX", "Final Check: Data Mismatch in Full-Duplex Mode")
    end

  end else if (m_cfg.is_hd) begin
    `uvm_info("UART_SCOREBOARD", "Final Check for Half-Duplex Mode", UVM_MEDIUM)
    if (wr_data1.thr[0] == wr_data2.rb[0]) begin
      `uvm_info("HALF_DUPLEX", "Final Check: Half-Duplex Data Match Successful", UVM_MEDIUM)
      test_passed_hd = 1;
    end else begin
      `uvm_error("HALF_DUPLEX", "Final Check: Data Mismatch in Half-Duplex Mode")
    end
  end else if (m_cfg.is_lb) begin
    `uvm_info("UART_SCOREBOARD", "Final Check for Loopback Mode", UVM_MEDIUM)
    // In loopback mode, each UART should receive its own transmitted data.
    if ((wr_data1.thr[0] == wr_data1.rb[0]) && (wr_data2.thr[0] == wr_data2.rb[0])) begin
      `uvm_info("LOOPBACK", "Final Check: Loopback Data Match Successful for both Uarts",
                UVM_MEDIUM)
      test_passed_lb = 1;
    end else begin
      `uvm_error("LOOPBACK", "Final Check: Data Mismatch in Loopback Mode")
    end
  end else if (m_cfg.is_pe) begin
    `uvm_info("PARITY_CHECK", "Running Parity Error Check", UVM_MEDIUM)
    test_passed_pe = 1;

    if (wr_data1.lsr[2]) begin
      `uvm_info("PARITY_CHECK", "UART1: Parity error detected as expected", UVM_MEDIUM)
    end else begin
      `uvm_error("PARITY_CHECK", "UART1: Expected parity error but none detected")
      test_passed_pe = 0;
    end

    if (wr_data2.lsr[2]) begin
      `uvm_info("PARITY_CHECK", "UART2: Parity error detected as expected", UVM_MEDIUM)
    end else begin
      `uvm_error("PARITY_CHECK", "UART2: Expected parity error but none detected")
      test_passed_pe = 0;
    end
  end else if (m_cfg.is_fe) begin
    `uvm_info("FRAMING_CHECK", "Running Framing Error Check", UVM_MEDIUM)
    /*
    if (wr_data1.lsr[3]) begin
      `uvm_info("FRAMING_CHECK", "UART1: Framing error detected as expected", UVM_MEDIUM)
    end else begin
      `uvm_error("FRAMING_CHECK", "UART1: Expected framing error but none detected")
    end
*/
    if (wr_data2.lsr[3]) begin
      `uvm_info("FRAMING_CHECK", "UART2: Framing error detected as expected", UVM_MEDIUM)
      test_passed_fe = 1;
    end else begin
      `uvm_error("FRAMING_CHECK", "UART2: Expected framing error but none detected")
    end

  end else if (m_cfg.is_be) begin
    `uvm_info("BREAKINTERRUPT_CHECK", "Running Break Interrupt Error Check", UVM_MEDIUM)
    test_passed_be = 1;

    if (wr_data1.lsr[4]) begin
      `uvm_info("BREAKINTERRUPT_CHECK", "UART1: Break Interrupt error detected as expected",
                UVM_MEDIUM)
    end else begin
      `uvm_error("BREAKINTERRUPT_CHECK", "UART1: Expected break interrupt error but none detected")
      test_passed_be = 0;
    end

    if (wr_data2.lsr[4]) begin
      `uvm_info("BREAKINTERRUPT_CHECK", "UART2: Break Interrupt error detected as expected",
                UVM_MEDIUM)
    end else begin
      `uvm_error("BREAKINTERRUPT_CHECK", "UART2: Expected break interrupt error but none detected")
      test_passed_be = 0;
    end
  end else if (m_cfg.is_oe) begin
    `uvm_info("OVERRUN_CHECK", "Running Overrun Error Check", UVM_MEDIUM)

    test_passed_oe = 1;
    if (wr_data1.lsr[1]) begin
      `uvm_info("OVERRUN_CHECK", "UART1: Overrun error detected as expected", UVM_MEDIUM)
    end else begin
      `uvm_error("OVERRUN_CHECK", "UART1: Expected overrun error but none detected")
      test_passed_oe = 0;
    end

    if (wr_data2.lsr[1]) begin
      `uvm_info("OVERRUN_CHECK", "UART2: Overrun error detected as expected", UVM_MEDIUM)
    end else begin
      `uvm_error("OVERRUN_CHECK", "UART2: Expected overrun error but none detected")
      test_passed_oe = 0;
    end
  end else if (m_cfg.is_thr) begin
    `uvm_info("THR_EMPTY_CHECK", "Running THR Empty Check", UVM_MEDIUM)
    test_passed_thr = 1;

    if (wr_data1.lsr[5]) begin
      `uvm_info("THR_EMPTY_CHECK", "UART1: THR empty detected as expected", UVM_MEDIUM)
    end else begin
      `uvm_error("THR_EMPTY_CHECK", "UART1: Expected THR empty but none detected")
      test_passed_thr = 0;
    end

    if (wr_data2.lsr[5]) begin
      `uvm_info("THR_EMPTY_CHECK", "UART2: THR empty detected as expected", UVM_MEDIUM)
    end else begin
      `uvm_error("THR_EMPTY_CHECK", "UART2: Expected THR empty but none detected")
      test_passed_thr = 0;
    end
  end
  test_outcome_cg.sample();
endfunction

