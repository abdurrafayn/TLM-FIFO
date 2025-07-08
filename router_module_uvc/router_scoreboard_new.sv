class router_scoreboard_new extends uvm_scoreboard;
`uvm_component_utils(router_scoreboard_new)

    int received_packets; 
    int wrong_packets; 
    int matched_packets;

    int max_packet_size;
    int router_en;

    int dropped;
    int matched;
    int not_matched;



        uvm_tlm_analysis_fifo #(yapp_packet) yapp_fifo_new;
        uvm_tlm_analysis_fifo #(hbus_transaction) hbus_fifo_new;
        uvm_tlm_analysis_fifo #(channel_packet) channel_fifo_0;
        uvm_tlm_analysis_fifo #(channel_packet) channel_fifo_1;
        uvm_tlm_analysis_fifo #(channel_packet) channel_fifo_2;

        uvm_get_port #(yapp_packet) yapp_get_port;
        uvm_get_port #(hbus_transaction) hbus_get_port;
        uvm_get_port #(channel_packet) chan0_get_port;
        uvm_get_port #(channel_packet) chan1_get_port;
        uvm_get_port #(channel_packet) chan2_get_port;


        `uvm_analysis_imp_decl(_yapp_router)
        `uvm_analysis_imp_decl(_chan0)
        `uvm_analysis_imp_decl(_chan1)
        `uvm_analysis_imp_decl(_chan2)


        // uvm_analysis_imp_yapp_router#(yapp_packet, router_scoreboard) router_packet_in;
        // uvm_analysis_imp_chan0#(channel_packet, router_scoreboard) channel_0_packet;
        // uvm_analysis_imp_chan1#(channel_packet, router_scoreboard) channel_1_packet;
        // uvm_analysis_imp_chan2#(channel_packet, router_scoreboard) channel_2_packet;


        function new (string name, uvm_component parent);
            super.new(name,parent);

        yapp_fifo_new = new("yapp_fifo_new", this);
        hbus_fifo_new = new("hbus_fifo_new", this);
        channel_fifo_0 = new("channel_fifo_0", this);
        channel_fifo_1 = new("channel_fifo_1", this);
        channel_fifo_2 = new("channel_fifo_2", this);



        yapp_get_port = new("yapp_get_port", this);
        hbus_get_port = new("hbus_get_port", this);
        chan0_get_port = new("chan0_get_port", this);
        chan1_get_port = new("chan1_get_port", this);
        chan2_get_port = new("chan2_get_port", this);


        endfunction


        function void connect_phase(uvm_phase phase);
            yapp_get_port.connect(yapp_fifo_new.get_peek_export);
            hbus_get_port.connect(hbus_fifo_new.get_peek_export);
            chan0_get_port.connect(channel_fifo_0.get_peek_export);
            chan1_get_port.connect(channel_fifo_1.get_peek_export);
            chan2_get_port.connect(channel_fifo_2.get_peek_export);

        endfunction

        task run_phase (uvm_phase phase);
        fork

        custom_compare();
        hbus();
            
        join

        endtask

        task custom_compare();

        yapp_packet pkt;
        channel_packet cpkt;

        yapp_get_port.get(pkt);
        if((!router_en) || (max_packet_size >= pkt.length) || (pkt.addr >= 3))
        dropped++;
        else 
        case(pkt.addr)
            2'b00:chan0_get_port.get(cpkt);
            2'b01:chan1_get_port.get(cpkt);
            2'b10:chan2_get_port.get(cpkt);
        endcase
        if(pkt == null)
        `uvm_info(get_type_name(),"PKT NULL", UVM_LOW)


        if(cpkt == null)
        `uvm_info(get_type_name(),"CPKT NULL", UVM_LOW)
        if(custom_comp(pkt,cpkt))
        begin
           matched++;
           `uvm_info(get_type_name,"Packet Matched", UVM_LOW); 
        end
        else
        begin
            not_matched++;
           `uvm_info(get_type_name,"Packet not Matched", UVM_LOW); 
        end

        endtask



        task hbus ();
        hbus_transaction hbus_pkt;
        hbus_get_port.get(hbus_pkt);
        if(hbus_pkt.haddr == 16'h1001)
            router_en = 1;
        if(hbus_pkt.haddr == 16'h1000)
            max_packet_size = hbus_pkt.hdata;
        endtask

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


    // function void write_yapp_router(input yapp_packet pkt);
    //     yapp_packet p_copy;
    //     $cast(p_copy,pkt.clone());
    //     //received_packets++;

    //     case(p_copy.addr)
    //     0: q0.push_back(p_copy);
    //     1: q1.push_back(p_copy);
    //     2: q2.push_back(p_copy);
    //     default:
    //         `uvm_warning("YAPP_SB", $sformatf("packet with illegal address %0d recevied", p_copy.addr))
    //     endcase
    // endfunction
    
    // //implemetations to pop packets from appropriate queue

    // function void write_chan0(input channel_packet cp);
    //     yapp_packet yp;
    //     if(cp.addr == 0) begin
    //        yp = q0.pop_front();
    //         received_packets++;
    //         if (custom_comp(yp, cp))
    //             matched_packets++;
    //         else begin
    //             `uvm_error("CHAN0", "No packet to compare in queue 0")
    //             wrong_packets++;
    //         end
    //     end else
    //         $display("Packet expected at channel 0 but received at = %0d", yp.addr);
        
    // endfunction

    // function void write_chan1(input channel_packet cp);
    //     yapp_packet yp;
    //     if(cp.addr == 1) begin
    //        yp = q1.pop_front();
    //         received_packets++;
    //         if (custom_comp(yp, cp))
    //             matched_packets++;
    //         else begin // function void write_yapp_router(input yapp_packet pkt);
    //     yapp_packet p_copy;
    //     $cast(p_copy,pkt.clone());
    //     //received_packets++;

    //     case(p_copy.addr)
    //     0: q0.push_back(p_copy);
    //     1: q1.push_back(p_copy);
    //     2: q2.push_back(p_copy);
    //     default:
    //         `uvm_warning("YAPP_SB", $sformatf("packet with illegal address %0d recevied", p_copy.addr))
    //     endcase
    // endfunction
    
    // //implemetations to pop packets from appropriate queue

    // function void write_chan0(input channel_packet cp);
    //     yapp_packet yp;
    //     if(cp.addr == 0) begin
    //        yp = q0.pop_front();
    //         received_packets++;
    //         if (custom_comp(yp, cp))
    //             matched_packets++;
    //         else begin
    //             `uvm_error("CHAN0", "No packet to compare in queue 0")
    //             wrong_packets++;
    //         end
    //     end else
    //         $display("Packet expected at channel 0 but received at = %0d", yp.addr);
        
    // endfunction

    // function void write_chan1(input channel_packet cp);
    //     yapp_packet yp;
    //     if(cp.addr == 1) begin
    //        yp = q1.pop_front();
    //         received_packets++;
    //         if (custom_comp(yp, cp))
    //             matched_packets++;
    //         else begin
    //             `uvm_error("CHAN1", "No packet to compare in queue 1")
    //             wrong_packets++;
    //         end
    //     end else
    //         $display("Packet expected at channel 1 but received at = %0d", yp.addr);
        
    // endfunction

    // function void write_chan2(input channel_packet cp);
    //     yapp_packet yp;
    //     if(cp.addr == 2) begin
    //        yp = q2.pop_front();
    //         received_packets++;
    //         if (custom_comp(yp, cp))
    //             matched_packets++;
    //         else begin
    //             `uvm_error("CHAN2", "No packet to compare in queue 2")
    //             wrong_packets++;
    //         end
    //     end
    //     elsereceived_packets
    //         $display("Packet expected at channel 2 but received at = 0d", yp.addr);
        
    // endfunction
    //             `uvm_error("CHAN1", "No packet to compare in queue 1")
    //             wrong_packets++;
    //         end
    //     end else
    //         $display("Packet expected at channel 1 but received at = %0d", yp.addr);
        
    // endfunction

    // function void write_chan2(input channel_packet cp);
    //     yapp_packet yp;
    //     if(cp.addr == 2) begin
    //        yp = q2.pop_front();
    //         received_packets++;
    //         if (custom_comp(yp, cp))
    //             matched_packets++;
    //         else begin
    //             `uvm_error("CHAN2", "No packet to compare in queue 2")
    //             wrong_packets++;
    //         end
    //     end
    //     else
    //         $display("Packet expected at channel 2 but received at = 0d", yp.addr);
        
    // endfunction

    function void report_phase(uvm_phase phase);
        //super.report_phase(phase);
            `uvm_info("SB_REPORT", $sformatf("Total Received: %0d", dropped), UVM_LOW)
            `uvm_info("SB_REPORT", $sformatf("Matched Packets: %0d", matched), UVM_LOW)
            `uvm_info("SB_REPORT", $sformatf("Wrong Packets: %0d", not_matched), UVM_LOW)
            // `uvm_info("SB_REPORT", $sformatf("Unmatched in Queue 0: %0d", q0.size()), UVM_LOW)
            // `uvm_info("SB_REPORT", $sformatf("Unmatched in Queue 1: %0d", q1.size()), UVM_LOW)
            // `uvm_info("SB_REPORT", $sformatf("Unmatched in Queue 2: %0d", q2.size()), UVM_LOW)
    endfunction
endclass