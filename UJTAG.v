
module UJTAG (  TDI,
                TDO,
                TMS,
                TCK,
                TRSTB,

                UTDI,        // output to user Data Registers输出到用户数据寄存器
                UTDO,        // input  from user Data Registers从用户输入数据寄存器
                UDRCAP,
                UDRCK,
                UDRSH,
                UDRUPD,
                URSTB,
                UIREG0,
                UIREG1,
                UIREG2,
                UIREG3,
                UIREG4,
                UIREG5,
                UIREG6,
                UIREG7);

input			TDI;
output			TDO;
input			TMS;
input			TCK;
input			TRSTB;

output          UTDI;        // output
input           UTDO;        // input
output          UDRCAP;
output          UDRCK;
output          UDRSH;
output          UDRUPD;
output          URSTB;
output          UIREG0;
output          UIREG1;
output          UIREG2;
output          UIREG3;
output          UIREG4;
output          UIREG5;
output          UIREG6;
output          UIREG7;

reg		[7:0]	UIREG;
reg				TDOq;
reg		[7:0]	IR_SHFTR;

wire			CLOCK_DR;
wire			CLOCK_IR;
wire			ENABLE;
wire			SELECT;
wire			SHIFT_DR;
wire			SHIFT_IR;
wire			TCK;
wire			TMS;
wire			UPDATE_DR;
wire			UPDATE_IR;
wire			TRSTB;

wire			UDRCK;
wire			UDRCAP;
wire			UDRSH;
wire			UDRUPD;
wire			URSTB;
wire			UTDI;
wire			URST;

wire			UIREG7;
wire			UIREG6;
wire			UIREG5;
wire			UIREG4;
wire			UIREG3;
wire			UIREG2;
wire			UIREG1;
wire			UIREG0;	  

assign			UIREG7 = UIREG[7];
assign			UIREG6 = UIREG[6];
assign			UIREG5 = UIREG[5];
assign			UIREG4 = UIREG[4];
assign			UIREG3 = UIREG[3];
assign			UIREG2 = UIREG[2];
assign			UIREG1 = UIREG[1];
assign			UIREG0 = UIREG[0];

assign			UDRCK  = TCK;
assign			TDO = ENABLE ?  TDOq : 1'bz; 
assign			UTDI = TDI;
assign			URSTB = ~URST;

always @(negedge TCK) begin
	TDOq <= SELECT ? IR_SHFTR[0] : UTDO;
end

always	@(posedge TCK or posedge URST) begin
	if (URST) begin
		UIREG <= 8'h00;
		IR_SHFTR <= 8'h00;
	end
	else begin
		if (CLOCK_IR)  IR_SHFTR <= SHIFT_IR ? {TDI, IR_SHFTR[7:1]} : 8'h08;
		else if (UPDATE_IR) UIREG   <= IR_SHFTR;
	end
end			

tap tap( .CLOCK_DR(UDRCAP), 
		 .CLOCK_IR(CLOCK_IR), 
		 .ENABLE(ENABLE), 
		 .RESET(URST), 
		 .SELECT(SELECT), 
		 .SHIFT_DR(UDRSH), 
		 .SHIFT_IR(SHIFT_IR), 
		 .TCK(TCK), 
		 .TMS(TMS),
		 .UPDATE_DR(UDRUPD), 
		 .UPDATE_IR(UPDATE_IR), 
		 .XTCK(~TCK), 
		 .XTRST(TRSTB));

endmodule  // UJTAG