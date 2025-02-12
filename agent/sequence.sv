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
    `uvm_info(get_type_name, "configuring LCR to load dlr", UVM_LOW)
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
    `uvm_info(get_type_name, "Loading DLR MSB", UVM_LOW)
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
    `uvm_info(get_type_name, "Loading DLR LSB", UVM_LOW)
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
    `uvm_info(get_type_name, "Configuring LCR to default mode", UVM_LOW)
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
    `uvm_info(get_type_name, "Configuring fcr", UVM_LOW)
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
    `uvm_info(get_type_name, "configuring ier", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //////////////////////////////write via thr//////////////////////////
    //    repeat (10) begin
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //thr
      wb_we_i == 1;
      wb_dat_i == e_cfg.i1;  // setting the data in test via e_cfg
    });
    `uvm_info(get_type_name, "Loading the data to thr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)
    //   end

    //////////////////////////read iir/////////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 2;  //iir
      wb_we_i == 0;  //read
    });
    `uvm_info(get_type_name, "reading iir", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //NOTE:get responce

    get_response(req);

    //Check the iir
    if (req.iir[3:1] == 3'b010) begin
      $display("The value of iir is %0b", req.iir);
      // sending 10 data form other uart
      //      repeat (10) begin
      start_item(req);
      assert (req.randomize() with {
        wb_addr_i == 0;  //rb
        wb_we_i == 0;  //read
      });
      `uvm_info(get_type_name, $sformatf("Printing from sequence: \n%s", req.sprint()), UVM_HIGH)
      finish_item(req);
      //     end
    end
  end
endtask  //fd1endtask

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
    `uvm_info(get_type_name, "configuring lcr to load dlr agth[1]", UVM_LOW)
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
    `uvm_info(get_type_name, "Loading dlr msb", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)


    /////////////////////////update the dlr lsb with diviser/////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //#10clk DLR MSB = 162 = 16'b0000_0000_1010_0010
      wb_we_i == 1;
      wb_dat_i == 8'b1010_0010;
    });
    `uvm_info(get_type_name, "Loading dlr lsb", UVM_LOW)
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
    `uvm_info(get_type_name, "configuring lcr to default mode", UVM_LOW)
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
    `uvm_info(get_type_name, "configuring fcr", UVM_LOW)
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
    `uvm_info(get_type_name, "configuring ier", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //////////////////////////////write via thr//////////////////////////
    //  repeat (10) begin
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //thr
      wb_we_i == 1;
      wb_dat_i == e_cfg.i2;  // setting the data in test via e_cfg
    });
    `uvm_info(get_type_name, "writing data to thr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)
    // end

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
      //      repeat (10) begin
      start_item(req);
      assert (req.randomize() with {
        wb_addr_i == 0;  //rb
        wb_we_i == 0;  //read
      });
      `uvm_info(get_type_name, $sformatf("Printing from sequence: \n%s", req.sprint()), UVM_HIGH)
      finish_item(req);
      //     end
    end
  end
endtask  //fd2endtask

class half_duplex_seq1 extends UART_sequence_base;
  `uvm_object_utils(half_duplex_seq1)
  extern function new(string name = "half_duplex_seq1");
  extern task body;
  uvm_event hd_event;
endclass

function half_duplex_seq1::new(string name = "half_duplex_seq1");
  super.new(name);
  hd_event = new("hd_event");
endfunction

task half_duplex_seq1::body;
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
    `uvm_info(get_type_name, "configuring LCR to load dlr", UVM_LOW)
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
    `uvm_info(get_type_name, "Loading DLR MSB", UVM_LOW)
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
    `uvm_info(get_type_name, "Loading DLR LSB", UVM_LOW)
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
    `uvm_info(get_type_name, "Configuring LCR to default mode", UVM_LOW)
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
    `uvm_info(get_type_name, "Configuring fcr", UVM_LOW)
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
    `uvm_info(get_type_name, "configuring ier", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //////////////////////////////write via thr//////////////////////////
    //    repeat (10) begin
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //thr
      wb_we_i == 1;
      wb_dat_i == e_cfg.i1;  // setting the data in test via e_cfg
    });
    `uvm_info(get_type_name, "Loading the data to thr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)
    //   end

    //////////////////////////read iir/////////////////////////////////
    //NOTE: Why is this sequence disabled?
    //
    /*NOTE:
      The sequence block for reading the IIR
      is commented out. The driver's IIR read
      logic is not triggered in half-duplex.
      The if condition (wb_addr_i == 2 &&
      wb_we_i == 0) never evaluates as true.
      Thus, the wait for int_o does not execute.
      We rely on the driver's logic to handle IIR.
    */
    ///////////////////////////////////////////////////////////////////

    /*   start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 2;  //iir
      wb_we_i == 0;  //read
    });
    `uvm_info(get_type_name, "reading iir", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //NOTE:get responce

    get_response(req);

    //Check the iir
    if (req.iir[3:1] == 3'b010) begin
      $display("The value of iir is %0b", req.iir);
      // sending 10 data form other uart
      //      repeat (10) begin
      start_item(req);
      assert (req.randomize() with {
        wb_addr_i == 0;  //rb
        wb_we_i == 0;  //read
      });
      `uvm_info(get_type_name, $sformatf("Printing from sequence: \n%s", req.sprint()), UVM_HIGH)
      finish_item(req);
      //     end
    end
    //hd_event.trigger;
  */
  end
endtask  //hd1endtask

class half_duplex_seq2 extends UART_sequence_base;
  `uvm_object_utils(half_duplex_seq2)
  extern function new(string name = "half_duplex_seq2");
  extern task body;
endclass

function half_duplex_seq2::new(string name = "half_duplex_seq2");
  super.new(name);
endfunction

task half_duplex_seq2::body;
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
    `uvm_info(get_type_name, "configuring lcr to load dlr agth[1]", UVM_LOW)
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
    `uvm_info(get_type_name, "Loading dlr msb", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)


    /////////////////////////update the dlr lsb with diviser/////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //#10clk DLR lsb =162  = 16'b0000_0000_1010_0010
      wb_we_i == 1;
      wb_dat_i == 8'b1010_0010;
    });
    `uvm_info(get_type_name, "Loading dlr lsb", UVM_LOW)
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
    `uvm_info(get_type_name, "configuring lcr to default mode", UVM_LOW)
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
    `uvm_info(get_type_name, "configuring fcr", UVM_LOW)
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
    `uvm_info(get_type_name, "configuring ier", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //////////////////////////////write via thr//////////////////////////
    //  repeat (10) begin
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //thr
      wb_we_i == 1;
      wb_dat_i == e_cfg.i2;  // setting the data in test via e_cfg
    });
    `uvm_info(get_type_name, "writing data to thr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)
    // end

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
      //      repeat (10) begin
      start_item(req);
      assert (req.randomize() with {
        wb_addr_i == 0;  //rb
        wb_we_i == 0;  //read
      });
      `uvm_info(get_type_name, $sformatf("Printing from sequence: \n%s", req.sprint()), UVM_HIGH)
      finish_item(req);
      //     end
    end
  end
endtask  //hd2endtask

class loopback_seq1 extends UART_sequence_base;
  `uvm_object_utils(loopback_seq1)
  extern function new(string name = "loopback_seq1");
  extern task body;
endclass

function loopback_seq1::new(string name = "loopback_seq1");
  super.new(name);
endfunction

task loopback_seq1::body;
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
    `uvm_info(get_type_name, "configuring LCR to load dlr", UVM_LOW)
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
    `uvm_info(get_type_name, "Loading DLR MSB", UVM_LOW)
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
    `uvm_info(get_type_name, "Loading DLR LSB", UVM_LOW)
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
    `uvm_info(get_type_name, "Configuring LCR to default mode", UVM_LOW)
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
    `uvm_info(get_type_name, "Configuring fcr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ////////////////////configure mcr///////////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 4;  //mcr
      wb_we_i == 1;
      wb_dat_i == 8'b0001_0000;  //mcr[4] set -> enable the loopback mode
    });
    `uvm_info(get_type_name, "configuring mcr to loopback mode", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    ////////////////////configure ier///////////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 1;  //ier
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0001;  //enable the rcvr buffer intrupt
    });
    `uvm_info(get_type_name, "configuring ier", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);


    //////////////////////////////write via thr//////////////////////////
    //    repeat (10) begin
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //thr
      wb_we_i == 1;
      wb_dat_i == e_cfg.i1;  // setting the data in test via e_cfg
    });
    `uvm_info(get_type_name, "Loading the data to thr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)
    //   end

    //////////////////////////read iir/////////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 2;  //iir
      wb_we_i == 0;  //read
    });
    `uvm_info(get_type_name, "reading iir", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //NOTE:get responce

    get_response(req);

    //Check the iir
    if (req.iir[3:1] == 3'b010) begin
      $display("The value of iir is %0b", req.iir);
      // sending 10 data form other uart
      //      repeat (10) begin
      start_item(req);
      assert (req.randomize() with {
        wb_addr_i == 0;  //rb
        wb_we_i == 0;  //read
      });
      `uvm_info(get_type_name, $sformatf("Printing from sequence: \n%s", req.sprint()), UVM_HIGH)
      finish_item(req);
      //     end
    end
  end
endtask

class loopback_seq2 extends UART_sequence_base;
  `uvm_object_utils(loopback_seq2)
  extern function new(string name = "loopback_seq2");
  extern task body;
endclass

function loopback_seq2::new(string name = "loopback_seq2");
  super.new(name);
endfunction

task loopback_seq2::body;
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
    `uvm_info(get_type_name, "configuring LCR to load dlr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    /////////////////////////update the dlr msb with diviser/////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 1;  //#10clk DLR MSB = 162 = 16'b0000_0000_1010_0010;
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0000;
    });
    `uvm_info(get_type_name, "Loading DLR MSB", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)


    /////////////////////////update the dlr lsb with diviser/////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //#10clk DLR MSB = 162 = 16'b0000_0000_1010_0010;
      wb_we_i == 1;
      wb_dat_i == 8'b1010_0010;
    });
    `uvm_info(get_type_name, "Loading DLR LSB", UVM_LOW)
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
    `uvm_info(get_type_name, "Configuring LCR to default mode", UVM_LOW)
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
    `uvm_info(get_type_name, "Configuring fcr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ////////////////////configure mcr///////////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 4;  //mcr
      wb_we_i == 1;
      wb_dat_i == 8'b0001_0000;  //mcr[4] set -> enable the loopback mode
    });
    `uvm_info(get_type_name, "configuring mcr to loopback mode", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    ////////////////////configure ier///////////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 1;  //ier
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0001;  //enable the rcvr buffer intrupt
    });
    `uvm_info(get_type_name, "configuring ier", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);


    //////////////////////////////write via thr//////////////////////////
    //    repeat (10) begin
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //thr
      wb_we_i == 1;
      wb_dat_i == e_cfg.i1;  // setting the data in test via e_cfg
    });
    `uvm_info(get_type_name, "Loading the data to thr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)
    //   end

    //////////////////////////read iir/////////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 2;  //iir
      wb_we_i == 0;  //read
    });
    `uvm_info(get_type_name, "reading iir", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //NOTE:get responce

    get_response(req);

    //Check the iir
    if (req.iir[3:1] == 3'b010) begin
      $display("The value of iir is %0b", req.iir);
      // sending 10 data form other uart
      //      repeat (10) begin
      start_item(req);
      assert (req.randomize() with {
        wb_addr_i == 0;  //rb
        wb_we_i == 0;  //read
      });
      `uvm_info(get_type_name, $sformatf("Printing from sequence: \n%s", req.sprint()), UVM_HIGH)
      finish_item(req);
      //     end
    end
  end
