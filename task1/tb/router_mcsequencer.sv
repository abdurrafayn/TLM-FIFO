class router_mcsequencer extends uvm_sequencer;


yapp_tx_sequencer yapp;
hbus_master_sequencer hbus;


`uvm_component_utils(router_mcsequencer)
  //  `uvm_field_object(yapp,hbus)
//`uvm_component_utils_end


function new(string name, uvm_component parent);
    super.new(name,parent);
endfunction


endclass