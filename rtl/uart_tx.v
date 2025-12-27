// UART TRANSMITTER
// - Sends 1 start bit, 8 data bits (LSB first), 1 stop bit
// - Operates on baud_tick (1 tick per bit time)

module uart_tx(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       baud_tick,     // 1 clk pulse per bit time
    input  wire       tx_start,       // Start transmission request
    input  wire [7:0] tx_data,        // Parallel input data

    output reg        tx,             // Serial output line
    output reg        tx_busy          // High while transmission is in progress
);

    // FSM States
    localparam IDLE  = 2'b00,          // Line idle (tx = 1)
               START = 2'b01,          // Start bit
               DATA  = 2'b10,          // Data bits
               STOP  = 2'b11;          // Stop bit

    // Internal registers
    reg [1:0] state;
    reg [7:0] shift_reg;               // Holds data to be transmitted
    reg [3:0] bit_idx;                 // Index for data bits (0 to 7)

    // FSM driven only by baud_tick
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Asynchronous reset
            state      <= IDLE;
            tx         <= 1'b1;         // UART line idle is HIGH
            tx_busy   <= 1'b0;
            bit_idx   <= 4'd0;
            shift_reg <= 8'd0;
        end
        else if (baud_tick) begin
            case (state)

                // ================== IDLE =======================//
                IDLE: begin
                    tx <= 1'b1;         // Keep line HIGH in idle
                    if (tx_start) begin
                        shift_reg <= tx_data;  // Latch data
                        bit_idx   <= 4'd0;     // Reset bit index
                        tx_busy   <= 1'b1;     // Mark TX as busy
                        state     <= START;
                    end
                end

                //=================== START =======================//
                START: begin
                    tx <= 1'b0;         // Transmit start bit
                    state <= DATA;
                end

                // ================== DATA =======================//
                DATA: begin
                    tx <= shift_reg[bit_idx];  // LSB first
                    if (bit_idx == 4'd7) begin
                        bit_idx <= 4'd0;
                        state   <= STOP;
                    end else begin
                        bit_idx <= bit_idx + 1'b1;
                    end
                end

                // ================== STOP ======================//
                STOP: begin
                    tx <= 1'b1;         // Transmit stop bit
                    tx_busy <= 1'b0;    // Transmission complete
                    state <= IDLE;
                end

                // ================ DEFAULT =====================//
                default: begin
                    state    <= IDLE;
                    tx       <= 1'b1;
                    tx_busy  <= 1'b0;
                    bit_idx  <= 4'd0;
                end

            endcase
        end
    end

endmodule
