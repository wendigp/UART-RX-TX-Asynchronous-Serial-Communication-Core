//ENV CONFIG
class env_config extends uvm_object;

	`uvm_object_utils(env_config)

	//Config declaration for both TX & RX
	tx_config	tx_cfg;
	rx_config	rx_cfg;

	//FLAGS
	bit has_tx_agent = 1;
	bit has_rx_agent = 1;
	bit has_virtual_sequencer = 1;
	bit has_scoreboard = 1;

	extern function new (string name = "env_config");
endclass

function env_config:: new(string name = "env_config");
	super.new(name);
endfunction
