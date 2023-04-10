module timer_cntr01(
			 DIR_RD_ADDRS,
			 DIR_WR_ADDRS,
			 WR_DATA,				   	
			 RD_DATA,   			
			 DIRECT_WR,			   	
			 CPUClock,
			 WR_EN,
			 RESET,
			 IACK_EXT0,
			 IACK_TIMR0,
			 IACK_EXT1,
			 IACK_TIMR1,
			 TIMR0_INT_REQ,
			 TIMR1_INT_REQ,
			 INT0_IN,
			 INT1_IN,
			 T1_IN,
			 T0_IN,
			 TERM_COUNT1,
			 OSC_DIV12_COUNT);

input  [7:0] DIR_RD_ADDRS;
input  [7:0] DIR_WR_ADDRS;
input  [7:0] WR_DATA;
output [7:0] RD_DATA;
input  		 DIRECT_WR;
input 		 CPUClock;
input		 WR_EN;
input		 RESET;
input		 IACK_TIMR0;
input		 IACK_TIMR1;
input		 IACK_EXT0;
input		 IACK_EXT1;
output		 TIMR0_INT_REQ;
output		 TIMR1_INT_REQ;
input		 INT0_IN;
input		 INT1_IN;
input		 T1_IN;
input		 T0_IN;
output		 TERM_COUNT1;
output		 OSC_DIV12_COUNT;


reg   [15:0] TIMR_CNTR0;
reg   [15:0] TIMR_CNTR1;

reg   [7:0]	 TCON;
reg   [7:0]  TMOD;

reg	  [1:0]	 T1q;
reg	  [1:0]	 T0q;

reg	  [1:0]	 EXT1q;
reg	  [1:0]	 EXT0q;

reg	  [3:0]  OSC_DIV12;
reg			 OSC_DIV12_COUNT;


reg   [7:0]  RD_DATA;

wire		 T1_ONE_SHOT;
wire		 T0_ONE_SHOT;

wire		 COUNT_NOW_0;
wire		 COUNT_NOW_0_MOD3;
wire		 COUNT_NOW_1;
wire		 TL0_CYOUT;
wire		 TL1_CYOUT;

wire [7:0]	 TL0_PLUS_ONE;
wire [7:0]	 TL1_PLUS_ONE;
wire [7:0]   TH0_PLUS_CY;
wire [7:0]   TH1_PLUS_CY;
wire		 TIMR0_INT_REQ;
wire		 TIMR1_INT_REQ;	

wire		 INT1_EDGE;
wire		 INT0_EDGE;

reg		 	 TERM_COUNT1;

