//==================================================
// RX TRANSACTION
//==================================================

class rx_txn extends uvm_sequence_item;

    `uvm_object_utils(rx_txn)

    //==================================================
    // DATA RECEIVED BY DUT
    //==================================================
    bit [7:0] rx_data;

    // NOTE:
    // = data_ready is a control/handshake signal
    // = It should NOT be part of the transaction
    // = Transaction represents stable, observed data only

    extern function new(string name = "rx_txn");
    extern function void do_print(uvm_printer printer);
endclass


//==================================================
// CONSTRUCTOR
//==================================================
function rx_txn::new(string name = "rx_txn");
    super.new(name);
endfunction

//==================================================
// PRINT METHOD
//==================================================
function void rx_txn::do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field("RX_DATA", this.rx_data, 8, UVM_HEX);
endfunction
