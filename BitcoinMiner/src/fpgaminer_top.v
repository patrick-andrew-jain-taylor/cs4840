/*
*
* Copyright (c) 2011-2012 fpgaminer@bitcoin-mining.com
*
*
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
* 
*/


`timescale 1ns/1ps

//module fpgaminer_top (osc_clk, midstate_buf_in, data_in);
module fpgaminer_top (clk, header_data_input, load_done, nonce_out);

	// The LOOP_LOG2 parameter determines how unrolled the SHA-256
	// calculations are. For example, a setting of 0 will completely
	// unroll the calculations, resulting in 128 rounds and a large, but
	// fast design.
	//
	// A setting of 1 will result in 64 rounds, with half the size and
	// half the speed. 2 will be 32 rounds, with 1/4th the size and speed.
	// And so on.
	//
	// Valid range: [0, 5]
`ifdef CONFIG_LOOP_LOG2
	parameter LOOP_LOG2 = `CONFIG_LOOP_LOG2;
`else
	parameter LOOP_LOG2 = 5;
`endif
  

	// No need to adjust these parameters
	localparam [5:0] LOOP = (6'd1 << LOOP_LOG2);
	// The nonce will always be larger at the time we discover a valid
	// hash. This is its offset from the nonce that gave rise to the valid
	// hash (except when LOOP_LOG2 == 0 or 1, where the offset is 131 or
	// 66 respectively).
	localparam [31:0] GOLDEN_NONCE_OFFSET = (32'd1 << (7 - LOOP_LOG2)) + 32'd1;

	input clk;
	input [767:0] header_data_input;
	input load_done;
	output [32:0] nonce_out;
	reg [32:0] nonce_out;
	//input rst;
	//input write;
	
	
	/*reg [32:0] header_data_output;
	
	reg [767:0] header_buffer;
	reg [1:0] load_cycle = 2'b0;
	reg loading = 1'b0;
	reg load_done = 1'b0;
	*/
	
	//// 
	reg [255:0] state = 0;
	reg [511:0] data = 0;
	reg [31:0] nonce = 32'h00000000;


	//// PLL
	wire hash_clk;
	
	/*
	`ifndef SIM
		main_pll pll_blk (clk, hash_clk);
	`else
		assign hash_clk = clk;
	`endif
