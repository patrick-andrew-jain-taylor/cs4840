// CSEE 4840 Lab1: Display and modify the contents of memory
//
// Spring 2014
//
// By: Peter Xu & Patrick Taylor
// Uni: px2117 & pat2138

module lab1(input logic       clk,
            input logic [3:0] KEY,
            output [7:0]      hex0, hex2, hex3);

   logic [3:0] 		      a;         // Address
   logic [7:0] 		      din, dout; // RAM data in and out
   logic 		      		we;        // RAM write enable

   hex7seg h0( .a(a),         .y(hex0) ),	//Don't change this. h0 will display the current address. See circuit block diagram in lab1.pdf
           h1( .a(dout[7:4]), .y(hex2) ),
           h2( .a(dout[3:0]), .y(hex3) );

   controller c( .* ); // Connect everything with matching names
   memory m( .* );
  
endmodule

module controller(input logic        clk,
						input logic [3:0]  KEY,
						input logic [7:0]  dout,
						output logic [3:0] a,
						output logic [7:0] din,
						output logic 	     we);

   // Replace these with your code
	
	always_ff @(posedge clk) begin
		if(@(negedge KEY[3]))
			a <= a + 4'd1;
		else if(@(negedge KEY[2]))
			a <= a - 4'd1;
		else
			a <= a;
	end
	
   //assign a = KEY;
   assign din = {KEY, ~KEY};
   assign we = 1'b1;
   
endmodule
		  
module hex7seg(input logic [3:0] a,
					output logic [7:0] y);

   //assign y = {a,a}; // Replace this with your code
	always_comb
		case(a)
			4'd0:		y = 8'b_0111111;
			4'd1:		y = 8'b_0000110;
			4'd2:		y = 8'b_1011011;
			4'd3:		y = 8'b_1001111;
			4'd4:		y = 8'b_1100110;
			4'd5:		y = 8'b_1101101;
			4'd6:		y = 8'b_1111101;
			4'd7:		y = 8'b_0000111;
			4'd8:		y = 8'b_1111111;
			4'd9:		y = 8'b_1100111;
			4'd10:	y = 8'b_1110111;
			4'd11:	y = 8'b_1111100;
			4'd12:	y = 8'b_0111001;
			4'd13:	y = 8'b_1011110;
			4'd14:	y = 8'b_1111001;
			4'd15:	y = 8'b_1110001;
			default: y = 8'b11111111;
	endcase
endmodule

// 16 X 8 synchronous RAM with old data read-during-write behavior
module memory(input logic        clk,
				  input logic [3:0]  a,
				  input logic [7:0]  din,
				  input logic 	 we,
				  output logic [7:0] dout);
   
   logic [7:0] 			 mem [15:0];

   always_ff @(posedge clk) begin
      if (we) mem[a] <= din;
      dout <= mem[a];
   end
        
endmodule

