`timescale 1ns/1ns


module USR_SFRs(
			 DIR_RD_ADDRS,
			 DIR_WR_ADDRS,
			 WR_DATA,				   	
			 RD_DATA,   			
			 DIRECT_WR,			   	
			 DIRECT_RD,
			 CPUClock,
			 WR_EN,
             RMW,
			 RESET,

			 RTI,			 		 
			 INT_REQ,	
			 IN_SERVICE,	 		
			 VECTOR,
			 IACK,		 				 
			 INT0,
			 INT1,
			 T0,
			 T1,

			 PORT0,
             PORT1,
             PORT2,

			 DAC0_TX_OE,
			 DAC0_SYNC_n,
			 DAC0_SIn,
			
			 DAC1_TX_OE,
			 DAC1_SYNC_n,
			 DAC1_SIn,
			
			IACK_TIMR0,
			OSC_DIV12_COUNT	);

input  [7:0] DIR_RD_ADDRS;
input  [7:0] DIR_WR_ADDRS;
input  [7:0] WR_DATA;
output [7:0] RD_DATA;
input  		 DIRECT_WR;
input   	 DIRECT_RD;
input 		 CPUClock;
input		 WR_EN;
input        RMW;
input		 RESET;
inout  [7:0] PORT0;
inout  [7:0] PORT1;
input  [7:0] PORT2;
    
input		 RTI;			 		 
output		 INT_REQ;	
output		 IN_SERVICE;	 		
output [2:0] VECTOR;
input		 IACK;		 				 
input		 INT0;
input		 INT1;
input		 T0;
input		 T1;


output		 DAC0_TX_OE;
output		 DAC0_SYNC_n;
output		 DAC0_SIn;

output		 DAC1_TX_OE;
output		 DAC1_SYNC_n;
output		 DAC1_SIn;

output		 IACK_TIMR0;
output		 OSC_DIV12_COUNT;

parameter    PORT0_ADDRS = 8'h80;    // LEDs
parameter    PORT1_ADDRS = 8'h90;    // LCD control
parameter    PORT2_ADDRS = 8'hA0;    // Keypad input
parameter	 IE_ADDRESS  = 8'hA8;	 // interrupt enable register 中断使能寄存器
parameter	 IP_ADDRESS  = 8'hB8;	 // interrupt priority register 中断优先级寄存器

reg    [7:0] PORT0q;
reg    [7:0] PORT1q;
reg    [7:0] RD_DATA;
reg	   [7:0] INT_ENABL;
reg	   [7:0] INT_PRIORITY;

reg 		 DAC0_SEL;
reg 		 DAC1_SEL;

wire   [7:0] PORT0;
wire   [7:0] PORT1;
wire   [7:0] RD_TIMERS;

wire         CPUClock;

wire   [7:0] INT_SRC;
wire 		 TIMR1_INT_REQ;
wire		 TIMR0_INT_REQ;
wire		 IN_SERVICE;
wire		 INT_REQ;

wire		 IACK_EXT0;
wire		 IACK_TIMR0;
wire		 IACK_EXT1;
wire		 IACK_TIMR1;
wire   [2:0] VECTOR;


wire		 DAC0_TX_OE;
wire		 DAC0_SYNC_n;
wire		 DAC0_SIn;

wire		 DAC1_TX_OE;
wire		 DAC1_SYNC_n;
wire		 DAC1_SIn;



assign		 PORT0 = PORT0q;
assign		 PORT1 = PORT1q;

assign		 INT_SRC = {4'b0000, TIMR1_INT_REQ, ~INT1, TIMR0_INT_REQ, ~INT0}; 


always @(DIR_WR_ADDRS) begin
	case(DIR_WR_ADDRS)
		8'h9C,
		8'h9D : begin
						DAC0_SEL = 1'b1;
						DAC1_SEL = 1'b0;
					 end	
		8'h9E,
		8'h9F : begin
						DAC0_SEL = 1'b0;
						DAC1_SEL = 1'b1;
					 end	
		default    : begin
						DAC0_SEL = 1'b0;
						DAC1_SEL = 1'b0;
					 end
	endcase						
end	
		
timer_cntr01 cntr(
			 .DIR_RD_ADDRS(DIR_RD_ADDRS),
			 .DIR_WR_ADDRS(DIR_WR_ADDRS),
			 .WR_DATA(WR_DATA),				   	
			 .RD_DATA(RD_TIMERS),   			
			 .DIRECT_WR(DIRECT_WR),			   	
			 .CPUClock(CPUClock),
			 .WR_EN(WR_EN),
			 .RESET(RESET),
			 .IACK_EXT0 (IACK_EXT0),
			 .IACK_TIMR0(IACK_TIMR0),
			 .IACK_EXT1 (IACK_EXT1),
			 .IACK_TIMR1(IACK_TIMR1),
			 .TIMR0_INT_REQ(TIMR0_INT_REQ),
			 .TIMR1_INT_REQ(TIMR1_INT_REQ),
			 .INT0_IN(INT0),
			 .INT1_IN(INT1),
			 .T1_IN(T1),
			 .T0_IN(T0),
			 .TERM_COUNT1(TERM_COUNT1),
			 .OSC_DIV12_COUNT(OSC_DIV12_COUNT));


PRI_ENC8 ENC(
			 .INT_SRC(INT_SRC), 
			 .INT_ENABL(INT_ENABL), 
			 .INT_PRIORITY(INT_PRIORITY),
			 .VECTOR(VECTOR), 
			 .CPUClock(CPUClock), 
			 .RESET(RESET), 
			 .RTI(RTI), 
			 .IACK(IACK), 
			 .INT_REQ(INT_REQ),
			 .IACK_EXT0(IACK_EXT0),
			 .IACK_TIMR0(IACK_TIMR0),
			 .IACK_EXT1(IACK_EXT1),
			 .IACK_TIMR1(IACK_TIMR1),
			 .IN_SERVICE(IN_SERVICE));
			

DAC7512 DAC_0(.BlockSel(DAC0_SEL),
			  .RegSel({DIR_WR_ADDRS[0]}),
			  .CPUWR(DIRECT_WR & WR_EN),
			  .CPUClock(CPUClock),
			  .DIn(WR_DATA),
			  .SYNC_n(DAC0_SYNC_n),
			  .SIn(DAC0_SIn),
			  .TxD_OE(DAC0_TX_OE),
			  .Reset(RESET));

DAC7512 DAC_1(.BlockSel(DAC1_SEL),
			  .RegSel({DIR_WR_ADDRS[0]}),
			  .CPUWR((DIRECT_WR & WR_EN)),
			  .CPUClock(CPUClock),
			  .DIn(WR_DATA),
			  .SYNC_n(DAC1_SYNC_n),
			  .SIn(DAC1_SIn),
			  .TxD_OE(DAC1_TX_OE),
			  .Reset(RESET));
			


always @(DIR_RD_ADDRS or PORT0q or PORT1q or PORT2 or RD_TIMERS or INT_PRIORITY or INT_ENABL) begin
   casex (DIR_RD_ADDRS)
		IP_ADDRESS	   : RD_DATA = INT_PRIORITY;
		IE_ADDRESS	   : RD_DATA = INT_ENABL;
        PORT0_ADDRS    : RD_DATA = PORT0q;
        PORT1_ADDRS    : RD_DATA = PORT1q;
		PORT2_ADDRS	   : RD_DATA = PORT2;
        default        : RD_DATA = RD_TIMERS;
  endcase
end


/////////////////////////////////////////////////////////////////////////////
// Simple 8-bit ports (PORT0 and PORT1)
// if selected, write to the appropriate port register
/////////////////////////////////////////////////////////////////////////////

always @(posedge CPUClock or posedge RESET) begin
	if (RESET) begin 
	    INT_ENABL    <= 8'h00;
	    INT_PRIORITY <= 8'h00;
        PORT0q       <= 8'hFF;
        PORT1q       <= 8'hFF;
    end
	else begin
        if (WR_EN & DIRECT_WR) begin
            case (DIR_WR_ADDRS)
				IP_ADDRESS	   : INT_PRIORITY <= WR_DATA;
				IE_ADDRESS	   : INT_ENABL    <= WR_DATA;
                PORT0_ADDRS    : PORT0q       <= WR_DATA;
                PORT1_ADDRS    : PORT1q       <= WR_DATA;
            endcase

        end
    end
end                            

endmodule		 
			 