endtask

class parity_error_seq1 extends UART_sequence_base;
  `uvm_object_utils(parity_error_seq1)
  extern function new(string name = "parity_error_seq1");
  extern task body;
endclass

function parity_error_seq1::new(string name = "parity_error_seq1");
  super.new(name);
endfunction

task parity_error_seq1::body;
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
    `uvm_info(get_type_name, "configuring LCR to load dlr", UVM_LOW)
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
    `uvm_info(get_type_name, "Loading DLR MSB", UVM_LOW)
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
    `uvm_info(get_type_name, "Loading DLR LSB", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ///////////////////////configure lcr///////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 3;  //lcr
      wb_we_i == 1;
      wb_dat_i == 8'b0001_1011;  //LCR[4]:set -> even parity,8bit,1stop bit
                                 //LCR[3]:set -> enable parity
    });
    `uvm_info(get_type_name, "Configuring LCR to default mode", UVM_LOW)
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
    `uvm_info(get_type_name, "Configuring fcr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ////////////////////configure ier///////////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 1;  //ier
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0100;  //IER[2]: set -> enable lsr
    });
    `uvm_info(get_type_name, "configuring ier", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //////////////////////////////write via thr//////////////////////////
    //    repeat (10) begin
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //thr
      wb_we_i == 1;
      wb_dat_i == e_cfg.i1;  // setting the data in test via e_cfg
    });
    `uvm_info(get_type_name, "Loading the data to thr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)
    //   end

    //////////////////////////read iir/////////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 2;  //iir
      wb_we_i == 0;  //read
    });
    `uvm_info(get_type_name, "reading iir", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //NOTE:get responce

    get_response(req);

    //Check the iir
    if (req.iir[3:1] == 3'b011) begin
      $display("The value of iir is %0b", req.iir);
      // sending 10 data form other uart
      //      repeat (10) begin
      start_item(req);
      assert (req.randomize() with {
        wb_addr_i == 5;  //lsr
        wb_we_i == 0;  //read
      });
      `uvm_info(get_type_name, $sformatf("Printing from sequence: \n%s", req.sprint()), UVM_HIGH)
      finish_item(req);
      //     end
    end
  end
