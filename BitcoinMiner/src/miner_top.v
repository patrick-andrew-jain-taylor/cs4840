
//`define IDX32(x) (((x)+1)*(32)-1):((x)*(32))
`define IDX8(x) (((x)+1)*(8)-1):((x)*(8))

module miner_top(


	input clk,
	input reset,
	input write,
	input read,
	input chipselect,
	input [7:0] writedata,
	input [6:0] address,
	
	output reg [7:0] readdata);
	
	reg [800:0] header_buffer = 801'b0;
	reg loading = 1'b0;
	reg load_done = 1'b0;
	reg start = 1'b0;
	reg read_gold_nonce = 1'b1;
	
	wire [32:0] nonce_out;

	/*
	// Parallelization	
	parameter mctr = 2;							//number of miners
	parameter nonce_idx = 383;
	reg [31:0] nonce_ram[ctr-1];
	reg [32:0] result_ram[0:mctr-1];
	localparam range = 2'd2;
	wire[32*mctr:0] nonce_out;
	
	genvar j;
	generate
		for (j=0; j < mctr; j=j+1) begin
			fpgaminer_top miner (clk, {header_buffer[767:nonce_idx], nonce_ram[j],header_buffer[351:0]}, load_done, nonce_out[`IDX32(j)]);
		end
	endgenerate
	*/
	
	fpgaminer_top miner (clk, header_buffer, load_done, nonce_out);
	
	always @(posedge clk) begin
		if(start) begin
			loading <= 1'b1;
			load_done <= 1'b0;
			start <= 1'b0;
			header_buffer <= 801'b0; //Reset all including the nonce and golden nonce
			read_gold_nonce = 1'b1;
		end
		else if(write && !loading && chipselect) begin
			if(address == 7'd102)
				start <= writedata[0];
		end
		else if(write && loading && chipselect) begin
			case(address)
				7'd0: header_buffer[7:0] <= writedata;
				7'd1: header_buffer[15:8] <= writedata;
				7'd2: header_buffer[23:16] <= writedata;
				7'd3: header_buffer[31:24] <= writedata;
				7'd4: header_buffer[39:32] <= writedata;
				7'd5: header_buffer[47:40] <= writedata;
				7'd6: header_buffer[55:48] <= writedata;
				7'd7: header_buffer[63:56] <= writedata;
				7'd8: header_buffer[71:64] <= writedata;
				7'd9: header_buffer[79:72] <= writedata;
				7'd10: header_buffer[87:80] <= writedata;
				7'd11: header_buffer[95:88] <= writedata;
				7'd12: header_buffer[103:96] <= writedata;
				7'd13: header_buffer[111:104] <= writedata;
				7'd14: header_buffer[119:112] <= writedata;
				7'd15: header_buffer[127:120] <= writedata;
				7'd16: header_buffer[135:128] <= writedata;
				7'd17: header_buffer[143:136] <= writedata;
				7'd18: header_buffer[151:144] <= writedata;
				7'd19: header_buffer[159:152] <= writedata;
				7'd20: header_buffer[167:160] <= writedata;
				7'd21: header_buffer[175:168] <= writedata;
				7'd22: header_buffer[183:176] <= writedata;
				7'd23: header_buffer[191:184] <= writedata;
				7'd24: header_buffer[199:192] <= writedata;
				7'd25: header_buffer[207:200] <= writedata;
				7'd26: header_buffer[215:208] <= writedata;
				7'd27: header_buffer[223:216] <= writedata;
				7'd28: header_buffer[231:224] <= writedata;
				7'd29: header_buffer[239:232] <= writedata;
				7'd30: header_buffer[247:240] <= writedata;
				
				7'd31: header_buffer[255:248] <= writedata;
				7'd32: header_buffer[263:256] <= writedata;
				7'd33: header_buffer[271:264] <= writedata;
				7'd34: header_buffer[279:272] <= writedata;
				7'd35: header_buffer[287:280] <= writedata;
				7'd36: header_buffer[295:288] <= writedata;
				7'd37: header_buffer[303:296] <= writedata;
				7'd38: header_buffer[311:304] <= writedata;
				7'd39: header_buffer[319:312] <= writedata;
				7'd40: header_buffer[327:320] <= writedata;
				7'd41: header_buffer[335:328] <= writedata;
				7'd42: header_buffer[343:336] <= writedata;
				7'd43: header_buffer[351:344] <= writedata;
				7'd44: header_buffer[359:352] <= writedata;
				7'd45: header_buffer[367:360] <= writedata;
				7'd46: header_buffer[375:368] <= writedata;
				7'd47: header_buffer[383:376] <= writedata;
				7'd48: header_buffer[391:384] <= writedata;
				7'd49: header_buffer[399:392] <= writedata;
				7'd50: header_buffer[407:400] <= writedata;
				7'd51: header_buffer[415:408] <= writedata;
				7'd52: header_buffer[423:416] <= writedata;
				7'd53: header_buffer[431:424] <= writedata;
				7'd54: header_buffer[439:432] <= writedata;
				7'd55: header_buffer[447:440] <= writedata;
				7'd56: header_buffer[455:448] <= writedata;
				7'd57: header_buffer[463:456] <= writedata;
				7'd58: header_buffer[471:464] <= writedata;
				7'd59: header_buffer[479:472] <= writedata;
				7'd60: header_buffer[487:480] <= writedata;
				
				7'd61: header_buffer[495:488] <= writedata;
				7'd62: header_buffer[503:496] <= writedata;
				7'd63: header_buffer[511:504] <= writedata;
				7'd64: header_buffer[519:512] <= writedata;
				7'd65: header_buffer[527:520] <= writedata;
				7'd66: header_buffer[535:528] <= writedata;
				7'd67: header_buffer[543:536] <= writedata;
				7'd68: header_buffer[551:544] <= writedata;
				7'd69: header_buffer[559:552] <= writedata;
				7'd70: header_buffer[567:560] <= writedata;
				7'd71: header_buffer[575:568] <= writedata;
				7'd72: header_buffer[583:576] <= writedata;
				7'd73: header_buffer[591:584] <= writedata;
				7'd74: header_buffer[599:592] <= writedata;
				7'd75: header_buffer[607:600] <= writedata;
				7'd76: header_buffer[615:608] <= writedata;
				7'd77: header_buffer[623:616] <= writedata;
				7'd78: header_buffer[631:624] <= writedata;
				7'd79: header_buffer[639:632] <= writedata;
				7'd80: header_buffer[647:640] <= writedata;
				7'd81: header_buffer[655:648] <= writedata;
				7'd82: header_buffer[663:656] <= writedata;
				7'd83: header_buffer[671:664] <= writedata;	
				7'd84: header_buffer[679:672] <= writedata;
				7'd85: header_buffer[687:680] <= writedata;
				7'd86: header_buffer[695:688] <= writedata;
				7'd87: header_buffer[703:696] <= writedata;
				7'd88: header_buffer[711:704] <= writedata;
				7'd89: header_buffer[719:712] <= writedata;
				7'd90: header_buffer[727:720] <= writedata;
				7'd91: header_buffer[735:728] <= writedata;
				7'd92: header_buffer[743:736] <= writedata;
				7'd93: header_buffer[751:744] <= writedata;
				7'd94: header_buffer[759:752] <= writedata;
				7'd95: begin
								header_buffer[767:760] <= writedata;
								
								/*
								integer i;
								for(i=0; i < mctr; i=i+1) begin
									nonce_ram[i] <= header_buffer[nonce_idx:nonce_idx-31] + i*range;
								end
								*/
								
								loading <= 1'b0;
								load_done <= 1'b1;
								start <= 1'b0;
						end
				// address 96 - 101 reserved
			endcase
		end	// end of if(write && loading)
		else if (read && chipselect) begin
			case (address)
				7'd0: readdata <= header_buffer[7:0];
				7'd1: readdata <= header_buffer[15:8];
				7'd2: readdata <= header_buffer[23:16];
				7'd3: readdata <= header_buffer[31:24];
				7'd4: readdata <= header_buffer[39:32];
				7'd5: readdata <= header_buffer[47:40];
				7'd6: readdata <= header_buffer[55:48];
				7'd7: readdata <= header_buffer[63:56];
				7'd8: readdata <= header_buffer[71:64];
				7'd9: readdata <= header_buffer[79:72];
				7'd10: readdata <= header_buffer[87:80];
				7'd11: readdata <= header_buffer[95:88];
				7'd12: readdata <= header_buffer[103:96];
				7'd13: readdata <= header_buffer[111:104];
				7'd14: readdata <= header_buffer[119:112];
				7'd15: readdata <= header_buffer[127:120];
				7'd16: readdata <= header_buffer[135:128];
				7'd17: readdata <= header_buffer[143:136];
				7'd18: readdata <= header_buffer[151:144];
				7'd19: readdata <= header_buffer[159:152];
				7'd20: readdata <= header_buffer[167:160];
				7'd21: readdata <= header_buffer[175:168];
				7'd22: readdata <= header_buffer[183:176];
				7'd23: readdata <= header_buffer[191:184];
				7'd24: readdata <= header_buffer[199:192];
				7'd25: readdata <= header_buffer[207:200];
				7'd26: readdata <= header_buffer[215:208];
				7'd27: readdata <= header_buffer[223:216];
				7'd28: readdata <= header_buffer[231:224];
				7'd29: readdata <= header_buffer[239:232];
				7'd30: readdata <= header_buffer[247:240];
				
				7'd31: readdata <= header_buffer[255:248];
				7'd32: readdata <= header_buffer[263:256];
				7'd33: readdata <= header_buffer[271:264];
				7'd34: readdata <= header_buffer[279:272];
				7'd35: readdata <= header_buffer[287:280];
				7'd36: readdata <= header_buffer[295:288];
				7'd37: readdata <= header_buffer[303:296];
				7'd38: readdata <= header_buffer[311:304];
				7'd39: readdata <= header_buffer[319:312];
				7'd40: readdata <= header_buffer[327:320];
				7'd41: readdata <= header_buffer[335:328];
				7'd42: readdata <= header_buffer[343:336];
				7'd43: readdata <= header_buffer[351:344];
				7'd44: readdata <= header_buffer[359:352];
				7'd45: readdata <= header_buffer[367:360];
				7'd46: readdata <= header_buffer[375:368];
				7'd47: readdata <= header_buffer[383:376];
				7'd48: readdata <= header_buffer[391:384];
				7'd49: readdata <= header_buffer[399:392];
				7'd50: readdata <= header_buffer[407:400];
				7'd51: readdata <= header_buffer[415:408];
				7'd52: readdata <= header_buffer[423:416];
				7'd53: readdata <= header_buffer[431:424];
				7'd54: readdata <= header_buffer[439:432];
				7'd55: readdata <= header_buffer[447:440];
				7'd56: readdata <= header_buffer[455:448];
				7'd57: readdata <= header_buffer[463:456];
				7'd58: readdata <= header_buffer[471:464];
				7'd59: readdata <= header_buffer[479:472];
				7'd60: readdata <= header_buffer[487:480];
				
				7'd61: readdata <= header_buffer[495:488];
				7'd62: readdata <= header_buffer[503:496];
				7'd63: readdata <= header_buffer[511:504];
				7'd64: readdata <= header_buffer[519:512];
				7'd65: readdata <= header_buffer[527:520];
				7'd66: readdata <= header_buffer[535:528];
				7'd67: readdata <= header_buffer[543:536];
				7'd68: readdata <= header_buffer[551:544];
				7'd69: readdata <= header_buffer[559:552];
				7'd70: readdata <= header_buffer[567:560];
				7'd71: readdata <= header_buffer[575:568];
				7'd72: readdata <= header_buffer[583:576];
				7'd73: readdata <= header_buffer[591:584];
				7'd74: readdata <= header_buffer[599:592];
				7'd75: readdata <= header_buffer[607:600];
				7'd76: readdata <= header_buffer[615:608];
				7'd77: readdata <= header_buffer[623:616];
				7'd78: readdata <= header_buffer[631:624];
				7'd79: readdata <= header_buffer[639:632];
				7'd80: readdata <= header_buffer[647:640];
				7'd81: readdata <= header_buffer[655:648];
				7'd82: readdata <= header_buffer[663:656];
				7'd83: readdata <= header_buffer[671:664];	
				7'd84: readdata <= header_buffer[679:672];
				7'd85: readdata <= header_buffer[687:680];
				7'd86: readdata <= header_buffer[695:688];
				7'd87: readdata <= header_buffer[703:696];
				7'd88: readdata <= header_buffer[711:704];
				7'd89: readdata <= header_buffer[719:712];
				7'd90: readdata <= header_buffer[727:720];
				7'd91: readdata <= header_buffer[735:728];
				7'd92: readdata <= header_buffer[743:736];
				7'd93: readdata <= header_buffer[751:744];
				7'd94: readdata <= header_buffer[759:752];
				7'd95: readdata <= header_buffer[767:760];
				
				//golden nonce
				7'd96: readdata <= header_buffer[775:768];
				7'd97: readdata <= header_buffer[783:776];
				7'd98: readdata <= header_buffer[791:784];
				7'd99: readdata <= header_buffer[799:792];
				7'd100: begin
								readdata[7:1] <= 6'b0;
			  				readdata[0] <= header_buffer[800];
							end
				//load state
				7'd101: begin
								readdata[0] <= loading;
								readdata[1] <= load_done;
								readdata[7:2] <= 5'b0;
							end
				//start state, may not be necessary to have a read option for it later
				7'd102: begin
								readdata[0] <= start;
								readdata[7:1] <= 6'b0;
							end
			endcase
		end
		else begin
			load_done <= 1'b0;
			
			if(read_gold_nonce && nonce_out[32]) begin		
				header_buffer[799:768] <= nonce_out[31:0];
				header_buffer[800] <= nonce_out[32];
				read_gold_nonce = 1'b0;
			end
			else
				header_buffer[800:768] <= header_buffer[800:768];
			
			/*
			integer k;
			for (k=0; k < mctr; k=k+1) begin
				result_ram[k] <= nonce_out[`IDX32(k)];
			end
			*/
			
		end
	end
	
endmodule

			/*
			******* 8 bit Write
				7'd0: header_buffer[7:0] <= writedata;
				7'd1: header_buffer[15:8] <= writedata;
				7'd2: header_buffer[23:16] <= writedata;
				7'd3: header_buffer[31:24] <= writedata;
				7'd4: header_buffer[39:32] <= writedata;
				7'd5: header_buffer[47:40] <= writedata;
				7'd6: header_buffer[55:48] <= writedata;
				7'd7: header_buffer[63:56] <= writedata;
				7'd8: header_buffer[71:64] <= writedata;
				7'd9: header_buffer[79:72] <= writedata;
				7'd10: header_buffer[87:80] <= writedata;
				7'd11: header_buffer[95:88] <= writedata;
				7'd12: header_buffer[103:96] <= writedata;
				7'd13: header_buffer[111:104] <= writedata;
				7'd14: header_buffer[119:112] <= writedata;
				7'd15: header_buffer[127:120] <= writedata;
				7'd16: header_buffer[135:128] <= writedata;
				7'd17: header_buffer[143:136] <= writedata;
				7'd18: header_buffer[151:144] <= writedata;
				7'd19: header_buffer[159:152] <= writedata;
				7'd20: header_buffer[167:160] <= writedata;
				7'd21: header_buffer[175:168] <= writedata;
				7'd22: header_buffer[183:176] <= writedata;
				7'd23: header_buffer[191:184] <= writedata;
				7'd24: header_buffer[199:192] <= writedata;
				7'd25: header_buffer[207:200] <= writedata;
				7'd26: header_buffer[215:208] <= writedata;
				7'd27: header_buffer[223:216] <= writedata;
				7'd28: header_buffer[231:224] <= writedata;
				7'd29: header_buffer[239:232] <= writedata;
				7'd30: header_buffer[247:240] <= writedata;
				
				7'd31: header_buffer[255:248] <= writedata;
				7'd32: header_buffer[263:256] <= writedata;
				7'd33: header_buffer[271:264] <= writedata;
				7'd34: header_buffer[279:272] <= writedata;
				7'd35: header_buffer[287:280] <= writedata;
				7'd36: header_buffer[295:288] <= writedata;
				7'd37: header_buffer[303:296] <= writedata;
				7'd38: header_buffer[311:304] <= writedata;
				7'd39: header_buffer[319:312] <= writedata;
				7'd40: header_buffer[327:320] <= writedata;
				7'd41: header_buffer[335:328] <= writedata;
				7'd42: header_buffer[343:336] <= writedata;
				7'd43: header_buffer[351:344] <= writedata;
				7'd44: header_buffer[359:352] <= writedata;
				7'd45: header_buffer[367:360] <= writedata;
				7'd46: header_buffer[375:368] <= writedata;
				7'd47: header_buffer[383:376] <= writedata;
				7'd48: header_buffer[391:384] <= writedata;
				7'd49: header_buffer[399:392] <= writedata;
				7'd50: header_buffer[407:400] <= writedata;
				7'd51: header_buffer[415:408] <= writedata;
				7'd52: header_buffer[423:416] <= writedata;
				7'd53: header_buffer[431:424] <= writedata;
				7'd54: header_buffer[439:432] <= writedata;
				7'd55: header_buffer[447:440] <= writedata;
				7'd56: header_buffer[455:448] <= writedata;
				7'd57: header_buffer[463:456] <= writedata;
				7'd58: header_buffer[471:464] <= writedata;
				7'd59: header_buffer[479:472] <= writedata;
				7'd60: header_buffer[487:480] <= writedata;
				
				7'd61: header_buffer[495:488] <= writedata;
				7'd62: header_buffer[503:496] <= writedata;
				7'd63: header_buffer[511:504] <= writedata;
				7'd64: header_buffer[519:512] <= writedata;
				7'd65: header_buffer[527:520] <= writedata;
				7'd66: header_buffer[535:528] <= writedata;
				7'd67: header_buffer[543:536] <= writedata;
				7'd68: header_buffer[551:544] <= writedata;
				7'd69: header_buffer[559:552] <= writedata;
				7'd70: header_buffer[567:560] <= writedata;
				7'd71: header_buffer[575:568] <= writedata;
				7'd72: header_buffer[583:576] <= writedata;
				7'd73: header_buffer[591:584] <= writedata;
				7'd74: header_buffer[599:592] <= writedata;
				7'd75: header_buffer[607:600] <= writedata;
				7'd76: header_buffer[615:608] <= writedata;
				7'd77: header_buffer[623:616] <= writedata;
				7'd78: header_buffer[631:624] <= writedata;
				7'd79: header_buffer[639:632] <= writedata;
				7'd80: header_buffer[647:640] <= writedata;
				7'd81: header_buffer[655:648] <= writedata;
				7'd82: header_buffer[663:656] <= writedata;
				7'd83: header_buffer[671:664] <= writedata;	
				7'd84: header_buffer[679:672] <= writedata;
				7'd85: header_buffer[687:680] <= writedata;
				7'd86: header_buffer[695:688] <= writedata;
				7'd87: header_buffer[703:696] <= writedata;
				7'd88: header_buffer[711:704] <= writedata;
				7'd89: header_buffer[719:712] <= writedata;
				7'd90: header_buffer[727:720] <= writedata;
				7'd91: header_buffer[735:728] <= writedata;
				7'd92: header_buffer[743:736] <= writedata;
				7'd93: header_buffer[751:744] <= writedata;
				7'd94: header_buffer[759:752] <= writedata;
				7'd95: begin
								header_buffer[767:760] <= writedata;

			**** 8 bit Read
				7'd0: readdata <= header_buffer[7:0];
				7'd1: readdata <= header_buffer[15:8];
				7'd2: readdata <= header_buffer[23:16];
				7'd3: readdata <= header_buffer[31:24];
				7'd4: readdata <= header_buffer[39:32];
				7'd5: readdata <= header_buffer[47:40];
				7'd6: readdata <= header_buffer[55:48];
				7'd7: readdata <= header_buffer[63:56];
				7'd8: readdata <= header_buffer[71:64];
				7'd9: readdata <= header_buffer[79:72];
				7'd10: readdata <= header_buffer[87:80];
				7'd11: readdata <= header_buffer[95:88];
				7'd12: readdata <= header_buffer[103:96];
				7'd13: readdata <= header_buffer[111:104];
				7'd14: readdata <= header_buffer[119:112];
				7'd15: readdata <= header_buffer[127:120];
				7'd16: readdata <= header_buffer[135:128];
				7'd17: readdata <= header_buffer[143:136];
				7'd18: readdata <= header_buffer[151:144];
				7'd19: readdata <= header_buffer[159:152];
				7'd20: readdata <= header_buffer[167:160];
				7'd21: readdata <= header_buffer[175:168];
				7'd22: readdata <= header_buffer[183:176];
				7'd23: readdata <= header_buffer[191:184];
				7'd24: readdata <= header_buffer[199:192];
				7'd25: readdata <= header_buffer[207:200];
				7'd26: readdata <= header_buffer[215:208];
				7'd27: readdata <= header_buffer[223:216];
				7'd28: readdata <= header_buffer[231:224];
				7'd29: readdata <= header_buffer[239:232];
				7'd30: readdata <= header_buffer[247:240];
				
				7'd31: readdata <= header_buffer[255:248];
				7'd32: readdata <= header_buffer[263:256];
				7'd33: readdata <= header_buffer[271:264];
				7'd34: readdata <= header_buffer[279:272];
				7'd35: readdata <= header_buffer[287:280];
				7'd36: readdata <= header_buffer[295:288];
				7'd37: readdata <= header_buffer[303:296];
				7'd38: readdata <= header_buffer[311:304];
				7'd39: readdata <= header_buffer[319:312];
				7'd40: readdata <= header_buffer[327:320];
				7'd41: readdata <= header_buffer[335:328];
				7'd42: readdata <= header_buffer[343:336];
				7'd43: readdata <= header_buffer[351:344];
				7'd44: readdata <= header_buffer[359:352];
				7'd45: readdata <= header_buffer[367:360];
				7'd46: readdata <= header_buffer[375:368];
				7'd47: readdata <= header_buffer[383:376];
				7'd48: readdata <= header_buffer[391:384];
				7'd49: readdata <= header_buffer[399:392];
				7'd50: readdata <= header_buffer[407:400];
				7'd51: readdata <= header_buffer[415:408];
				7'd52: readdata <= header_buffer[423:416];
				7'd53: readdata <= header_buffer[431:424];
				7'd54: readdata <= header_buffer[439:432];
				7'd55: readdata <= header_buffer[447:440];
				7'd56: readdata <= header_buffer[455:448];
				7'd57: readdata <= header_buffer[463:456];
				7'd58: readdata <= header_buffer[471:464];
				7'd59: readdata <= header_buffer[479:472];
				7'd60: readdata <= header_buffer[487:480];
				
				7'd61: readdata <= header_buffer[495:488];
				7'd62: readdata <= header_buffer[503:496];
				7'd63: readdata <= header_buffer[511:504];
				7'd64: readdata <= header_buffer[519:512];
				7'd65: readdata <= header_buffer[527:520];
				7'd66: readdata <= header_buffer[535:528];
				7'd67: readdata <= header_buffer[543:536];
				7'd68: readdata <= header_buffer[551:544];
				7'd69: readdata <= header_buffer[559:552];
				7'd70: readdata <= header_buffer[567:560];
				7'd71: readdata <= header_buffer[575:568];
				7'd72: readdata <= header_buffer[583:576];
				7'd73: readdata <= header_buffer[591:584];
				7'd74: readdata <= header_buffer[599:592];
				7'd75: readdata <= header_buffer[607:600];
				7'd76: readdata <= header_buffer[615:608];
				7'd77: readdata <= header_buffer[623:616];
				7'd78: readdata <= header_buffer[631:624];
				7'd79: readdata <= header_buffer[639:632];
				7'd80: readdata <= header_buffer[647:640];
				7'd81: readdata <= header_buffer[655:648];
				7'd82: readdata <= header_buffer[663:656];
				7'd83: readdata <= header_buffer[671:664];	
				7'd84: readdata <= header_buffer[679:672];
				7'd85: readdata <= header_buffer[687:680];
				7'd86: readdata <= header_buffer[695:688];
				7'd87: readdata <= header_buffer[703:696];
				7'd88: readdata <= header_buffer[711:704];
				7'd89: readdata <= header_buffer[719:712];
				7'd90: readdata <= header_buffer[727:720];
				7'd91: readdata <= header_buffer[735:728];
				7'd92: readdata <= header_buffer[743:736];
				7'd93: readdata <= header_buffer[751:744];
				7'd94: readdata <= header_buffer[759:752];
				7'd95: readdata <= header_buffer[767:760];
				
				7'd96: readdata <= header_buffer[775:768];
				7'd97: readdata <= header_buffer[783:776];
				7'd98: readdata <= header_buffer[791:784];
				7'd99: readdata <= header_buffer[799:792];
			
			********************
			********************

			32-bit data
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
						
						
			8-bit data:		
				5'd0: header_buffer[7:0] <= writedata;
				5'd1: header_buffer[15:8] <= writedata;
				5'd2: header_buffer[23:16] <= writedata;
				5'd3: header_buffer[31:24] <= writedata;
				5'd4: header_buffer[39:32] <= writedata;
				5'd5: header_buffer[47:40] <= writedata;
				5'd6: header_buffer[55:48] <= writedata;
				5'd7: header_buffer[63:56] <= writedata;
				5'd8: header_buffer[71:64] <= writedata;
				5'd9: header_buffer[79:72] <= writedata;
				5'd10: header_buffer[87:80] <= writedata;
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
				5'd23: header_buffer[767:736] <= writedata;
				5'd24: header_buffer[7:0] <= writedata;
				5'd25: header_buffer[63:32] <= writedata;
				5'd26: header_buffer[95:64] <= writedata;
				5'd27: header_buffer[127:96] <= writedata;
				5'd28: header_buffer[159:128] <= writedata;
				5'd29: header_buffer[191:160] <= writedata;
				5'd30: header_buffer[223:192] <= writedata;
				
				5'd31: header_buffer[63:32] <= writedata;
				5'd32: header_buffer[95:64] <= writedata;
				5'd33: header_buffer[127:96] <= writedata;
				5'd34: header_buffer[159:128] <= writedata;
				5'd35: header_buffer[191:160] <= writedata;
				5'd36: header_buffer[223:192] <= writedata;
				5'd37: header_buffer[255:224] <= writedata;
				5'd38: header_buffer[287:256] <= writedata;
				5'd39: header_buffer[319:288] <= writedata;
				5'd40: header_buffer[351:320] <= writedata;
				5'd41: header_buffer[383:352] <= writedata;
				5'd42: header_buffer[415:384] <= writedata;
				5'd43: header_buffer[447:416] <= writedata;
				5'd44: header_buffer[479:448] <= writedata;
				5'd45: header_buffer[511:480] <= writedata;
				5'd46: header_buffer[543:512] <= writedata;
				5'd47: header_buffer[575:544] <= writedata;
				5'd48: header_buffer[607:576] <= writedata;
				5'd49: header_buffer[639:608] <= writedata;
				5'd50: header_buffer[671:640] <= writedata;
				5'd51: header_buffer[703:672] <= writedata;
				5'd52: header_buffer[735:704] <= writedata;
				5'd53: header_buffer[767:736] <= writedata;
				5'd54: header_buffer[7:0] <= writedata;
				5'd55: header_buffer[63:32] <= writedata;
				5'd56: header_buffer[95:64] <= writedata;
				5'd57: header_buffer[127:96] <= writedata;
				5'd58: header_buffer[159:128] <= writedata;
				5'd59: header_buffer[191:160] <= writedata;
				5'd60: header_buffer[223:192] <= writedata;
				
				5'd61: header_buffer[63:32] <= writedata;
				5'd62: header_buffer[95:64] <= writedata;
				5'd63: header_buffer[127:96] <= writedata;
				5'd64: header_buffer[159:128] <= writedata;
				5'd65: header_buffer[191:160] <= writedata;
				5'd66: header_buffer[223:192] <= writedata;
				5'd67: header_buffer[255:224] <= writedata;
				5'd68: header_buffer[287:256] <= writedata;
				5'd69: header_buffer[319:288] <= writedata;
				5'd70: header_buffer[351:320] <= writedata;
				5'd71: header_buffer[383:352] <= writedata;
				5'd72: header_buffer[415:384] <= writedata;
				5'd73: header_buffer[447:416] <= writedata;
				5'd74: header_buffer[479:448] <= writedata;
				5'd75: header_buffer[511:480] <= writedata;
				5'd76: header_buffer[543:512] <= writedata;
				5'd77: header_buffer[575:544] <= writedata;
				5'd78: header_buffer[607:576] <= writedata;
				5'd79: header_buffer[639:608] <= writedata;
				5'd80: header_buffer[671:640] <= writedata;
				5'd81: header_buffer[703:672] <= writedata;
				5'd82: header_buffer[735:704] <= writedata;
				5'd83: header_buffer[767:736] <= writedata;	
				5'd84: header_buffer[7:0] <= writedata;
				5'd85: header_buffer[63:32] <= writedata;
				5'd86: header_buffer[95:64] <= writedata;
				5'd87: header_buffer[127:96] <= writedata;
				5'd88: header_buffer[159:128] <= writedata;
				5'd89: header_buffer[191:160] <= writedata;
				5'd90: header_buffer[223:192] <= writedata;
				5'd91: header_buffer[63:32] <= writedata;
				5'd92: header_buffer[95:64] <= writedata;
				5'd93: header_buffer[127:96] <= writedata;
				5'd94: header_buffer[159:128] <= writedata;
				5'd95: begin
							header_buffer[767:736] <= writedata;
							loading <= 1'b0;
						end
						
			******************************* 32-bit data w/ byteenable			
			5'd0:  
				begin
						if(byteenable[0]) header_buffer[7:0] <= writedata[7:0];
						if(byteenable[1]) header_buffer[15:8] <= writedata[15:8];
						if(byteenable[2]) header_buffer[23:16] <= writedata[23:16];
						if(byteenable[3]) header_buffer[31:24] <= writedata[31:24];
					end
				5'd1:
				begin
						if(byteenable[0]) header_buffer[39:32] <= writedata[7:0];
						if(byteenable[1]) header_buffer[47:40] <= writedata[15:8];
						if(byteenable[2]) header_buffer[55:48] <= writedata[23:16];
						if(byteenable[3]) header_buffer[63:56] <= writedata[31:24];
					end
				5'd2:
				begin
						if(byteenable[0]) header_buffer[71:64] <= writedata[7:0];
						if(byteenable[1]) header_buffer[79:72] <= writedata[15:8];
						if(byteenable[2]) header_buffer[87:80] <= writedata[23:16];
						if(byteenable[3]) header_buffer[95:88] <= writedata[31:24];
					end
				5'd3:
				begin
						if(byteenable[0]) header_buffer[103:96] <= writedata[7:0];
						if(byteenable[1]) header_buffer[111:104] <= writedata[15:8];
						if(byteenable[2]) header_buffer[119:112] <= writedata[23:16];
						if(byteenable[3]) header_buffer[127:120] <= writedata[31:24];
					end
				5'd4: 
				begin
						if(byteenable[0]) header_buffer[135:128] <= writedata[7:0];
						if(byteenable[1]) header_buffer[143:136] <= writedata[15:8];
						if(byteenable[2]) header_buffer[151:144] <= writedata[23:16];
						if(byteenable[3]) header_buffer[159:152] <= writedata[31:24];
					end
				5'd5:
				begin
						if(byteenable[0]) header_buffer[167:160] <= writedata[7:0];
						if(byteenable[1]) header_buffer[175:168] <= writedata[15:8];
						if(byteenable[2]) header_buffer[183:176] <= writedata[23:16];
						if(byteenable[3]) header_buffer[191:184] <= writedata[31:24];
					end
				5'd6:
				begin
						if(byteenable[0]) header_buffer[199:192] <= writedata[7:0];
						if(byteenable[1]) header_buffer[207:200] <= writedata[15:8];
						if(byteenable[2]) header_buffer[215:208] <= writedata[23:16];
						if(byteenable[3]) header_buffer[223:216] <= writedata[31:24];
					end
				5'd7:
				begin
						if(byteenable[0]) header_buffer[231:224] <= writedata[7:0];
						if(byteenable[1]) header_buffer[239:232] <= writedata[15:8];
						if(byteenable[2]) header_buffer[247:240] <= writedata[23:16];
						if(byteenable[3]) header_buffer[255:248] <= writedata[31:24];
					end
				5'd8:
				begin
						if(byteenable[0]) header_buffer[263:256] <= writedata[7:0];
						if(byteenable[1]) header_buffer[271:264] <= writedata[15:8];
						if(byteenable[2]) header_buffer[279:272] <= writedata[23:16];
						if(byteenable[3]) header_buffer[287:280] <= writedata[31:24];
					end
				5'd9:
				begin
						if(byteenable[0]) header_buffer[295:288] <= writedata[7:0];
						if(byteenable[1]) header_buffer[303:296] <= writedata[15:8];
						if(byteenable[2]) header_buffer[311:304] <= writedata[23:16];
						if(byteenable[3]) header_buffer[319:312] <= writedata[31:24];
					end
				5'd10:
				begin
						if(byteenable[0]) header_buffer[327:320] <= writedata[7:0];
						if(byteenable[1]) header_buffer[335:328] <= writedata[15:8];
						if(byteenable[2]) header_buffer[343:336] <= writedata[23:16];
						if(byteenable[3]) header_buffer[351:344] <= writedata[31:24];
					end
				5'd11:
				begin
						if(byteenable[0]) header_buffer[359:352] <= writedata[7:0];
						if(byteenable[1]) header_buffer[367:360] <= writedata[15:8];
						if(byteenable[2]) header_buffer[375:368] <= writedata[23:16];
						if(byteenable[3]) header_buffer[383:376] <= writedata[31:24];
					end
				5'd12:
				begin
						if(byteenable[0]) header_buffer[391:384] <= writedata[7:0];
						if(byteenable[1]) header_buffer[399:392] <= writedata[15:8];
						if(byteenable[2]) header_buffer[407:400] <= writedata[23:16];
						if(byteenable[3]) header_buffer[415:408] <= writedata[31:24];
					end
				5'd13: 
				begin
						if(byteenable[0]) header_buffer[423:416] <= writedata[7:0];
						if(byteenable[1]) header_buffer[431:424] <= writedata[15:8];
						if(byteenable[2]) header_buffer[439:432] <= writedata[23:16];
						if(byteenable[3]) header_buffer[447:440] <= writedata[31:24];
					end
				5'd14: 
				begin
						if(byteenable[0]) header_buffer[455:448] <= writedata[7:0];
						if(byteenable[1]) header_buffer[463:456] <= writedata[15:8];
						if(byteenable[2]) header_buffer[471:464] <= writedata[23:16];
						if(byteenable[3]) header_buffer[479:472] <= writedata[31:24];
					end
				5'd15:
				begin
						if(byteenable[0]) header_buffer[487:480] <= writedata[7:0];
						if(byteenable[1]) header_buffer[495:488] <= writedata[15:8];
						if(byteenable[2]) header_buffer[503:496] <= writedata[23:16];
						if(byteenable[3]) header_buffer[511:504] <= writedata[31:24];
					end
				5'd16:
				begin
						if(byteenable[0]) header_buffer[519:512] <= writedata[7:0];
						if(byteenable[1]) header_buffer[527:520] <= writedata[15:8];
						if(byteenable[2]) header_buffer[535:528] <= writedata[23:16];
						if(byteenable[3]) header_buffer[543:536] <= writedata[31:24];
					end
				5'd17: 
				begin
						if(byteenable[0]) header_buffer[551:544] <= writedata[7:0];
						if(byteenable[1]) header_buffer[559:552] <= writedata[15:8];
						if(byteenable[2]) header_buffer[567:560] <= writedata[23:16];
						if(byteenable[3]) header_buffer[575:568] <= writedata[31:24];
					end
				5'd18: 
				begin
						if(byteenable[0]) header_buffer[583:576] <= writedata[7:0];
						if(byteenable[1]) header_buffer[591:584] <= writedata[15:8];
						if(byteenable[2]) header_buffer[599:592] <= writedata[23:16];
						if(byteenable[3]) header_buffer[607:600] <= writedata[31:24];
					end
				5'd19:
				begin
						if(byteenable[0]) header_buffer[615:608] <= writedata[7:0];
						if(byteenable[1]) header_buffer[623:616] <= writedata[15:8];
						if(byteenable[2]) header_buffer[631:624] <= writedata[23:16];
						if(byteenable[3]) header_buffer[639:632] <= writedata[31:24];
					end
				5'd20:
				begin
						if(byteenable[0]) header_buffer[647:640] <= writedata[7:0];
						if(byteenable[1]) header_buffer[655:648] <= writedata[15:8];
						if(byteenable[2]) header_buffer[663:656] <= writedata[23:16];
						if(byteenable[3]) header_buffer[671:664] <= writedata[31:24];
					end
				5'd21:
				begin
						if(byteenable[0]) header_buffer[679:672] <= writedata[7:0];
						if(byteenable[1]) header_buffer[687:680] <= writedata[15:8];
						if(byteenable[2]) header_buffer[695:688] <= writedata[23:16];
						if(byteenable[3]) header_buffer[703:696] <= writedata[31:24];
					end
				5'd22:
				begin
						if(byteenable[0]) header_buffer[711:704] <= writedata[7:0];
						if(byteenable[1]) header_buffer[719:712] <= writedata[15:8];
						if(byteenable[2]) header_buffer[727:720] <= writedata[23:16];
						if(byteenable[3]) header_buffer[735:728] <= writedata[31:24];
					end
				5'd23: 
				begin
						if(byteenable[0]) header_buffer[743:736] <= writedata[7:0];
						if(byteenable[1]) header_buffer[751:744] <= writedata[15:8];
						if(byteenable[2]) header_buffer[759:752] <= writedata[23:16];
						if(byteenable[3]) header_buffer[767:760] <= writedata[31:24];
						loading <= 1'b0;
						load_done <= 1'b1;
					end
			*/
