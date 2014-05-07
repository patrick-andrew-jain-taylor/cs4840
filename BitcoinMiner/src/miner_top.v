
//`define IDX32(x) (((x)+1)*(32)-1):((x)*(32))
`define IDX8(x) (((x)+1)*(8)-1):((x)*(8))
`define NONCEIDX 383:352

module miner_top(
	input clk,
	input reset,
	input write,
	input read,
	input chipselect,
	input [7:0] writedata,
	input [7:0] address,
	
	output reg [7:0] readdata);
	
	reg [767:0] header_buffer = 768'd0;
	reg [32:0] gold_nonce = 33'd0; //Can get rid of this later
	
	reg loading = 1'b0;
	reg load_done = 1'b0;
	reg start = 1'b0;
	reg stop = 1'b0;
	reg read_gold_nonce = 1'b1;
	reg ticket = 1'b0;
	
	wire [32:0] nonce_out_a[0:mctr-1];
	
	//wire [32:0] nonce_out;
	//assign nonce_out = 33'd0;
	
	// Parallelization
	parameter mctr = 5;							//number of miners
	parameter NONCE_IDX = 383;			//index in Header Buffer containing nonce info
	localparam range = 32'd1000000;	//the range of nonce values for each miner

	reg [31:0] nonce_ram[0:4];
	reg [32:0] result_ram[0:4];

	
	// Instantiate mctr miners
	genvar j;
	generate
		for (j=0; j < 4; j=j+1) begin : MINERS
			//wire [32:0] m_nonce_out;
			
			fpgaminer_top miner (clk, {header_buffer[767:NONCE_IDX], nonce_ram[j],header_buffer[351:0]}, load_done, nonce_out_a[j]);
		end
	endgenerate
	
	//fpgaminer_top miner (clk, header_buffer, load_done, nonce_out);
	
	always @(posedge clk) begin
		
		// Establish the nonce values from which each miner will start
		nonce_ram[0] <= header_buffer[`NONCEIDX];
		nonce_ram[1] <= header_buffer[`NONCEIDX] + range;	
		nonce_ram[2] <= header_buffer[`NONCEIDX] + 2*range;
		nonce_ram[3] <= header_buffer[`NONCEIDX] + 3*range;
		nonce_ram[4] <= header_buffer[`NONCEIDX] + 4*range;
		
		if(start && !loading) begin
			loading <= 1'b1;
			load_done <= 1'b0;
			start <= 1'b0;
			header_buffer <= 768'd0; //Reset all including the nonce and golden nonce
			
			//gold_nonce <= 33'd0;
			
			result_ram[0] <= 33'd0;
			result_ram[1] <= 33'd0;
			result_ram[2] <= 33'd0;
			result_ram[3] <= 33'd0;
			result_ram[4] <= 33'd0;
			
			nonce_ram[0] <= 32'd0;
			nonce_ram[1] <= 32'd0;
			nonce_ram[2] <= 32'd0;
			nonce_ram[3] <= 32'd0;
			nonce_ram[4] <= 32'd0;
		
			
			read_gold_nonce = 1'b1;
			stop <= 1'b0;
		end
		else if(write && !loading && chipselect) begin
			if(address == 7'd102)
				start <= writedata[0];
		end
		else if(write && loading && chipselect) begin
			case(address)
				8'd0: header_buffer[7:0] <= writedata;
				8'd1: header_buffer[15:8] <= writedata;
				8'd2: header_buffer[23:16] <= writedata;
				8'd3: header_buffer[31:24] <= writedata;
				8'd4: header_buffer[39:32] <= writedata;
				8'd5: header_buffer[47:40] <= writedata;
				8'd6: header_buffer[55:48] <= writedata;
				8'd7: header_buffer[63:56] <= writedata;
				8'd8: header_buffer[71:64] <= writedata;
				8'd9: header_buffer[79:72] <= writedata;
				8'd10: header_buffer[87:80] <= writedata;
				8'd11: header_buffer[95:88] <= writedata;
				8'd12: header_buffer[103:96] <= writedata;
				8'd13: header_buffer[111:104] <= writedata;
				8'd14: header_buffer[119:112] <= writedata;
				8'd15: header_buffer[127:120] <= writedata;
				8'd16: header_buffer[135:128] <= writedata;
				8'd17: header_buffer[143:136] <= writedata;
				8'd18: header_buffer[151:144] <= writedata;
				8'd19: header_buffer[159:152] <= writedata;
				8'd20: header_buffer[167:160] <= writedata;
				8'd21: header_buffer[175:168] <= writedata;
				8'd22: header_buffer[183:176] <= writedata;
				8'd23: header_buffer[191:184] <= writedata;
				8'd24: header_buffer[199:192] <= writedata;
				8'd25: header_buffer[207:200] <= writedata;
				8'd26: header_buffer[215:208] <= writedata;
				8'd27: header_buffer[223:216] <= writedata;
				8'd28: header_buffer[231:224] <= writedata;
				8'd29: header_buffer[239:232] <= writedata;
				8'd30: header_buffer[247:240] <= writedata;
				
				8'd31: header_buffer[255:248] <= writedata;
				8'd32: header_buffer[263:256] <= writedata;
				8'd33: header_buffer[271:264] <= writedata;
				8'd34: header_buffer[279:272] <= writedata;
				8'd35: header_buffer[287:280] <= writedata;
				8'd36: header_buffer[295:288] <= writedata;
				8'd37: header_buffer[303:296] <= writedata;
				8'd38: header_buffer[311:304] <= writedata;
				8'd39: header_buffer[319:312] <= writedata;
				8'd40: header_buffer[327:320] <= writedata;
				8'd41: header_buffer[335:328] <= writedata;
				8'd42: header_buffer[343:336] <= writedata;
				8'd43: header_buffer[351:344] <= writedata;
				8'd44: header_buffer[359:352] <= writedata;
				8'd45: header_buffer[367:360] <= writedata;
				8'd46: header_buffer[375:368] <= writedata;
				8'd47: header_buffer[383:376] <= writedata;
				8'd48: header_buffer[391:384] <= writedata;
				8'd49: header_buffer[399:392] <= writedata;
				8'd50: header_buffer[407:400] <= writedata;
				8'd51: header_buffer[415:408] <= writedata;
				8'd52: header_buffer[423:416] <= writedata;
				8'd53: header_buffer[431:424] <= writedata;
				8'd54: header_buffer[439:432] <= writedata;
				8'd55: header_buffer[447:440] <= writedata;
				8'd56: header_buffer[455:448] <= writedata;
				8'd57: header_buffer[463:456] <= writedata;
				8'd58: header_buffer[471:464] <= writedata;
				8'd59: header_buffer[479:472] <= writedata;
				8'd60: header_buffer[487:480] <= writedata;
				
				8'd61: header_buffer[495:488] <= writedata;
				8'd62: header_buffer[503:496] <= writedata;
				8'd63: header_buffer[511:504] <= writedata;
				8'd64: header_buffer[519:512] <= writedata;
				8'd65: header_buffer[527:520] <= writedata;
				8'd66: header_buffer[535:528] <= writedata;
				8'd67: header_buffer[543:536] <= writedata;
				8'd68: header_buffer[551:544] <= writedata;
				8'd69: header_buffer[559:552] <= writedata;
				8'd70: header_buffer[567:560] <= writedata;
				8'd71: header_buffer[575:568] <= writedata;
				8'd72: header_buffer[583:576] <= writedata;
				8'd73: header_buffer[591:584] <= writedata;
				8'd74: header_buffer[599:592] <= writedata;
				8'd75: header_buffer[607:600] <= writedata;
				8'd76: header_buffer[615:608] <= writedata;
				8'd77: header_buffer[623:616] <= writedata;
				8'd78: header_buffer[631:624] <= writedata;
				8'd79: header_buffer[639:632] <= writedata;
				8'd80: header_buffer[647:640] <= writedata;
				8'd81: header_buffer[655:648] <= writedata;
				8'd82: header_buffer[663:656] <= writedata;
				8'd83: header_buffer[671:664] <= writedata;	
				8'd84: header_buffer[679:672] <= writedata;
				8'd85: header_buffer[687:680] <= writedata;
				8'd86: header_buffer[695:688] <= writedata;
				8'd87: header_buffer[703:696] <= writedata;
				8'd88: header_buffer[711:704] <= writedata;
				8'd89: header_buffer[719:712] <= writedata;
				8'd90: header_buffer[727:720] <= writedata;
				8'd91: header_buffer[735:728] <= writedata;
				8'd92: header_buffer[743:736] <= writedata;
				8'd93: header_buffer[751:744] <= writedata;
				8'd94: header_buffer[759:752] <= writedata;
				8'd95: begin
								header_buffer[767:760] <= writedata;
								loading <= 1'b0;
								load_done <= 1'b1;
						end
				// address 96 - 101 reserved
			endcase
		end	// end of if(write && loading)
		else if (read && chipselect && !loading) begin
			case (address)
				8'd0: readdata <= header_buffer[7:0];
				8'd1: readdata <= header_buffer[15:8];
				8'd2: readdata <= header_buffer[23:16];
				8'd3: readdata <= header_buffer[31:24];
				8'd4: readdata <= header_buffer[39:32];
				8'd5: readdata <= header_buffer[47:40];
				8'd6: readdata <= header_buffer[55:48];
				8'd7: readdata <= header_buffer[63:56];
				8'd8: readdata <= header_buffer[71:64];
				8'd9: readdata <= header_buffer[79:72];
				8'd10: readdata <= header_buffer[87:80];
				8'd11: readdata <= header_buffer[95:88];
				8'd12: readdata <= header_buffer[103:96];
				8'd13: readdata <= header_buffer[111:104];
				8'd14: readdata <= header_buffer[119:112];
				8'd15: readdata <= header_buffer[127:120];
				8'd16: readdata <= header_buffer[135:128];
				8'd17: readdata <= header_buffer[143:136];
				8'd18: readdata <= header_buffer[151:144];
				8'd19: readdata <= header_buffer[159:152];
				8'd20: readdata <= header_buffer[167:160];
				8'd21: readdata <= header_buffer[175:168];
				8'd22: readdata <= header_buffer[183:176];
				8'd23: readdata <= header_buffer[191:184];
				8'd24: readdata <= header_buffer[199:192];
				8'd25: readdata <= header_buffer[207:200];
				8'd26: readdata <= header_buffer[215:208];
				8'd27: readdata <= header_buffer[223:216];
				8'd28: readdata <= header_buffer[231:224];
				8'd29: readdata <= header_buffer[239:232];
				8'd30: readdata <= header_buffer[247:240];
				
				8'd31: readdata <= header_buffer[255:248];
				8'd32: readdata <= header_buffer[263:256];
				8'd33: readdata <= header_buffer[271:264];
				8'd34: readdata <= header_buffer[279:272];
				8'd35: readdata <= header_buffer[287:280];
				8'd36: readdata <= header_buffer[295:288];
				8'd37: readdata <= header_buffer[303:296];
				8'd38: readdata <= header_buffer[311:304];
				8'd39: readdata <= header_buffer[319:312];
				8'd40: readdata <= header_buffer[327:320];
				8'd41: readdata <= header_buffer[335:328];
				8'd42: readdata <= header_buffer[343:336];
				8'd43: readdata <= header_buffer[351:344];
				8'd44: readdata <= header_buffer[359:352];
				8'd45: readdata <= header_buffer[367:360];
				8'd46: readdata <= header_buffer[375:368];
				8'd47: readdata <= header_buffer[383:376];
				8'd48: readdata <= header_buffer[391:384];
				8'd49: readdata <= header_buffer[399:392];
				8'd50: readdata <= header_buffer[407:400];
				8'd51: readdata <= header_buffer[415:408];
				8'd52: readdata <= header_buffer[423:416];
				8'd53: readdata <= header_buffer[431:424];
				8'd54: readdata <= header_buffer[439:432];
				8'd55: readdata <= header_buffer[447:440];
				8'd56: readdata <= header_buffer[455:448];
				8'd57: readdata <= header_buffer[463:456];
				8'd58: readdata <= header_buffer[471:464];
				8'd59: readdata <= header_buffer[479:472];
				8'd60: readdata <= header_buffer[487:480];
				
				8'd61: readdata <= header_buffer[495:488];
				8'd62: readdata <= header_buffer[503:496];
				8'd63: readdata <= header_buffer[511:504];
				8'd64: readdata <= header_buffer[519:512];
				8'd65: readdata <= header_buffer[527:520];
				8'd66: readdata <= header_buffer[535:528];
				8'd67: readdata <= header_buffer[543:536];
				8'd68: readdata <= header_buffer[551:544];
				8'd69: readdata <= header_buffer[559:552];
				8'd70: readdata <= header_buffer[567:560];
				8'd71: readdata <= header_buffer[575:568];
				8'd72: readdata <= header_buffer[583:576];
				8'd73: readdata <= header_buffer[591:584];
				8'd74: readdata <= header_buffer[599:592];
				8'd75: readdata <= header_buffer[607:600];
				8'd76: readdata <= header_buffer[615:608];
				8'd77: readdata <= header_buffer[623:616];
				8'd78: readdata <= header_buffer[631:624];
				8'd79: readdata <= header_buffer[639:632];
				8'd80: readdata <= header_buffer[647:640];
				8'd81: readdata <= header_buffer[655:648];
				8'd82: readdata <= header_buffer[663:656];
				8'd83: readdata <= header_buffer[671:664];	
				8'd84: readdata <= header_buffer[679:672];
				8'd85: readdata <= header_buffer[687:680];
				8'd86: readdata <= header_buffer[695:688];
				8'd87: readdata <= header_buffer[703:696];
				8'd88: readdata <= header_buffer[711:704];
				8'd89: readdata <= header_buffer[719:712];
				8'd90: readdata <= header_buffer[727:720];
				8'd91: readdata <= header_buffer[735:728];
				8'd92: readdata <= header_buffer[743:736];
				8'd93: readdata <= header_buffer[751:744];
				8'd94: readdata <= header_buffer[759:752];
				8'd95: readdata <= header_buffer[767:760];
				
				//golden nonce (for the single miner, won't be needing this later)
				/*
				8'd96: readdata <= gold_nonce[7:0];
				8'd97: readdata <= gold_nonce[15:8];
				8'd98: readdata <= gold_nonce[23:16];
				8'd99: readdata <= gold_nonce[31:24];
				8'd100: begin
								readdata[7:2] <= 5'b00000;
								readdata[1] <= ticket;
			  				readdata[0] <= gold_nonce[32];
							end
				*/
				//load state
				8'd101: begin
								readdata[0] <= loading;
								readdata[1] <= load_done;
								readdata[7:2] <= 5'b000000;
							end
				//start state, may not be necessary to have a read option for it later
				8'd102: begin
								readdata[0] <= start;
								readdata[1] <= stop;
								readdata[7:2] <= 5'b000000;
							end
				//read_gold_nonce, nonce_out[32]
				8'd103: begin
								readdata[0] <= read_gold_nonce;
								//readdata[1] <= nonce_out[32];
								readdata[2] <= nonce_out_a[0][32]; //MINERS[0].m_nonce_out[32];
								readdata[3] <= nonce_out_a[1][32]; //MINERS[1].m_nonce_out[32];
							end
				
				//nonce_ram
				8'd104: readdata <= nonce_ram[0][`IDX8(0)];
				8'd105: readdata <= nonce_ram[0][`IDX8(1)];
				8'd106: readdata <= nonce_ram[0][`IDX8(2)];
				8'd107: readdata <= nonce_ram[0][`IDX8(3)];
							
				8'd108: readdata <= nonce_ram[1][`IDX8(0)];
				8'd109: readdata <= nonce_ram[1][`IDX8(1)];
				8'd110: readdata <= nonce_ram[1][`IDX8(2)];
				8'd111: readdata <= nonce_ram[1][`IDX8(3)];
				
			
				8'd112: readdata <= nonce_ram[2][`IDX8(0)];
				8'd113: readdata <= nonce_ram[2][`IDX8(1)];
				8'd114: readdata <= nonce_ram[2][`IDX8(2)];
				8'd115: readdata <= nonce_ram[2][`IDX8(3)];
							
				8'd116: readdata <= nonce_ram[3][`IDX8(0)];
				8'd117: readdata <= nonce_ram[3][`IDX8(1)];
				8'd118: readdata <= nonce_ram[3][`IDX8(2)];
				8'd119: readdata <= nonce_ram[3][`IDX8(3)];
							
				8'd120: readdata <= nonce_ram[4][`IDX8(0)];
				8'd121: readdata <= nonce_ram[4][`IDX8(1)];
				8'd122: readdata <= nonce_ram[4][`IDX8(2)];
				8'd123: readdata <= nonce_ram[4][`IDX8(3)];
				
				
				//result_ram
				8'd148: readdata <= result_ram[0][`IDX8(0)];
				8'd149: readdata <= result_ram[0][`IDX8(1)];
				8'd150: readdata <= result_ram[0][`IDX8(2)];
				8'd151: readdata <= result_ram[0][`IDX8(3)];
				8'd152: begin
								readdata[7:1] <= 6'b000000;
			  				readdata[0] <= result_ram[0][32];
							end
							
				8'd153: readdata <= result_ram[1][`IDX8(0)];
				8'd154: readdata <= result_ram[1][`IDX8(1)];
				8'd155: readdata <= result_ram[1][`IDX8(2)];
				8'd156: readdata <= result_ram[1][`IDX8(3)];
				8'd157: begin
								readdata[7:1] <= 6'b000000;
			  				readdata[0] <= result_ram[1][32];
							end
				
							
				8'd158: readdata <= result_ram[2][`IDX8(0)];
				8'd159: readdata <= result_ram[2][`IDX8(1)];
				8'd160: readdata <= result_ram[2][`IDX8(2)];
				8'd161: readdata <= result_ram[2][`IDX8(3)];
				8'd162: begin
								readdata[7:1] <= 6'b000000;
			  				readdata[0] <= result_ram[2][32];
							end
				
				8'd163: readdata <= result_ram[3][`IDX8(0)];
				8'd164: readdata <= result_ram[3][`IDX8(1)];
				8'd165: readdata <= result_ram[3][`IDX8(2)];
				8'd166: readdata <= result_ram[3][`IDX8(3)];
				8'd167: begin
								readdata[7:1] <= 6'b000000;
			  				readdata[0] <= result_ram[3][32];
							end
							
				8'd168: readdata <= result_ram[4][`IDX8(0)];
				8'd169: readdata <= result_ram[4][`IDX8(1)];
				8'd170: readdata <= result_ram[4][`IDX8(2)];
				8'd171: readdata <= result_ram[4][`IDX8(3)];
				8'd172: begin
								readdata[7:1] <= 6'b000000;
			  				readdata[0] <= result_ram[4][32];
							end
							
			endcase
		end
		else if(stop) begin
				//gold_nonce[31:0] <= nonce_out[31:0];
				//gold_nonce[32] <= nonce_out[32];
				
				//Make sure the first index ranges from 0 to mctr-1
				result_ram[0][31:0] <= nonce_out_a[0][31:0]; //MINERS[0].m_nonce_out[31:0];
				result_ram[1][31:0] <= nonce_out_a[1][31:0]; //MINERS[1].m_nonce_out[31:0];
				result_ram[2][31:0] <= nonce_out_a[2][31:0]; //MINERS[2].m_nonce_out[31:0];
				result_ram[3][31:0] <= nonce_out_a[3][31:0]; //MINERS[3].m_nonce_out[31:0];
				result_ram[4][31:0] <= nonce_out_a[4][31:0]; //MINERS[4].m_nonce_out[31:0];
				
				result_ram[0][32] <= nonce_out_a[0][32]; //MINERS[0].m_nonce_out[32];
				result_ram[1][32] <= nonce_out_a[1][32]; //MINERS[1].m_nonce_out[32];
				result_ram[2][32] <= nonce_out_a[2][32]; //MINERS[2].m_nonce_out[32];
				result_ram[3][32] <= nonce_out_a[3][32]; //MINERS[3].m_nonce_out[32];
				result_ram[4][32] <= nonce_out_a[4][32]; //MINERS[4].m_nonce_out[32];
		end
		else begin
			load_done <= 1'b0;
			
			ticket = nonce_out_a[0][32] ||
							 nonce_out_a[1][32] ||
							 nonce_out_a[2][32] ||
							 nonce_out_a[3][32] ||
							 nonce_out_a[4][32];
			
			if(read_gold_nonce && ticket && !loading) begin		
				//gold_nonce[31:0] <= nonce_out[31:0]; //fix this
				//gold_nonce[32] <= nonce_out[32];
				
				
				result_ram[0][31:0] <= nonce_out_a[0][31:0]; //MINERS[0].m_nonce_out[31:0];
				result_ram[1][31:0] <= nonce_out_a[1][31:0]; //MINERS[1].m_nonce_out[31:0];
				result_ram[2][31:0] <= nonce_out_a[2][31:0]; //MINERS[2].m_nonce_out[31:0];
				result_ram[3][31:0] <= nonce_out_a[3][31:0]; //MINERS[3].m_nonce_out[31:0];
				result_ram[4][31:0] <= nonce_out_a[4][31:0]; //MINERS[4].m_nonce_out[31:0];
				
				result_ram[0][32] <= nonce_out_a[0][32]; //MINERS[0].m_nonce_out[32];
				result_ram[1][32] <= nonce_out_a[1][32]; //MINERS[1].m_nonce_out[32];
				result_ram[2][32] <= nonce_out_a[2][32]; //MINERS[2].m_nonce_out[32];
				result_ram[3][32] <= nonce_out_a[3][32]; //MINERS[3].m_nonce_out[32];
				result_ram[4][32] <= nonce_out_a[4][32]; //MINERS[4].m_nonce_out[32];		

				read_gold_nonce = 1'b0;
				stop <= 1'b1;
			end
			else begin
				gold_nonce <= 33'd0;
			
				result_ram[0] <= 33'd0;
				result_ram[1] <= 33'd0;
				result_ram[2] <= 33'd0;
				result_ram[3] <= 33'd0;
				result_ram[4] <= 33'd0;
			end
			
		end
	end //end of always @ (posedge clk)
	
endmodule