endtask

class parity_error_seq2 extends UART_sequence_base;
  `uvm_object_utils(parity_error_seq2)
  extern function new(string name = "parity_error_seq2");
  extern task body;
endclass

function parity_error_seq2::new(string name = "parity_error_seq2");
  super.new(name);
endfunction

task parity_error_seq2::body;
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
    `uvm_info(get_type_name, "configuring lcr to load dlr agth[1]", UVM_LOW)
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
    `uvm_info(get_type_name, "Loading dlr msb", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)


    /////////////////////////update the dlr lsb with diviser/////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //#10clk DLR LSB = 162 = 16'b0000_0000_1010_0010
      wb_we_i == 1;
      wb_dat_i == 8'b1010_0010;
    });
    `uvm_info(get_type_name, "Loading dlr lsb", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ///////////////////////configure lcr///////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 3;  //lcr
      wb_we_i == 1;
      wb_dat_i == 8'b0000_1011;  //LCR[4]:reset -> odd parity,8bit,1stop bit
                                 //LCR[3]:set -> enable parity
    });
    `uvm_info(get_type_name, "configuring lcr to default mode", UVM_LOW)
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
    `uvm_info(get_type_name, "configuring fcr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ////////////////////configure ier///////////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 1;  //ier
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0100;  //IER[2]: set -> enable lsr
    });
    `uvm_info(get_type_name, "configuring ier", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //////////////////////////////write via thr//////////////////////////
    //  repeat (10) begin
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //thr
      wb_we_i == 1;
      wb_dat_i == e_cfg.i2;  // setting the data in test via e_cfg
    });
    `uvm_info(get_type_name, "writing data to thr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)
    // end

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
    if (req.iir[3:1] == 3'b011) begin
      $display("The value of iir is %0b", req.iir);
      // sending 10 data form other uart
      //      repeat (10) begin
      start_item(req);
      assert (req.randomize() with {
        wb_addr_i == 5;  //read lsr
        wb_we_i == 0;  //read
      });
      `uvm_info(get_type_name, $sformatf("Printing from sequence: \n%s", req.sprint()), UVM_HIGH)
      finish_item(req);
      //     end
    end
  end
endtask



class framing_error_seq1 extends UART_sequence_base;
  `uvm_object_utils(framing_error_seq1)
  extern function new(string name = "framing_error_seq1");
  extern task body;
endclass

function framing_error_seq1::new(string name = "framing_error_seq1");
  super.new(name);
endfunction

task framing_error_seq1::body;
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
    `uvm_info(get_type_name, "configuring LCR to load dlr", UVM_LOW)
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
    `uvm_info(get_type_name, "Loading DLR MSB", UVM_LOW)
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
    `uvm_info(get_type_name, "Loading DLR LSB", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ///////////////////////configure lcr///////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 3;  //lcr
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0111;  //LCR[0:1]:11 -> no of bits is each char = 8
                                 //no parity
    });
    `uvm_info(get_type_name, "Configuring LCR to default mode", UVM_LOW)
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
    `uvm_info(get_type_name, "Configuring fcr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ////////////////////configure ier///////////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 1;  //ier
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0100;  //IER[2]: set -> enable lsr
    });
    `uvm_info(get_type_name, "configuring ier", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //////////////////////////////write via thr//////////////////////////
    //    repeat (10) begin
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //thr
      wb_we_i == 1;
      wb_dat_i == 8'b0110_1101;  // setting the data mannualy since frame size is changed to 7
    });
    `uvm_info(get_type_name, "Loading the data to thr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)
    //   end

    //////////////////////////read iir/////////////////////////////////
    /* start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 2;  //iir
      wb_we_i == 0;  //read
    });
    `uvm_info(get_type_name, "reading iir", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //NOTE:get responce

    get_response(req);

    //Check the iir for 3'b011 which indicates parity,framing and overrun
    if (req.iir[3:1] == 3'b011) begin
      $display("The value of iir is %0b", req.iir);
      // sending 10 data form other uart
      //      repeat (10) begin
      start_item(req);
      assert (req.randomize() with {
        wb_addr_i == 5;  //lsr
        wb_we_i == 0;  //read
      });
      `uvm_info(get_type_name, $sformatf("Printing from sequence: \n%s", req.sprint()), UVM_HIGH)
      finish_item(req);
      //     end
    end
    */
  end
endtask

class framing_error_seq2 extends UART_sequence_base;
  `uvm_object_utils(framing_error_seq2)
  extern function new(string name = "framing_error_seq2");
  extern task body;
endclass

function framing_error_seq2::new(string name = "framing_error_seq2");
  super.new(name);
endfunction

task framing_error_seq2::body;
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
    `uvm_info(get_type_name, "configuring lcr to load dlr agth[1]", UVM_LOW)
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
    `uvm_info(get_type_name, "Loading dlr msb", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)


    /////////////////////////update the dlr lsb with diviser/////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //#10clk DLR LSB = 162 = 16'b0000_0000_1010_0010
      wb_we_i == 1;
      wb_dat_i == 8'b1010_0010;
    });
    `uvm_info(get_type_name, "Loading dlr lsb", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ///////////////////////configure lcr///////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 3;  //lcr
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0110;  //LCR[1:0]:10 ->size of char is 7 bits
    });
    `uvm_info(get_type_name, "configuring lcr to default mode", UVM_LOW)
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
    `uvm_info(get_type_name, "configuring fcr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ////////////////////configure ier///////////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 1;  //ier
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0100;  //IER[2]: set -> enable lsr
    });
    `uvm_info(get_type_name, "configuring ier", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //////////////////////////////write via thr//////////////////////////
    //  repeat (10) begin
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //thr
      wb_we_i == 1;
      wb_dat_i == 7'b0011_101;  // setting mannual data | frame size is 7
    });
    `uvm_info(get_type_name, "writing data to thr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)
    // end

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

    //Check the iir for 3'b011 framing, parity or overrun error
    if (req.iir[3:1] == 3'b011) begin
      $display("The value of iir is %0b", req.iir);
      // sending 10 data form other uart
      //      repeat (10) begin
      start_item(req);
      assert (req.randomize() with {
        wb_addr_i == 5;  //read lsr
        wb_we_i == 0;  //read
      });
      `uvm_info(get_type_name, $sformatf("Printing from sequence: \n%s", req.sprint()), UVM_HIGH)
      finish_item(req);
      //     end
    end
  end