assign 		 {TL0_CYOUT, TL0_PLUS_ONE} = TIMR_CNTR0[7:0] + 1'b1;
assign		 {TL1_CYOUT, TL1_PLUS_ONE} = TIMR_CNTR1[7:0] + 1'b1;
assign		 TH0_PLUS_CY = TIMR_CNTR0[15:8] + ((&TMOD[1:0]) ? 1'b1 : (~|TMOD[1:0] ? (&TIMR_CNTR0[4:0]) : TL0_CYOUT));
assign		 TH1_PLUS_CY = TIMR_CNTR1[15:8] + (~|TMOD[1:0] ? (&TIMR_CNTR1[4:0]) : TL1_CYOUT);
assign		 TIMR1_INT_REQ = TCON[7];
assign		 TIMR0_INT_REQ = TCON[5];
assign		 T1_ONE_SHOT = (~T1q[1] & T1q[0]) | (~TMOD[6] & OSC_DIV12_COUNT);
assign		 T0_ONE_SHOT = (~T0q[1] & T0q[0]) | (~TMOD[2] & OSC_DIV12_COUNT);
assign		 INT1_EDGE = ~EXT1q[1] & EXT1q[0];
assign		 INT0_EDGE = ~EXT0q[1] & EXT0q[0];
assign		 COUNT_NOW_0 = TCON[4] &  T0_ONE_SHOT & (~TMOD[3] | INT0_IN);
assign		 COUNT_NOW_0_MOD3 = TCON[6] &  T1_ONE_SHOT & (~TMOD[7] | INT1_IN);
assign		 COUNT_NOW_1 = (&TMOD[1:0]) ? (~&TMOD[5:4]) : COUNT_NOW_0_MOD3;

parameter	 TCON_ADDRESS = 8'h88;
parameter	 TMOD_ADDRESS = 8'h89;
parameter	 TL0_ADDRESS  = 8'h8A;
parameter	 TL1_ADDRESS  = 8'h8B;
parameter	 TH0_ADDRESS  = 8'h8C;
parameter	 TH1_ADDRESS  = 8'h8D;


always @(DIR_RD_ADDRS or TIMR_CNTR0 or TIMR_CNTR1 or TCON or TMOD) begin
	casex (DIR_RD_ADDRS)
		TCON_ADDRESS : RD_DATA = TCON;
		TMOD_ADDRESS : RD_DATA = TMOD;
		TL0_ADDRESS  : RD_DATA = TIMR_CNTR0[7:0];
		TH0_ADDRESS  : RD_DATA = TIMR_CNTR0[15:8]; 
		TL1_ADDRESS  : RD_DATA = TIMR_CNTR1[7:0];
		TH1_ADDRESS  : RD_DATA = TIMR_CNTR1[15:8];
		default		 : RD_DATA = 8'hxx;
	endcase
end			 


always @(posedge CPUClock or posedge RESET) begin
	if (RESET) begin
		OSC_DIV12 <= 4'h0;
		OSC_DIV12_COUNT <= 1'b0;
	end
	else begin
	     if	(OSC_DIV12 == 4'hC)	begin
	     	OSC_DIV12 <= 4'h1;
			OSC_DIV12_COUNT <= 1'b1;
		 end
		 else begin
		 	OSC_DIV12 <= OSC_DIV12 + 1'b1;
			OSC_DIV12_COUNT <= 1'b0;
		 end
	end
end

// T1 and T0 one-shots

always @(posedge CPUClock or posedge RESET) begin
	if (RESET) begin
		T1q <= 2'b00;
		T0q <= 2'b00;
	end
	else begin
		T1q <= {T1q[0], T1_IN};
		T0q <= {T0q[0], T0_IN};
	end
end

// EXT1 and EXT0 one-shots//EXT1和EXT0一个镜头

always @(posedge CPUClock or posedge RESET) begin
	if (RESET) begin
		EXT1q <= 2'b00;
		EXT0q <= 2'b00;
	end
	else begin
		EXT1q <= {EXT1q[0], ~INT1_IN};
		EXT0q <= {EXT0q[0], ~INT0_IN};
	end
end

//  TMODE REGISTER //TMODE寄存器

always @(posedge CPUClock or posedge RESET) begin
	if (RESET) TMOD <= 8'h00;
	else if ((DIR_WR_ADDRS == TMOD_ADDRESS)  & WR_EN & DIRECT_WR)  TMOD <= WR_DATA;
end

//  TCON REGISTER //TCON的注册

always @(posedge CPUClock or posedge RESET) begin
	if (RESET) begin
		TCON 		 <= 8'h00;
		TERM_COUNT1  <= 1'b0;
	end
	else begin
		if (TERM_COUNT1) TERM_COUNT1 <= 1'b0;
		if ((DIR_WR_ADDRS == TCON_ADDRESS)  & WR_EN & DIRECT_WR)  {TCON[6], TCON[4], TCON[2], TCON[0]} <= {WR_DATA[6], WR_DATA[4], WR_DATA[2], WR_DATA[0]};
		case (TMOD[1:0])  // actions of the flags depend on the mode 该旗的行动取决于模式
			2'b00 : begin  // 13-bit timer mode //13位定时器模式
						if (IACK_TIMR0) TCON[5] <= 1'b0;
						else if (&TIMR_CNTR0[15:8] & COUNT_NOW_0 & (&TIMR_CNTR0[4:0])) TCON[5] <= 1'b1;
					end
			2'b01 : begin  // 16-bit timer mode //16位定时器模式
						if (IACK_TIMR0) TCON[5] <= 1'b0;
						else if (&TIMR_CNTR0[15:0] & COUNT_NOW_0)  TCON[5] <= 1'b1;
					end
			2'b10 : begin  // 8-bit reloadable cournter mode //8位增值cournter模式
						if (IACK_TIMR0) TCON[5] <= 1'b0;
						else if (&TIMR_CNTR0[7:0] & COUNT_NOW_0)  TCON[5] <= 1'b1;
					end
			2'b11 : begin  // split 8-bit counter mode  //分裂的8位计数器模式
						if (IACK_TIMR1) TCON[7] <= 1'b0;
						else if (&TIMR_CNTR0[15:8] & TCON[6])   TCON[7] <= 1'b1;
						if (IACK_TIMR0) TCON[5] <= 1'b0;
						else if (&TIMR_CNTR0[7:0]  & COUNT_NOW_0_MOD3)  TCON[5] <= 1'b1;	
					end
		endcase
                          // 该旗的行动取决于模式
		case (TMOD[5:4])  // actions of the flags depend on the mode 
			2'b00 : begin  // 13-bit timer mode //13位定时器模式
						if (IACK_TIMR1) TCON[7] <= 1'b0;
						else if (&TIMR_CNTR1[15:8] & COUNT_NOW_1  & (&TIMR_CNTR1[4:0]))  begin
							if (~&TMOD[1:0]) TCON[7] <= 1'b1;
							TERM_COUNT1 <= 1'b1;
						end
					end
			2'b01 : begin  // 16-bit timer mode //16位定时器模式
						if (IACK_TIMR1) TCON[7] <= 1'b0;
						else if (&TIMR_CNTR1[15:0] & COUNT_NOW_1)  begin
							if (~&TMOD[1:0]) TCON[7] <= 1'b1;
							TERM_COUNT1 <= 1'b1;
						end
					end
			2'b10 : begin  // 8-bit reloadable cournter mode //8位增值cournter模式
						if (IACK_TIMR1) TCON[7] <= 1'b0;
						else if (&TIMR_CNTR1[7:0] & COUNT_NOW_1)  begin
							if (~&TMOD[1:0]) TCON[7] <= 1'b1;
							TERM_COUNT1 <= 1'b1;
						end
					end
		endcase

		if (IACK_EXT0) TCON[1] <= 1'b0;
		else if (~TCON[0]) TCON[1] <= ~INT0_IN;
		else if (INT0_EDGE) TCON[1] <= 1'b1;

		if (IACK_EXT1) TCON[3] <= 1'b0;
		else if (~TCON[2]) TCON[3] <= ~INT1_IN;
		else if (INT1_EDGE) TCON[3] <= 1'b1;

	end
end

// TIMER COUNTER 0 Low byte  //定时器0低字节

always @(posedge CPUClock or posedge RESET) begin
	if (RESET) TIMR_CNTR0 <= 16'h0000;
	else begin
		if ((DIR_WR_ADDRS == TL0_ADDRESS)  & WR_EN & DIRECT_WR) TIMR_CNTR0[7:0] <= WR_DATA;
		else begin
			case (TMOD[1:0])
				2'b00 :  begin
							if (COUNT_NOW_0) TIMR_CNTR0[7:0] <= TL0_PLUS_ONE;
						 end
				2'b01 :  begin
							if (COUNT_NOW_0) TIMR_CNTR0[7:0] <= TL0_PLUS_ONE;
						 end
				2'b10 :  begin
							if (COUNT_NOW_0) TIMR_CNTR0[7:0] <= (&TIMR_CNTR0[7:0]) ?  TIMR_CNTR0[15:8] : TL0_PLUS_ONE;
						 end
				2'b11 :  begin 
							if (COUNT_NOW_0_MOD3) TIMR_CNTR0[7:0] <= TL0_PLUS_ONE; 
						 end
			endcase
		end

// TIMER COUNTER 0 Hi byte //定时器计数器0喜字节

		if ((DIR_WR_ADDRS == TH0_ADDRESS)  & WR_EN & DIRECT_WR) TIMR_CNTR0[15:8] <= WR_DATA;
		else begin
			case (TMOD[1:0])
				2'b00 :  begin
							if (COUNT_NOW_0) TIMR_CNTR0[15:8] <= TH0_PLUS_CY[7:0];
						 end
				2'b01 :  begin
							if (COUNT_NOW_0) TIMR_CNTR0[15:8] <= TH0_PLUS_CY[7:0];
						 end
				2'b11 :  begin
							if (COUNT_NOW_0_MOD3) TIMR_CNTR0[15:8] <= TH0_PLUS_CY[7:0];
						 end	 
			endcase
		end
	end
end

// TIMER COUNTER 1 Low byte //定时器1低字节

always @(posedge CPUClock or posedge RESET) begin
	if (RESET) TIMR_CNTR1 <= 16'h0000;
	else begin
		if ((DIR_WR_ADDRS == TL1_ADDRESS)  & WR_EN & DIRECT_WR) TIMR_CNTR1[7:0] <= WR_DATA;
		else if (COUNT_NOW_1) begin
			case (TMOD[5:4])
				2'b00 :  TIMR_CNTR1[7:0] <= TL1_PLUS_ONE;
				2'b01 :  TIMR_CNTR1[7:0] <= TL1_PLUS_ONE;
				2'b10 :  TIMR_CNTR1[7:0] <= (&TIMR_CNTR1[7:0]) ? TIMR_CNTR1[15:8] : TL1_PLUS_ONE;
			endcase
		end

// TIMER COUNTER 1 Hi byte //定时器1你好字节

		if ((DIR_WR_ADDRS == TH1_ADDRESS)  & WR_EN & DIRECT_WR) TIMR_CNTR1[15:8] <= WR_DATA;
		else begin
			case (TMOD[5:4])
				2'b00 :  begin
							if (COUNT_NOW_1) TIMR_CNTR1[15:8] <= TH1_PLUS_CY[7:0];
						 end
				2'b01 :  begin
							if (COUNT_NOW_1) TIMR_CNTR1[15:8] <= TH1_PLUS_CY[7:0];
						 end
			endcase
		end
	end
end

endmodule // CNTR_TIMR01.v



