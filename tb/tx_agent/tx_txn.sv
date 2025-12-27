//TX TRANSACTION
class tx_txn extends uvm_sequence_item;

	`uvm_object_utils(tx_txn)

	//DATA TO BE TRANSMITTED
	rand bit [7:0] tx_data;
	
	extern function new(string name = "tx_txn");
	extern function void do_print(uvm_printer printer);
endclass

function tx_txn::new(string name = "tx_txn");
	super.new(name);
endfunction

function void tx_txn::do_print(uvm_printer printer);
	super.do_print(printer);

	printer.print_field("TX_DATA",this.tx_data, 8, UVM_HEX);
endfunction