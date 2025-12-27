// ==============================
// UART TOP MODULE
// ==============================
// - Integrates UART TX and RX
// - Uses separate baud generators:
//   == TX : 1x baud tick
//   == RX : 16x oversampling tick
// - Fully parameterized for CLK_FREQ and BAUD_RATE
// ==============================

module uart_top #(
    parameter CLK_FREQ  = 50_000_000,   // System clock frequency
    parameter BAUD_RATE = 9600           // UART baud rate
)(
    input  wire        clk,
    input  wire        reset_n,

    // ================= TX PORTS =================
    input  wire        tx_start,
    input  wire [7:0]  tx_data,

    output wire        tx_busy,
    output wire        tx_serial,

    // ================= RX PORTS =================
    input  wire        rx_serial,

    output wire [7:0]  rx_data,
    output wire        data_ready
);

    // ================= INTERNAL BAUD SIGNALS =================
    wire baud_tick;      // TX bit timing (1x baud)
    wire sample_tick;    // RX oversampling timing (16x baud)

    // ================= BAUD RATE GENERATORS ==================
    baud_rate_gen_tx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_baud_tx (
        .clk       (clk),
        .rst_n     (reset_n),
        .baud_tick (baud_tick)
    );

    baud_rate_gen_rx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_baud_rx (
        .clk        (clk),
        .rst_n      (reset_n),
        .sample_tick(sample_tick)
    );

    // ===================== TRANSMITTER =======================
    uart_tx u_tx (
        .clk       (clk),
        .rst_n     (reset_n),
        .baud_tick (baud_tick),
        .tx_start  (tx_start),
        .tx_data   (tx_data),
        .tx        (tx_serial),
        .tx_busy   (tx_busy)
    );

    // ======================= RECEIVER ========================
    uart_rx u_rx (
        .clk        (clk),
        .rst_n      (reset_n),
        .sample_tick(sample_tick),
        .tx_data_rx (rx_serial),
        .rx_data    (rx_data),
        .data_ready (data_ready)
    );

endmodule

