
OUTFILE prgen_fifo.v

module prgen_fifo(PORTS);

   parameter                  WIDTH      = 8;
   parameter                  DEPTH_FULL = 8;

   parameter 		      SINGLE     = DEPTH_FULL == 1;
   parameter 		      DEPTH      = SINGLE ? 1 : DEPTH_FULL -1;
   parameter 		      DEPTH_BITS = 
			      (DEPTH <= 2)   ? 1 :
			      (DEPTH <= 4)   ? 2 :
			      (DEPTH <= 8)   ? 3 :
			      (DEPTH <= 16)  ? 4 :
			      (DEPTH <= 32)  ? 5 :
			      (DEPTH <= 64)  ? 6 :
			      (DEPTH <= 128) ? 7 : 
			      (DEPTH <= 256) ? 8 : 0; //0 is ilegal

   parameter 		      LAST_LINE  = DEPTH-1;
   
   

   input                      clk;
   input                      reset;

   input 		      push;
   input 		      pop;
   input [WIDTH-1:0] 	      din;
   output [WIDTH-1:0] 	      dout;
   //output 		      next;
   output 		      empty;
   output 		      full;
   

   wire 		      reg_push;
   wire 		      reg_pop;
   wire 		      fifo_push;
   wire 		      fifo_pop;
   
   reg [DEPTH-1:0] 	      fullness_in;
   reg [DEPTH-1:0] 	      fullness_out;
   reg [DEPTH-1:0] 	      fullness;
   reg [WIDTH-1:0] 	      fifo [DEPTH-1:0];
   wire 		      fifo_empty;
   wire 		      next;
   reg [WIDTH-1:0] 	      dout;
   reg 			      dout_empty;
   reg [DEPTH_BITS-1:0]       ptr_in;
   reg [DEPTH_BITS-1:0]       ptr_out;
   
   


   assign 		      reg_push  = push & fifo_empty & (dout_empty | pop);
   assign 		      reg_pop   = pop & fifo_empty;
   assign 		      fifo_push = !SINGLE & push & (~reg_push);
   assign 		      fifo_pop  = !SINGLE & pop & (~reg_pop);
   
   
   always @(posedge clk or posedge reset)
     if (reset)
       begin
	  dout       <= #FFD {WIDTH{1'b0}};
	  dout_empty <= #FFD 1'b1;
       end
     else if (reg_push)
       begin
	  dout       <= #FFD din;
	  dout_empty <= #FFD 1'b0;
       end
     else if (reg_pop)
       begin
	  dout       <= #FFD {WIDTH{1'b0}};
	  dout_empty <= #FFD 1'b1;
       end
     else if (fifo_pop)
       begin
	  dout       <= #FFD fifo[ptr_out];
	  dout_empty <= #FFD 1'b0;
       end
   
   always @(posedge clk or posedge reset)
     if (reset)
       ptr_in <= #FFD {DEPTH_BITS{1'b0}};
     else if (fifo_push)
       ptr_in <= #FFD ptr_in == LAST_LINE ? 0 : ptr_in + 1'b1;

   always @(posedge clk or posedge reset)
     if (reset)
       ptr_out <= #FFD {DEPTH_BITS{1'b0}};
     else if (fifo_pop)
       ptr_out <= #FFD ptr_out == LAST_LINE ? 0 : ptr_out + 1'b1;

   always @(posedge clk)
     if (fifo_push)
       fifo[ptr_in] <= #FFD din;

   
   always @(/*AUTOSENSE*/fifo_push or ptr_in)
     begin
	fullness_in = {DEPTH{1'b0}};
	fullness_in[ptr_in] = fifo_push;
     end
   
   always @(/*AUTOSENSE*/fifo_pop or ptr_out)
     begin
	fullness_out = {DEPTH{1'b0}};
	fullness_out[ptr_out] = fifo_pop;
     end
   
   always @(posedge clk or posedge reset)
     if (reset)
       fullness <= #FFD {DEPTH{1'b0}};
     else if (fifo_push | fifo_pop)
       fullness <= #FFD (fullness & (~fullness_out)) | fullness_in;


   assign next       = |fullness;
   assign fifo_empty = ~next;
   assign empty      = fifo_empty & dout_empty;
   assign full       = SINGLE ? !dout_empty : &fullness;

endmodule


