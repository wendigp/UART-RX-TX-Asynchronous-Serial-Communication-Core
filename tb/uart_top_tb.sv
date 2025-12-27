// ================================
// UART TOP TESTBENCH (UVM)
// ================================
`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

module uart_top_tb;

    // -----------------------------
    // Clock & Reset
    // -----------------------------
    bit clk;

    // Clock generation: 50 MHz (20 ns period)
    initial clk = 0;
    always #10 clk = ~clk;

    // -----------------------------
    // Interface
    // -----------------------------
    uart_if u_if (.clk(clk));

    // -----------------------------
    // DUT Instantiation
    // -----------------------------
    uart_top dut (
        .clk        (clk),
        .reset_n    (u_if.rst_n),

        // TX
        .tx_start   (u_if.tx_start),
        .tx_data    (u_if.tx_data),
        .tx_busy    (u_if.tx_busy),
        .tx_serial  (u_if.tx),

        // RX
        .rx_serial  (u_if.rx),
        .rx_data    (u_if.rx_data),
        .data_ready (u_if.data_ready)
    );

    // -----------------------------
    // Reset Generation
    // -----------------------------
    initial begin
        u_if.rst_n = 1'b0;
        repeat (10) @(posedge clk);
        u_if.rst_n = 1'b1;
    end

    // -----------------------------
    // UVM Configuration & Run
    // -----------------------------
    initial begin
        // Make virtual interface available to all UVM components
        uvm_config_db#(virtual uart_if)::set(null, "*", "vif", u_if);

        run_test();   // default test
    end

endmodule