endtask



class overrun_error_seq1 extends UART_sequence_base;
  `uvm_object_utils(overrun_error_seq1)
  extern function new(string name = "overrun_error_seq1");
  extern task body;
endclass

function overrun_error_seq1::new(string name = "overrun_error_seq1");
  super.new(name);
endfunction

task overrun_error_seq1::body;
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
    `uvm_info(get_type_name, "configuring LCR to load dlr", UVM_LOW)
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
    `uvm_info(get_type_name, "Loading DLR MSB", UVM_LOW)
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
    `uvm_info(get_type_name, "Loading DLR LSB", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ///////////////////////configure lcr///////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 3;  //lcr
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0011;  //LCR[0:1]:11 -> no of bits is each char = 8
                                 //no parity
    });
    `uvm_info(get_type_name, "Configuring LCR to default mode", UVM_LOW)
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
    `uvm_info(get_type_name, "Configuring fcr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ////////////////////configure ier///////////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 1;  //ier
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0100;  //IER[2]: set -> enable lsr
    });
    `uvm_info(get_type_name, "configuring ier", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //////////////////////////////write via thr//////////////////////////
    repeat (19) begin //fifo depth in dut is 16, inorder for it to overfolow and throw overrun error
      start_item(req);
      `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
      assert (req.randomize() with {
        wb_addr_i == 0;  //thr
        wb_we_i == 1;
        wb_dat_i == e_cfg.i1;  // setting the data mannualy since frame size is changed to 7
      });
      `uvm_info(get_type_name, "Loading the data to thr", UVM_LOW)
      `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
      finish_item(req);
      `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)
    end

    //////////////////////////read iir/////////////////////////////////
    /*
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 2;  //iir
      wb_we_i == 0;  //read
    });
    `uvm_info(get_type_name, "reading iir", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //NOTE:get responce

    get_response(req);

    //Check the iir for 3'b011 which indicates parity,framing and overrun
    if (req.iir[3:1] == 3'b011) begin
      $display("The value of iir is %0b", req.iir);
      start_item(req);
      assert (req.randomize() with {
        wb_addr_i == 5;  //lsr
        wb_we_i == 0;  //read
      });
      `uvm_info(get_type_name, $sformatf("Printing from sequence: \n%s", req.sprint()), UVM_HIGH)
      finish_item(req);
    end
    */
  end
endtask

class overrun_error_seq2 extends UART_sequence_base;
  `uvm_object_utils(overrun_error_seq2)
  extern function new(string name = "overrun_error_seq2");
  extern task body;
endclass

function overrun_error_seq2::new(string name = "overrun_error_seq2");
  super.new(name);
endfunction

task overrun_error_seq2::body;
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
    `uvm_info(get_type_name, "configuring lcr to load dlr agth[1]", UVM_LOW)
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
    `uvm_info(get_type_name, "Loading dlr msb", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)


    /////////////////////////update the dlr lsb with diviser/////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //#10clk DLR LSB = 162 = 16'b0000_0000_1010_0010
      wb_we_i == 1;
      wb_dat_i == 8'b1010_0010;
    });
    `uvm_info(get_type_name, "Loading dlr lsb", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ///////////////////////configure lcr///////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 3;  //lcr
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0011;  //LCR[1:0]:11 ->size of char is 8 bits
    });
    `uvm_info(get_type_name, "configuring lcr to default mode", UVM_LOW)
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
    `uvm_info(get_type_name, "configuring fcr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ////////////////////configure ier///////////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 1;  //ier
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0100;  //IER[2]: set -> enable lsr
    });
    `uvm_info(get_type_name, "configuring ier", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //////////////////////////////write via thr//////////////////////////
    //depth of fifo in dut is 16, inorder for it to overflow
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //thr
      wb_we_i == 1;
      wb_dat_i == e_cfg.i2;  // setting data in test via e_cfg
    });
    `uvm_info(get_type_name, "writing data to thr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)
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

    //Check the iir for 3'b011 framing, parity or overrun error
    if (req.iir[3:1] == 3'b011) begin
      $display("The value of iir is %0b", req.iir);
      start_item(req);
      assert (req.randomize() with {
        wb_addr_i == 5;  //read lsr
        wb_we_i == 0;  //read
      });
      `uvm_info(get_type_name, $sformatf("Printing from sequence: \n%s", req.sprint()), UVM_HIGH)
      finish_item(req);
    end
  end
