// RX CONFIGURATION CLASS

class rx_config extends uvm_object;

	`uvm_object_utils(rx_config)

	// RX agent mode
	uvm_active_passive_enum is_active = UVM_PASSIVE;

	// Virtual interface handle
	virtual uart_if vif;

	// UART parameters
	int unsigned oversample = 16;
	int unsigned data_bits = 8;
	int unsigned stop_bits = 1;

	// Constructor
	function new(string name = "rx_config");
		super.new(name);
	endfunction

endclass

