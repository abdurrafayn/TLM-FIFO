/*-----------------------------------------------------------------
File name     : hw_top.sv
Developers    : Kathleen Meade, Brian Dickinson
Created       : 01/04/11
Description   : lab06_vif hardware top module for acceleration
              : Instantiates clock generator and YAPP interface only for testing - no DUT
Notes         : From the Cadence "SystemVerilog Accelerated Verification with UVM" training
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2015
-----------------------------------------------------------------*/

module hw_top;

  // Clock and reset signals
  logic [31:0]  clock_period;
  logic         run_clock;
  logic         clock;
  logic         reset;

  // YAPP Interface to the DUT
  yapp_if in0(clock, reset);

  //clock and reset instantiations
  clock_and_reset_if cr_vif(.clock(clock), .reset(reset),.run_clock(run_clock),.clock_period(clock_period));
  
  //hbus instantiations
  hbus_if hbus_vif(.clock(clock),.reset(reset));
  
  //three channels instantiations
  channel_if ch0_vif(.clock(clock),.reset(reset));
  channel_if ch1_vif(.clock(clock),.reset(reset));
  channel_if ch2_vif(.clock(clock),.reset(reset));


  yapp_router dut(
    .reset(reset),
    .clock(clock),
    .error(),

    // YAPP interface
    .in_data(in0.in_data),
    .in_data_vld(in0.in_data_vld),
    .in_suspend(in0.in_suspend),

    // Output Channels
    //Channel 0
    .data_0(ch0_vif.data),
    .data_vld_0(ch0_vif.data_vld),
    .suspend_0(ch0_vif.suspend),
    //Channel 1
    .data_1(ch1_vif.data),
    .data_vld_1(ch1_vif.data_vld),
    .suspend_1(ch1_vif.suspend),
    //Channel 2
    .data_2(ch2_vif.data),
    .data_vld_2(ch2_vif.data_vld),
    .suspend_2(ch2_vif.suspend),

    // HBUS Interface 
    .haddr(hbus_vif.haddr),
    .hdata(hbus_vif.hdata_w),
    .hen(hbus_vif.hen),
    .hwr_rd(hbus_vif.hwr_rd));


  // CLKGEN module generates clock
  clkgen clkgen (
    .clock(clock),
    //.run_clock(1'b1),
    .run_clock(run_clock),
    // .clock_period(32'd10)
    .clock_period(clock_period)
  );

  // initial begin
  //   reset <= 1'b0;
  //  // in0.in_suspend <= 1'b0;
  //   @(negedge clock)
  //     #1 reset <= 1'b1;
  //   @(negedge clock)
  //     #1 reset <= 1'b0;
  // end

endmodule
