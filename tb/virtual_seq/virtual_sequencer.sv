//==================================================
// VIRTUAL SEQUENCER
//==================================================

class v_sequencer extends uvm_sequencer #(uvm_sequence_item);  // This sequencer does not arbitrate sequence items.It exists only to coordinate other sequencers

    `uvm_component_utils(v_sequencer)

    //==================================================
    // HANDLE DECLARATIONS
    //==================================================
    tx_sequencer   tx_seqr;
    env_config     env_cfg;

    extern function new(string name = "v_sequencer", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
endclass

//==================================================
// CONSTRUCTOR
//==================================================
function v_sequencer::new(string name = "v_sequencer", uvm_component parent);
    super.new(name,parent);
endfunction

//==================================================
// BUILD PHASE
//==================================================
function void v_sequencer::build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db #(env_config)::get(this,"","env_config",env_cfg)) begin
        `uvm_fatal("VIRTUAL_SEQUENCER",
                   "CANNOT GET DATA FROM ENV_CONFIG. HAVE YOU SET IT?")
    end
endfunction

