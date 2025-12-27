//==================================================
// RX MONITOR
//==================================================
// = Observes RX parallel output from DUT
// = Samples data when data_ready is asserted
// = Publishes transaction to scoreboard
// = Collects functional coverage
//==================================================

class rx_monitor extends uvm_monitor;
    
    `uvm_component_utils(rx_monitor)

    //==================================================
    // HANDLE DECLARATIONS
    //==================================================
    virtual uart_if.MON_RX_MP      vif;
    rx_config                      rx_cfg;

    uvm_analysis_port #(rx_txn)    monitor_port;

    // Coverage transaction handle
    rx_txn cov_xtn;

    //==================================================
    // FUNCTIONAL COVERAGE (FIXED 8-BIT UART)
    //==================================================
    covergroup rx_cg;
        option.per_instance = 1;

        // RX data value coverage
        cp_rx_data : coverpoint cov_xtn.rx_data {
            bins zero = {8'h00};
            bins max  = {8'hFF};
            bins mid[] = {[8'h01:8'hFE]};
        }

        // MSB coverage
        cp_msb : coverpoint cov_xtn.rx_data[7] {
            bins zero = {0};
            bins one  = {1};
        }

        // Cross coverage
        cross_rx : cross cp_rx_data, cp_msb;
    endgroup

    extern function new(string name = "rx_monitor", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task collect_data();
endclass

//==================================================
// CONSTRUCTOR
//==================================================
function rx_monitor::new(string name = "rx_monitor", uvm_component parent);
    super.new(name,parent);
    monitor_port = new("monitor_port", this);
    rx_cg = new();
endfunction

//==================================================
// BUILD PHASE
//==================================================
function void rx_monitor::build_phase (uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db #(rx_config)::get(this,"","rx_config",rx_cfg)) begin
        `uvm_fatal("RX MONITOR","CANNOT GET DATA FROM RX_CONFIG. HAVE YOU SET IT?")
    end

    if(!uvm_config_db #(virtual uart_if.MON_RX_MP)::get(this,"","vif",vif)) begin
        `uvm_fatal("RX MONITOR","CANNOT GET RX VIF")
    end
endfunction

//==================================================
// RUN PHASE
//==================================================
task rx_monitor::run_phase (uvm_phase phase);

    // Align once before monitoring
    @(vif.mon_rx_cb);

    //==================================================
    // WAIT FOR RESET DEASSERTION
    //==================================================
    while(!vif.mon_rx_cb.rst_n)
        @(vif.mon_rx_cb);

    //==================================================
    // CONTINUOUS MONITORING
    //==================================================
    forever begin
        collect_data();
    end
endtask

//==================================================
// COLLECT RX DATA
//==================================================
task rx_monitor::collect_data();

    rx_txn xtn;
    xtn = rx_txn::type_id::create("xtn");

    //==================================================
    // WAIT FOR RX DATA VALID
    //==================================================
    while(!vif.mon_rx_cb.data_ready)
        @(vif.mon_rx_cb);

    //==================================================
    // SAMPLE DATA
    //==================================================
    xtn.rx_data    = vif.mon_rx_cb.rx_data;

    //==================================================
    // FUNCTIONAL COVERAGE
    //==================================================
    cov_xtn = xtn;
    rx_cg.sample();

    //==================================================
    // SEND TO SCOREBOARD
    //==================================================
    monitor_port.write(xtn);

    //==================================================
    // WAIT FOR data_ready DEASSERTION
    //==================================================
    while(vif.mon_rx_cb.data_ready)
        @(vif.mon_rx_cb);
endtask
