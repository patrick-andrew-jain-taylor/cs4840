/*
 * Avalon memory-mapped peripheral for the VGA LED Emulator
 *
 * Stephen A. Edwards
 * Columbia University
 
  		Peter Xu px2117, Patrick Taylor pat2138
 */

module VGA_LED(input logic        clk,
	       input logic 	  reset,
	       input logic [31:0]  writedata,
	       input logic 	  write,
	       input 		  chipselect,
	       input logic [2:0]  address,

	       output logic [7:0] VGA_R, VGA_G, VGA_B,
	       output logic 	  VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n,
	       output logic 	  VGA_SYNC_n);

	/*
   logic [7:0] 			  hex0, hex1, hex2, hex3,
				  hex4, hex5, hex6, hex7;
	*/
	logic [9:0]			cx, cy;
	
   VGA_LED_Emulator led_emulator(.clk50(clk), .*);

   always_ff @(posedge clk)
     if (reset) begin
	cx <= 10'd320;
	cy <= 10'd240;
     end else if (chipselect && write) begin
	cx <= writedata[19:10];
	cy <= writedata[9:0];
		end
endmodule
