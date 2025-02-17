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

  /////////////////////coverage lcr////////////
  //
  bit [7:0] lcr_val;
  covergroup lcr_usage_cg;
    option.per_instance = 1;

    // Word Length bits [1:0]
    cp_word_length: coverpoint lcr_val[1:0] {
      bins default_val = {0};  // 2'b00 => 5 bits
      bins used_vals = {[1 : 3]};  // covers 2'b01, 2'b10, 2'b11
    }

    // Stop bit (bit 2)
    cp_stop_bit: coverpoint lcr_val[2] {
      bins default_val = {1'b0};  // one stop bit
      bins used_val = {1'b1};  // two stop bits
    }

    // Parity Enable (bit 3)
    cp_parity_en: coverpoint lcr_val[3] {
      bins default_val = {1'b0}; bins used_val = {1'b1};
    }

    // Even Parity (bit 4)
    cp_even_parity: coverpoint lcr_val[4] {
      bins default_val = {1'b0}; bins used_val = {1'b1};
    }

    // Skip bit 5 (Stick Parity) intentionally

    // Break Control (bit 6)
    cp_break_ctrl: coverpoint lcr_val[6] {
      bins default_val = {1'b0}; bins used_val = {1'b1};
    }

    // Divisor Latch Access (bit 7)
    cp_dlab: coverpoint lcr_val[7] {
      bins default_val = {1'b0}; bins used_val = {1'b1};
    }
  endgroup : lcr_usage_cg
  ///////////////////////////////////////////////////////////////

  /////////////////////coverage ier/////////////////////////////
  bit [7:0] ier_val;
  covergroup ier_usage_cg;
    option.per_instance = 1;

    // Bit 0: Received Data Available Interrupt Enable
    cp_rda_ie: coverpoint ier_val[0] {
      bins disabled = {1'b0}; bins enabled = {1'b1};
    }

    // Bit 1: Transmitter Holding Register Empty Interrupt Enable
    cp_thre_ie: coverpoint ier_val[1] {
      bins disabled = {1'b0}; bins enabled = {1'b1};
    }

    // Bit 2: Receiver Line Status Interrupt Enable
    cp_lsr_ie: coverpoint ier_val[2] {
      bins disabled = {1'b0}; bins enabled = {1'b1};
    }

  endgroup : ier_usage_cg
  //////////////////////////////////////////////////////////////


  //////////////////////////cg fcr/////////////////////////////
  bit [7:0] fcr_val;
  covergroup fcr_usage_cg;
    option.per_instance = 1;

    // Bit 1: RX FIFO reset
    cp_rx_fifo_reset: coverpoint fcr_val[1] {
      bins reset = {1'b1};
    }

    // Bit 2: TX FIFO reset
    cp_tx_fifo_reset: coverpoint fcr_val[2] {
      bins reset = {1'b1};
    }

    // Bits [7:6]: FIFO Trigger Level
    cp_fifo_trigger: coverpoint fcr_val[7:6] {
      bins level_1 = {2'b00};  // '00' => 1 byte
      bins level_4 = {2'b01};  // '01' => 4 bytes
      bins level_8 = {2'b10};  // '10' => 8 bytes
      bins level_14 = {2'b11};  // '11' => 14 bytes
    }

  endgroup : fcr_usage_cg

  /////////////////////////////////////////////////////////////
  //NOTE: MCR coverage

  bit [7:0] mcr_val;
  covergroup mcr_usage_cg;
    option.per_instance = 1;

    // Bit 4: Loopback Mode
    cp_loopback: coverpoint mcr_val[4] {
      bins loopback = {1'b1};  // 1 => loopback mode
    }

  endgroup : mcr_usage_cg

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


  endgroup


  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern function void check_phase(uvm_phase phase);
endclass

function uart_scoreboard::new(string name, uvm_component parent);
  super.new(name, parent);
  test_outcome_cg = new();
  uart_coverage = new();
  lcr_usage_cg = new();
  ier_usage_cg = new();
  fcr_usage_cg = new();
  mcr_usage_cg = new();
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
      `uvm_info(get_type_name, $sformatf("xtn1 =%s ", wr_data1.sprint()), UVM_LOW)
      `uvm_info(get_type_name, $sformatf("xtn2 =%s ", wr_data2.sprint()), UVM_LOW)

      uart_coverage.sample();  // Collect coverage data

      // Sample LCR coverage from wr_data1, if conditions met
      if ((wr_data1.wb_addr_i == 3) &&
          (wr_data1.wb_we_i == 1)   &&
          (wr_data1.wb_stb_i == 1)  &&
          (wr_data1.wb_cyc_i == 1)) begin
        //`uvm_info("SCOREBOARD_DEBUG", $sformatf(
        //         "Sampling LCR coverage with wr_data1=0x%0h", wr_data1.wb_dat_i), UVM_LOW);
        lcr_val = wr_data1.wb_dat_i;
        lcr_usage_cg.sample();
      end

      // Also sample LCR coverage from wr_data2, if conditions met
      if ((wr_data2.wb_addr_i == 3) &&
          (wr_data2.wb_we_i == 1)   &&
          (wr_data2.wb_stb_i == 1)  &&
          (wr_data2.wb_cyc_i == 1)) begin
        //`uvm_info("SCOREBOARD_DEBUG", $sformatf(
        //         "Sampling LCR coverage with wr_data2=0x%0h", wr_data2.wb_dat_i), UVM_LOW);
        lcr_val = wr_data2.wb_dat_i;
        lcr_usage_cg.sample();
      end
      //NOTE: ier sample
      if ((wr_data1.wb_addr_i == 1) &&
          (wr_data1.wb_we_i == 1)   &&
          (wr_data1.wb_stb_i == 1)  &&
          (wr_data1.wb_cyc_i == 1)) begin

        ier_val = wr_data1.wb_dat_i;
        ier_usage_cg.sample();  // sample coverage for bits 0..2
      end

      if ((wr_data2.wb_addr_i == 1) &&
          (wr_data2.wb_we_i == 1)   &&
          (wr_data2.wb_stb_i == 1)  &&
          (wr_data2.wb_cyc_i == 1)) begin

        ier_val = wr_data2.wb_dat_i;
        ier_usage_cg.sample();
      end

      //NOTE:fcr sample

      if ((wr_data1.wb_addr_i == 2) &&
    (wr_data1.wb_we_i   == 1) &&
    (wr_data1.wb_stb_i  == 1) &&
    (wr_data1.wb_cyc_i  == 1)) begin
        fcr_val = wr_data1.wb_dat_i;
        fcr_usage_cg.sample();
      end

      if ((wr_data2.wb_addr_i == 2) &&
    (wr_data2.wb_we_i   == 1) &&
    (wr_data2.wb_stb_i  == 1) &&
    (wr_data2.wb_cyc_i  == 1)) begin
        fcr_val = wr_data2.wb_dat_i;
        fcr_usage_cg.sample();
      end

      //NOTE: Mcr sample
      if ((wr_data1.wb_addr_i == 4) &&
    (wr_data1.wb_we_i   == 1) &&
    (wr_data1.wb_stb_i  == 1) &&
    (wr_data1.wb_cyc_i  == 1)) begin

        mcr_val = wr_data1.wb_dat_i;
        mcr_usage_cg.sample();
      end

      if ((wr_data2.wb_addr_i == 4) &&
    (wr_data2.wb_we_i   == 1) &&
    (wr_data2.wb_stb_i  == 1) &&
    (wr_data2.wb_cyc_i  == 1)) begin

        mcr_val = wr_data2.wb_dat_i;
        mcr_usage_cg.sample();
      end


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