endtask


class breakinterrupt_error_seq1 extends UART_sequence_base;
  `uvm_object_utils(breakinterrupt_error_seq1)
  extern function new(string name = "breakinterrupt_error_seq1");
  extern task body;
endclass

function breakinterrupt_error_seq1::new(string name = "breakinterrupt_error_seq1");
  super.new(name);
endfunction

task breakinterrupt_error_seq1::body;
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
    `uvm_info(get_type_name, "configuring LCR to load dlr", UVM_LOW)
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
    `uvm_info(get_type_name, "Loading DLR MSB", UVM_LOW)
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
    `uvm_info(get_type_name, "Loading DLR LSB", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ///////////////////////configure lcr///////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 3;  //lcr
      wb_we_i == 1;
      wb_dat_i == 8'b0100_0011;  //8bit,1stop bit
                                 //LCR[6] -> set: break_interrupt enable
    });
    `uvm_info(get_type_name, "Configuring LCR to default mode", UVM_LOW)
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
    `uvm_info(get_type_name, "Configuring fcr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ////////////////////configure ier///////////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 1;  //ier
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0100;  //IER[2]: set -> enable lsr
    });
    `uvm_info(get_type_name, "configuring ier", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //////////////////////////////write via thr//////////////////////////
    //    repeat (10) begin
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //thr
      wb_we_i == 1;
      wb_dat_i == e_cfg.i1;  // setting the data in test via e_cfg
    });
    `uvm_info(get_type_name, "Loading the data to thr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)
    //   end

    //////////////////////////read iir/////////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 2;  //iir
      wb_we_i == 0;  //read
    });
    `uvm_info(get_type_name, "reading iir", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //NOTE:get responce

    get_response(req);

    //Check the iir
    if (req.iir[3:1] == 3'b011) begin
      $display("The value of iir is %0b", req.iir);
      // sending 10 data form other uart
      //      repeat (10) begin
      start_item(req);
      assert (req.randomize() with {
        wb_addr_i == 5;  //lsr
        wb_we_i == 0;  //read
      });
      `uvm_info(get_type_name, $sformatf("Printing from sequence: \n%s", req.sprint()), UVM_HIGH)
      finish_item(req);
      //     end
    end
  end
