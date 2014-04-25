

module miner_top(
	input clk,
	input reset,
	input write,
	input [31:0] writedata,
	input [4:0] address);
	
	reg [767:0] header_buffer;
	reg loading = 1'b0;
	reg start = 1'b0;
	
	fpgaminer_top miner (clk, header_buffer, loading);
	
	
	always @(posedge clk) begin
		if(reset) begin
			loading = 1'b1;
		end
		else if(write && loading) begin
			case(address)
				5'd0: header_buffer[31:0] <= writedata;
				5'd1: header_buffer[63:32] <= writedata;
				5'd2: header_buffer[95:64] <= writedata;
				5'd3: header_buffer[127:96] <= writedata;
				5'd4: header_buffer[159:128] <= writedata;
				5'd5: header_buffer[191:160] <= writedata;
				5'd6: header_buffer[223:192] <= writedata;
				5'd7: header_buffer[255:224] <= writedata;
				5'd8: header_buffer[287:256] <= writedata;
				5'd9: header_buffer[319:288] <= writedata;
				5'd10: header_buffer[351:320] <= writedata;
				5'd11: header_buffer[383:352] <= writedata;
				5'd12: header_buffer[415:384] <= writedata;
				5'd13: header_buffer[447:416] <= writedata;
				5'd14: header_buffer[479:448] <= writedata;
				5'd15: header_buffer[511:480] <= writedata;
				5'd16: header_buffer[543:512] <= writedata;
				5'd17: header_buffer[575:544] <= writedata;
				5'd18: header_buffer[607:576] <= writedata;
				5'd19: header_buffer[639:608] <= writedata;
				5'd20: header_buffer[671:640] <= writedata;
				5'd21: header_buffer[703:672] <= writedata;
				5'd22: header_buffer[735:704] <= writedata;
				5'd23: begin
							header_buffer[767:736] <= writedata;
							loading <= 1'b0;
						end
			endcase
		end
	end
	
endmodule
