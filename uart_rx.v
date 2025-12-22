//UART RECIEVER

module uart_rx (
		input wire clk,
		input wire rst_n,
		input wire tx_data_rx,
		input wire sample_tick,
		
		output reg [7:0]rx_data,
		output reg data_ready);

//FSM STATES
localparam IDLE = 3'd0,
		START = 3'd1,
		DATA = 3'd2,
		STOP = 3'd3,
		DONE = 3'd4;

reg [2:0] state;
reg [7:0] data_reg;
reg [2:0] data_idx;
reg [3:0] rx_cnt;			// 0-15 16x oversampling


always @(posedge clk, negedge rst_n)
	begin
		if(!rst_n)
			begin
			state <= IDLE;
			rx_cnt <= 4'd0;
			data_reg <= 8'd0;
			data_idx <= 3'd0;
			rx_data  <= 8'd0;
			data_ready <= 1'b0;
			end
		else if (sample_tick)
			begin 
			data_ready <= 1'b0;
			
			case(state)
				IDLE : begin
					if(tx_data_rx == 1'b0)
						begin
						state <= START;
						rx_cnt <= 4'd0;
						end
					else
						state <= IDLE;
					end

				START : begin
					rx_cnt <= rx_cnt + 1; 		
					if(rx_cnt == 4'd7)		//Centre of start bit
					begin
					if(tx_data_rx == 0)
						begin
						state <= DATA;
						rx_cnt <= 4'd0;
						data_idx <= 3'd0;
						end
					else
						state <= IDLE;		//False Start
					end
					end
	
				DATA : begin
					rx_cnt <= rx_cnt +1;	
					if(rx_cnt == 4'd15)
						begin
							data_reg[data_idx] <= tx_data_rx;
							data_idx 	   <= data_idx + 1;
							rx_cnt 		   <= 4'd0;
							if(data_idx == 3'd7)
								state <= STOP;
						end
					end

				STOP : begin
					rx_cnt <= rx_cnt + 1;
					if(rx_cnt == 4'd15)
						begin
							if(tx_data_rx)
								state <= DONE;
							else
								state <= IDLE;		//framing error
						rx_cnt <= 4'd0;
						end
					end

				DONE : begin
					rx_data <= data_reg;
					data_ready <= 1'b1;
					state <= IDLE;
					end
			endcase
		end
	end
endmodule
		

