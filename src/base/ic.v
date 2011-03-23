OUTFILE PREFIX_ic.v
INCLUDE def_ic.txt 
ITER MX

ITER SX SLAVE_NUM ##external slave ports don't include decerr slave

module  PREFIX_ic (PORTS); 

   input 				      clk;
   input 				      reset;

   port 				      MMX_GROUP_IC_AXI;
   revport 				      SSX_GROUP_IC_AXI;
ENDITER SX
ITER SX ##use global iterator
  
   wire [EXPR(SLV_BITS-1):0] 		      MMX_AWSLV;
   wire [EXPR(SLV_BITS-1):0] 		      MMX_ARSLV;
   
   wire [EXPR(MSTR_BITS-1):0] 		      SSX_AWMSTR;
   wire [EXPR(MSTR_BITS-1):0] 		      SSX_ARMSTR;
   wire 				      SSX_AWIDOK;
   wire 				      SSX_ARIDOK;
   

   CREATE ic_addr.v def_ic.txt
   PREFIX_ic_addr
   PREFIX_ic_addr_rd (.clk(clk),
		      .reset(reset),
		      .MMX_ASLV(MMX_ARSLV),
		      .MMX_AGROUP_IC_AXI_A(MMX_ARGROUP_IC_AXI_A),
		      .SSX_AMSTR(SSX_ARMSTR),
		      .SSX_AIDOK(SSX_ARIDOK),
		      .SSX_AGROUP_IC_AXI_A(SSX_ARGROUP_IC_AXI_A),
		      STOMP ,
		      );

   
   PREFIX_ic_addr
   PREFIX_ic_addr_wr (
		      .clk(clk),
		      .reset(reset),
		      .MMX_ASLV(MMX_AWSLV),
		      .MMX_AGROUP_IC_AXI_A(MMX_AWGROUP_IC_AXI_A),
		      .SSX_AMSTR(SSX_AWMSTR),
		      .SSX_AIDOK(SSX_AWIDOK),
		      .SSX_AGROUP_IC_AXI_A(SSX_AWGROUP_IC_AXI_A),
		      STOMP ,
		      );

   
   CREATE ic_resp.v def_ic.txt DEFCMD(SWAP CONST(RW) R)
   PREFIX_ic_resp
   PREFIX_ic_rresp (
		    .clk(clk),
		    .reset(reset),
		    .MMX_AGROUP_IC_AXI_CMD(MMX_ARGROUP_IC_AXI_CMD),
		    .MMX_GROUP_IC_AXI_R(MMX_RGROUP_IC_AXI_R),
		    .SSX_GROUP_IC_AXI_R(SSX_RGROUP_IC_AXI_R),
		    STOMP ,
		    );

   
   CREATE ic_wdata.v def_ic.txt
   PREFIX_ic_wdata
   PREFIX_ic_wdata (
		    .clk(clk),
		    .reset(reset),
		    .MMX_AWGROUP_IC_AXI_CMD(MMX_AWGROUP_IC_AXI_CMD),
		    .MMX_WGROUP_IC_AXI_W(MMX_WGROUP_IC_AXI_W),
		    .SSX_WGROUP_IC_AXI_W(SSX_WGROUP_IC_AXI_W),
    		.SSX_AWVALID(SSX_AWVALID),
    		.SSX_AWREADY(SSX_AWREADY),
		    .SSX_AWMSTR(SSX_AWMSTR),
		    STOMP ,
		    );

   
   CREATE ic_resp.v def_ic.txt DEFCMD(SWAP CONST(RW) W)
   PREFIX_ic_resp
   PREFIX_ic_bresp (
		    .clk(clk),
		    .reset(reset),
		    .MMX_AGROUP_IC_AXI_CMD(MMX_AWGROUP_IC_AXI_CMD),
		    .MMX_GROUP_IC_AXI_B(MMX_BGROUP_IC_AXI_B),
		    .MMX_DATA(),
		    .MMX_LAST(),
		    .SSX_GROUP_IC_AXI_B(SSX_BGROUP_IC_AXI_B),
		    .SSX_DATA({DATA_BITS{1'b0}}),
		    .SSX_LAST(1'b1),
		    STOMP ,
		    );
   
   
   IFDEF DEF_DECERR_SLV
     wire 	     SSERR_GROUP_IC_AXI;
   
   CREATE ic_decerr.v def_ic.txt
   PREFIX_ic_decerr
     PREFIX_ic_decerr (
		       .clk(clk),
		       .reset(reset),
		       .AWIDOK(SSERR_AWIDOK),
		       .ARIDOK(SSERR_ARIDOK),
		       .GROUP_IC_AXI(SSERR_GROUP_IC_AXI),
		       STOMP ,
		       );
   ENDIF DEF_DECERR_SLV
      
      
     endmodule


