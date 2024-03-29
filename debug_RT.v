`timescale 1ns/1ns

module debug_RT( 
			  CPUClock, 
			  OP_FETCH,
			  RESET_IN,
			  RESET_OUT,
			  MONITOR_REQUEST,
			  HW_BREAK_REQUEST,
			  HW_BREAK_FLAG,
			  SW_BREAK_FLAG,
			  MONITOR_INST,
			  MONITOR_ADDR,
			  MONITOR_WR_DATA,
			  MONITOR_RD_DATA,
			  MONITOR_CYC_CMPL,
              MONITOR_DIRECT,
			  LAST_FETCH,
			  PC,
			  INT_REQ,
			  INST_REG, 
			  ACC, 
			  B_REG, 
			  DPH, 
			  DPL, 
			  PSW, 
			  SP, 
			  RD_ADDRS, 
			  WR_ADDRS, 
			  RD_DATA, 
			  WR_DATA, 
			  DIRECT_RD, 
			  DIRECT_WR, 
			  WREN, 
			  REAL_TIME_ON,
			  BREAK_FLAG,
			  RETRY,
			  TCK, 
              TDI,
              TDO, 
              TMS,
              TRSTB );

input		  CPUClock;
input		  OP_FETCH;
input		  RESET_IN;
output		  RESET_OUT;
output		  MONITOR_REQUEST;
output		  HW_BREAK_REQUEST;
input		  HW_BREAK_FLAG;
input         SW_BREAK_FLAG;
output  [2:0] MONITOR_INST;
output [15:0] MONITOR_ADDR;
output  [7:0] MONITOR_WR_DATA;
input   [7:0] MONITOR_RD_DATA;
input         MONITOR_CYC_CMPL;
output        MONITOR_DIRECT;
input  [15:0] LAST_FETCH;
input  [15:0] PC;
input		  INT_REQ;

input	[10:0] INST_REG; 
input	[7:0] ACC;
input	[7:0] B_REG; 
input	[7:0] DPH;
input	[7:0] DPL; 
input	[7:0] PSW; 
input	[7:0] SP;
input	[7:0] RD_ADDRS; 
input	[7:0] WR_ADDRS; 
input	[7:0] RD_DATA;
input	[7:0] WR_DATA; 
input		  DIRECT_RD; 
input		  DIRECT_WR; 
input		  WREN; 

output		  REAL_TIME_ON;	
input		  BREAK_FLAG;
input		  RETRY;

input		  TCK;
input		  TDI;
output		  TDO;
input		  TMS;
input		  TRSTB;

wire          TDO;

parameter   STATUS_SEL   = 8'h21;
parameter   MONITOR_INST_SEL = 8'h26;
parameter   MCU_ID = 8'h03;

reg [2:0]  CNTRL;
reg		   FORCE_BREAKq;
reg [15:0] MONITOR_ADDR;
reg [7:0]  MONITOR_WR_DATA;
reg [2:0]  MONITOR_INST;
reg [2:0]  MONITOR_INSTq;
reg		   MONITOR_REQUEST;
reg		   MONITOR_REQUESTq;
reg [7:0]  SHIFT_REG;
reg		   MONITOR_COMPLETE;

//
// TRACE STUFF //微量的东西
//
reg [6:0] WRITE_PNTR;			 // IR_INSTR_28 
reg [6:0] READ_PNTR;			 // IR_INSTR_29 
reg 	  BUFF_FULL;			 
reg [7:0] TRACE_CNTRL;			 // IR_INSTR_2A 

reg [7:0] ADDRS_CMPR1H;			 // IR_INSTR_2B 
reg [7:0] ADDRS_CMPR1L;			 // IR_INSTR_2C 
reg [7:0] ADDRS_CMPR2H;			 // IR_INSTR_2D
reg [7:0] ADDRS_CMPR2L;			 // IR_INSTR_2E 
reg [7:0] ADDRS_CMPR3H;			 // IR_INSTR_2F 
reg [7:0] ADDRS_CMPR3L;			 // IR_INSTR_30 
reg  [35:0] T_STAMP;
reg  [35:0] TS_SAMPL;
reg			TRACE_STARTED;
reg			TS_SAMPL_ENABLE;
reg	 [34:0]	PRE_SAMPL;

wire [143:0] SAMPLE;


reg [2:0] CYCL_DET;
reg		  EXECUTE;

wire [7:0] STATUS;
wire [7:0] UIREG_;
wire RESET_IN;
wire RESET_OUT;
wire URST_;
wire URSTB_;
wire UDRUPD_;
wire UDRCK_;
wire UDRCAP_;
wire UDRSH_;
wire UTDI_;
wire UDRCKb;
wire CLR_MFUNC;
wire STATUS_SELECTED;
wire INST_SELECTED;
wire CLR_MONITOR_COMPLETE;
wire FORCE_RESET;
wire FORCE_BREAK;
wire CLR_HW_BREAK;
wire MONITOR_DIRECT;
wire HW_BREAK_REQUEST;
wire BREAK_DETECT1;
wire BREAK_DETECT2;
wire BREAK_DETECT3;
wire TRACE_EN;
wire QUAL_EN;
wire TRACE_ON;			  //TRACE_CNTRL[0]  //trace跟踪
wire FLUSH;				  //TRACE_CNTRL[1]
wire BRK_PNT_EN1;		  //TRACE_CNTRL[2]
wire BRK_PNT_EN2;		  //TRACE_CNTRL[3]
wire BRK_PNT_EN3;		  //TRACE_CNTRL[4]
wire FLUSH_BUFF;  
wire BREAK_QUAL;
wire [15:0] LAST_FETCHq; 
wire [7:0] INST_REGq; 
wire [7:0] ACCq;
wire [7:0] B_REGq; 
wire [7:0] DPHq;
wire [7:0] DPLq; 
wire [7:0] PSWq; 
wire [7:0] SPq;
wire [7:0] RD_ADDRSq; 
wire [7:0] WR_ADDRSq; 
wire [7:0] RD_DATAq;
wire [7:0] WR_DATAq; 
wire [35:0] T_STAMPq; 
wire 	   DIRECT_RDq; 
wire 	   DIRECT_WRq; 
wire 	   WRENq;
wire 	   INT_REQq; 
wire	   EXECUTED;
wire	   SINGLE_CYCL;
wire	   MULTI_CYCL;



assign SINGLE_CYCL = OP_FETCH & (CYCL_DET == 3'b001);
assign MULTI_CYCL = OP_FETCH & |CYCL_DET[2:1];
assign	SAMPLE = {LAST_FETCH, INST_REG[7:0], ACC, B_REG, DPH, DPL, PSW, SP, RD_ADDRS, WR_ADDRS, RD_DATA, WR_DATA, T_STAMP, DIRECT_RD, DIRECT_WR, WREN, INST_REG[9]  };
assign FLUSH_BUFF = URST_ | FLUSH;
assign CLR_HW_BREAK =  RESET_OUT | URST_;
assign FORCE_RESET    =  CNTRL[0];
assign FORCE_BREAK    =  CNTRL[1];
assign MONITOR_DIRECT = ~CNTRL[2];
assign URST_        = ~URSTB_;
assign STATUS_SELECTED = (UIREG_ == STATUS_SEL);
assign INST_SELECTED   = (UIREG_ == MONITOR_INST_SEL);
assign CLR_MFUNC            = MONITOR_CYC_CMPL | URST_ | RESET_OUT;
assign CLR_MONITOR_COMPLETE = (URST_ | (STATUS_SELECTED & UDRUPD_));
assign HW_BREAK_REQUEST = FORCE_BREAKq | BREAK_DETECT1 | BREAK_DETECT2 | BREAK_DETECT3;
assign BREAK_QUAL =  ~INT_REQ & ~MONITOR_REQUEST; 
assign QUAL_EN = ~BREAK_FLAG  	& 
					OP_FETCH	& 
					~FLUSH 		& 
					TRACE_ON 	& 
					~MONITOR_REQUEST ;	

assign TRACE_ON 	= TRACE_CNTRL[0];	  				//TRACE_CNTRL[0]
assign FLUSH    	= TRACE_CNTRL[1];	  				//TRACE_CNTRL[1]
assign BRK_PNT_EN1	= TRACE_CNTRL[2] & BREAK_QUAL;	  	//TRACE_CNTRL[2]
assign BRK_PNT_EN2	= TRACE_CNTRL[3] & BREAK_QUAL;	  	//TRACE_CNTRL[3]
assign BRK_PNT_EN3	= TRACE_CNTRL[4] & BREAK_QUAL;	  	//TRACE_CNTRL[4]		
assign REAL_TIME_ON = TRACE_CNTRL[7];  					// 1 = real time mode on; 0 = off			  
				                                        // 1 =实时模式，0 =关闭
assign STATUS = { 
				 1'b1,					 			// D7 
				 MONITOR_REQUEST,
				 MONITOR_COMPLETE, 
                 RESET_IN,
                 FORCE_RESET, 
                 HW_BREAK_FLAG,
				 SW_BREAK_FLAG,
                 RETRY			 						// D0 
                 };

assign RESET_OUT = RESET_IN | FORCE_RESET;
assign UDRCKb = UDRCK_;


// global clock buffer instantiations for use with QuickLogic 
//全局时钟缓冲与QuickLogic使用实例化
//gclkbuff_25um gclk1( .A(RESET_IN | FORCE_RESET) , .Z(RESET_OUT) );
//gclkbuff_25um gclk2( .A(UDRCK_) , .Z(UDRCKb) );

ADDRS_CMPR16 CMPR1(.A(PC), 
				   .B({ADDRS_CMPR1H, ADDRS_CMPR1L}), 
				   .EN(BRK_PNT_EN1), 
				   .EQ(BREAK_DETECT1));
                  
ADDRS_CMPR16 CMPR2(.A(PC), 
				   .B({ADDRS_CMPR2H, ADDRS_CMPR2L}), 
				   .EN(BRK_PNT_EN2), 
				   .EQ(BREAK_DETECT2));

ADDRS_CMPR16 CMPR3(.A(PC), 
				   .B({ADDRS_CMPR3H, ADDRS_CMPR3L}), 
				   .EN(BRK_PNT_EN3), 
				   .EQ(BREAK_DETECT3));

// 144-Channel trace buffer //144频道跟踪缓冲区
// ALTERA Cyclone instantiation //ALTERA公司气旋实例
/*
ram128x144 TRACE(
					.data({LAST_FETCH, INST_REG[7:0], ACC, B_REG, DPH, DPL, PSW, SP, 
							(MULTI_CYCL ? PRE_SAMPL[34:3] : {RD_ADDRS, WR_ADDRS, RD_DATA, WR_DATA}), 
							T_STAMP, (MULTI_CYCL ? PRE_SAMPL[2:0] : {DIRECT_RD, DIRECT_WR, WREN}), INST_REG[9] }),
					.wren(MULTI_CYCL | SINGLE_CYCL),
					.wraddress(WRITE_PNTR),
					.rdaddress(READ_PNTR),
					.clock(CPUClock),
					.q({LAST_FETCHq, INST_REGq, ACCq, B_REGq, DPHq, DPLq, PSWq, SPq, RD_ADDRSq, WR_ADDRSq, RD_DATAq, WR_DATAq, T_STAMPq, DIRECT_RDq, DIRECT_WRq, WRENq, INT_REQq }));
*/
					
// 144-Channel trace buffer //144频道跟踪缓冲区
// QuickLogic Eclipse II  instantiation //QuickLogic的Eclipse II的实例
/*
r128a144_25um TRACE(
					.wa(WRITE_PNTR),
					.ra(READ_PNTR),
					.wd({LAST_FETCH, INST_REG[7:0], ACC, B_REG, DPH, DPL, PSW, SP, 
							(MULTI_CYCL ? PRE_SAMPL[34:3] : {RD_ADDRS, WR_ADDRS, RD_DATA, WR_DATA}), 
							T_STAMP, (MULTI_CYCL ? PRE_SAMPL[2:0] : {DIRECT_RD, DIRECT_WR, WREN}), INST_REG[9] }),
					.rd({LAST_FETCHq, INST_REGq, ACCq, B_REGq, DPHq, DPLq, PSWq, SPq, RD_ADDRSq, WR_ADDRSq, RD_DATAq, WR_DATAq, T_STAMPq, DIRECT_RDq, DIRECT_WRq, WRENq, INT_REQq }),
					.we(MULTI_CYCL | SINGLE_CYCL),
					.wclk(CPUClock));					
*/

always @(posedge CPUClock or posedge FLUSH_BUFF) begin
	if (FLUSH_BUFF) begin
		BUFF_FULL <= 1'b0;
		WRITE_PNTR <= 7'h00;
		T_STAMP <= 36'h0_0000_0000;
		TRACE_STARTED <= 1'b0;
		CYCL_DET <= 3'b000;
		EXECUTE <= 1'b0;
		TS_SAMPL <= 36'h0_0000_0002;
		TRACE_STARTED <= 1'b0;
		TS_SAMPL_ENABLE <= 1'b1;
		PRE_SAMPL <= 35'h0_0000_0000;
	end
	else begin
	
		PRE_SAMPL <= {RD_ADDRS, WR_ADDRS, RD_DATA, WR_DATA, DIRECT_RD, DIRECT_WR, WREN};
		
		casex (UIREG_[7:0])
			8'h54,
			8'h55,
			8'h56,
			8'h57,
			8'h58	: TS_SAMPL_ENABLE <= 1'b0;
			default : TS_SAMPL_ENABLE <= 1'b1;
		endcase
		
		if (TS_SAMPL_ENABLE) TS_SAMPL <= T_STAMP;			
				
		if (QUAL_EN) CYCL_DET <= 3'b001;
		else if (~OP_FETCH & |CYCL_DET) CYCL_DET <= CYCL_DET + 1'b1;
		else if (OP_FETCH) CYCL_DET <= 3'b000;
		
		if ((CYCL_DET == 3'b001) & OP_FETCH) EXECUTE <= 1'b1;  // indicates single ~ instruction.
		                                                       // 表明唯一~指示。  
		else EXECUTE <= 1'b0;
		
		if(TRACE_STARTED) T_STAMP <= T_STAMP + 1'b1;
		else if (QUAL_EN & ~TRACE_STARTED) begin
			TRACE_STARTED <= 1'b1;
			T_STAMP <= T_STAMP + 1'b1;
		end			
		if (MULTI_CYCL | SINGLE_CYCL) begin
			if (&WRITE_PNTR) BUFF_FULL <= 1'b1;
			WRITE_PNTR <= WRITE_PNTR + 1'b1;
		end
	end
end
		

always @(posedge CPUClock or posedge CLR_MONITOR_COMPLETE) begin
	if (CLR_MONITOR_COMPLETE) MONITOR_COMPLETE <= 1'b0;
	else if (MONITOR_CYC_CMPL) MONITOR_COMPLETE <= 1'b1;
end

always @(posedge CPUClock or posedge URST_) begin
	if (URST_) MONITOR_INST <= 3'b000;
	else begin
	   if (MONITOR_CYC_CMPL) MONITOR_INST <= 3'b000;
	   else if (OP_FETCH & MONITOR_REQUEST) MONITOR_INST <= MONITOR_INSTq;
	end
end


always @(posedge CPUClock or posedge CLR_MFUNC) begin
	if (CLR_MFUNC) MONITOR_REQUEST <= 1'b0;
    else if (OP_FETCH & MONITOR_REQUESTq) MONITOR_REQUEST <= 1'b1;
end


always @(posedge UDRCKb or posedge CLR_MFUNC) begin
	if (CLR_MFUNC) MONITOR_REQUESTq <= 1'b0;
    else if (INST_SELECTED & UDRUPD_) MONITOR_REQUESTq <= 1'b1;
end

always @(posedge CPUClock or posedge CLR_HW_BREAK) begin
	if (CLR_HW_BREAK) FORCE_BREAKq <= 1'b0;
	else  FORCE_BREAKq <= FORCE_BREAK;
end


always @(posedge UDRCKb or posedge URST_) begin
    if (URST_) begin
        SHIFT_REG   		<=  8'h00;
        CNTRL       		<=  3'b000;
        MONITOR_ADDR    	<=  16'h0000;
        MONITOR_INSTq   	<=  3'b000;
        MONITOR_WR_DATA 	<=  8'h00;

		READ_PNTR 			<=  7'h00;	 // IR_INSTR_29 -- write only
		TRACE_CNTRL 		<=  8'h81;	 // IR_INSTR_2A -- write only
		ADDRS_CMPR1H 		<=  8'h00;	 // IR_INSTR_2B -- write only
		ADDRS_CMPR1L 		<=  8'h00;	 // IR_INSTR_2C -- write only
		ADDRS_CMPR2H 		<=  8'h00;	 // IR_INSTR_2D	-- write only
		ADDRS_CMPR2L 		<=  8'h00;	 // IR_INSTR_2E -- write only
		ADDRS_CMPR3H 		<=  8'h00;	 // IR_INSTR_2F -- write only
		ADDRS_CMPR3L 		<=  8'h00;	 // IR_INSTR_30 -- write only
    end

    else begin

        if (UDRCAP_ & ~UDRSH_) begin
            case (UIREG_[7:0])
                8'h20 : SHIFT_REG <= MCU_ID;
                8'h21 : SHIFT_REG <= STATUS;
                8'h23 : SHIFT_REG <= LAST_FETCH[7:0];
                8'h24 : SHIFT_REG <= LAST_FETCH[15:8];
                8'h25 : SHIFT_REG <= MONITOR_RD_DATA;
				8'h27 : SHIFT_REG <= {7'b0000_000, BUFF_FULL};
				8'h28 : SHIFT_REG <= {1'b0, WRITE_PNTR[6:0]};
				8'h29 : SHIFT_REG <= {1'b0, READ_PNTR[6:0]};
				8'h37 :	SHIFT_REG <= TRACE_CNTRL;
				8'h40 : SHIFT_REG <= LAST_FETCHq[15:8];
				8'h41 : begin
							SHIFT_REG <= LAST_FETCHq[7:0];
							READ_PNTR <= READ_PNTR + 1'b1;
						end	
				8'h42 : SHIFT_REG <= INST_REGq; 
				8'h43 : SHIFT_REG <= ACCq;
				8'h44 : SHIFT_REG <= B_REGq; 
				8'h45 : SHIFT_REG <= DPHq;
				8'h46 : SHIFT_REG <= DPLq; 
				8'h47 : SHIFT_REG <= PSWq; 
				8'h48 : SHIFT_REG <= SPq;
				8'h49 : SHIFT_REG <= RD_ADDRSq; 
				8'h4A : SHIFT_REG <= WR_ADDRSq; 
				8'h4B : SHIFT_REG <= RD_DATAq;
				8'h4C : SHIFT_REG <= WR_DATAq; 
				8'h4D : SHIFT_REG <= T_STAMPq[7:0]; 
				8'h4E : SHIFT_REG <= T_STAMPq[15:8]; 
				8'h4F : SHIFT_REG <= T_STAMPq[23:16]; 
				8'h50 : SHIFT_REG <= T_STAMPq[31:24]; 
				8'h51 : SHIFT_REG <= {DIRECT_RDq, DIRECT_WRq, WRENq, INT_REQq, T_STAMPq[35:32]}; 
				8'h54 : SHIFT_REG <= TS_SAMPL[7:0]; 
				8'h55 : SHIFT_REG <= TS_SAMPL[15:8]; 
				8'h56 : SHIFT_REG <= TS_SAMPL[23:16];
				8'h57 : SHIFT_REG <= TS_SAMPL[31:24];
				8'h58 : SHIFT_REG <= {4'h0, TS_SAMPL[35:32]};
            endcase
        end
		else if (UDRSH_)  SHIFT_REG <= {UTDI_, SHIFT_REG[7:1]};

        if (UDRUPD_) begin
            case (UIREG_[7:0])
                8'h22 : CNTRL[2:0]    	   <= SHIFT_REG[2:0];
                8'h23 : MONITOR_ADDR[7:0]  <= SHIFT_REG;
                8'h24 : MONITOR_ADDR[15:8] <= SHIFT_REG;
                8'h25 : MONITOR_WR_DATA    <= SHIFT_REG;
                8'h26 : MONITOR_INSTq[2:0] <= SHIFT_REG[2:0];

				8'h29 :	READ_PNTR 	   	   <= SHIFT_REG[6:0]; 
				8'h2A :	TRACE_CNTRL    	   <= SHIFT_REG; 
				8'h2B :	ADDRS_CMPR1H   	   <= SHIFT_REG; 
				8'h2C :	ADDRS_CMPR1L   	   <= SHIFT_REG; 
				8'h2D :	ADDRS_CMPR2H   	   <= SHIFT_REG; 
				8'h2E :	ADDRS_CMPR2L   	   <= SHIFT_REG; 
				8'h2F :	ADDRS_CMPR3H   	   <= SHIFT_REG; 
				8'h30 :	ADDRS_CMPR3L   	   <= SHIFT_REG; 											  
            endcase
        end
    end
end


UJTAG ujtag(
`ifdef SYNTH_APA		  
`else
                .TDI(TDI),
                .TDO(TDO),
                .TMS(TMS),
                .TCK(TCK),
                .TRSTB(TRSTB),
`endif
                .UTDI(UTDI_),                // output
                .UTDO(SHIFT_REG[0]),        // input
                .UDRCAP(UDRCAP_),
                .UDRCK(UDRCK_),
                .UDRSH(UDRSH_),
                .UDRUPD(UDRUPD_),
                .URSTB(URSTB_),
                .UIREG0(UIREG_[0]),
                .UIREG1(UIREG_[1]),
                .UIREG2(UIREG_[2]),
                .UIREG3(UIREG_[3]),
                .UIREG4(UIREG_[4]),
                .UIREG5(UIREG_[5]),
                .UIREG6(UIREG_[6]),
                .UIREG7(UIREG_[7]));



endmodule // debug_RT
