// INTERFACE
interface uart_if (input bit clk);

    logic rst_n;

    // TX Control (parallel side)
    logic        tx_start;
    logic [7:0]  tx_data;
    logic        tx_busy;

    // Serial side
    logic tx;    // DUT TX output
    logic rx;    // DUT RX input

    // RX output (parallel side)
    logic [7:0] rx_data;
    logic       data_ready;

    // ================= TX DRIVER =================
    clocking drv_cb_tx @(posedge clk);
        default input #0 output #0;
        output rst_n;
        output tx_start;
        output tx_data;
        input  tx_busy;
    endclocking

    // ================= TX MONITOR =================
    clocking mon_cb_tx @(posedge clk);
        default input #0 output #0;
        input tx;
        input tx_busy;
    endclocking

    // ================= RX DRIVER =================
    clocking drv_cb_rx @(posedge clk);
        default input #0 output #0;
        output rx;
    endclocking

    // ================= RX MONITOR =================
    clocking mon_cb_rx @(posedge clk);
        default input #0 output #0;
        input rx;
        input rx_data;
        input data_ready;
    endclocking

    // ================= MODPORTS =================
    modport DRV_MP_TX (clocking drv_cb_tx);
    modport MON_MP_TX (clocking mon_cb_tx);
    modport DRV_MP_RX (clocking drv_cb_rx);
    modport MON_MP_RX (clocking mon_cb_rx);

endinterface

