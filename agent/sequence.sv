class UART_sequence_base extends uvm_sequence #(UART_xtn);
  `uvm_object_utils(UART_sequence_base)
  env_config e_cfg;
  extern function new(string name = "UART_sequence_base");
  extern task body;
endclass

function UART_sequence_base::new(string name = "UART_sequence_base");
  super.new(name);
endfunction

task UART_sequence_base::body();
  `uvm_info(get_type_name, "In the body of base class", UVM_LOW)
  if (!uvm_config_db#(env_config)::get(null, get_full_name, "env_config", e_cfg))
    `uvm_fatal(get_type_name, "failed to get env_config in seq")
endtask

class full_duplex_seq1 extends UART_sequence_base;
  `uvm_object_utils(full_duplex_seq1)
  extern function new(string name = "full_duplex_seq1");
  extern task body;
endclass

function full_duplex_seq1::new(string name = "full_duplex_seq1");
  super.new(name);
endfunction

task full_duplex_seq1::body;
  super.body;
  //////////////////////////////////////////////////////////////////
  //NOTE: Step 1: Updte the diviser to the dlr reg to set proper baud rate
  //LCR addr = 3, select lcr[7] == 1 to select dlr (addr =1|MSB addr=0|LSB)
  //NOTE: Step 2:Come to normal mode via lcr[7] = 0 to select other reg and
  //configure the lcr as required
  //NOTE: Step 3: reset the fifo's via fcr, fcr[1] and fcr[2] clears the
  //fifos , fcr[7:6] define the fifo intrupt trigger level
  //NOTE: Step 4: enable the reciver buffer intrupt via ier, set ier[0]
  //NOTE: Step 5: write the data into the thr

  //WARN: Transmission is over till here,rcv part begins

  //NOTE: Strp 6:configure iir(addr = 2 same as fcr) and read the data if
  //available
  ///////////////////////////////////////////////////////////////////
  begin
    ///////////select the dlr via the lcr/////////////////////////////
    req = UART_xtn::type_id::create("req");
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 3;
      wb_we_i == 1;
      wb_dat_i[7] == 1;  //NOTE: LCR is [7:0]
    });
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    /////////////////////////update the dlr msb with diviser/////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 1;  //#10clk DLR MSB = 325 = 16'b0000_0001_0100_0101
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0001;
    });
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)


    /////////////////////////update the dlr lsb with diviser/////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //#10clk DLR MSB = 325 = 16'b0000_0001_0100_0101
      wb_we_i == 1;
      wb_dat_i == 8'b0100_0101;
    });
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ///////////////////////configure lcr///////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 3;  //lcr
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0011;  //no parity,8bit,1stop bit
    });
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ////////////////////////configure fcr//////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 2;  //fcr
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0110;  //trigger after 1 byte reception and clear fifo
    });
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ////////////////////configure ier///////////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 1;  //ier
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0001;  //enable the rcvr buffer intrupt
    });
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //////////////////////////////write via thr//////////////////////////
    repeat (10) begin
      start_item(req);
      `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
      assert (req.randomize() with {
        wb_addr_i == 0;  //thr
        wb_we_i == 1;
        wb_dat_i == e_cfg.i1;  // setting the data in test via e_cfg
      });
      `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
      finish_item(req);
      `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)
    end

    //////////////////////////read iir/////////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 2;  //iir
      wb_we_i == 0;  //read
    });
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //NOTE:get responce

    get_response(req);

    //Check the iir
    if (req.iir[3:1] == 3'b010) begin
      $display("The value of iir is %0b", req.iir);
      // sending 10 data form other uart
      repeat (10) begin
        start_item(req);
        assert (req.randomize() with {
          wb_addr_i == 0;  //rb
          wb_we_i == 0;  //read
        });
        `uvm_info(get_type_name, $sformatf("Printing from sequence: \n%s", req.sprint()), UVM_HIGH)
        finish_item(req);
      end
    end
  end
endtask


class full_duplex_seq2 extends UART_sequence_base;
  `uvm_object_utils(full_duplex_seq2)
  extern function new(string name = "full_duplex_seq2");
  extern task body;
endclass

function full_duplex_seq2::new(string name = "full_duplex_seq2");
  super.new(name);
endfunction

task full_duplex_seq2::body;
  super.body;
  begin
    ///////////select the dlr via the lcr/////////////////////////////
    req = UART_xtn::type_id::create("req");
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 3;
      wb_we_i == 1;
      wb_dat_i[7] == 1;  //NOTE: LCR is [7:0]
    });
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    /////////////////////////update the dlr msb with diviser/////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 1;  //#10clk DLR MSB = 162 = 16'b0000_0000_1010_0010
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0000;
    });
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)


    /////////////////////////update the dlr lsb with diviser/////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //#10clk DLR MSB = 325 = 16'b0000_0000_1010_0010
      wb_we_i == 1;
      wb_dat_i == 8'b1010_0010;
    });
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ///////////////////////configure lcr///////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 3;  //lcr
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0011;  //no parity,8bit,1stop bit
    });
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ////////////////////////configure fcr//////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 2;  //fcr
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0110;  //trigger after 1 byte reception and clear fifo
    });
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ////////////////////configure ier///////////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 1;  //ier
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0001;  //enable the rcvr buffer intrupt
    });
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //////////////////////////////write via thr//////////////////////////
    repeat (10) begin
      start_item(req);
      `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
      assert (req.randomize() with {
        wb_addr_i == 0;  //thr
        wb_we_i == 1;
        wb_dat_i == e_cfg.i2;  // setting the data in test via e_cfg
      });
      `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
      finish_item(req);
      `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)
    end

    //////////////////////////read iir/////////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 2;  //iir
      wb_we_i == 0;  //read
    });
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //NOTE:get responce

    get_response(req);

    //Check the iir
    if (req.iir[3:1] == 3'b010) begin
      $display("The value of iir is %0b", req.iir);
      // sending 10 data form other uart
      repeat (10) begin
        start_item(req);
        assert (req.randomize() with {
          wb_addr_i == 0;  //rb
          wb_we_i == 0;  //read
        });
        `uvm_info(get_type_name, $sformatf("Printing from sequence: \n%s", req.sprint()), UVM_HIGH)
        finish_item(req);
      end
    end
  end
endtask
