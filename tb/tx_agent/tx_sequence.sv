//==================================================
// TX SEQUENCES
//==================================================

//==================================================
// BASE SEQUENCE
//==================================================
class base_seq extends uvm_sequence #(tx_txn);

    `uvm_object_utils(base_seq)
    
    // Number of transactions
    int unsigned num_txns = 10;
    
    extern function new(string name = "base_seq");
endclass

function base_seq::new(string name = "base_seq");
    super.new(name);
endfunction


//==================================================
// FULLY RANDOM TX SEQUENCE
//==================================================
class random_tx_seq extends base_seq;
    
    `uvm_object_utils(random_tx_seq)

    extern function new(string name = "random_tx_seq");
    extern task body();
endclass

function random_tx_seq::new(string name = "random_tx_seq");
    super.new(name);
endfunction

task random_tx_seq::body();
    tx_txn req;

    repeat(num_txns) begin
        req = tx_txn::type_id::create("req");
        start_item(req);

        if(!req.randomize())
            `uvm_error("RAND_TX_SEQ", "Randomization failed")

        finish_item(req);
    end
endtask


//==================================================
// DIRECTED PATTERN TX SEQUENCE
//==================================================
class directed_tx_seq extends base_seq;
    
    `uvm_object_utils(directed_tx_seq)

    extern function new(string name = "directed_tx_seq");
    extern task body();
endclass

function directed_tx_seq::new(string name = "directed_tx_seq");
    super.new(name);
endfunction

task directed_tx_seq::body();
    tx_txn req;

    repeat(num_txns) begin
        req = tx_txn::type_id::create("req");
        start_item(req);

        if(!req.randomize() with { tx_data == 8'hA5; })
            `uvm_error("DIRECTED_TX_SEQ", "Randomization failed")

        finish_item(req);
    end
endtask

