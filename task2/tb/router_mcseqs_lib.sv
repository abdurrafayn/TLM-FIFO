class router_simple_mcseq extends uvm_sequence;

`uvm_object_utils(router_simple_mcseq)

`uvm_declare_p_sequencer(router_mcsequencer)

function new(string name= "router_simple_mcseq");
    super.new(name);
endfunction

hbus_small_packet_seq small_packets;        //Set the router to accept small packets (payload length < 21) and enable it.
hbus_read_max_pkt_seq max_packets;          // Read the router MAXPKTSIZE register to make sure it has been correctly set.
yapp_012_packets yapp_packets;              // Send six consecutive YAPP packets to addresses 0, 1, 2 using yapp_012_seq.
hbus_set_default_regs_seq large_packets;    // Set the router to accept large packets (payload length < 64).
six_yapp_seq six_packets;                   // Send a random sequence of six YAPP packets.

virtual task pre_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body

 virtual task post_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body

  virtual task body();

   `uvm_do_on(small_packets,p_sequencer.hbus)
   `uvm_do_on(max_packets,p_sequencer.hbus)
  repeat(2) 
       begin
           `uvm_do_on(yapp_packets, p_sequencer.yapp)
       end
   `uvm_do_on(large_packets,p_sequencer.hbus)
   `uvm_do_on(max_packets,p_sequencer.hbus)
   `uvm_do_on(six_packets,p_sequencer.yapp)

  endtask

endclass: router_simple_mcseq