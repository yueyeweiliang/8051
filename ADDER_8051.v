
`timescale 1ns/1ns

module ADDER_8051 ( TERM_A, 	  
					TERM_B, 
					CI, 		  // carry in  //携带
					ADDER_OUT, 	  // adder out //加法器出
					CO, 		  // carry out //进行
					HCO, 		  // half carry out (aka aux. carry)上半年进行（又名辅助。履行）
					OVO);		  // overflow out //溢出了

input  [7:0] TERM_A;
input  [7:0] TERM_B;
input  		 CI;
output [7:0] ADDER_OUT;
output 		 CO;
output 		 HCO;
output 		 OVO;

wire   [7:0] ADDER_OUT;
wire  		 CO;
wire		 CO6;
wire		 HCO;
wire	     OVO;

wire		 MSB;
wire   [2:0] HI_NYB;
wire   [3:0] LO_NYB;

assign {CO, MSB} 	 = TERM_A[7]   + TERM_B[7]   + CO6;
assign {CO6, HI_NYB} = TERM_A[6:4] + TERM_B[6:4] + HCO;
assign {HCO, LO_NYB} = TERM_A[3:0] + TERM_B[3:0] + CI;
assign ADDER_OUT 	 = {MSB, HI_NYB, LO_NYB};

assign OVO = CO ^ CO6;

endmodule  //ADDER_8051






