class router_module_env extends uvm_env;

        `uvm_component_utils(router_module_env)

        uvm_analysis_export #(yapp_packet) yapp_packet_in_export;
        uvm_analysis_export #(channel_packet) chan0_packet_export;
        uvm_analysis_export #(channel_packet) chan1_packet_export;
        uvm_analysis_export #(channel_packet) chan2_packet_export;
        uvm_analysis_export #(hbus_transaction) hbus_packet_export;


        router_scoreboard yapp_router_scb;
        router_reference yapp_router_ref;

    function new (string name, uvm_component parent);
        super.new(name,parent);                 
    endfunction

    virtual function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        yapp_router_scb = router_scoreboard::type_id::create("yapp_router_scb", this);
        yapp_router_ref = router_reference::type_id::create("yapp_router_ref", this);


        //creating exports

        yapp_packet_in_export = new("yapp_packet_in_export", this);
        chan0_packet_export = new("chan0_packet_export", this);
        chan1_packet_export = new("chan1_packet_export", this);
        chan2_packet_export = new("chan2_packet_export", this);
        hbus_packet_export = new("hbus_packet_export", this);


    endfunction

    virtual function void connect_phase(uvm_phase phase);
        yapp_router_ref.yapp_to_ref.connect(yapp_router_scb.router_packet_in);

        chan0_packet_export.connect(yapp_router_scb.channel_0_packet);
        chan1_packet_export.connect(yapp_router_scb.channel_1_packet);
        chan2_packet_export.connect(yapp_router_scb.channel_2_packet);
        yapp_packet_in_export.connect(yapp_router_ref.yapp_packet_in);
        hbus_packet_export.connect(yapp_router_ref.hbus_packet_in);

    endfunction
endclass

