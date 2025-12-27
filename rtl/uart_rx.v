// UART RECEIVER (16x Oversampling)

module uart_rx (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       tx_data_rx,
    input  wire       sample_tick,

    output reg [7:0]  rx_data,
    output reg        data_ready
);

    // FSM States
    localparam IDLE  = 3'd0,
               START = 3'd1,
               DATA  = 3'd2,
               STOP  = 3'd3,
               DONE  = 3'd4;

    reg [2:0] state;
    reg [7:0] data_reg;
    reg [2:0] data_idx;
    reg [3:0] rx_cnt;          // 0?15 (16x oversampling)

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            rx_cnt     <= 4'd0;
            data_reg   <= 8'd0;
            data_idx   <= 3'd0;
            rx_data    <= 8'd0;
            data_ready <= 1'b0;
        end
        else if (sample_tick) begin
            data_ready <= 1'b0;

            case (state)

                // ---------------- IDLE ----------------
                IDLE: begin
                    rx_cnt   <= 4'd0;
                    data_idx <= 3'd0;
                    if (tx_data_rx == 1'b0)
                        state <= START;
                end

                // ---------------- START ----------------
                START: begin
                    rx_cnt <= rx_cnt + 1'b1;
                    if (rx_cnt == 4'd7) begin       // center of start bit
                        if (tx_data_rx == 1'b0) begin
                            state  <= DATA;
                            rx_cnt <= 4'd0;
                        end else begin               // false start
                            state  <= IDLE;
                            rx_cnt <= 4'd0;
                        end
                    end
                end

                // ---------------- DATA ----------------
                DATA: begin
                    rx_cnt <= rx_cnt + 1'b1;
                    if (rx_cnt == 4'd15) begin
                        data_reg[data_idx] <= tx_data_rx;
                        rx_cnt <= 4'd0;

                        if (data_idx == 3'd7) begin
                            state    <= STOP;
                            data_idx <= 3'd0;
                        end else begin
                            data_idx <= data_idx + 1'b1;
                        end
                    end
                end

                // ---------------- STOP ----------------
                STOP: begin
                    rx_cnt <= rx_cnt + 1'b1;
                    if (rx_cnt == 4'd15) begin
                        rx_cnt <= 4'd0;
                        if (tx_data_rx == 1'b1)
                            state <= DONE;
                        else begin                   // framing error
                            state    <= IDLE;
                            data_idx <= 3'd0;
                        end
                    end
                end

                // ---------------- DONE ----------------
                DONE: begin
                    rx_data    <= data_reg;
                    data_ready <= 1'b1;              // 1-cycle pulse
                    state      <= IDLE;
                end

                // ---------------- DEFAULT ----------------
                default: begin
                    state    <= IDLE;
                    rx_cnt   <= 4'd0;
                    data_idx <= 3'd0;
                end

            endcase
        end
    end

endmodule