*/
  assign hash_clk = clk;

	//// Hashers
	wire [255:0] hash, hash2;
	reg [5:0] cnt = 6'd0;
	reg feedback = 1'b0;

	sha256_transform #(.LOOP(LOOP)) uut (
		.clk(hash_clk),
		.feedback(feedback),
		.cnt(cnt),
		.rx_state(state),
		.rx_input(data),
		.tx_hash(hash)
	);
	sha256_transform #(.LOOP(LOOP)) uut2 (
		.clk(hash_clk),
		.feedback(feedback),
		.cnt(cnt),
		.rx_state(256'h5be0cd191f83d9ab9b05688c510e527fa54ff53a3c6ef372bb67ae856a09e667),	//H7,...,H0
		.rx_input({256'h0000010000000000000000000000000000000000000000000000000080000000, hash}),
		.tx_hash(hash2)
	);


	//// Virtual Wire Control
	reg [255:0] midstate_buf = 0, data_buf = 0;
	wire [255:0] midstate_vw, data2_vw;

/*
	`ifndef SIM
		virtual_wire # (.PROBE_WIDTH(0), .WIDTH(256), .INSTANCE_ID("STAT")) midstate_vw_blk(.probe(), .source(midstate_vw));
		virtual_wire # (.PROBE_WIDTH(0), .WIDTH(256), .INSTANCE_ID("DAT2")) data2_vw_blk(.probe(), .source(data2_vw));
	`endif
*/

	//// Virtual Wire Output
	reg [31:0] golden_nonce = 0;
	
/*
	`ifndef SIM
		virtual_wire # (.PROBE_WIDTH(32), .WIDTH(0), .INSTANCE_ID("GNON")) golden_nonce_vw_blk (.probe(golden_nonce), .source());
		//virtual_wire # (.PROBE_WIDTH(32), .WIDTH(0), .INSTANCE_ID("NONC")) nonce_vw_blk (.probe(nonce), .source());
	`endif
*/
  
  reg start = 1'b0;
  

	//// Control Unit
	reg is_golden_ticket = 1'b0;
	reg feedback_d1 = 1'b1;
	wire [5:0] cnt_next;
	wire [31:0] nonce_next;
	wire feedback_next;
	`ifndef SIM
		wire reset;
		assign reset = 1'b0;
	`else
		reg reset = 1'b0;	// NOTE: Reset is not currently used in the actual FPGA; for simulation only.
	`endif

	assign cnt_next =  reset ? 6'd0 : (LOOP == 1) ? 6'd0 : (cnt + 6'd1) & (LOOP-1);
	// On the first count (cnt==0), load data from previous stage (no feedback)
	// on 1..LOOP-1, take feedback from current stage
	// This reduces the throughput by a factor of (LOOP), but also reduces the design size by the same amount
	assign feedback_next = (LOOP == 1) ? 1'b0 : (cnt_next != {(LOOP_LOG2){1'b0}});
	assign nonce_next =
		reset ? 32'd0 :
		feedback_next ? nonce : (nonce + 32'd1);

	//assign nonce_out = header_data_output;
	
	always @ (posedge hash_clk)
	begin
		`ifdef SIM
			midstate_buf <= 256'h2b3f81261b3cfd001db436cfdsim:/fpgaminer_top/midstate_buf4c8f3f9c7450c9a0d049bee71cba0ea2619c0b5;
			data_buf <= 256'h00000000000000000000000080000000_00000000_39f3001b6b7b8d4dc14bfc31;
			nonce <= 30411740;
		`else
			//midstate_buf <= midstate_vw;
			//data_buf <= data2_vw;
			//midstate_buf <= midstate_buf_in; //256'h228ea4732a3c9ba860c009cda7252b9161a5e75ec8c582a5f106abb3af41f790;
			//data_buf <= data_in; //512'h000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000002194261a9395e64dbed17115;
			
			if(load_done)
				start <= 1'b1;
			
			if(start == 1'b1) begin 
  			   midstate_buf <= header_data_input[255:0];
			   data_buf <= header_data_input[767:256];
			 end
		`endif
    
    if(is_golden_ticket)
      nonce_out[32] <= is_golden_ticket;
    nonce_out[31:0] <= golden_nonce;
		
		cnt <= cnt_next;
		feedback <= feedback_next;
		feedback_d1 <= feedback;
		

		// Give new data to the hasher
		state <= midstate_buf;
		data <= {384'h000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000, nonce_next, data_buf[95:0]};
	  if(start == 1'b0)
	     nonce <= nonce_next;
	  else begin
	     nonce <= header_data_input[383:352];
	     start <= 1'b0;
	  end
	   	
		
		/*
		if(write && !loading) begin
			loading <= 1'b1;
		end
		
		if(loading) begin
			if(load_cycle == 2'b0) begin
				header_buffer[255:0] <= header_data_input;
				load_cycle <= 2'b1;
				loading <= 1'b0;
				//header_buffer[767:384] <= header_data_input;
				//load_done <= 1'b1;
			end
			else if(load_cycle == 2'b1) begin
				header_buffer[511:256] <= header_data_input;
				load_cycle <= 2'b10;
				loading <= 1'b0;
			end
			else if(load_cycle == 2'b10) begin
				header_buffer[767:511] <= header_data_input;
				//load_cycle <= 2'b00;
				load_done <= 1'b1;
			end
		end
		
		if(load_done) begin
			midstate_buf <= header_buffer[255:0];
			data_buf <= header_buffer[767:256];
			nonce <= header_buffer[383:352];
			load_done <= 1'b0;
			loading <= 1'b0;
			load_cycle <= 2'b0;
		end 
		*/
		
		// Check to see if the last hash generated is valid.
		is_golden_ticket <= (hash2[255:224] == 32'h00000000) && !feedback_d1;
		if(is_golden_ticket)
		begin
			// TODO: Find a more compact calculation for this
			if (LOOP == 1)
				golden_nonce <= nonce - 32'd131;
			else if (LOOP == 2)
				golden_nonce <= nonce - 32'd66;
			else
				golden_nonce <= nonce - GOLDEN_NONCE_OFFSET;
		end
`ifdef SIM
		if (!feedback_d1)
			$display ("nonce: %8x\nhash2: %64x\n", nonce, hash2);
`endif
	end
	
	 
	 
	  

endmodule

