class router_scoreboard extends uvm_scoreboard;
`uvm_component_utils(router_scoreboard)

    int received_packets; 
    int wrong_packets; 
    int matched_packets;
    
    yapp_packet q0[$];
    yapp_packet q1[$];
    yapp_packet q2[$];


        `uvm_analysis_imp_decl(_yapp_router)
        `uvm_analysis_imp_decl(_chan0)
        `uvm_analysis_imp_decl(_chan1)
        `uvm_analysis_imp_decl(_chan2)


        uvm_analysis_imp_yapp_router#(yapp_packet, router_scoreboard) router_packet_in;
        uvm_analysis_imp_chan0#(channel_packet, router_scoreboard) channel_0_packet;
        uvm_analysis_imp_chan1#(channel_packet, router_scoreboard) channel_1_packet;
        uvm_analysis_imp_chan2#(channel_packet, router_scoreboard) channel_2_packet;


        function new (string name, uvm_component parent);
            super.new(name,parent);
            //creating analysis implementations
            router_packet_in = new("router_packet_in", this);
            channel_0_packet = new("channel_0_packet", this);
            channel_1_packet = new("channel_1_packet", this);
            channel_2_packet = new("channel_2_packet", this);

            // received_packets    = 0; 
            // wrong_packets       = 0;
            // matched_packets     = 0;
            
        endfunction

            //comparing function
    // function bit comp_equal (input yapp_packet yp, input channel_packet cp);
    //   // returns first mismatch only
    //   if (yp.addr != cp.addr) begin
    //     `uvm_error("PKT_COMPARE",$sformatf("Address mismatch YAPP %0d Chan %0d",yp.addr,cp.addr))
    //     return(0);
    //   end
    //   if (yp.length != cp.length) begin
    //     `uvm_error("PKT_COMPARE",$sformatf("Length mismatch YAPP %0d Chan %0d",yp.length,cp.length))
    //     return(0);
    //   end
    //   foreach (yp.payload [i])
    //     if (yp.payload[i] != cp.payload[i]) begin
    //       `uvm_error("PKT_COMPARE",$sformatf("Payload[%0d] mismatch YAPP %0d Chan %0d",i,yp.payload[i],cp.payload[i]))
    //       return(0);
    //     end
    //   if (yp.parity != cp.parity) begin
    //     `uvm_error("PKT_COMPARE",$sformatf("Parity mismatch YAPP %0d Chan %0d",yp.parity,cp.parity))
    //     return(0);
    //   end
    //   return(1);
    // endfunction


    function bit custom_comp (input yapp_packet yp, input channel_packet cp, uvm_comparer comparer = null);
        if(comparer == null)
        comparer = new();

        custom_comp = comparer.compare_field("addr", yp.addr,cp.addr,2);
        custom_comp &= comparer.compare_field("length", yp.length, cp.length, 6);

        foreach (yp.payload[i]) 
            begin
                custom_comp &= comparer.compare_field("payload", yp.payload[i], cp.payload[i], 8);
            end
        custom_comp &= comparer.compare_field("parity", yp.parity, cp.parity, 1);
        return custom_comp;
    endfunction


    function void write_yapp_router(input yapp_packet pkt);
        yapp_packet p_copy;
        $cast(p_copy,pkt.clone());
        //received_packets++;

        case(p_copy.addr)
        0: q0.push_back(p_copy);
        1: q1.push_back(p_copy);
        2: q2.push_back(p_copy);
        default:
            `uvm_warning("YAPP_SB", $sformatf("packet with illegal address %0d recevied", p_copy.addr))
        endcase
    endfunction
    
    //implemetations to pop packets from appropriate queue

    function void write_chan0(input channel_packet cp);
        yapp_packet yp;
        if(cp.addr == 0) begin
           yp = q0.pop_front();
            received_packets++;
            if (custom_comp(yp, cp))
                matched_packets++;
            else begin
                `uvm_error("CHAN0", "No packet to compare in queue 0")
                wrong_packets++;
            end
        end else
            $display("Packet expected at channel 0 but received at = %0d", yp.addr);
        
    endfunction

    function void write_chan1(input channel_packet cp);
        yapp_packet yp;
        if(cp.addr == 1) begin
           yp = q1.pop_front();
            received_packets++;
            if (custom_comp(yp, cp))
                matched_packets++;
            else begin
                `uvm_error("CHAN1", "No packet to compare in queue 1")
                wrong_packets++;
            end
        end else
            $display("Packet expected at channel 1 but received at = %0d", yp.addr);
        
    endfunction

    function void write_chan2(input channel_packet cp);
        yapp_packet yp;
        if(cp.addr == 2) begin
           yp = q2.pop_front();
            received_packets++;
            if (custom_comp(yp, cp))
                matched_packets++;
            else begin
                `uvm_error("CHAN2", "No packet to compare in queue 2")
                wrong_packets++;
            end
        end
        else
            $display("Packet expected at channel 2 but received at = 0d", yp.addr);
        
    endfunction

    function void report_phase(uvm_phase phase);
        //super.report_phase(phase);
            `uvm_info("SB_REPORT", $sformatf("Total Received: %0d", received_packets), UVM_LOW)
            `uvm_info("SB_REPORT", $sformatf("Matched Packets: %0d", matched_packets), UVM_LOW)
            `uvm_info("SB_REPORT", $sformatf("Wrong Packets: %0d", wrong_packets), UVM_LOW)
            `uvm_info("SB_REPORT", $sformatf("Unmatched in Queue 0: %0d", q0.size()), UVM_LOW)
            `uvm_info("SB_REPORT", $sformatf("Unmatched in Queue 1: %0d", q1.size()), UVM_LOW)
            `uvm_info("SB_REPORT", $sformatf("Unmatched in Queue 2: %0d", q2.size()), UVM_LOW)
    endfunction
endclass