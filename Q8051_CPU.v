`timescale 1ns/1ns


module Q8051_CPU( PC, 
  				  PROG_DIN, 
				  PROG_DOUT, 
  				  PROG_WR, 
 				  USR_RD_ADDRS,
				  USR_WR_ADDRS,
				  USR_RD_DATA,
				  USR_WR_DATA,
 				  DIRECT_WR,
				  DIRECT_RD,
  				  CPUClock, 
 				  WR_EN,
                  RMW,
  				  RESET_IN,
                  RESET_OUT,
				  RTI,
  				  IACK,
				  XDATA_CYCL,
				  XDBUS_IN,
                  XDBUS_OUT,
  				  OE_n,
  				  WR_n,
                  MONITOR_DIRECT,
				
				  PCE_n,	
				  DCE_n,	
					
				  Clock_In,
  				  OP_FETCH,
				  INT_REQ,
				  VECTOR,
  				  MONITOR_CYCL,
                  BREAK_FLAG,
				  RD_CLK,
                  TCK, 
                  TDI,
                  TDO, 
                  TMS,
                  TRSTB);

output	[15:0] PC;
input	 [7:0] PROG_DIN;
output	 [7:0] PROG_DOUT;
output	 	   PROG_WR;
input	 [7:0] XDBUS_IN;
output   [7:0] XDBUS_OUT;
output	 [7:0] USR_RD_ADDRS;
output	 [7:0] USR_WR_ADDRS;
input	 [7:0] USR_RD_DATA;
output	 [7:0] USR_WR_DATA;
output         DIRECT_WR;
output		   DIRECT_RD;
output         MONITOR_DIRECT;
output         WR_EN;
output		   PCE_n;	
output		   DCE_n;	
output		   WR_n;	
output		   OE_n;
input		   Clock_In;
output		   CPUClock;
output		   OP_FETCH;
output         RMW;
output		   IACK;
output		   RTI;
input		   INT_REQ;
input	 [2:0] VECTOR;
input		   RESET_IN;
output         RESET_OUT;
output		   MONITOR_CYCL;

output         BREAK_FLAG;
input		   RD_CLK;
output		   XDATA_CYCL;

input		   TCK;
input		   TDI;
input		   TMS;
output		   TDO;
input		   TRSTB;

wire           TDO;



parameter	ACALL		   =	11'b0_0_0_xxx1_0001;	// absolute call	
		   
parameter	ADD_A_Rn	   =	11'b0_0_0_0010_1xxx;	// add source byte (Rn) to (A)
parameter	ADD_A_Dir	   =	11'b0_0_0_0010_0101;	// add source byte (Direct) to (A)
parameter	ADD_A_aRi	   =	11'b0_0_0_0010_011x;	// add source byte ((Ri)) to (A)
parameter	ADD_A_imD	   =	11'b0_0_0_0010_0100;	// add source byte #Data to (A)
						   	
parameter	ADDC_A_Rn	   =	11'b0_0_0_0011_1xxx;	// addc source byte (Rn) to (A)
parameter	ADDC_A_Dir	   =	11'b0_0_0_0011_0101;	// addc source byte (Direct) to (A)
parameter	ADDC_A_aRi	   =	11'b0_0_0_0011_011x;	// addc source byte ((Ri)) to (A)
parameter	ADDC_A_imD	   =	11'b0_0_0_0011_0100;	// addc source byte #Data to (A)
		     
parameter	AJMP		   =	11'b0_0_0_xxx0_0001;	// absolute jump
		     
parameter	ANL_A_Rn	   =	11'b0_0_0_0101_1xxx;	// AND source byte (Rn) with (A)
parameter	ANL_A_Dir	   =	11'b0_0_0_0101_0101;	// AND source byte (Direct) with (A)
parameter	ANL_A_aRi	   =	11'b0_0_0_0101_011x;	// AND source byte ((Ri)) with (A)
parameter	ANL_A_imD	   =	11'b0_0_0_0101_0100;	// AND source byte #Data with (A)
parameter	ANL_Dir_A      =	11'b0_0_0_0101_0010;	// AND Direct byte (A) with (Direct)
parameter	ANL_Dir_imD    =	11'b0_0_0_0101_0011;	// AND Direct #Data with (Direct)
		     
parameter	ANL_C_Bit	   =	11'b0_0_0_1000_0010;	// AND Carry  with Bit
parameter	ANL_C_nBit	   =	11'b0_0_0_1011_0000;	// AND Carry  with not Bit
		     
parameter	CJNE_A_Dir	   =	11'b0_0_0_1011_0101;	// Compare then jump not equal
parameter	CJNE_A_imD	   =	11'b0_0_0_1011_0100;	// Compare immediate and jump not equal
parameter	CJNE_Rn_imD	   =	11'b0_0_0_1011_1xxx;	// Compare reg with #Data and jump not equal
parameter	CJNE_aRi_imD   =	11'b0_0_0_1011_011x;	// Compare ((Ri)) with #Data and jump not equal
		     
parameter	CLR_A		   =	11'b0_0_0_1110_0100;	// Clear Acc
parameter	CLR_Bit		   =	11'b0_0_0_1100_0010;	// Clear Bit
parameter	CLR_C		   =	11'b0_0_0_1100_0011;	// Clear Carry
		     
parameter	CPL_A		   =	11'b0_0_0_1111_0100;	// complement Acc
parameter	CPL_Bit		   =	11'b0_0_0_1011_0010;	// complement Bit
parameter	CPL_C		   =	11'b0_0_0_1011_0011;	// complement Carry
		     
parameter	DA			   =	11'b0_0_0_1101_0100;	// Decimal adjust Acc
		     
parameter	DEC_A		   =	11'b0_0_0_0001_0100;	// DEC Acc
parameter	DEC_Rn		   =	11'b0_0_0_0001_1xxx;	// DEC Rn
parameter	DEC_Dir		   =	11'b0_0_0_0001_0101;	// DEC Dir
parameter	DEC_aRi		   =	11'b0_0_0_0001_011x;	// DEC ((Ri))
		     
parameter	DIV			   =	11'b0_0_0_1000_0100;	// Divide (A/B) : i => A, r => B
		     
parameter	DJNZ_Rn		   =	11'b0_0_0_1101_1xxx;	// Decrement Rn and jump if not 0
parameter	DJNZ_Dir	   = 	11'b0_0_0_1101_0101;	// Decrement Dir and jump if not 0
		     
parameter	INC_A		   =	11'b0_0_0_0000_0100;	// Increment A
parameter	INC_Rn		   =	11'b0_0_0_0000_1xxx;	// Increment Rn
parameter	INC_Dir		   =	11'b0_0_0_0000_0101;	// Increment Dir
parameter	INC_aRi		   =	11'b0_0_0_0000_011x;	// Increment ((Ri))
parameter	INC_DPTR	   = 	11'b0_0_0_1010_0011;	// Increment DPTR
		     
parameter	JB			   =	11'b0_0_0_0010_0000;	// jump if bit is set
parameter	JBC			   =	11'b0_0_0_0001_0000;	// jump if bit is set but clear it first
parameter	JC			   =	11'b0_0_0_0100_0000;	// jump if carry is set
parameter	JMP			   =	11'b0_0_0_0111_0011;	// jump to (A+DPTR)
parameter	JNB			   =	11'b0_0_0_0011_0000;	// jump if bit not set
parameter	JNC			   =	11'b0_0_0_0101_0000;	// jump if Carry not set
parameter	JNZ			   =	11'b0_0_0_0111_0000;	// jump if Acc not 0
parameter	JZ			   =	11'b0_0_0_0110_0000;	// jump if Acc = 0
		     
parameter	LCALL		   =	11'b0_0_0_0001_0010;	// long call
parameter	LJMP		   =	11'b0_0_0_0000_0010;	// long jump
		     
parameter	MOV_A_Rn	   = 	11'b0_0_0_1110_1xxx;	// move A <= Rn
parameter	MOV_A_Dir	   = 	11'b0_0_0_1110_0101;	// move A <= Direct
parameter	MOV_A_aRi	   = 	11'b0_0_0_1110_011x;	// move A <= ((Ri))
parameter	MOV_A_imD	   = 	11'b0_0_0_0111_0100;	// move A <= #Data
parameter	MOV_Rn_A	   = 	11'b0_0_0_1111_1xxx;	// move Rn <= A
parameter	MOV_Rn_Dir	   =	11'b0_0_0_1010_1xxx;	// move Rn <= Dir
parameter	MOV_Rn_imD	   =	11'b0_0_0_0111_1xxx;	// move Rn <= #Data
parameter	MOV_Dir_A	   = 	11'b0_0_0_1111_0101;	// move Dir <= A
parameter	MOV_Dir_Rn	   =	11'b0_0_0_1000_1xxx;	// move Dir <= Rn
parameter	MOV_Dir_Dir	   =	11'b0_0_0_1000_0101;	// move Dir <= Dir
parameter	MOV_Dir_aRi	   =	11'b0_0_0_1000_011x;	// move Dir <= ((Ri))
parameter	MOV_Dir_imD	   =	11'b0_0_0_0111_0101;	// move Dir <= #Data
parameter	MOV_aRi_A	   = 	11'b0_0_0_1111_011x;	// move ((Ri)) <= A
parameter	MOV_aRi_Dir	   =	11'b0_0_0_1010_011x;	// move ((Ri)) <= Dir
parameter	MOV_aRi_imD	   =	11'b0_0_0_0111_011x;	// move ((Ri)) <= #Data
		     
parameter	MOV_C_Bit	   = 	11'b0_0_0_1010_0010;	// move C <= Bit (bit addressed)
parameter	MOV_Bit_C	   = 	11'b0_0_0_1001_0010;	// move Bit <= C
		     
parameter	MOV_DPTR_imD16 =	11'b0_0_0_1001_0000;	// load DPTR with #Data16
parameter	MOVC_A_aA_DPTR =	11'b0_0_0_1001_0011;	// move A <= ((A) + (DPTR))
parameter	MOVC_A_aA_PC   =	11'b0_0_0_1000_0011;	// move A <= ((A) + (PC))
		     
parameter	MOVX_A_aRi	   =	11'b0_0_0_1110_001x;	// move A <= ((Ri))
parameter	MOVX_A_DPTR	   =	11'b0_0_0_1110_0000;	// move A <= ((DPTR))
parameter	MOVX_aRi_A	   =	11'b0_0_0_1111_001x;	// move ((Ri)) <= A
parameter	MOVX_DPTR_A	   =	11'b0_0_0_1111_0000;	// move ((DPTR)) <= A
		     
parameter	MUL			   =	11'b0_0_0_1010_0100;	// multiply BA <= A * B 
		     
parameter	NOP			   =	11'b0_0_0_0000_0000;	// no operation
		     
parameter	ORL_A_Rn	   = 	11'b0_0_0_0100_1xxx;	// A <= A | Rn
parameter	ORL_A_Dir	   = 	11'b0_0_0_0100_0101;	// A <= A | Dir
parameter	ORL_A_aRi	   = 	11'b0_0_0_0100_011x;	// A <= A | aRi
parameter	ORL_A_imD	   = 	11'b0_0_0_0100_0100;	// A <= A | #Data
parameter	ORL_Dir_A	   = 	11'b0_0_0_0100_0010;	// Dir <= Dir | A
parameter	ORL_Dir_imD	   =	11'b0_0_0_0100_0011;	// Dir <= Dir | #Data
		     
parameter	ORL_C_Bit	   = 	11'b0_0_0_0111_0010;	// C <= C | Bit
parameter	ORL_C_nBit	   =	11'b0_0_0_1010_0000;	// C <= C | ~Bit
		     
parameter	POP_Dir		   =	11'b0_0_0_1101_0000;	// POP Direct
parameter	PUSH_Dir	   = 	11'b0_0_0_1100_0000;	// PUSH Direct
		     
parameter	RET			   =	11'b0_0_0_0010_0010;	// Return
parameter	RETI		   =	11'b0_0_0_0011_0010;	// Return from interrupt
		     
parameter	RLA		   	   =	11'b0_0_0_0010_0011;	// rotate accumultor left
parameter	RLC_A		   =	11'b0_0_0_0011_0011;	// rotate accumulator left through carry
		     
parameter	RR_A		   =	11'b0_0_0_0000_0011;	// rotate accumulator right
parameter 	RRC_A		   =	11'b0_0_0_0001_0011;	// rotate accumulator right through carry
		     
parameter	SETB_C		   =	11'b0_0_0_1101_0011;	// set Carry
parameter	SETB_Bit	   = 	11'b0_0_0_1101_0010;	// set bit
		     
parameter	SJMP		   =	11'b0_0_0_1000_0000;	// short jump rel
		     
parameter	SUBB_A_Rn	   = 	11'b0_0_0_1001_1xxx;	// subtract with borrow A <= A - C - Rn
parameter	SUBB_A_Dir	   =	11'b0_0_0_1001_0101;	// A <= A - C - Dir
parameter	SUBB_A_aRi	   =	11'b0_0_0_1001_011x;	// A <= A - C - ((Ri))
parameter	SUBB_A_imD	   =	11'b0_0_0_1001_0100;	// A <= A - C - #Data
		     
parameter	SWAP_A		   =	11'b0_0_0_1100_0100;	// swap Acc nybles
parameter	SWBRK		   = 	11'b0_0_0_1010_0101;	// software break instruction sets force-break bit 
		     						
parameter	XCH_A_Rn	   = 	11'b0_0_0_1100_1xxx;	// A <=> Rn
parameter	XCH_A_Dir	   = 	11'b0_0_0_1100_0101;	// A <=> Dir
parameter	XCH_A_aRi	   = 	11'b0_0_0_1100_011x;	// A <=> ((Ri))
		     
parameter	XCHD		   = 	11'b0_0_0_1101_011x;	// A(L) <=> ((Ri))(L)  lower nyble exchanged
		     
parameter	XRL_A_Rn	   = 	11'b0_0_0_0110_1xxx;	// A <= A ^ Rn
parameter	XRL_A_Dir	   = 	11'b0_0_0_0110_0101;	// A <= A ^ Dir
parameter	XRL_A_aRi	   = 	11'b0_0_0_0110_011x;	// A <= A ^ ((Ri))
parameter	XRL_A_imD	   = 	11'b0_0_0_0110_0100;	// A <= A ^ #Data
parameter	XRL_Dir_A	   = 	11'b0_0_0_0110_0010;	// Dir <= Dir ^ A
parameter	XRL_Dir_imD	   = 	11'b0_0_0_0110_0011;	// Dir <= Dir ^ #Data

parameter	MON_INST	   = 	11'b1_0_0_xxxx_xxxx;	// Monitor Instruction 监测指示  
parameter	EXCEPTION	   = 	11'b0_1_0_xxxx_xxxx;	// Exception 例外
parameter	BREAK_MODE	   =	11'b0_0_1_xxxx_xxxx;	// Break mode打破模式,

//  Addresses defined for certain SFR registers 地址定义为某些SFR寄存器
parameter    ACC_ADDRS     = 8'hE0;              // Accumulator
parameter    DPH_ADDRS     = 8'h83;              // Data Pointer High
parameter    DPL_ADDRS     = 8'h82;              // Data Pointer Low

//  MONITOR INSTRUCTIONS

parameter	 MPROG_RD	   = 3'b001;			// monitor program read 监控程序读取
parameter	 MPROG_WR	   = 3'b010;		    // monitor program write 显示器程序写道  
parameter	 MDATA_RD	   = 3'b011;			// monitor data read  监测数据读取
parameter	 MDATA_WR	   = 3'b100;			// monitor data write 显示器数据写道  
parameter	 MXTRN_RD	   = 3'b101;			// monitor external read 监控外部读
parameter	 MXTRN_WR	   = 3'b110;			// monitor external write  显示器外部写道   
parameter	 MCLR_BRK	   = 3'b111;			// monitor return from breakpoint 监视断点返回


reg  [2:0]	 CYCLE_STATE;			 		    // Instruction Cycle 指令周期
reg [10:0]   INST_REG;			 				// instruction register 指令寄存器
reg          MULTICYCL_INSTR;                   // indicates current fetch is multicycle 表明当前毒品是多周期
reg  [7:0]   RD_ADDRS;                          // current Data READ address 目前的数据读取地址
reg  [7:0]	 WR_ADDRS;							// current Data WRITE address 目前的数据写地址
reg			 WR_EN;								// write enable 写使能
reg			 RD_EN;								// read enable  阅读使
reg  [7:0]   WR_DATA;                           // write side data 写端数据
reg          DIRECT_RD;                         // direct read address mode直接读取地址模式
reg          DIRECT_WR;                         // direct write address mode 直接写地址模式

reg [15:0]   PC;								// program counter 程序计数器
reg  [7:0]	 PCH_TEMP;


reg  [7:0]	 OPERAND_1;							// Operand 1 register (clocked) 操作数寄存器1（时钟）

reg  [7:0]   TERM_A;							// A-side of ALU 
reg  [7:0]   TERM_B;							// B-side of ALU 
reg  [7:0]   DATA_A;							// A-side of ALU 
reg  [7:0]   DATA_B;							// B-side of ALU 
reg			 CARRY_IN;							// Carry into ALU 带进ALU的
reg			 CARRY_OUT;							// Carry into PSW for latching 到PSW内携带闭锁
reg			 OVERFLOW;							// Overflow into PSW for latching 到PSW内溢出的闭锁
reg			 HALF_CARRY;						// Half carry into PSW for latching进行到一半闭锁PSW内
reg  [7:0]	 ALU;								// this is the output of the ALU  这是ALU的输出


reg			 ZERO;								// 1 = ALU is zero 1 = ALU是零

reg			 SELECTED_BIT;						// muxed output (1 of 8) from selected register for bit manipulation instructions
                                                // 合并调制输出（1 8）对位操作指令寄存器选择
reg			 INC_SP;
reg			 DEC_SP;

reg			 OV_ENABLE;							// overflow flag enable 溢出标志启用
reg			 CY_ENABLE;							// carry flage enable 携带flage使
reg			 HC_ENABLE;							// half carry flag enable半进位标志启用
reg			 DIV_INST;							// divide instruction is decoded 鸿沟指令解码
reg			 MUL_INST;							// multiply instruction is decoded 
                                                // 乘法指令进行解码
reg  [15:0]  PC_ADDER_A;						// A side of PC adder 加法器的PC端
reg  [15:0]  PC_ADDER_B;						// B side of PC adder 乙加法器的PC端
reg   [2:0]  BIT_NUMBER;					    // bit number is from the lower three bits of OPERAND_1	register
                                                // 位数字是从低三个OPERAND_1寄存器位
reg			 IACK;
reg			 RTI;

reg 		 LOW_GT_EQ_09h;
reg 		 HI_GT_EQ_09h;

reg	  [7:0]  XCHG_ACC_IN;
reg			 XCHG_INST;

reg   [7:0]	 MONITOR_RD_DATA;
reg			 MONITOR_CYC_CMPL;

reg [15:0]   LAST_FETCH;
reg			 SW_BREAK_FLAG;
reg			 HW_BREAK_FLAG;
reg			 MONITOR_CYCL;
reg			 CYq;				// used by INC_DPTR 使用INC_DPTR

reg			 PROG_WR;
reg          PC_CI;
reg          SSTEP;
reg          RMW;



reg [1:0]	INT_LEVEL;

reg			XDATA_CYCL;

reg			RETRY;


wire		  	CPUClock;
wire  [15:0] DISPLACEMENT;
wire		 BREAK_FLAG;
wire [7:0]   PROG_DOUT; 
wire		 CY;								// carry flag (from PSW)从旗PSW内进行（）	 
wire		 HC;								// half carry flag (from PSW)半进位标志（从PSW内）
wire		 OV;								// overflow flag (from PSW)溢出标志（从PSW内）
wire  [7:0]  STATE;
wire  [3:0]  INTR;                              // encoded interrup inputs中断输入编码
wire         OP_FETCH;                          // active high op_fetch signal 高op_fetch积极信号
wire  [2:0]  STATE_PLUS_ONE;                    // CYCLE_STATE + 1
wire  [7:0]  SP_PLUS_ONE;                       // SP + 1
wire [15:0] BRANCH_ADDRESS; 
wire [15:0] NEXT_PC;							// Next PC --> output of 16-bit PC adder
                                                // 下一个电脑 - >“输出的16位PC加法器
wire        COMPARE_NOT_EQUAL;					// compare operation not zero比较操作不为零
wire		ACCUMULATOR_IS_ZERO;				// ACC contents is zero行政协调会的内容是零
wire		DEC_RESULT_NOT_ZERO;				// result of decrement operation is not zero
                                                // 减量操作的结果不为零
wire  [7:0] CLR_MASK;							// CLR_MASK
wire  [7:0] SET_MASK;							// SET_MASK
wire  [7:0] CMPL_MASK;							// CMPL_MASK
wire  [7:0] BIT_ADDRESS;						// bit-addressable register address
                                                // 位寻址的寄存器地址
wire  [7:0] SET_C_MASK;							// variable mask depending on Carry bit
                                                // 变量面具取决于进位
wire 		ADDER_CARRY;						// the carry output of the adder
                                                // 进位加法器输出的
wire 		ADDER_HC;							// half carry output of the adder
                                                // 一半携带的加法器输出
wire 		ADDER_OV;							// overflow output of the adder	
                                                //溢出输出的加法器
wire  [7:0] ADDER_OUT;							// output of adder	输出加法器
wire  [7:0] RD_DATA;
wire  [7:0] RD_SFR_DATA;
wire  [7:0] RD_RAM_DATA;
wire  [7:0] DPH;								// Data pointer high数据指针高
wire  [7:0] DPL;								// Data pointer low数据指针低
wire  [7:0] SP;									// Stack pointer堆栈指针
wire  [7:0] ACC;								// Accumulator累加器
wire  [7:0]	PSW;								// Program Status Word 程序状态字
wire		RESET;								// active high reset 高有效复位
wire        RESET_OUT;
wire		BIT_IS_SET;
wire		B_IS_ZERO;			
wire 		DA_HI_CY;
wire  [3:0] DA_HI;
wire [10:0] INST_PREFETCH;
wire  [7:0] XDBUS_OUT;
wire		RD_USR_SFR;
wire  [7:0] USR_RD_ADDRS;
wire  [7:0] USR_WR_ADDRS;
wire  [7:0] USR_WR_DATA;
wire        PC_CY;
wire        HW_BREAK_REQUEST;
wire	 [2:0] MONITOR_INST;
wire	[15:0] MONITOR_ADDR;
wire	 [7:0] MONITOR_WR_DATA;
wire		   MONITOR_REQUEST;
wire           MONITOR_DIRECT;
wire    [15:0] Plus_one;
wire   [2:0] INSTR_EXTN;
wire   [15:0] LAST_FETCH_PLUS_ONE;
wire   [7:0] READ_ADDRS;
wire   [7:0] WRITE_ADDRS;
wire		 REAL_TIME_ON;
wire   [7:0] B_REG;
wire		 LOADED;

assign		LOADED = 1'b1;
assign      Plus_one = 'b1;
assign      RESET = RESET_OUT;
assign		USR_RD_ADDRS = RD_ADDRS;
assign		USR_WR_ADDRS = WR_ADDRS;
assign		USR_WR_DATA = WR_DATA;
assign		BREAK_FLAG = SW_BREAK_FLAG |  (~SSTEP & (HW_BREAK_REQUEST | HW_BREAK_FLAG));
assign  	XDBUS_OUT = MONITOR_CYCL ? MONITOR_WR_DATA : ACC;
assign		INST_PREFETCH = {INSTR_EXTN, PROG_DIN};
assign 		PROG_DOUT = MONITOR_WR_DATA;
assign  	{DA_HI_CY, DA_HI} = (ADDER_CARRY | CY | HI_GT_EQ_09h) ? (4'h6 + RD_DATA[7:4]) : 5'b0_0000;
assign		ACCUMULATOR_IS_ZERO = ~|ACC;
assign		CY = PSW[7];
assign		HC = PSW[6];
assign		OV = PSW[2];
assign 		RD_DATA = (RD_ADDRS[7] & DIRECT_RD & ~(~MONITOR_DIRECT & MONITOR_CYCL)) ? (RD_USR_SFR ? USR_RD_DATA : RD_SFR_DATA) : RD_RAM_DATA;
assign 		OP_FETCH = STATE[0];
assign 		STATE = 1'b1 << CYCLE_STATE;   // decode the instruction machine cycle
                                           // 机器周期的指令解码
assign 		STATE_PLUS_ONE = CYCLE_STATE + 1'b1; // STATE incrementor 状态incrementor
assign 		COMPARE_NOT_EQUAL = |ADDER_OUT;
assign	    DEC_RESULT_NOT_ZERO = COMPARE_NOT_EQUAL;
assign 		SET_C_MASK = CY << BIT_NUMBER;			// 8-bit mux with Carry used as enable to create a mask
                                                    // 8位卡里多路作为使创建一个面具
assign 		SET_MASK =  1'b1 << BIT_NUMBER;			// create mask for set bit instruction
                                                    // 创建掩码位指令集
assign 		CLR_MASK = ~SET_MASK;					// create mask for clear bit instruction
                                                    // 创造清晰位指令面具
assign 		BIT_ADDRESS = PROG_DIN[7] ? {1'b1, PROG_DIN[6:3], 3'b000} : {4'b0010, PROG_DIN[6:3]};
assign		BIT_IS_SET = SELECTED_BIT;
assign 		DISPLACEMENT = {(PROG_DIN[7] ? 8'hff : 8'h00), PROG_DIN};
assign 		{PC_CY, NEXT_PC} = PC_ADDER_A + PC_ADDER_B + PC_CI;
assign		LAST_FETCH_PLUS_ONE = LAST_FETCH + 1'b1;


EXTRNL_BUS EXTRNL_BUS(
					  .Clock_In(Clock_In), 
					  .RESET(RESET), 
					  .DCE_n(DCE_n), 
					  .PCE_n(PCE_n), 
					  .OE_n(OE_n), 
					  .WR_n(WR_n),
					  .CPUClock(CPUClock),
					  .INST_REG(INST_REG),
					  .MONITOR_INST(MONITOR_INST));
		 

INST_EXT INST_EXT( 
				.INT_REQ(INT_REQ), 
				.MONITOR_REQUEST(MONITOR_REQUEST), 
				.BREAK_FLAG(BREAK_FLAG), 
				.INSTR_EXTN(INSTR_EXTN),
				.INT_LEVEL(INT_LEVEL),
				.REAL_TIME_ON(REAL_TIME_ON));

debug_RT debug( 
			   .CPUClock(CPUClock), 
			   .OP_FETCH(OP_FETCH),
			   .RESET_IN(RESET_IN),
			   .RESET_OUT(RESET_OUT),
			   .MONITOR_REQUEST(MONITOR_REQUEST),
			   .HW_BREAK_REQUEST(HW_BREAK_REQUEST),
			   .HW_BREAK_FLAG(HW_BREAK_FLAG),
			   .SW_BREAK_FLAG(SW_BREAK_FLAG),
			   .MONITOR_INST(MONITOR_INST),
			   .MONITOR_ADDR(MONITOR_ADDR),
			   .MONITOR_WR_DATA(MONITOR_WR_DATA),
			   .MONITOR_RD_DATA(MONITOR_RD_DATA),
			   .MONITOR_CYC_CMPL(MONITOR_CYC_CMPL),
               .MONITOR_DIRECT(MONITOR_DIRECT),
			   .LAST_FETCH(LAST_FETCH),
			   .PC(PC),
			   .INT_REQ(INT_REQ),
			
			   .INST_REG(INST_REG), 
			   .ACC(ACC), 
			   .B_REG(B_REG), 
			   .DPH(DPH), 
			   .DPL(DPL), 
			   .PSW(PSW), 
			   .SP(SP), 
			   .RD_ADDRS(READ_ADDRS), 
			   .WR_ADDRS(WRITE_ADDRS), 
			   .RD_DATA(RD_DATA), 
			   .WR_DATA(WR_DATA), 
			   .DIRECT_RD(DIRECT_RD), 
			   .DIRECT_WR(DIRECT_WR), 
			   .WREN(WR_EN | MUL_INST | DIV_INST), 
			   .REAL_TIME_ON(REAL_TIME_ON),	
			   .BREAK_FLAG(BREAK_FLAG),
			   .RETRY(RETRY),
			
               .TCK(TCK), 
               .TDI(TDI),
               .TDO(TDO), 
               .TMS(TMS),
               .TRSTB(TRSTB));

ADDER_8051 ADDER_8051 (.TERM_A(TERM_A), 
					   .TERM_B(TERM_B), 
					   .CI(CARRY_IN), 
					   .ADDER_OUT(ADDER_OUT), 
					   .CO(ADDER_CARRY), 
					   .HCO(ADDER_HC), 
					   .OVO(ADDER_OV));

CPU_SFR_S SFRs(
					  .DIR_RD_ADDRS(RD_ADDRS),
					  .DIR_WR_ADDRS(WR_ADDRS),
					  .WR_DATA(WR_DATA),				   	// this is the write input to the RAM module
					                                        //这是写输入到RAM模块
					  .RD_DATA(RD_SFR_DATA),   				// this is the read output from CPU SFRs
					                                        // 这是从CPU读取输出寄存器
					  .DIRECT_WR(DIRECT_WR ),			   // 1 = Direct address mode, 0 = Indirect
					                                       // 1 =直接地址模式，0 =间接
					  .CPUClock(CPUClock),
					  .WR_EN(WR_EN & ~(~MONITOR_DIRECT & MONITOR_CYCL)),
					  .XCHG_INST(XCHG_INST),
					  .MUL_INST(MUL_INST),
					  .DIV_INST(DIV_INST),
					  .INC_SP(INC_SP),
					  .DEC_SP(DEC_SP),
					  .ACC(ACC),
					  .PSW(PSW),
					  .SP(SP),
					  .SP_PLUS_ONE(SP_PLUS_ONE),
					  .DPH(DPH),
					  .DPL(DPL),
					  .B_REG(B_REG),
					  .RESET(RESET),
					  .CY_ENABLE(CY_ENABLE),
					  .CY_IN(CARRY_OUT),
					  .OV_ENABLE(OV_ENABLE),
					  .OV_IN(ADDER_OV),
					  .HC_ENABLE(HC_ENABLE),
					  .HC_IN(ADDER_HC),
					  .STATE(STATE),
					  .B_IS_ZERO(B_IS_ZERO),
					  .XCHG_ACC_IN(XCHG_ACC_IN),
					  .RD_USR_SFR(RD_USR_SFR));



RAM_BLOCK RAM0 (	.DIR_RD_ADDRS(RD_ADDRS),
					.DIR_WR_ADDRS(WR_ADDRS),
					.WR_DATA(WR_DATA),				   // this is the write input to the RAM module
					                                   // 这是写输入到RAM模块
					.RD_DATA(RD_RAM_DATA),			   // this is the read output from the RAM module
					                                   // 这是从RAM读取输出模块
					.DIRECT_WR(DIRECT_WR),			   // 1 = Direct address mode, 0 = Indirect
					                                   // 1 =直接地址模式，0 =间接
					.DIRECT_RD(DIRECT_RD),			   // 1 = Direct address mode, 0 = Indirect
					                                   // 1 =直接地址模式，0 =间接
					.PSW43({PSW[4:3]}),
					.iR_SEL(INST_REG[0]),			   // INST_REG[0]
					.CPUClock(CPUClock),
					.RD_CLK(RD_CLK),
					.WR_EN(WR_EN),
					.READ_ADDRS(READ_ADDRS),
					.WRITE_ADDRS(WRITE_ADDRS),
                    .MONITOR_CYCL(MONITOR_CYCL),
                    .MONITOR_DIRECT(MONITOR_DIRECT));


always @(RD_DATA or BIT_NUMBER) begin				   // this is the bit selector (mux) block for bit test instructions
                                                       // 这是位选择器（mux）为位测试指令块
	casex (BIT_NUMBER)
		3'b000 : SELECTED_BIT = RD_DATA[0];
		3'b001 : SELECTED_BIT = RD_DATA[1];
		3'b010 : SELECTED_BIT = RD_DATA[2];
		3'b011 : SELECTED_BIT = RD_DATA[3];
		3'b100 : SELECTED_BIT = RD_DATA[4];
		3'b101 : SELECTED_BIT = RD_DATA[5];
		3'b110 : SELECTED_BIT = RD_DATA[6];
		3'b111 : SELECTED_BIT = RD_DATA[7];
	   default : SELECTED_BIT = 1'bx;
	endcase
end	 

always @(INST_REG or RD_DATA or ACC or STATE) begin

	casex (INST_REG)
		XCH_A_Rn,
		XCH_A_aRi	: begin
						XCHG_INST   = 1'b1;
						XCHG_ACC_IN = RD_DATA;
					  end

		XCH_A_Dir	: begin
						XCHG_INST   = STATE[1];
						XCHG_ACC_IN = RD_DATA;
					  end

						 
		XCHD		: begin
						XCHG_INST = 1'b1;		
						XCHG_ACC_IN = {ACC[7:4], RD_DATA[3:0]};
					  end
		default 	: begin
						XCHG_INST = 1'b0;
						XCHG_ACC_IN = 8'hxx;
					  end
	endcase
end

always @(INST_REG or STATE) begin
	casex (INST_REG)

		EXCEPTION,
		ACALL		: begin
						INC_SP = |STATE[2:1];
						DEC_SP = 1'b0;
					  end

		LCALL		: begin
						INC_SP = |STATE[3:2];
						DEC_SP = 1'b0;
					  end
		RET,
		RETI		: begin
						INC_SP = 1'b0;
						DEC_SP = |STATE[2:1];
					  end
		POP_Dir		: begin
						INC_SP = 1'b0;
						DEC_SP = STATE[1];
					  end
		PUSH_Dir	: begin
						INC_SP = STATE[1];
						DEC_SP = 1'b0;
					  end
		default 	: begin
						INC_SP = 1'b0;
						DEC_SP = 1'b0;
					  end
	endcase
end


always @(INST_REG) begin
	casex (INST_REG)
		MUL 	: MUL_INST = 1'b1;
		default : MUL_INST = 1'b0;
	endcase
end


always @(INST_REG) begin
	casex (INST_REG)
		DIV 	: DIV_INST = 1'b1;
		default : DIV_INST = 1'b0;
	endcase
end


always @(INST_REG or MONITOR_INST) begin
	casex (INST_REG)
	      MOVX_A_aRi,
	      MOVX_A_DPTR,	
	      MOVX_aRi_A,	
	      MOVX_DPTR_A  : begin
							XDATA_CYCL = 1'b1;
						 end	
		  MON_INST,
		  BREAK_MODE   : begin
							 casex (MONITOR_INST)
	 						 	MXTRN_RD,
	 						 	MXTRN_WR  :	begin
												XDATA_CYCL = 1'b1;
											end
						 		default   : XDATA_CYCL = 1'b0;					

							 endcase
					    end		
		default		   : XDATA_CYCL = 1'b0;					
	endcase
end

    


//  this selects the addends for the next PC 这个选择在未来PC的加数
always @(INST_REG 				or 
	     STATE    				or 
	     DPH 					or 
	     DPL 					or 
	     ACC 					or 
	     PC 					or 
	     DISPLACEMENT 			or 
	     COMPARE_NOT_EQUAL 		or 
	     DEC_RESULT_NOT_ZERO 	or 
	     BIT_IS_SET 			or 
	     ACCUMULATOR_IS_ZERO 	or 
	     CY                     or
         Plus_one)	            begin

	casex (INST_REG)

		CJNE_A_Dir,		
		CJNE_A_imD,																   		
		CJNE_Rn_imD,  															   		
		CJNE_aRi_imD	: begin	// these are three byte instructions 这是3字节指令
							  PC_CI = STATE[2] & COMPARE_NOT_EQUAL;
							  PC_ADDER_B =  PC;
                              PC_ADDER_A = (STATE[2] & COMPARE_NOT_EQUAL) ? DISPLACEMENT : Plus_one;
						  end

		DJNZ_Rn			: begin
							  PC_CI = STATE[1] & DEC_RESULT_NOT_ZERO;
							  PC_ADDER_B =  PC;
                              PC_ADDER_A = (STATE[1] & DEC_RESULT_NOT_ZERO) ? DISPLACEMENT : Plus_one;
						  end

		DJNZ_Dir     	: begin
							  PC_CI = STATE[2] & DEC_RESULT_NOT_ZERO;
							  PC_ADDER_B =  PC;
                              PC_ADDER_A = (STATE[2] & DEC_RESULT_NOT_ZERO) ? DISPLACEMENT : Plus_one;
						  end														 			 
		JB,	
		JBC				: begin																	
							  PC_CI = STATE[2] & BIT_IS_SET;
							  PC_ADDER_B =  PC;
                              PC_ADDER_A = (STATE[2] & BIT_IS_SET) ? DISPLACEMENT : Plus_one;
						  end

		JMP          	: begin																	
                              PC_CI = 1'b0;
							  PC_ADDER_B = STATE[1] ? {8'h00, ACC} : PC;										
							  PC_ADDER_A = STATE[1] ? {DPH, DPL} : Plus_one;
						  end

		JNB				: begin																
							  PC_CI = STATE[2] & ~BIT_IS_SET;
							  PC_ADDER_B =  PC;
                              PC_ADDER_A = (STATE[2] & ~BIT_IS_SET) ? DISPLACEMENT : Plus_one;
						  end

		JC				: begin
							  PC_CI = STATE[1] & CY;
							  PC_ADDER_B = PC;
                              PC_ADDER_A = (STATE[1] & CY) ? DISPLACEMENT : Plus_one;
						  end
		JNC				: begin
							  PC_CI = STATE[1] & ~CY;
							  PC_ADDER_B = PC;
                              PC_ADDER_A = (STATE[1] & ~CY) ? DISPLACEMENT : Plus_one;
						  end

		JZ				: begin
							  PC_CI = STATE[1] & ACCUMULATOR_IS_ZERO;
							  PC_ADDER_B = PC;
                              PC_ADDER_A = (STATE[1] & ACCUMULATOR_IS_ZERO) ? DISPLACEMENT : Plus_one;
						  end

		JNZ				: begin
							  PC_CI =  STATE[1] & ~ACCUMULATOR_IS_ZERO;
							  PC_ADDER_B = PC;
                              PC_ADDER_A = (STATE[1] & ~ACCUMULATOR_IS_ZERO) ? DISPLACEMENT : Plus_one;
						  end

		SJMP			: begin
                              PC_CI = STATE[1] ;
							  PC_ADDER_B = PC ;
                              PC_ADDER_A = STATE[1] ? DISPLACEMENT : Plus_one;
						  end

       MOVC_A_aA_DPTR :	  begin
                             PC_CI = 1'b0;
 							 if (STATE[1]) begin
 							 	PC_ADDER_B = {DPH, DPL};
 							 	PC_ADDER_A = {8'h00, ACC};
							 end
 							 else begin
 							 	PC_ADDER_B = PC;
 							 	PC_ADDER_A = Plus_one;
							 end
						  end
         
       MOVC_A_aA_PC  : 	  begin
                            PC_CI = 1'b0;
							PC_ADDER_B = PC;
							if (STATE[1]) PC_ADDER_A = {8'h00, ACC};
							else PC_ADDER_A = Plus_one;
						  end

		default			: begin
                              PC_CI = 1'b0;
							  PC_ADDER_B = PC;									   		 
							  PC_ADDER_A = Plus_one;
						  end
	endcase
end




always @( RD_DATA) begin
	casex (RD_DATA[3:0])
		4'hA,
		4'hB,
		4'hC,
		4'hD,
		4'hE,
		4'hF	: LOW_GT_EQ_09h = 1'b1;
		default : LOW_GT_EQ_09h = 1'b0;

	endcase
end


always @( ADDER_OUT) begin
	casex (ADDER_OUT[7:4])
		4'hA,
		4'hB,
		4'hC,
		4'hD,
		4'hE,
		4'hF	: HI_GT_EQ_09h = 1'b1;
		default : HI_GT_EQ_09h = 1'b0;

	endcase
end

//  ALU BLOCK

always @( INST_REG 	or 
          ACC 			or
          ALU			or 
          CY 			or 
          OV 			or 
          RD_DATA 		or 
		  DATA_A		or
		  DATA_B		or
		  ADDER_CARRY	or
		  ADDER_OV		or
		  ADDER_HC		or
		  ADDER_OUT		or
		  CLR_MASK		or
		  SET_MASK		or
          SELECTED_BIT	or
          B_IS_ZERO		or
          DA_HI_CY		or
          CYq			or
          STATE         or
          PROG_DIN      or
          RMW)		    begin

	casex (INST_REG)

		

              ADD_A_Dir, 
              ADD_A_imD 	: begin
                                RMW        = 1'b0;
								TERM_A     = DATA_A;
								TERM_B     = DATA_B;
								CARRY_IN   = 1'b0;
								CARRY_OUT  = ADDER_CARRY;
								OVERFLOW   = ADDER_OV;
								HALF_CARRY = ADDER_HC;
								CY_ENABLE  = STATE[1];
								HC_ENABLE  = STATE[1];
								OV_ENABLE  = STATE[1];
								ZERO       = 1'bx;
								ALU		   = ADDER_OUT;
							  end	 

              ADD_A_aRi,
              ADD_A_Rn		: begin
                                RMW        = 1'b0;
								TERM_A     = DATA_A;
								TERM_B     = DATA_B;
								CARRY_IN   = 1'b0;
								CARRY_OUT  = ADDER_CARRY;
								OVERFLOW   = ADDER_OV;
								HALF_CARRY = ADDER_HC;
								CY_ENABLE  = STATE[0];
								HC_ENABLE  = STATE[0];
								OV_ENABLE  = STATE[0];
								ZERO       = 1'bx;
								ALU		   = ADDER_OUT;
							  end	 

              ADDC_A_aRi, 
		      ADDC_A_Rn  	: begin
                                RMW        = 1'b0;
								TERM_A     = DATA_A;
								TERM_B     = DATA_B;
								CARRY_IN   = CY;
								CARRY_OUT  = ADDER_CARRY;
								OVERFLOW   = ADDER_OV;
								HALF_CARRY = ADDER_HC;
								CY_ENABLE  = STATE[0];
								HC_ENABLE  = STATE[0];
								OV_ENABLE  = STATE[0];
								ZERO       = 1'bx;
								ALU		   = ADDER_OUT;
							  end	 

	          ADDC_A_Dir,
              ADDC_A_imD  	: begin
                                RMW        = 1'b0;
								TERM_A     = DATA_A;
								TERM_B     = DATA_B;
								CARRY_IN   = CY;
								CARRY_OUT  = ADDER_CARRY;
								OVERFLOW   = ADDER_OV;
								HALF_CARRY = ADDER_HC;
								CY_ENABLE  = STATE[1];
								HC_ENABLE  = STATE[1];
								OV_ENABLE  = STATE[1];
								ZERO       = 1'bx;
								ALU		   = ADDER_OUT;
							  end	 



              ANL_A_Rn,
              ANL_A_aRi,
              ANL_A_Dir,
              ANL_A_imD,
              ANL_Dir_imD,
              ANL_Dir_A  : begin
                                RMW        = 1'b1;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;				   
								CARRY_OUT  = 1'bx;		   
								OVERFLOW   = 1'bx;		   
								HALF_CARRY = 1'bx;		   
								CY_ENABLE  = 1'b0;
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;				   
								ALU		   = DATA_A & DATA_B;
							end

              MOV_Dir_Dir,
      		  MOV_A_Rn,	         	 
	  		  MOV_A_aRi,
	   		  MOV_A_Dir  : begin
                                RMW        = 1'b0;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;		   
								CARRY_OUT  = 1'bx;		   
								OVERFLOW   = 1'bx;		   
								HALF_CARRY = 1'bx;		   
								CY_ENABLE  = 1'b0;
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;		   
								ALU		   = RD_DATA;
							end


	   		  MOV_A_imD   : begin
                                RMW        = 1'b0;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;		  
								CARRY_OUT  = 1'bx;		  
								OVERFLOW   = 1'bx;		  
								HALF_CARRY = 1'bx;		  
								CY_ENABLE  = 1'b0;
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;		  
								ALU		   = PROG_DIN;
							end

			  MOV_Dir_imD   : begin
                                RMW        = 1'b0;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;		  
								CARRY_OUT  = 1'bx;		  
								OVERFLOW   = 1'bx;		  
								HALF_CARRY = 1'bx;		  
								CY_ENABLE  = 1'b0;
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;		  
								ALU		   = PROG_DIN;
							end
   
			  MOV_Dir_A   : begin
                                RMW        = 1'b0;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;		  
								CARRY_OUT  = 1'bx;		  
								OVERFLOW   = 1'bx;		  
								HALF_CARRY = 1'bx;		  
								CY_ENABLE  = 1'b0;
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;		  
								ALU		   = ACC;
							end
   
            MOV_Bit_C    : begin
                                RMW        = 1'b1;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;		   
								CARRY_OUT  = 1'bx;		   
								OVERFLOW   = 1'bx;		   
								HALF_CARRY = 1'bx;		   
								CY_ENABLE  = 1'b0;
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;		   
								ALU		   = 8'hxx;
							end
       
             
              ORL_Dir_A, 					             
			  ORL_A_Rn,	      
              ORL_A_aRi,	      
              ORL_A_Dir, 
              ORL_A_imD,
              ORL_Dir_imD : begin
                                RMW        = 1'b1;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;		   
								CARRY_OUT  = 1'bx;		   
								OVERFLOW   = 1'bx;		   
								HALF_CARRY = 1'bx;		   
								CY_ENABLE  = 1'b0;
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;		   
								ALU		   = DATA_A | DATA_B;
							end


	  		  SUBB_A_Rn,	
	  		  SUBB_A_aRi  :	begin
                                RMW        = 1'b0;
								TERM_A     = DATA_A;
								TERM_B     = ~DATA_B;
								CARRY_IN   = ~CY;				  
								CARRY_OUT  = ~ADDER_CARRY;		  
								OVERFLOW   = ADDER_OV;			  
								HALF_CARRY = ~ADDER_HC;			  
								CY_ENABLE  = STATE[0];
								HC_ENABLE  = STATE[0];
								OV_ENABLE  = STATE[0];
								ZERO       = 1'bx;				  
								ALU		   = ADDER_OUT;
							  end	 		 

              SUBB_A_Dir,
              SUBB_A_imD :	begin
                                RMW        = 1'b0;
								TERM_A     = DATA_A;
								TERM_B     = ~DATA_B;
								CARRY_IN   = ~CY;				  
								CARRY_OUT  = ~ADDER_CARRY;		  
								OVERFLOW   = ADDER_OV;			  
								HALF_CARRY = ~ADDER_HC;			  
								CY_ENABLE  = STATE[1];
								HC_ENABLE  = STATE[1];
								OV_ENABLE  = STATE[1];
								ZERO       = 1'bx;				  
								ALU		   = ADDER_OUT;
							  end	 


              XRL_Dir_A,  					  
			  XRL_A_Rn,
			  XRL_A_aRi,
              XRL_A_Dir,
              XRL_A_imD,
              XRL_Dir_imD :  begin
                                RMW        = 1'b1;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;			
								CARRY_OUT  = 1'bx;		   	
								OVERFLOW   = 1'bx;			
								HALF_CARRY = 1'bx;			
								CY_ENABLE  = 1'b0;
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;			
								ALU		   = DATA_A ^ DATA_B;
							end


              XCH_A_Rn,
              XCH_A_aRi,	 
              XCH_A_Dir :  begin
                                RMW        = 1'b0;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;				  
								CARRY_OUT  = 1'bx;		   		  
								OVERFLOW   = 1'bx;			      
								HALF_CARRY = 1'bx;			      
								CY_ENABLE  = 1'b0;
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;				  
								ALU		   = ACC;
              				end	


              ANL_C_Bit :  begin
                                RMW        = 1'b0;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;				
								CARRY_OUT  = CY & SELECTED_BIT;	
								OVERFLOW   = 1'bx;			   
								HALF_CARRY = 1'bx;			   
								CY_ENABLE  = STATE[1];
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;				  
								ALU		   = 8'hxx;
              				end	

              ANL_C_nBit :  begin
                                RMW        = 1'b0;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;				   	
								CARRY_OUT  = CY & ~SELECTED_BIT;   	
								OVERFLOW   = 1'bx;			   		
								HALF_CARRY = 1'bx;			   		
								CY_ENABLE  = STATE[1];
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;				   	
								ALU		   = 8'hxx;
              				end	

              MOV_C_Bit :  begin
                                RMW        = 1'b0;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;				   
								CARRY_OUT  = SELECTED_BIT;		   
								OVERFLOW   = 1'bx;				   
								HALF_CARRY = 1'bx;  			   
								CY_ENABLE  = STATE[1];
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;				   
								ALU		   = 8'hxx;
              				end	

              ORL_C_Bit :  begin
                                RMW        = 1'b0;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;				   
								CARRY_OUT  = CY | SELECTED_BIT;	   
								OVERFLOW   = 1'bx;			   		
								HALF_CARRY = 1'bx;			   		
								CY_ENABLE  = STATE[1];
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;				   
								ALU		   = 8'hxx;
              				end	

              ORL_C_nBit :  begin
                                RMW        = 1'b0;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;				   
								CARRY_OUT  = CY | ~SELECTED_BIT;   
								OVERFLOW   = 1'bx;				   
								HALF_CARRY = 1'bx;				   
								CY_ENABLE  = STATE[1];
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;				   
								ALU		   = 8'hxx;
              				end	

              CLR_C 	 :  begin
                                RMW        = 1'b0;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;				   
								CARRY_OUT  = 1'b0;   			   
								OVERFLOW   = 1'bx;				   
								HALF_CARRY = 1'bx;				   
								CY_ENABLE  = STATE[0];
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;				   
								ALU		   = 8'hxx;
							end

              CPL_C	 	:  begin
                                RMW        = 1'b0;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;				   
								CARRY_OUT  = ~CY;				   
								OVERFLOW   = 1'bx;				   
								HALF_CARRY = 1'bx;				   
								CY_ENABLE  = STATE[0];
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;				   
								ALU		   = 8'hxx;
						   end

              SETB_C	:  begin
                                RMW        = 1'b0;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;				   
								CARRY_OUT  = 1'b1;   			   
								OVERFLOW   = 1'bx;				   
								HALF_CARRY = 1'bx;				   
								CY_ENABLE  = STATE[0];
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;				   
								ALU		   = 8'hxx;
						   end
	     

              CJNE_A_Dir,	                              
              CJNE_A_imD,	 
              CJNE_Rn_imD,	 
              CJNE_aRi_imD : begin
                                RMW        = 1'b0;
								TERM_A     = DATA_A;
								TERM_B     = ~DATA_B;
								CARRY_IN   = 1'b1;				   
								CARRY_OUT  = ~ADDER_CARRY;	   	   
								OVERFLOW   = 1'bx;			   	   
								HALF_CARRY = 1'bx;			   	   
								CY_ENABLE  = STATE[2];
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = ~|ALU;			   	
								ALU		   = 8'hxx;
              				end	
                              

              JBC,	     						
              CLR_Bit	:	begin
                                RMW        = 1'b1;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;				    
								CARRY_OUT  = 1'bx;   		   		
								OVERFLOW   = 1'bx;			   		
								HALF_CARRY = 1'bx;			   		
								CY_ENABLE  = 1'b0;
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;			   		
								ALU		   = RD_DATA & CLR_MASK;
							end

              CPL_Bit 	:	begin
                                RMW        = 1'b1;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;			   
								CARRY_OUT  = 1'bx;   		   
								OVERFLOW   = 1'bx;			   
								HALF_CARRY = 1'bx;			   
								CY_ENABLE  = 1'b0;
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;			   
								ALU		   = RD_DATA ^ SET_MASK;
							end

              SETB_Bit : 	begin
                                RMW        = 1'b1;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;			   
								CARRY_OUT  = 1'bx;   		   
								OVERFLOW   = 1'bx;			   
								HALF_CARRY = 1'bx;			   
								CY_ENABLE  = 1'b0;
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;			   
								ALU		   = RD_DATA | SET_MASK;
	     					end

                             

							 
			  DA  		: 	begin
                                RMW        = 1'b0;
								TERM_A     = DATA_A;
								TERM_B     = DATA_B;
								CARRY_IN   = 1'b0;			   
								CARRY_OUT  = DA_HI_CY;   	   
								OVERFLOW   = 1'bx;			   
								HALF_CARRY = 1'bx;			   
								CY_ENABLE  = STATE[1];
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;			   
								ALU		   = 8'hxx;
	     					end

						
  	 		  RLC_A 	: 	begin
                                RMW        = 1'b0;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;			   
								CARRY_OUT  = ACC[7];   		   
								OVERFLOW   = 1'bx;			   
								HALF_CARRY = 1'bx;			   
								CY_ENABLE  = STATE[0];
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;			   
								ALU		   = 8'hxx;
	     					end	 

  	 		  RRC_A : 	begin
                                RMW        = 1'b0;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;			   
								CARRY_OUT  = ACC[0];   		   
								OVERFLOW   = 1'bx;			   
								HALF_CARRY = 1'bx;			   
								CY_ENABLE  = STATE[0];
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;			   
								ALU		   = 8'hxx;
	     					end
						 


              DEC_A,
              DEC_Rn,
              DJNZ_Rn,	 
              DJNZ_Dir,	 
              DEC_aRi,	 					             
              DEC_Dir	: begin
                                RMW        = 1'b1;
								TERM_A     = 8'hFF;
								TERM_B     = DATA_B;
								CARRY_IN   = 1'b0;			   
								CARRY_OUT  = 1'bx;   		   
								OVERFLOW   = 1'bx;			   
								HALF_CARRY = 1'bx;			   
								CY_ENABLE  = 1'b0;
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;			   
								ALU		   = ADDER_OUT;
						  end

              INC_DPTR :  begin
                                RMW        = 1'b0;
								TERM_A     = 8'h00;
								TERM_B     = DATA_B;
								CARRY_IN   = STATE[1] ? 1'b1 : CYq;			   
								CARRY_OUT  = 1'bx;   		   
								OVERFLOW   = 1'bx;			   
								HALF_CARRY = 1'bx;			   
								CY_ENABLE  = 1'b0;
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;			   
								ALU		   = ADDER_OUT;
						  end

			  INC_A,
              INC_Rn,
              INC_aRi,	 					  
              INC_Dir :  begin
                                RMW        = 1'b1;
								TERM_A     = 8'h00;
								TERM_B     = DATA_B;
								CARRY_IN   = 1'b1;			   
								CARRY_OUT  = 1'bx;   		   
								OVERFLOW   = 1'bx;			   
								HALF_CARRY = 1'bx;			   
								CY_ENABLE  = 1'b0;
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = 1'b0;
								ZERO       = 1'bx;			   
								ALU		   = ADDER_OUT;
						  end
 
              
              DIV  :  begin
                                RMW        = 1'b0;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;			   
								CARRY_OUT  = 1'b0;   		   
								OVERFLOW   = B_IS_ZERO;		   
								HALF_CARRY = 1'bx;			   
								CY_ENABLE  = STATE[4];
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = STATE[4];
								ZERO       = 1'bx;			   
								ALU		   = 8'hxx;
						  end

              MUL  :  begin
                                RMW        = 1'b0;
								TERM_A     = 8'hxx;
								TERM_B     = 8'hxx;
								CARRY_IN   = 1'bx;			   
								CARRY_OUT  = 1'b0;   		   
								OVERFLOW   = ~B_IS_ZERO;	   
								HALF_CARRY = 1'bx;			   
								CY_ENABLE  = STATE[4];
								HC_ENABLE  = 1'b0;
								OV_ENABLE  = STATE[4];
								ZERO       = 1'bx;			   
								ALU		   = 8'hxx;
						  end

 
                         
		default :	begin
                        RMW        = 1'b0;
						TERM_A     = 8'hxx;
						TERM_B     = 8'hxx;
						CARRY_IN   = 1'bx;				   
						CARRY_OUT  = 1'bx;   		   	   
						OVERFLOW   = 1'bx;			   	   
						HALF_CARRY = 1'bx;			   	   
						CY_ENABLE  = 1'b0;
						HC_ENABLE  = 1'b0;
						OV_ENABLE  = 1'b0;
						ZERO       = 1'bx;			   	   
						ALU		   = 8'hxx;
					end


    endcase
end	
	


// This always @ block selects which address/data bus gets connected to the Data RAM block
//这始终@块选择的地址/数据总线连接到数据获取内存块
always @(INST_REG 			or 
		 OPERAND_1 			or 
		 SP 				or 
		 SP_PLUS_ONE		or
		 STATE 				or 
		 SET_C_MASK 		or 
		 BIT_ADDRESS		or
		 NEXT_PC    		or 
		 RD_DATA 			or 
		 ACC 				or 
		 PSW 				or 
		 PC					or
		 ALU				or
		 LOW_GT_EQ_09h		or
		 CY					or
		 HC					or
		 DA_HI		    	or
		 ADDER_OUT			or
		 MONITOR_INST		or
		 MONITOR_WR_DATA	or				
		 MONITOR_ADDR		or
		 PROG_DIN			or
		 LAST_FETCH         or
         XDBUS_IN           or
         BIT_IS_SET         or
         MONITOR_DIRECT)		    begin

    casex (INST_REG[10:0]) 
    
    EXCEPTION		 : begin
						    BIT_NUMBER = 3'bxxx;
							WR_DATA    =  STATE[1] ? LAST_FETCH[7:0] : {8'h00, LAST_FETCH[15:8]};
	                        WR_ADDRS   =  SP_PLUS_ONE;
							DIRECT_WR  =  1'b1;
							DIRECT_RD  = 1'b0;
							RD_ADDRS   = 8'hxx;
							WR_EN      = |STATE[2:1];
							RD_EN	   = 1'b0;
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
					   end
	 CJNE_Rn_imD  : begin                     // 3 bytes
						  BIT_NUMBER = 3'bxxx;
						  WR_ADDRS   = 8'hxx;
						  WR_DATA    = 8'hxx;
						  DIRECT_WR  = 1'b0;
						  DIRECT_RD  = STATE[2];
						  RD_ADDRS   = {3'b000, PSW[4:3], INST_REG[2:0]};
						  WR_EN      = 1'b0;
						  RD_EN		 = STATE[2];
						  DATA_A     = RD_DATA;
						  DATA_B	 = OPERAND_1;	// immediate data即时数据
					    end
    	                                                     
		 ADD_A_Rn,	 
         ADDC_A_Rn,	 
         ANL_A_Rn,	 
         MOV_A_Rn,	      
         ORL_A_Rn,	      
         SUBB_A_Rn,	      
         XRL_A_Rn	 : begin                     // 1 byte
						BIT_NUMBER = 3'bxxx;
						WR_ADDRS   = ACC_ADDRS;
						WR_DATA    = ALU;
						DIRECT_WR  = 1'b1;
						DIRECT_RD  = 1'b1;
                        RD_ADDRS   = {3'b000, PSW[4:3], INST_REG[2:0]};
						WR_EN      = STATE[0];
						RD_EN	   = 1'b1;
						DATA_A	   = ACC;
						DATA_B     = RD_DATA;
                      end



		 CJNE_A_Dir: begin                      // 3 bytes
						BIT_NUMBER = 3'bxxx;
						WR_ADDRS   = 8'hxx;
						WR_DATA    = 8'hxx;
						DIRECT_WR  = 1'b0;
						DIRECT_RD  = STATE[2];
                        RD_ADDRS   = OPERAND_1;
						WR_EN      = 1'b0;
						RD_EN	   = STATE[2];
						DATA_A	   = ACC;
						DATA_B     = RD_DATA;
                      end
	     ADD_A_Dir,	 
         ADDC_A_Dir, 
         ANL_A_Dir,	 
         MOV_A_Dir,	 
         ORL_A_Dir,	 
         SUBB_A_Dir, 
         XRL_A_Dir	 : begin                    // 2 bytes
						BIT_NUMBER = 3'bxxx;
						WR_ADDRS   = ACC_ADDRS;
						WR_DATA    = ALU;
						DIRECT_WR  = 1'b1;
						DIRECT_RD  = 1'b1;
                        RD_ADDRS   = PROG_DIN;
						WR_EN      = STATE[1];
						RD_EN	   = 1'b1;
						DATA_A	   = ACC;
						DATA_B     = RD_DATA;
                      end


		 CJNE_aRi_imD : begin                   // 3 bytes
						BIT_NUMBER = 3'bxxx;
   						WR_ADDRS   = 8'hxx;
						WR_DATA    = 8'hxx;
						DIRECT_WR  = 1'b0;
						DIRECT_RD  = 1'b0;
                        RD_ADDRS   = 8'hxx;
						WR_EN      = 1'b0;
						RD_EN	   = 1'b1;
						DATA_A     = RD_DATA;
						DATA_B	   = OPERAND_1;
                     end

         ADD_A_aRi,	 
         ADDC_A_aRi, 
         ANL_A_aRi,	 
         MOV_A_aRi,	 
         ORL_A_aRi,	 
         SUBB_A_aRi, 
         XRL_A_aRi : begin                          // 1 byte
						BIT_NUMBER = 3'bxxx;
   						WR_ADDRS   = ACC_ADDRS;
						WR_DATA    = ALU;
						DIRECT_WR  = 1'b1;
						DIRECT_RD  = 1'b0;
                        RD_ADDRS   = 8'hxx;
						WR_EN      = STATE[0];
						DATA_A	   = ACC;
						DATA_B     = RD_DATA;
                      end


	     CJNE_A_imD : begin                         // 3 bytes
						BIT_NUMBER = 3'bxxx;
   						WR_ADDRS   = 8'hxx;
						WR_DATA    = 8'hxx;
						DIRECT_WR  = 1'b0;
						DIRECT_RD  = 1'b0;
                        RD_ADDRS   = 8'hxx;
						WR_EN      = 1'b0;
						DATA_A	   = ACC;
						DATA_B     = OPERAND_1;
                      end


         ADD_A_imD,	  
         ADDC_A_imD,  
         ANL_A_imD,	  
         MOV_A_imD,	  
         ORL_A_imD,	  
         SUBB_A_imD,  
         XRL_A_imD	  : begin                       // 2 byte
						BIT_NUMBER = 3'bxxx;
   						WR_ADDRS   = ACC_ADDRS;
						WR_DATA    = ALU;
						DIRECT_WR  = 1'b1;
						DIRECT_RD  = 1'b0;
                        RD_ADDRS   = 8'hxx;
						WR_EN      = STATE[1];
						DATA_A	   = ACC;
						DATA_B     = PROG_DIN;
                      end


         ANL_Dir_A,	 
         MOV_Dir_A,	 
         ORL_Dir_A,	 
         XRL_Dir_A : begin                          // 2 byte
						BIT_NUMBER = 3'bxxx;
   						WR_ADDRS   = PROG_DIN;
						WR_DATA    = ALU;
						DIRECT_WR  = 1'b1;
						DIRECT_RD  = 1'b1;
                        RD_ADDRS   = PROG_DIN;
						WR_EN      = STATE[1];
						DATA_A	   = ACC;
						DATA_B     = RD_DATA;
                      end

         	 
         ANL_Dir_imD, 
         MOV_Dir_imD, 
         ORL_Dir_imD, 
         XRL_Dir_imD : begin                        // 3 byte
						BIT_NUMBER = 3'bxxx;
						WR_ADDRS   = OPERAND_1;
						WR_DATA    = ALU;
						DIRECT_WR  = 1'b1;
						DIRECT_RD  = 1'b1;
                        RD_ADDRS   = OPERAND_1;
						WR_EN      = STATE[2];
						DATA_A	   = PROG_DIN;
						DATA_B	   = RD_DATA;
                      end


         DEC_Rn, 
         INC_Rn 	 : begin                        // 1 byte
						  	BIT_NUMBER = 3'bxxx;
							WR_ADDRS   = {3'b000, PSW[4:3], INST_REG[2:0]};
							WR_DATA    = ALU;
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
	                        RD_ADDRS   =  {3'b000, PSW[4:3], INST_REG[2:0]};
							WR_EN      = STATE[0];
							DATA_A	   = 8'hxx;
							DATA_B	   = RD_DATA;
                      end

         DJNZ_Rn	 : begin                        // 2 byte
						  	BIT_NUMBER = 3'bxxx;
							WR_ADDRS   = {3'b000, PSW[4:3], INST_REG[2:0]};
							WR_DATA    = ALU;
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
	                        RD_ADDRS   =  {3'b000, PSW[4:3], INST_REG[2:0]};
							WR_EN      = STATE[1];
							DATA_A	   = 8'hxx;
							DATA_B	   = RD_DATA;
                       end


         DEC_Dir,	 
         INC_Dir    :  begin
						 	BIT_NUMBER = 3'bxxx;
							WR_ADDRS   = PROG_DIN;
							WR_DATA    = ALU;
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
	                        RD_ADDRS   = PROG_DIN;
							WR_EN      = STATE[1];
							DATA_A	   = 8'hxx;
							DATA_B	   = RD_DATA;
                      end

         DJNZ_Dir	 : begin
						 	BIT_NUMBER = 3'bxxx;
							WR_ADDRS   = OPERAND_1;
							WR_DATA    = ALU;
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
	                        RD_ADDRS   = OPERAND_1;
							WR_EN      = STATE[2];
							DATA_A	   = 8'hxx;
							DATA_B	   = RD_DATA;
                      end

         DEC_aRi,
         INC_aRi	 : begin
						    BIT_NUMBER = 3'bxxx;
	                        WR_ADDRS   = 8'hxx;
							WR_DATA    = ALU;
							DIRECT_WR  = 1'b0;
							DIRECT_RD  = 1'b0;
							RD_ADDRS   = 8'hxx;
							WR_EN      = STATE[0];
							DATA_A	   = 8'hxx;
							DATA_B	   = RD_DATA;
                       end

                             

              CLR_C,
              CPL_C,
              SETB_C  : begin
						    BIT_NUMBER = 3'bxxx;
	                        WR_ADDRS   = 8'hxx;
							WR_DATA    = 8'hxx;
							DIRECT_WR  = 1'b0;
							DIRECT_RD  = 1'b0;
							RD_ADDRS   = 8'hxx;
							WR_EN      = 1'b0;
							DATA_A	   = 8'hxx;
							DATA_B	   = 8'hxx;
                        end
	     
							 
              CPL_A	 : begin
						    BIT_NUMBER = 3'bxxx;
	                        WR_ADDRS   = ACC_ADDRS;
							WR_DATA    = ~RD_DATA;
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = ACC_ADDRS;
							WR_EN      = STATE[0];
							DATA_A	   = 8'hxx;
							DATA_B	   = 8'hxx;
                        end
		
			  CLR_A	 : begin
						    BIT_NUMBER = 3'bxxx;
	                        WR_ADDRS   = ACC_ADDRS;
							WR_DATA    = 8'h00;
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = 8'hxx;
							WR_EN      = STATE[0];
							DATA_A	   = 8'hxx;
							DATA_B	   = 8'hxx;
                        end

			  DA 	: begin
						    BIT_NUMBER = 3'bxxx;
	                        WR_ADDRS   = ACC_ADDRS;
							WR_DATA    = {DA_HI, ADDER_OUT[3:0]};
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = ACC_ADDRS;
							WR_EN      = STATE[0];
							DATA_A	   = (LOW_GT_EQ_09h | HC) ? 8'h06 : 8'h00;
							DATA_B	   =  RD_DATA;
                       end	 


              INC_A,
              DEC_A	 :  begin
						    BIT_NUMBER = 3'bxxx;
	                        WR_ADDRS   = ACC_ADDRS;
							WR_DATA    = ALU;
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = ACC_ADDRS;
							WR_EN      = STATE[0];
							DATA_A	   = 8'hxx;
							DATA_B	   = RD_DATA;
                        end

              INC_DPTR :  begin
						    BIT_NUMBER = 3'bxxx;
	                        WR_ADDRS   = STATE[1] ? DPL_ADDRS : DPH_ADDRS;
							WR_DATA    = ALU;
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = STATE[1] ? DPL_ADDRS : DPH_ADDRS;
							WR_EN      = |STATE[2:1];
							DATA_A	   = 8'hxx;
							DATA_B	   = RD_DATA;
                        end


              RLA	 :  begin
						    BIT_NUMBER = 3'bxxx;
	                        WR_ADDRS   = ACC_ADDRS;
							WR_DATA    = {ACC[6:0], ACC[7]};
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = ACC_ADDRS;
							WR_EN      = STATE[0];
							DATA_A	   = 8'hxx;
							DATA_B	   = 8'hxx;
                       end

  	 		  RLC_A	 :  begin
						    BIT_NUMBER = 3'bxxx;
	                        WR_ADDRS   = ACC_ADDRS;
							WR_DATA    = {ACC[6:0], CY};
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = ACC_ADDRS;
							WR_EN      = STATE[0];
							DATA_A	   = 8'hxx;
							DATA_B	   = 8'hxx;
                        end	 
  	 		  RR_A	 :  begin
						    BIT_NUMBER = 3'bxxx;
	                        WR_ADDRS   = ACC_ADDRS;
							WR_DATA    = {ACC[0], ACC[7:1]};
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = ACC_ADDRS;
							WR_EN      = STATE[0];
							DATA_A	   = 8'hxx;
							DATA_B	   = 8'hxx;
                        end	 
  	 		  RRC_A  :  begin
						    BIT_NUMBER = 3'bxxx;
	                        WR_ADDRS   = ACC_ADDRS;
							WR_DATA    = {CY, ACC[7:1]};
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = ACC_ADDRS;
							WR_EN      = STATE[0];
							DATA_A	   = 8'hxx;
							DATA_B	   = 8'hxx;
                        end	 

  	 		  SWAP_A : begin
						    BIT_NUMBER = 3'bxxx;
	                        WR_ADDRS   = ACC_ADDRS;
							WR_DATA    = {ACC[3:0], ACC[7:4]};
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = ACC_ADDRS;
							WR_EN      = STATE[0];
							DATA_A	   = 8'hxx;
							DATA_B	   = 8'hxx;
                       end	 
    

         MOV_Rn_A	 : begin
						    BIT_NUMBER = 3'bxxx;
							WR_ADDRS   = {3'b000, PSW[4:3], INST_REG[2:0]};
							WR_DATA    = ACC;
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b0;
	                        RD_ADDRS   = ACC_ADDRS;
							WR_EN      = STATE[0];
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                      end

         MOV_Rn_Dir	 : begin
						    BIT_NUMBER = 3'bxxx;
							WR_ADDRS   = {3'b000, PSW[4:3], INST_REG[2:0]};
							WR_DATA    = RD_DATA;
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
	                        RD_ADDRS   = PROG_DIN;
							WR_EN      = STATE[1];
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                      end

         MOV_Rn_imD	 : begin
						    BIT_NUMBER = 3'bxxx;
							WR_ADDRS   = {3'b000, PSW[4:3], INST_REG[2:0]};
							WR_DATA    = PROG_DIN;
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b0;
	                        RD_ADDRS   = 8'hxx;
							WR_EN      = STATE[1];
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                      end

         MOV_Dir_Rn	 : begin
						    BIT_NUMBER = 3'bxxx;
							WR_DATA    = RD_DATA;
	                        WR_ADDRS   = PROG_DIN;
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = {3'b000, PSW[4:3], INST_REG[2:0]};
							WR_EN      = STATE[1];
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                      end

         MOV_Dir_Dir : begin
						    BIT_NUMBER = 3'bxxx;
							WR_DATA    = RD_DATA;
	                        WR_ADDRS   = PROG_DIN;
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = OPERAND_1;
							WR_EN      = STATE[2];
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                       end

         MOV_Dir_aRi : begin
						    BIT_NUMBER = 3'bxxx;
							WR_DATA    = RD_DATA;
	                        WR_ADDRS   = PROG_DIN;
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b0;
							RD_ADDRS   = 8'hxx;
							WR_EN      = STATE[1];
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                       end


         MOV_aRi_A	 : begin
						    BIT_NUMBER = 3'bxxx;
							WR_DATA    = ACC;
	                        WR_ADDRS   = 8'hxx;
							DIRECT_WR  = 1'b0;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = ACC_ADDRS;
							WR_EN      = STATE[0];
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                       end

         MOV_aRi_Dir : begin
						    BIT_NUMBER = 3'bxxx;
							WR_DATA    = RD_DATA;
	                        WR_ADDRS   = 8'hxx;
							DIRECT_WR  = 1'b0;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = PROG_DIN;
							WR_EN      = STATE[1];
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                      end

         MOV_aRi_imD : begin
						    BIT_NUMBER = 3'bxxx;
							WR_DATA    = PROG_DIN;
	                        WR_ADDRS   = 8'hxx;
							DIRECT_WR  = 1'b0;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = 8'hxx;
							WR_EN      = STATE[1];
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                       end

         MOV_DPTR_imD16  : begin
						    BIT_NUMBER = 3'bxxx;
							WR_DATA    = PROG_DIN;
	                        WR_ADDRS   = STATE[2] ? DPL_ADDRS : DPH_ADDRS;
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = 8'hxx;
							WR_EN      = |STATE[2:1];
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                           end

              MOVC_A_aA_DPTR,  
              MOVC_A_aA_PC  : begin
								BIT_NUMBER = 3'bxxx;
		   						WR_ADDRS   = ACC_ADDRS;
								WR_DATA    = PROG_DIN;
								DIRECT_WR  = 1'b1;
								DIRECT_RD  = 1'b0;
		                        RD_ADDRS   = 8'hxx;
								WR_EN      = STATE[2];
								DATA_A	   = 8'hxx;
								DATA_B     = 8'hxx;
                      		  end

				MOVX_A_aRi,
				MOVX_A_DPTR : begin
								BIT_NUMBER = 3'bxxx;
		   						WR_ADDRS   = ACC_ADDRS;
								WR_DATA    = XDBUS_IN;
								DIRECT_WR  = 1'b1;
								DIRECT_RD  = 1'b0;
		                        RD_ADDRS   = 8'hxx;
								WR_EN      = STATE[2];
								DATA_A	   = 8'hxx;
								DATA_B     = 8'hxx;
                      		  end


         ANL_C_Bit,	 
        ANL_C_nBit,  
		ORL_C_nBit,
		 ORL_C_Bit,
         MOV_C_Bit	 : begin																			 
						    BIT_NUMBER = PROG_DIN[2:0];
							WR_DATA    = 8'hxx;
	                        WR_ADDRS   = 8'hxx;			// 8'hD0 
							DIRECT_WR  = 1'b0;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = BIT_ADDRESS;
							WR_EN      = 1'b0;
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                       end

         	   JBC  : begin                             // 3 byte
						    BIT_NUMBER = OPERAND_1[2:0];
							WR_DATA    = ALU;
	                        WR_ADDRS   = {OPERAND_1[7:3], 3'b000};
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   =  {OPERAND_1[7:3], 3'b000};
							WR_EN      = STATE[2] & BIT_IS_SET;
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                       end

         	   JB  : begin                             // 3 byte
						    BIT_NUMBER = OPERAND_1[2:0];
							WR_DATA    = 8'hxx;
	                        WR_ADDRS   = 8'hxx;
							DIRECT_WR  = 1'b0;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   =  {OPERAND_1[7:3], 3'b000};
							WR_EN      = 1'b0;
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                       end

         	   JNB  : begin                             // 3 byte
						    BIT_NUMBER = OPERAND_1[2:0];
							WR_DATA    = 8'hxx;
	                        WR_ADDRS   = 8'hxx;
							DIRECT_WR  = 1'b0;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   =  {OPERAND_1[7:3], 3'b000};
							WR_EN      = 1'b0;
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                       end


 		   CPL_Bit,
           CLR_Bit,	 
		  SETB_Bit  : begin
						    BIT_NUMBER = PROG_DIN[2:0];
							WR_DATA    = ALU;
	                        WR_ADDRS   = BIT_ADDRESS;
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = BIT_ADDRESS;
							WR_EN      = STATE[1];
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                       end

         MOV_Bit_C	 : begin
						    BIT_NUMBER = PROG_DIN[2:0];
							WR_DATA    = SET_C_MASK | RD_DATA;
	                        WR_ADDRS   = BIT_ADDRESS;
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = BIT_ADDRESS;
							WR_EN      = STATE[1];
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                       end


         POP_Dir	 : begin
						    BIT_NUMBER = 3'bxxx;
							WR_DATA    = RD_DATA;
	                        WR_ADDRS   = PROG_DIN;
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = SP;
							WR_EN      = STATE[1];
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
         			   end


		 ACALL		 : begin
						    BIT_NUMBER = 3'bxxx;
							WR_DATA    =  STATE[1] ? NEXT_PC[7:0] : {NEXT_PC[15:8]};
	                        WR_ADDRS   =  SP_PLUS_ONE;
							DIRECT_WR  =  1'b1;
							DIRECT_RD  = 1'bx;
							RD_ADDRS   = 8'hxx;
							WR_EN      = |STATE[2:1];
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
					   end

		 LCALL		 : begin
						    BIT_NUMBER = 3'bxxx;
							WR_DATA    =  STATE[2] ? NEXT_PC[7:0] : {NEXT_PC[15:8]};
	                        WR_ADDRS   =  SP_PLUS_ONE;
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'bx;
							RD_ADDRS   = 8'hxx;
							WR_EN      = |STATE[3:2];
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
					   end
          			    
         PUSH_Dir	 : begin
						    BIT_NUMBER = 3'bxxx;
							WR_DATA    = RD_DATA;
	                        WR_ADDRS   = SP_PLUS_ONE;
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = PROG_DIN;
							WR_EN      = STATE[1];
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                       end

         RET,	
         RETI	     : begin
						    BIT_NUMBER = 3'bxxx;
							WR_DATA    = 8'hxx;
	                        WR_ADDRS   = 8'hxx;
							DIRECT_WR  = 1'b0;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   =   SP;
							WR_EN      = 1'b0;
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                       end

         XCH_A_Rn     : begin
						    BIT_NUMBER = 3'bxxx;
							WR_DATA    = ACC;
	                        WR_ADDRS   = {3'b000, PSW[4:3], INST_REG[2:0]};
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = {3'b000, PSW[4:3], INST_REG[2:0]};
							WR_EN      = STATE[0];
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                       end	
                       	      
         XCH_A_Dir     : begin
						    BIT_NUMBER = 3'bxxx;
							WR_DATA    = ACC;
	                        WR_ADDRS   = PROG_DIN;
							DIRECT_WR  = 1'b1;
							DIRECT_RD  = 1'b1;
							RD_ADDRS   = PROG_DIN;
							WR_EN      = STATE[1];
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                       end	
          
         XCH_A_aRi     : begin
						    BIT_NUMBER = 3'bxxx;
							WR_DATA    = ACC;
	                        WR_ADDRS   = 8'hxx;
							DIRECT_WR  = 1'b0;
							DIRECT_RD  = 1'b0;
							RD_ADDRS   = 8'hxx;
							WR_EN      = STATE[0];
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                       end	 
         XCHD	     : begin
						    BIT_NUMBER = 3'bxxx;
							WR_DATA    = {RD_DATA[7:4], ACC[3:0]};
	                        WR_ADDRS   = 8'hxx;
							DIRECT_WR  = 1'b0;
							DIRECT_RD  = 1'b0;
							RD_ADDRS   = 8'hxx;
							WR_EN      = STATE[0];
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                       end

 
		 MON_INST,
		 BREAK_MODE : begin
			 			 casex (MONITOR_INST)
			 				MDATA_WR:	begin
			 							    BIT_NUMBER = 3'bxxx;
			 								WR_DATA    = MONITOR_WR_DATA;
			 							    WR_ADDRS   = MONITOR_ADDR[7:0];
			 								DIRECT_WR  = 1'b1;
			 								DIRECT_RD  = 1'b1;
			 								RD_ADDRS   = 8'hxx;
			 								WR_EN      = STATE[2];
			 								DATA_A     = 8'hxx;
	                      					DATA_B	   = 8'hxx;
	                      				end

	 		 			 	MDATA_RD  :	begin
			 							    BIT_NUMBER = 3'bxxx;
			 								WR_DATA    = 8'hxx;
			 							    WR_ADDRS   = 8'hxx;
			 								DIRECT_WR  = 1'b0;
			 								DIRECT_RD  = 1'b1;
			 								RD_ADDRS   = MONITOR_ADDR[7:0];
			 								WR_EN      = 1'b0;
			 								DATA_A     = 8'hxx;
	                      					DATA_B	   = 8'hxx;
	                      				end

         					default	  : begin
											BIT_NUMBER = 3'bxxx;
											WR_DATA    = 8'hxx;
	     					                WR_ADDRS   = 8'hxx;
											DIRECT_WR  = 1'b0;
											DIRECT_RD  = 1'b0;
											RD_ADDRS   = 8'hxx;
											WR_EN      = 1'b0;
											DATA_A     = 8'hxx;
											DATA_B	   = 8'hxx;
         					            end

			 			 endcase
		 		      end

         default	     : begin
						    BIT_NUMBER = 3'bxxx;
							WR_DATA    = 8'hxx;
	                        WR_ADDRS   = 8'hxx;
							DIRECT_WR  = 1'b0;
							DIRECT_RD  = 1'b0;
							RD_ADDRS   = 8'hxx;
							WR_EN      = 1'b0;
							DATA_A     = 8'hxx;
							DATA_B	   = 8'hxx;
                       end
    endcase
end


always @(INST_PREFETCH or STATE or LOADED) begin // gotta do a little look ahead off the instruction bus
                                                 //必须做一些展望关闭指令总线  
     casex (INST_PREFETCH) 

	    ADD_A_Rn,	 
        ADD_A_aRi,	 
        ADDC_A_Rn,	 
        ADDC_A_aRi,  
        ANL_A_Rn,	 
        ANL_A_aRi,	 
        CLR_A,	      
        CLR_C,	      
        CPL_A,	      
        CPL_C,	      
        DA,	      
        DEC_A,	      
        DEC_Rn,	 
        DEC_aRi,	 
        INC_A,	
        INC_Rn,	 
        INC_aRi,	 
        MOV_A_Rn,	 
        MOV_A_aRi,	 
        MOV_Rn_A,	 
        MOV_aRi_A,	 
        NOP,	      
        ORL_A_Rn,	 
        ORL_A_aRi,	 
        RLA,	      
        RLC_A,	      
        RR_A,	      
        RRC_A,	      
        SETB_C,	 
        SUBB_A_Rn,	 
        SUBB_A_aRi,	 
        SWAP_A,	 
        XCH_A_Rn,	 
        XCH_A_aRi,	 
        XCHD,	      
        XRL_A_Rn,	 
        XRL_A_aRi       : MULTICYCL_INSTR = ~LOADED;
        default         : MULTICYCL_INSTR = STATE[0];	 
    endcase
end
         

always @(posedge CPUClock or posedge RESET) begin
	if (RESET) begin
		CYCLE_STATE   	 <=  4'b0000;
		INST_REG      	 <= 11'b000_00000000;
        PC            	 <= 'h0; 
		PCH_TEMP	  	 <=  'h0;
		OPERAND_1	  	 <=  8'h00;
		LAST_FETCH		 <= 'h0;
		SW_BREAK_FLAG 	 <=  1'b0;
		HW_BREAK_FLAG 	 <=  1'b0;
		MONITOR_CYCL	 <=  1'b0;
		MONITOR_RD_DATA  <=  8'h00;
		MONITOR_CYC_CMPL <=  1'b0;
        SSTEP            <= 1'b0;
		IACK			 <=  1'b0;
		RTI				 <=  1'b0;
		CYq				 <=  1'b0;
		INT_LEVEL 		 <= 2'b00;
		RETRY 			 <= 1'b0;
		PROG_WR 		 <= 1'b0;
	end
	else begin
         if (SSTEP) SSTEP <= 1'b0;
		 CYq <= ADDER_CARRY;
		 if (IACK) IACK <= 1'b0;
		 if (RTI)  RTI  <= 1'b0;

		 if (MONITOR_REQUEST & OP_FETCH) MONITOR_CYCL <= 1'b1;

		 if (OP_FETCH) LAST_FETCH <= PC;

         if (OP_FETCH) begin		  // STATE[0] = 1 = OP_FETCH
			  PC <= NEXT_PC;
              INST_REG <= INST_PREFETCH;
			  if (MULTICYCL_INSTR) CYCLE_STATE <= STATE_PLUS_ONE;
         end

         OPERAND_1 <= PROG_DIN;

		 if (HW_BREAK_REQUEST) HW_BREAK_FLAG <= 1'b1;

		 if (~OP_FETCH) begin

	         casex (INST_REG)
				  MON_INST,
				  BREAK_MODE : begin
								 casex (MONITOR_INST)
	 							 	MPROG_WR  :	begin
													if (STATE[1]) begin
														PC <= MONITOR_ADDR;
														CYCLE_STATE <= STATE_PLUS_ONE;
														MONITOR_CYC_CMPL <= 1'b1;
														PROG_WR <= 1'b1;
													end
													if (STATE[2]) begin
														PC <= LAST_FETCH;
														MONITOR_RD_DATA <= PROG_DIN;
	                           							CYCLE_STATE <= 4'b0000;
	                           							MONITOR_CYCL <= 1'b0;
														MONITOR_CYC_CMPL <= 1'b0;
														PROG_WR <= 1'b0;
	                           						end
								 				end

	 							 	MPROG_RD  :	begin
													if (STATE[1]) begin
														PC <= MONITOR_ADDR;
														CYCLE_STATE <= STATE_PLUS_ONE;
														MONITOR_CYC_CMPL <= 1'b1;
													end 
													if (STATE[2]) begin
														PC <= LAST_FETCH;
														MONITOR_RD_DATA <= PROG_DIN;
	                           							CYCLE_STATE <= 4'b0000;
	                           							MONITOR_CYCL <= 1'b0;
														MONITOR_CYC_CMPL <= 1'b0;
	                           						end
								 				end

									MDATA_WR,
	 							 	MDATA_RD  :	begin
													if (STATE[1]) begin
														PC <= LAST_FETCH;
														CYCLE_STATE <= STATE_PLUS_ONE;
														MONITOR_CYC_CMPL <= 1'b1;
													end 
													if (STATE[2]) begin
														PC <= LAST_FETCH;
														MONITOR_RD_DATA <= RD_DATA;
	                           							CYCLE_STATE <= 4'b0000;
	                           							MONITOR_CYCL <= 1'b0;
														MONITOR_CYC_CMPL <= 1'b0;

	                           						end
								 				end

	 							 	MXTRN_RD  :	begin
													if (STATE[1]) begin
														PC <= MONITOR_ADDR;
														MONITOR_CYC_CMPL <= 1'b1;
														CYCLE_STATE <= STATE_PLUS_ONE;
													end 
													if (STATE[2]) begin
														MONITOR_RD_DATA <= XDBUS_IN;
	                           							CYCLE_STATE <= 4'b0000;
	                           							MONITOR_CYCL <= 1'b0;
														MONITOR_CYC_CMPL <= 1'b0;
														PC <= LAST_FETCH;
	                           						end
								 				end

	 							 	MXTRN_WR  :	begin
													if (STATE[1]) begin
														PC <= MONITOR_ADDR;
														CYCLE_STATE <= STATE_PLUS_ONE;
														MONITOR_CYC_CMPL <= 1'b1;
													end 
													if (STATE[2]) begin
	                           							CYCLE_STATE <= 4'b0000;
	                           							MONITOR_CYCL <= 1'b0;
														MONITOR_CYC_CMPL <= 1'b0;
														PC <= LAST_FETCH;
	                           						end
								 				end

	 							 	MCLR_BRK  :	begin
														if (STATE[1]) begin
															if (~REAL_TIME_ON | ((~|INT_LEVEL) & REAL_TIME_ON )) begin		//
																PC <= MONITOR_ADDR;
																RETRY <= 1'b0;
															end		
															else RETRY <= 1'b1;														
															CYCLE_STATE <= STATE_PLUS_ONE;
															MONITOR_CYC_CMPL <= 1'b1;
														end 
														if (STATE[2]) begin
									 						SW_BREAK_FLAG <= 1'b0;
									 						HW_BREAK_FLAG <= 1'b0;
		                           							CYCLE_STATE <= 4'b0000;
		                           							MONITOR_CYCL <= 1'b0;
															MONITOR_CYC_CMPL <= 1'b0;
															if (~REAL_TIME_ON | ((~|INT_LEVEL) & REAL_TIME_ON )) begin		//
		                                                        if (~SSTEP) SSTEP <= 1'b1;
															end
		                           						end
												end	
	  							   default :	begin
													PC <= LAST_FETCH;
	                            					CYCLE_STATE <= 4'b0000;	
	                           						MONITOR_CYCL <= 1'b0;							  
	                            				end							  
	 							 endcase
							   end


	              EXCEPTION	: begin
								if (STATE[2]) begin
									CYCLE_STATE <= 4'b0000;
									PC <= {10'b0000_0000_00, VECTOR, 3'b011};
									if (~IACK) IACK <= 1'b1;
									if (BREAK_FLAG & ~INT_LEVEL[1]) INT_LEVEL <= INT_LEVEL + 1'b1;
								end
								else  CYCLE_STATE <= STATE_PLUS_ONE;
	                          end


				  SWBRK :	  begin
								PC <= LAST_FETCH;
								SW_BREAK_FLAG <= 1'b1;
	                            CYCLE_STATE <= 4'b0000;
							  end

				  AJMP	      : begin

	                             	      CYCLE_STATE <= 4'b0000;
	                             	      PC <= {NEXT_PC[15:11], INST_REG[7:5], PROG_DIN};
	                            end   
                                  
	              ACALL	      : begin

	                             	if (STATE[1]) begin
	                             	      CYCLE_STATE <= STATE_PLUS_ONE;
	                             	end
	                             	if (STATE[2]) begin
	                             	      CYCLE_STATE <= 4'b0000;
	                             	      PC <= {NEXT_PC[15:11], INST_REG[7:5], PROG_DIN};
	                             	end
	                            end     
	                                 



	              POP_Dir,  
	              PUSH_Dir, 
	              MOV_Rn_Dir,
				  MOV_Dir_Rn,	// 2-byte move instructions / 2个字节的移动指示
	              MOV_Rn_imD,
	              MOV_Dir_aRi,
	              MOV_aRi_Dir,
	              MOV_aRi_imD,
	              MOV_Bit_C,	 
	              ANL_Dir_A,
	              DEC_Dir,
	              INC_Dir,																		  
	              MOV_Dir_A,																	  
	              ORL_Dir_A,																	             
	              XRL_Dir_A,       
	              CLR_Bit,
	              CPL_Bit,
	              SETB_Bit,	
	              ANL_C_Bit,
	              ANL_C_nBit,
	              MOV_C_Bit,
	              ORL_C_Bit,
	              ORL_C_nBit, 
	              ADD_A_Dir, 
	              ADD_A_imD, 
		          ADDC_A_Dir,	 
	              ADDC_A_imD,
	              ANL_A_Dir,
	              ANL_A_imD,
		   		  MOV_A_Dir,	
		   		  MOV_A_imD,
	              ORL_A_Dir,	      
	              ORL_A_imD,
	              SUBB_A_Dir,
	              SUBB_A_imD,
	              XRL_A_Dir,
	              XRL_A_imD,
	              XCH_A_Dir	:  begin
	                           		CYCLE_STATE <= 4'b0000;
	                           		PC <= NEXT_PC;
	                           end


	              MOV_Dir_Dir,
	              ANL_Dir_imD,
				  MOV_Dir_imD,
	              ORL_Dir_imD,
	              XRL_Dir_imD	 : begin
										if (STATE[1]) CYCLE_STATE <= STATE_PLUS_ONE;
										if (STATE[2]) CYCLE_STATE <= 4'b0000;
										PC <= NEXT_PC;
	                               end


	                            														  
	              INC_DPTR	   : begin		// although one byte, it requires 2 clocks
	                                        // 虽然一个字节，它需要2时钟
									if (STATE[2]) begin
										CYCLE_STATE <= 4'b0000;
									end
									else CYCLE_STATE <= STATE_PLUS_ONE;
	                             end															        

	              MUL	      : begin
	              					if (STATE[3:1]) CYCLE_STATE <= STATE_PLUS_ONE; 
	              					else if (STATE[4]) CYCLE_STATE <= 4'b0000; 														  
	                            end	


	              DIV	      : begin
	              					if (STATE[3:1]) CYCLE_STATE <= STATE_PLUS_ONE; 
	              					else if (STATE[4]) CYCLE_STATE <= 4'b0000; 														  
	                            end	
																								  	
	              DJNZ_Rn	  : begin
									PC <= NEXT_PC;
	                                CYCLE_STATE <= 4'b0000;	
	                            end															  
	              DJNZ_Dir	  : begin
                                    PC <= NEXT_PC;
                                    if (STATE[2])   CYCLE_STATE <= 4'b0000;
                                    else  CYCLE_STATE <= STATE_PLUS_ONE;
	                            end															  	

																								  	
	              JMP	      : begin															        
									PC <= NEXT_PC;
	                                CYCLE_STATE <= 4'b0000;									        
								end
																								  	
	              CJNE_A_Dir,	                              
	              CJNE_A_imD,                             
	              CJNE_Rn_imD,                             
	              CJNE_aRi_imD,	 
	              JB,
	              JBC,															
	              JNB	      : begin																
									if (STATE[1]) CYCLE_STATE <= STATE_PLUS_ONE;	   // three-byte branch									  
	                                else CYCLE_STATE <= 4'b0000;
	                                PC <= NEXT_PC;																		
	                            end	

	              SJMP,              														        
				  JNZ,																					
				  JZ,																				        
	              JC,
	              JNC	      : begin
	                                CYCLE_STATE <= 4'b0000;                         // three-byte branch	
	                                PC <= NEXT_PC;	
	                            end																	

	              LCALL	      : begin

	                             	if (STATE[1]) begin
	                             	      CYCLE_STATE <= STATE_PLUS_ONE;
                                          PC <= NEXT_PC;
	                             	end
	                             	if (STATE[2]) begin
	                             	      CYCLE_STATE <= STATE_PLUS_ONE;
                                          PCH_TEMP <= OPERAND_1;
	                             	end
	                             	if (STATE[3]) begin
	                             	      CYCLE_STATE <= 4'b0000;
	                             	      PC <= {PCH_TEMP, OPERAND_1};
	                             	end
	                            end     

                  LJMP        : begin
                                    if (STATE[2]) begin
                                        CYCLE_STATE <= 4'b0000;
                                        PC <= {OPERAND_1, PROG_DIN};
                                    end
                                    else begin
	                                    CYCLE_STATE <= STATE_PLUS_ONE;
                                        PC <= NEXT_PC;
                                    end
                                end
    


	              MOV_DPTR_imD16  : begin
										if (STATE[1]) CYCLE_STATE <= STATE_PLUS_ONE;	   // three-byte instr 3个字节的instr									  
		                                else CYCLE_STATE <= 4'b0000;
		                                PC <= NEXT_PC;																		
	                                end

	
	               MOVC_A_aA_PC,
	               MOVC_A_aA_DPTR  : begin
			   					 		if (STATE[1]) begin
		                                    CYCLE_STATE <= STATE_PLUS_ONE;
		                                	PC <= NEXT_PC;

										end
										if (STATE[2]) begin
											CYCLE_STATE <= 4'b0000;
											PC <= LAST_FETCH_PLUS_ONE;
										end

	                                end


	              MOVX_A_aRi	 : begin
			   					 		if (STATE[1]) begin
		                                    CYCLE_STATE <= STATE_PLUS_ONE;
		                                	PC <= {8'h00, RD_DATA};
										end
										if (STATE[2]) begin
											CYCLE_STATE <= 4'b0000;
											PC <= LAST_FETCH_PLUS_ONE;
										end
	                                end



	              MOVX_A_DPTR	 : begin
			   					 		if (STATE[1]) begin
		                                    CYCLE_STATE <= STATE_PLUS_ONE;
		                                	PC <= {DPH, DPL};
										end
										if (STATE[2]) begin
											CYCLE_STATE <= 4'b0000;
											PC <= LAST_FETCH_PLUS_ONE;
										end

	                                end


	              MOVX_aRi_A	 : begin
			   					 		if (STATE[1]) begin
		                                    CYCLE_STATE <= STATE_PLUS_ONE;
		                                	PC <= {8'h00, RD_DATA};
										end
										if (STATE[2]) begin
											CYCLE_STATE <= 4'b0000;
											PC <= LAST_FETCH_PLUS_ONE;
										end
	                                end


	              MOVX_DPTR_A	 : begin
			   					 		if (STATE[1]) begin
		                                    CYCLE_STATE <= STATE_PLUS_ONE;
		                                	PC <= {DPH, DPL};
										end
										if (STATE[2]) begin
											CYCLE_STATE <= 4'b0000;
											PC <= LAST_FETCH_PLUS_ONE;
										end
	                                end
	                       

	              RET	      : begin
									if (STATE[1]) begin
										CYCLE_STATE <= STATE_PLUS_ONE;
										PCH_TEMP <= RD_DATA;
										PC <= NEXT_PC;
									end	
									else begin
										CYCLE_STATE <= 4'b0000;
										PC <= {PCH_TEMP, RD_DATA};
 									end
	                            end

	              RETI	      : begin
									if (STATE[1]) begin
										CYCLE_STATE <= STATE_PLUS_ONE;
										PCH_TEMP <= RD_DATA;
										PC <= NEXT_PC;
									end	
									else begin
										CYCLE_STATE <= 4'b0000;
										PC <= {PCH_TEMP, RD_DATA};
										if (~RTI) RTI <= 1'b1;
										if (BREAK_FLAG & |INT_LEVEL) INT_LEVEL <= INT_LEVEL - 1'b1;
									end
	                            end

	         endcase
		end
	end
end

endmodule
