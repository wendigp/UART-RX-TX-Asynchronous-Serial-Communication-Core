// TX CONFIGURATION CLASS

class tx_config extends uvm_object;

	`uvm_object_utils(tx_config)

	// TX agent mode
	uvm_active_passive_enum is_active = UVM_ACTIVE;

	// Virtual interface handle
	virtual uart_if vif;

	// UART parameters
	int unsigned oversample = 16;

	// Currently DUT supports fixed 8-N-1
	// Kept for future configurability
	int unsigned data_bits = 8;
	int unsigned stop_bits = 1;

	// Constructor
	function new(string name = "tx_config");
		super.new(name);
	endfunction

endclass

