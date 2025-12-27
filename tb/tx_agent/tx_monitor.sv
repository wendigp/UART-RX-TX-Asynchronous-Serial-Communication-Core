//==================================================
// TX MONITOR
//==================================================
// = Observes serial TX line
// = Detects start bit
// = Samples data bits using oversampling
// = Reconstructs parallel data
// = Publishes transaction to scoreboard
// = Collects functional coverage
//==================================================

class tx_monitor extends uvm_monitor;
    
    `uvm_component_utils(tx_monitor)

    //==================================================
    // HANDLE DECLARATIONS
    //==================================================
    virtual uart_if.MON_TX_MP      vif;
    tx_config                      tx_cfg;

    uvm_analysis_port #(tx_txn)    monitor_port;

    // Coverage transaction handle
    tx_txn cov_xtn;

    //==================================================
    // FUNCTIONAL COVERAGE (FIXED 8-BIT UART)
    //==================================================
    covergroup tx_cg;
        option.per_instance = 1;

        // TX data coverage
        cp_tx_data : coverpoint cov_xtn.tx_data {
            bins zero = {8'h00};
            bins max  = {8'hFF};
            bins mid[] = {[8'h01:8'hFE]};
        }

        // MSB coverage
        cp_msb : coverpoint cov_xtn.tx_data[7] {
            bins zero = {0};
            bins one  = {1};
        }

        // Cross coverage
        cross_tx : cross cp_tx_data, cp_msb;
    endgroup

    extern function new(string name = "tx_monitor", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task collect_data();
endclass

//==================================================
// CONSTRUCTOR
//==================================================
function tx_monitor::new(string name = "tx_monitor", uvm_component parent);
    super.new(name,parent);
    monitor_port = new("monitor_port", this);
    tx_cg = new();
endfunction

//==================================================
// BUILD PHASE
//==================================================
function void tx_monitor::build_phase (uvm_phase phase);
    super.build_phase(phase);

    // Get TX configuration
    if(!uvm_config_db #(tx_config)::get(this,"","tx_config",tx_cfg)) begin
        `uvm_fatal("TX MONITOR","CANNOT GET DATA FROM TX_CONFIG. HAVE YOU SET IT?")
    end

    // Get virtual interface
    if(!uvm_config_db #(virtual uart_if.MON_TX_MP)::get(this,"","vif",vif)) begin
        `uvm_fatal("TX MONITOR","CANNOT GET TX VIF")
    end
endfunction

//==================================================
// RUN PHASE
//==================================================
task tx_monitor::run_phase (uvm_phase phase);

    // Align once before starting monitoring
    @(vif.mon_tx_cb);

    //==================================================
    // WAIT FOR RESET DEASSERTION
    //==================================================
    while(!vif.mon_tx_cb.rst_n)
        @(vif.mon_tx_cb);

    //==================================================
    // CONTINUOUS MONITORING
    //==================================================
    forever begin
        collect_data();
    end
endtask

//==================================================
// COLLECT SERIAL DATA AND RECONSTRUCT BYTE
//==================================================
task tx_monitor::collect_data();
    tx_txn xtn;
    bit [7:0] data;

    xtn = tx_txn::type_id::create("xtn");

    //==================================================
    // WAIT FOR START BIT (tx == 0)
    //==================================================
    while(vif.mon_tx_cb.tx == 1'b1)
        @(vif.mon_tx_cb);

    //==================================================
    // MOVE TO MIDDLE OF START BIT
    //==================================================
    repeat(tx_cfg.oversample / 2)
        @(vif.mon_tx_cb);

    //==================================================
    // SAMPLE DATA BITS (LSB FIRST)
    //==================================================
    for (int i = 0; i < 8; i++) begin
        repeat(tx_cfg.oversample)
            @(vif.mon_tx_cb);
        data[i] = vif.mon_tx_cb.tx;
    end

    //==================================================
    // SAMPLE STOP BIT
    //==================================================
    repeat(tx_cfg.stop_bits * tx_cfg.oversample)
        @(vif.mon_tx_cb);

    if(vif.mon_tx_cb.tx != 1'b1)
        `uvm_error("TX MONITOR", "STOP BIT ERROR")

    //==================================================
    // PUBLISH DATA
    //==================================================
    xtn.tx_data = data;

    //==================================================
    // FUNCTIONAL COVERAGE
    //==================================================
    cov_xtn = xtn;
    tx_cg.sample();

    //==================================================
    // SEND DATA TO SCOREBOARD
    //==================================================
    monitor_port.write(xtn);
endtask

