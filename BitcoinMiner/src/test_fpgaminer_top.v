// Testbench for fpgaminer_top.v
// TODO: Expand and generalize to test any mining core or complete design.
//


`timescale 1ns/1ps

module test_fpgaminer_top(input [255:0] midstate_buf,
	input [511:0] data_2,
	input newinput,
	output reg [255:0] midstate_buf_out,
	output reg [511:0] data_out,
	output [31:0] golden_nonce,
	output golden_nonce_ticket);

	reg clk = 1'b0;

	fpgaminer_top # (.LOOP_LOG2(0)) uut (clk, midstate_buf_out, data_out);

	reg [31:0] cycle = 32'd0;

	initial begin
		clk = 0;
		#100


		// Test data
		uut.midstate_buf = midstate_buf; //256'h228ea4732a3c9ba860c009cda7252b9161a5e75ec8c582a5f106abb3af41f790;
		uut.data_buf = data_2; //512'h000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000002194261a9395e64dbed17115;
		uut.nonce = data_2[127:96]; //32'h0e33337a - 256;	// Minus a little so we can exercise the code a bit
    
	 while(1)
		begin
			#5 clk = 1; #5 clk = 0;
		end
	end


	always @ (posedge clk)
	begin
		if (newinput)
		begin
			midstate_buf_out = midstate_buf; //256'h228ea4732a3c9ba860c009cda7252b9161a5e75ec8c582a5f106abb3af41f790;
			data_out = data_2;//512'h000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000002194261a9395e64dbed17115;
			uut.nonce = data_2[127:96]; //32'h0e33337a - 256;	// Minus a little so we can exercise the code a bit
    	end
		cycle <= cycle + 32'd1;
	end

endmodule

