// TX DRIVER

class tx_driver extends uvm_driver #(tx_txn);

    `uvm_component_utils(tx_driver)

    // Object handles
    tx_config                    tx_cfg;
    virtual uart_if.DRV_TX_MP    vif;

    extern function new(string name = "tx_driver", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task send_to_dut(tx_txn req);
endclass

function tx_driver::new(string name = "tx_driver", uvm_component parent);
    super.new(name,parent);
endfunction

function void tx_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Get TX config
    if(!uvm_config_db #(tx_config)::get(this,"","tx_config",tx_cfg)) begin
        `uvm_fatal("TX DRIVER","CANNOT GET DATA FROM TX_CONFIG")
    end

    // Get virtual interface
    if(!uvm_config_db #(virtual uart_if.DRV_TX_MP)::get(this,"","vif",vif)) begin
        `uvm_fatal("TX DRIVER", "CANNOT GET TX VIF")
    end
endfunction

task tx_driver::run_phase(uvm_phase phase);

    tx_txn req;

    // Align to clocking block
    @(vif.drv_tx_cb);

    // Wait for reset deassertion
    while(!vif.drv_tx_cb.rst_n) begin
        vif.drv_tx_cb.tx_start <= 1'b0;
        vif.drv_tx_cb.tx_data  <= '0;
        @(vif.drv_tx_cb);
    end

    forever begin
        seq_item_port.get_next_item(req);
        send_to_dut(req);
        seq_item_port.item_done();
    end
endtask

task tx_driver::send_to_dut(tx_txn req);

    // Wait until DUT is ready (tx_busy == 0)
    while (vif.drv_tx_cb.tx_busy)
        @(vif.drv_tx_cb);

    // Drive transaction
    vif.drv_tx_cb.tx_data  <= req.tx_data;
    vif.drv_tx_cb.tx_start <= 1'b1;
    @(vif.drv_tx_cb);
    vif.drv_tx_cb.tx_start <= 1'b0;
endtask


/* Reset duration is a design contract 
 Reset overrides in-flight transactions 
 Drivers wait, monitors discard, scoreboard flushes 
 Mid-transaction reset is a feature test, not a bug 
*/