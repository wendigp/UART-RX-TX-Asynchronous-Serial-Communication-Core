// TX SEQUENCER

class tx_sequencer extends uvm_sequencer #(tx_txn);

  `uvm_component_utils(tx_sequencer)

  extern function new(string name = "tx_sequencer", uvm_component parent);

endclass


function tx_sequencer::new(string name = "tx_sequencer", uvm_component parent);
	super.new(name, parent);
endfunction

