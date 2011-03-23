OUTFILE PREFIX_ic_addr.v

ITER MX
ITER SX

module PREFIX_ic_addr (PORTS);

   input 				      clk;
   input 				      reset;
   
   output [EXPR(SLV_BITS-1):0] 		      MMX_ASLV;
   port 				      MMX_AGROUP_IC_AXI_A;
   output [EXPR(MSTR_BITS-1):0] 	      SSX_AMSTR;
   output 				      SSX_AIDOK;
   revport 				      SSX_AGROUP_IC_AXI_A;
   
   
   parameter 				      MASTER_NONE = 0;
   parameter 				      MASTERMX    = 1 << MX;

   parameter 				      ABUS_WIDTH = GONCAT(GROUP_IC_AXI_A.IN.WIDTH +);

   
   wire [ABUS_WIDTH-1:0] 		      SSX_ABUS;
   
   wire [ABUS_WIDTH-1:0] 		      MMX_ABUS;
   
   wire 				      SSX_MMX;
   
   wire [EXPR(SLV_BITS-1):0] 		      MMX_ASLV;
   
   wire 				      MMX_AIDOK;
   
   wire [EXPR(MSTRS-1):0] 		      SSX_master;

   reg [EXPR(MSTR_BITS-1):0] 		      SSX_AMSTR;

   wire 				      SSX_AIDOK;
   
   CREATE ic_dec.v def_ic.txt
   PREFIX_ic_dec #(ADDR_BITS)
   PREFIX_ic_dec (
		  .MMX_AADDR(MMX_AADDR),
		  .MMX_AID(MMX_AID),
		  .MMX_ASLV(MMX_ASLV),
		  .MMX_AIDOK(MMX_AIDOK),
		  STOMP ,
		  );

   
   CREATE ic_arbiter.v def_ic.txt DEFCMD(SWAP MSTR_SLV mstr) DEFCMD(SWAP MSTRNUM MSTRS) DEFCMD(SWAP SLVNUM SLVS) DEFCMD(DEFINE DEF_PRIO)
   PREFIX_ic_mstr_arbiter
   PREFIX_ic_mstr_arbiter(
			  .clk(clk),
			  .reset(reset),
      
			  .MMX_slave(MMX_ASLV),
      
			  .SSX_master(SSX_master),
      
			  .M_last({MSTRS{1'b1}}),
			  .M_req({CONCAT(MMX_AVALID ,)}),
			  .M_grant({CONCAT(MMX_AREADY ,)})
			  );
   
   LOOP SX
     always @(/*AUTOSENSE*/SSX_master)         
       begin                                    
	  case (SSX_master)                    
	    MASTERMX : SSX_AMSTR = MX;         
	    default : SSX_AMSTR = MASTER_NONE; 
	  endcase                               
       end                                      
   ENDLOOP SX
      
     assign 		     SSX_MMX    = SSX_master[MX];
   
   assign 		     MMX_ABUS   = {GONCAT(MMX_AGROUP_IC_AXI_A.IN ,)};

   
   assign 		     {GONCAT(SSX_AGROUP_IC_AXI_A.IN ,)} = SSX_ABUS;
   
   
   LOOP SX
   assign 		     SSX_ABUS  = CONCAT((MMX_ABUS & {ABUS_WIDTH{SSX_MMX}}) |);              
   assign 		     SSX_AIDOK = CONCAT((SSX_MMX & MMX_AIDOK) |);                  
   ENDLOOP SX
   
   LOOP MX
       assign 		 MMX_AREADY = 
					  SSX_MMX ? SSX_AREADY :  
					  ~MMX_AVALID;            
   ENDLOOP MX
      
     endmodule


