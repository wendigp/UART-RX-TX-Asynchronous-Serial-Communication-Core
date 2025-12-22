// UART TRANSMITTER

module uart_tx(
	input wire clk,
	input wire rst_n,
	input wire baud_tick,			// 1 clk pulse per bit time
	input wire tx_start,
	input wire [7:0]tx_data,		//Parallel input data

	output reg tx,				//Serial data output
	output reg tx_busy);


	//FSM States
	localparam 	IDLE = 2'b00,
			START = 2'b01,
			DATA = 2'b10,
			STOP = 2'b11;

	//Internal control signals
	reg [1:0] state;
	reg [7:0] shift_reg;
	reg [3:0] bit_idx;			//Index for data bits

	always @(posedge clk , negedge rst_n)
		begin
		if(!rst_n)
			begin
			state <= IDLE;
			tx    <= 1'b1;		//HIGH by default
			tx_busy <= 1'b0;
			bit_idx <= 4'd0;
			shift_reg <= 8'd0;

			end

		else if (baud_tick)
			begin
			case (state)
			IDLE :  begin		
				tx 	<= 1'b1;
				tx_busy <= 1'b0;
				if(tx_start) 
					begin
					shift_reg <= tx_data;
					state	  <= START;
					tx_busy   <= 1'b1;
					end
				end
			START :  begin
				tx <= 1'b0;			//Start bit
				bit_idx <= 4'd0;
				state <= DATA;
				end
			DATA : begin
				tx <= shift_reg [bit_idx]; 		//LSB first
				if(bit_idx == 4'd7)
					begin
					bit_idx <= 4'd0;
					state <= STOP;
					end
				else
					begin
					bit_idx <= bit_idx + 1'b1;
					state <= DATA;
					end
				end

			STOP : begin
				tx <= 1'b1;
				state <= IDLE;
				end
			default : begin
					state <= IDLE;
					tx <= 1'b1;
				  end
			endcase
		end
		end

endmodule



			

	