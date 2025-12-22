//Baud rate generator

module baud_rate_gen_tx #(
	parameter CLK_FREQ = 50_000_000,   	//System Clk Frequency
	parameter BAUD_RATE = 9600		//Desired Baud Rate
	)(
		input wire clk,
		input wire rst_n,
		output reg baud_tick);		//1 clk pulse per bit time

localparam integer BAUD_CNT_MAX = CLK_FREQ / BAUD_RATE;

reg [$clog2(BAUD_CNT_MAX)-1 : 0] baud_cnt;

always@(posedge clk, negedge rst_n)
	begin
		if(!rst_n) 
			begin
			baud_tick <= 1'b0;
			baud_cnt <= 1'b0;
			end
		else 
			begin
			if (baud_cnt == BAUD_CNT_MAX) 
				begin
				baud_cnt <= 1'b0;
				baud_tick  <= 1'b1;
				end
			else
				begin
				baud_cnt <= baud_cnt + 1'b1;
				baud_tick  <= 1'b0;
				end
			end
	end
endmodule


