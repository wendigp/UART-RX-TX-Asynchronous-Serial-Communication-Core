//==================================================
// VIRTUAL SEQUENCES
//==================================================

//==================================================
// BASE VIRTUAL SEQUENCE
//==================================================
class v_base_seq extends uvm_sequence #(uvm_sequence_item);

    `uvm_object_utils(v_base_seq)

    //==================================================
    // HANDLE DECLARATIONS
    //==================================================
    tx_sequencer    tx_seqr;
    v_sequencer     v_seqr;

    extern function new(string name = "v_base_seq");
    extern task body();
endclass

function v_base_seq::new(string name = "v_base_seq");
    super.new(name);
endfunction

task v_base_seq::body();

    //==================================================
    // CAST m_sequencer TO VIRTUAL SEQUENCER
    //==================================================
    if(!$cast(v_seqr, m_sequencer)) begin
        `uvm_fatal("VIRTUAL_SEQ", "SEQUENCER CASTING FAILED")
    end

    //==================================================
    // GET ACTUAL SEQUENCERS FROM ENV
    //==================================================
    tx_seqr = v_seqr.tx_seqr;
endtask


//==================================================
// TC 1 = RANDOM TX VIRTUAL SEQUENCE
//==================================================
class v_random_tx_seq extends v_base_seq;

    `uvm_object_utils(v_random_tx_seq)

    extern function new(string name = "v_random_tx_seq");
    extern task body();
endclass

function v_random_tx_seq::new(string name = "v_random_tx_seq");
    super.new(name);
endfunction

task v_random_tx_seq::body();

	 random_tx_seq random;
    //==================================================
    // INITIALIZE BASE VIRTUAL SEQUENCE
    //==================================================
    super.body();

    //==================================================
    // START RANDOM TX SEQUENCE
    //==================================================
   
    random = random_tx_seq::type_id::create("random");
    random.start(tx_seqr);
endtask


//==================================================
// TC 2 = DIRECTED TX VIRTUAL SEQUENCE
//==================================================
class v_directed_tx_seq extends v_base_seq;

    `uvm_object_utils(v_directed_tx_seq)

    extern function new(string name = "v_directed_tx_seq");
    extern task body();
endclass

function v_directed_tx_seq::new(string name = "v_directed_tx_seq");
    super.new(name);
endfunction

task v_directed_tx_seq::body();

	   directed_tx_seq directed;
    //==================================================
    // INITIALIZE BASE VIRTUAL SEQUENCE
    //==================================================
    super.body();

    //==================================================
    // START DIRECTED TX SEQUENCE
    //==================================================
 
    directed = directed_tx_seq::type_id::create("directed");
    directed.start(tx_seqr);
endtask

