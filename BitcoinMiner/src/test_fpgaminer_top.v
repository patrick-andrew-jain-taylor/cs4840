// Testbench for fpgaminer_top.v
// TODO: Expand and generalize to test any mining core or complete design.
//


`timescale 1ns/1ps

module test_fpgaminer_top(input [255:0] header_midstate_buf,
	input [511:0] header_data,
	input [31:0] header_nonce,
	input newinput,
	input clk,
	
	//output reg [255:0] midstate_buf_out,
	//output reg [511:0] data_out,
	output reg [31:0] golden_nonce,
	output reg golden_nonce_ticket);

/*
  parameter IDLE = 1'b1;
  parameter LOAD = 1'b0;
  reg state; 
*/
	//reg clk = 1'b0;

	//fpgaminer_top # (.LOOP_LOG2(4)) uut (clk, midstate_buf_out, data_out);
  fpgaminer_top # (.LOOP_LOG2(4)) uut (clk);
  
	//reg [31:0] cycle = 32'd0;
  
  /*
	initial begin
		clk = 0;
		#100


		// Test data
		uut.midstate_buf = header_midstate_buf; //256'h228ea4732a3c9ba860c009cda7252b9161a5e75ec8c582a5f106abb3af41f790;
		uut.data_buf = header_data; //512'h000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000002194261a9395e64dbed17115;
		uut.nonce = header_nonce; //32'h0e33337a - 256;	// Minus a little so we can exercise the code a bit
    
	 while(1)
		begin
			#5 clk = 1; #5 clk = 0;
		end
	end
	*/


	always @ (posedge clk)
	begin
	  golden_nonce = uut.golden_nonce;
	  golden_nonce_ticket = uut.is_golden_ticket;
	  
	  //option1
	  /*
	  if(newinput) begin
      midstate_buf_out = header_midstate_buf;
      data_out = header_data;
      uut.nonce = header_nonce;	    	      
    end
    */
    
    //option2
	  /*
	  @ (posedge newinput) begin
      midstate_buf_out = header_midstate_buf;
      data_out = header_data;
      uut.nonce = header_nonce;	    
    end
    */
	  
	  
	  //option3
	  
	  /*
	  case(state)
      IDLE: begin
        if (newinput) state <= LOAD;
          
      end
      LOAD: begin
			  midstate_buf_out = header_midstate_buf; //256'h228ea4732a3c9ba860c009cda7252b9161a5e75ec8c582a5f106abb3af41f790;
			  data_out = header_data;//512'h000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000002194261a9395e64dbed17115;
			  uut.nonce = header_nonce; //32'h0e33337a - 256;	// Minus a little so we can exercise the code a bit
  	   end
  	   default: state <= IDLE;
		endcase
		*/
		//cycle <= cycle + 32'd1;
	end
	
	always @ (posedge newinput) begin
      //midstate_buf_out = header_midstate_buf;
      //data_out = header_data;
      uut.midstate_buf = header_midstate_buf;
      uut.data_buf = header_data;
      uut.nonce = header_nonce;	        	  
  end

endmodule

