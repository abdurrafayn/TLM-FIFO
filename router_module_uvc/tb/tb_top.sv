module tb_top;
    import uvm_pkg::*;
    
    `include "uvm_macros.svh"
    
    //importing package files 
    import yapp_pkg::*;
    import channel_pkg::*;
    import clock_and_reset_pkg::*;
    import hbus_pkg::*;
   
    `include "../sv/router_reference.sv"
    
    `include "router_scoreboard.sv"
    
    `include "../sv/router_module_env.sv"
    
    `include "router_mcsequencer.sv"
    
    `include "router_mcseqs_lib.sv"

    `include "router_tb.sv"  
    
    `include "router_test_lib.sv"  
    
    initial begin
        yapp_vif_config::set(null,"uvm_test_top.inst_tb.environment.agent.*","vif",hw_top.in0);

        channel_vif_config::set(null,"uvm_test_top.inst_tb.channel_0.rx_agent.*","vif",hw_top.ch0_vif);
        channel_vif_config::set(null,"uvm_test_top.inst_tb.channel_1.rx_agent.*","vif",hw_top.ch1_vif);
        channel_vif_config::set(null,"uvm_test_top.inst_tb.channel_2.rx_agent.*","vif",hw_top.ch2_vif);

        clock_and_reset_vif_config::set(null,"uvm_test_top.inst_tb.clock_and_reset.agent.*","vif",hw_top.cr_vif);
        hbus_vif_config::set(null,"uvm_test_top.inst_tb.hbus.*","vif",hw_top.hbus_vif);


        run_test();
    end


    //uvm_test_top.inst_tb.environment.agent.

endmodule

