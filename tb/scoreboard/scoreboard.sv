//==================================================
// SCOREBOARD
//==================================================
// = Compares TX transmitted data with RX received data
// = Uses analysis FIFOs to decouple monitor timing
// = Maintains PASS / FAIL statistics
//==================================================

class scoreboard extends uvm_scoreboard;

    `uvm_component_utils(scoreboard)

    //==================================================
    // TLM ANALYSIS FIFOS
    //==================================================
    uvm_tlm_analysis_fifo #(tx_txn) fifo_tx;
    uvm_tlm_analysis_fifo #(rx_txn) fifo_rx;

    //==================================================
    // RESULT COUNTERS
    //==================================================
    int unsigned pass_cnt;
    int unsigned fail_cnt;

    extern function new(string name = "scoreboard", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task check_data(tx_txn t_data, rx_txn r_data);
    extern function void report_phase(uvm_phase phase);
endclass


//==================================================
// CONSTRUCTOR
//==================================================
function scoreboard::new(string name = "scoreboard", uvm_component parent);
    super.new(name,parent);
endfunction


//==================================================
// BUILD PHASE
//==================================================
function void scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);

    fifo_tx = new("fifo_tx", this);
    fifo_rx = new("fifo_rx", this);

    pass_cnt = 0;
    fail_cnt = 0;
endfunction


//==================================================
// RUN PHASE
//==================================================
task scoreboard::run_phase(uvm_phase phase);

    tx_txn t_data;
    rx_txn r_data;

    forever begin
        //==============================================
        // GET TX DATA (EXPECTED)
        //==============================================
        fifo_tx.get(t_data);
        `uvm_info("TX_SCOREBOARD",$sformatf("TX DATA RECEIVED:\n%s", t_data.sprint()),UVM_LOW)

        //==============================================
        // GET RX DATA (ACTUAL)
        //==============================================
        fifo_rx.get(r_data);
        `uvm_info("RX_SCOREBOARD",$sformatf("RX DATA RECEIVED:\n%s", r_data.sprint()),UVM_LOW)

        //==============================================
        // COMPARE DATA
        //==============================================
        check_data(t_data, r_data);
    end
endtask


//==================================================
// DATA COMPARISON
//==================================================
task scoreboard::check_data(tx_txn t_data, rx_txn r_data);

    if (t_data.tx_data == r_data.rx_data) begin
        pass_cnt++;
        `uvm_info("SCOREBOARD",$sformatf("PASS = TX = %h RX = %h",t_data.tx_data, r_data.rx_data),UVM_LOW)
    end
    else begin
        fail_cnt++;
        `uvm_error("SCOREBOARD",$sformatf("FAIL = TX = %h RX = %h",t_data.tx_data, r_data.rx_data))
    end
endtask


//==================================================
// REPORT PHASE
//==================================================
function void scoreboard::report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info("SCOREBOARD_REPORT",$sformatf("FINAL RESULT = PASS = %0d, FAIL = %0d", pass_cnt, fail_cnt),UVM_LOW)

    if (fail_cnt == 0)
        `uvm_info("SCOREBOARD_REPORT", "TEST PASSED", UVM_NONE)
    else
        `uvm_error("SCOREBOARD_REPORT", "TEST FAILED")
endfunction