endtask

class breakinterrupt_error_seq2 extends UART_sequence_base;
  `uvm_object_utils(breakinterrupt_error_seq2)
  extern function new(string name = "breakinterrupt_error_seq2");
  extern task body;
endclass

function breakinterrupt_error_seq2::new(string name = "breakinterrupt_error_seq2");
  super.new(name);
endfunction

task breakinterrupt_error_seq2::body;
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
    `uvm_info(get_type_name, "configuring lcr to load dlr agth[1]", UVM_LOW)
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
    `uvm_info(get_type_name, "Loading dlr msb", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)


    /////////////////////////update the dlr lsb with diviser/////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //#10clk DLR LSB = 162 = 16'b0000_0000_1010_0010
      wb_we_i == 1;
      wb_dat_i == 8'b1010_0010;
    });
    `uvm_info(get_type_name, "Loading dlr lsb", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ///////////////////////configure lcr///////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 3;  //lcr
      wb_we_i == 1;
      wb_dat_i == 8'b0100_0011;  //8bit,1stop bit
                                 //LCR[6]:set -> brak_interrupt enable
    });
    `uvm_info(get_type_name, "configuring lcr to default mode", UVM_LOW)
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
    `uvm_info(get_type_name, "configuring fcr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)

    ////////////////////configure ier///////////////////////////////////
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 1;  //ier
      wb_we_i == 1;
      wb_dat_i == 8'b0000_0100;  //IER[2]: set -> enable lsr
    });
    `uvm_info(get_type_name, "configuring ier", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW);

    //////////////////////////////write via thr//////////////////////////
    //  repeat (10) begin
    start_item(req);
    `uvm_info(get_type_name, "start_item unblocked", UVM_LOW)
    assert (req.randomize() with {
      wb_addr_i == 0;  //thr
      wb_we_i == 1;
      wb_dat_i == e_cfg.i2;  // setting the data in test via e_cfg
    });
    `uvm_info(get_type_name, "writing data to thr", UVM_LOW)
    `uvm_info(get_type_name, $sformatf("printing from sequence \n %s", req.sprint()), UVM_HIGH)
    finish_item(req);
    `uvm_info(get_type_name, "finish_item unblocked", UVM_LOW)
    // end

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
    if (req.iir[3:1] == 3'b011) begin
      $display("The value of iir is %0b", req.iir);
      // sending 10 data form other uart
      //      repeat (10) begin
      start_item(req);
      assert (req.randomize() with {
        wb_addr_i == 5;  //read lsr
        wb_we_i == 0;  //read
      });
      `uvm_info(get_type_name, $sformatf("Printing from sequence: \n%s", req.sprint()), UVM_HIGH)
      finish_item(req);
      //     end
    end
  end
endtask

