class router_scoreboard_new extends uvm_scoreboard;
`uvm_component_utils(router_scoreboard_new)

    int received_packets = 0; 
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
        forever begin
                yapp_get_port.get(pkt);
                received_packets++; 
                `uvm_info(get_type_name(),"Received Packet 313", UVM_LOW)
                if((!router_en) || (max_packet_size > pkt.length) || (pkt.addr > 2)) begin
                dropped++;
                `uvm_info(get_type_name(),"INSIDE IF LOOP", UVM_LOW)
                end
                else begin
                case(pkt.addr)
                    2'b00:chan0_get_port.get(cpkt);
                    2'b01:chan1_get_port.get(cpkt);
                    2'b10:chan2_get_port.get(cpkt);
                endcase
                if(pkt == null)
                `uvm_info(get_type_name(),"PKT NULL", UVM_LOW)


                if(cpkt == null) begin
                `uvm_info(get_type_name(),"CPKT NULL", UVM_LOW)
                return;
                end 

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
                end

        end
        endtask

        task hbus ();
        hbus_transaction hbus_pkt;
        hbus_get_port.get(hbus_pkt);
        if(hbus_pkt.haddr == 16'h1001 && (hbus_pkt.haddr == HBUS_WRITE))
            router_en = 1;
        if(hbus_pkt.haddr == 16'h1000 && (hbus_pkt.haddr == HBUS_WRITE))
            max_packet_size = hbus_pkt.hdata;
        endtask

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



    function void report_phase(uvm_phase phase);
        //super.report_phase(phase);
            `uvm_info("SB_REPORT", $sformatf("Total Received: %0d", received_packets), UVM_LOW)
            `uvm_info("SB_REPORT", $sformatf("Matched Packets: %0d", matched), UVM_LOW)
            `uvm_info("SB_REPORT", $sformatf("Wrong Packets: %0d", not_matched), UVM_LOW)
            `uvm_info("SB_REPORT", $sformatf("Dropped Packets: %0d", dropped), UVM_LOW)
            // `uvm_info("SB_REPORT", $sformatf("Unmatched in Queue 0: %0d", q0.size()), UVM_LOW)
            // `uvm_info("SB_REPORT", $sformatf("Unmatched in Queue 1: %0d", q1.size()), UVM_LOW)
            // `uvm_info("SB_REPORT", $sformatf("Unmatched in Queue 2: %0d", q2.size()), UVM_LOW)
    endfunction
endclass