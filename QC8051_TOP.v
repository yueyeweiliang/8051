//-----------------------------------------------------------------------------------------------------------------------
//
//	QuickCores Q8051 CPU example top-level design with on-chip JTAG debug and real-time monitoring
//  Version 1.02
//	November 09, 2003
//  
//	For updates and app-notes, development hardware, visit www.quickcores.com 
//  For technical assistance, call QuickCores at (972) 578 1121 or send an email to jerry@quickcores.com
//
//
//	QuickCores has posted this Q8051 CPU netlist library for your unrestricted use and modification	with the hope that
//  	it may be useful, but QuickCores makes no warranty or guarantee (implied or otherwise) that it is free from 
//		errors or that it is fit for any purpose or that such use will not infringe the rights of anyone.  
//		QuickCores expressly disclaims any liability which may arise in whole 
//		or in part from its use or misuse including infringing the rights of anyone.  The posting of this
//		file or any related files is not intended to place into the public domain any related patents.
//
//  This is an example top-level Q8051 design with the following features:
//		 dual 8-bit output-only parallel port, fixed totum-pole output
//		 single 8-bit input-only parallel port
//		 prioritized interrupt handler
//		 dual  counter timer circuit
//		 dual DAC7512 synchronous serial ports
//		 external bus interface using 4xClock
//
//	The example design also includes the on-chip, real-time monitor and debug logic	module which is compatible
//		with Domain Technologies high level C language debugger and mini-USB JTAG controller pod 
//
//
//
//	The design should easily synthesize with Symplify Lite (Actel, QuickLogic, Xilinx) and ALTERA Quartus II web edition)
//		Before synthesis, be sure to remove comments in front of the desired RAM block (see RAM instantiations below)
//		Depending on how you have your system configured, you may need to manually instantiate global clock buffers for 
//		CPUClock, TCK
//
//	If you need target hardware, QuickCores offers a project board with ALTERA Cyclone EP1C6T144C8 installed.
//	The board has dual 12-bit DACs, external flash memory, LCD, and built-in USB 1.1 programmer
//	The $500 price include BoxView high level C language debugger
//	For details, visit QuickCores web site at:  www.quickcores.com or email or call using information above.
//		
//-----------------------------------------------------------------------------------------------------------------------


`timescale 1ns/1ns

module QC8051_TOP( 
			   EXT_ADDRS,		// O	    CPU program counter & external address (only 11 lower bits used in FREE version)
  			                              //CPU的程序计数器和外部地址（在免费版本只用于低11位）
  			   XDBUS,			// I/O/Z    external Flash data bus	 //外在一刹那数据总线	    
  			   OE_n,			// O	   	external Flash active low read control  (OE_n) 
  			                              //外在一刹那活跃低落读了控制(OE_n)  
  			   WR_n,			// O		external Flash active low write control (WE_n)
  			                              //外部闪存低电平写控制（WE_n）
			   XFLASH_CS_n,		// O		external Flash active low chip select   (CE_n)
			                              //外部闪存芯片低电平选择（CE_n）
  			   Clock_In, 		// I		External clock input //外部时钟输入
   			   OP_FETCH,		// O		CPU op-code fetch output (1 = op-fetch) indicates 1st byte of instruction
			                              //CPU的运算代码提取输出（1 =运算提取）表示教学第一字节
			   BREAK_FLAG,		// O		1 = S/W or H/W breakpoint detected //1 =的S / W或H / W的断点检测
			   MONITOR_CYCL,	// O		1 = current CPU cycle is a monitor cycle //1 =当前CPU循环周期是一个监视器
  			   XRESET_n,		// I		active low reset input (connected to key button 4)
  			                              //低有效复位输入（连接到关键按钮4）
			   PORT0,			// O		8-bit (readable) output port (connected to LEDs
			                              //8位（可读）输出端口（连接到LED
               PORT1,			// O 		8-bit (readable) output port (connected to LCD data/control lines
                                          //8位（可读）输出端口（连接到液晶显示器数据/控制线
               PORT2,			// I		8-bit input-only port (LSBs connected to 3-button keypad)
                                          //8位输入唯一的港口（连接到3键键盘最低有效位）
               CPUClock,		// O		CPUClock output   CPUClock输出
               OSC_EN,			// O		target board oscillator enable = 1  //目标板上振荡器使= 1
			   T0,				// I		Timer/counter0 trigger input  //Timer/counter0触发输入
			   T1,				// I		Timer/counter1 trigger input  //Timer/counter1触发输入
			   INT0,			// I		Interrupt 0 input  //中断0输入
			   INT1,			// I 		Interrupt 1 input  //中断1输入
			
	 		   DAC0_SCLK,		// O		DAC 0 Serial Clock //DAC的串行时钟0
			   DAC0_SYNC_n,		// O		DAC 0 Sync output  //DAC的同步输出0
			   DAC0_SIn,		// O 		DAC 0 Serial data output  //DAC的串行数据输出0
			
			   DAC1_SCLK,		// O		DAC 1 Serial Clock  //DAC的串行时钟1
			   DAC1_SYNC_n,		// O		DAC 1 Sync output   //DAC的同步输出1
			   DAC1_SIn,		// O 		DAC 1 Serial data output  //DAC的串行数据输出1
			
               TCK,		
               TDI,		
               TDO,		
               TMS,		
               TRSTB);			

output	[19:0] EXT_ADDRS;
inout	 [7:0] XDBUS;
output		   OE_n;
output		   WR_n;
output		   XFLASH_CS_n;
input		   Clock_In;
output		   OP_FETCH;
output		   BREAK_FLAG;
output		   MONITOR_CYCL;
input		   XRESET_n;
inout    [7:0] PORT0;

inout    [7:0] PORT1;
output         CPUClock;
output         OSC_EN;
input    [7:0] PORT2;

input		   TCK;	
input		   TDI;	
output		   TDO;	
input		   TMS;	
input		   TRSTB;

input		   T0;
input		   T1;
input		   INT0;
input		   INT1;

output		   DAC0_SCLK;
output		   DAC0_SYNC_n;
output		   DAC0_SIn;

output		   DAC1_SCLK;
output		   DAC1_SYNC_n;
output		   DAC1_SIn;

	
wire	[15:0] PC;
wire	 [7:0] PROG_DOUT;		     
wire		   PROG_WR;
wire		   PROG_RD;
wire	 [7:0] XDBUS;
wire		   XRD_n;
wire		   XWR_n;
wire		   XFLASH_CS_n;
wire		   OP_FETCH;
wire		   TDO;
wire		   RESET;
wire           RESET_OUT;
wire	 [7:0] PORT0;
wire	 [7:0] PORT1;
wire     [7:0] PORT2;
wire     [7:0] USR_RD_ADDRS;
wire     [7:0] USR_WR_ADDRS;
wire     [7:0] USR_RD_DATA;
wire     [7:0] USR_WR_DATA;
wire		   DIRECT_WR;
wire		   DIRECT_RD;
wire		   WR_EN;
wire		   MONITOR_CYCL;
wire		   USFR_WREN;					
wire	 [7:0] RAM_DOUT;
wire		   BREAK_FLAG;
wire		   RESET_IN;
wire		   IACK;
wire		   RTI;
wire		   CPUClock;
wire           OSC_EN;                      
wire           RMW;
wire           MONITOR_DIRECT;
wire	 [2:0] VECTOR;
wire		   INT_REQ;
wire		   IN_SERVICE;
wire   [10:0]  PC_TRUNC;
wire   [7:0]   XDBUS_IN;
wire   [7:0]   XPBUS_IN;
wire   [7:0]   XDBUS_OUT;
wire		   XDIRECTION;

wire		   DAC0_SCLK;
wire		   DAC0_TX_OE;
wire		   DAC0_SYNC_n;
wire		   DAC0_SIn;

wire		   DAC1_SCLK;
wire		   DAC1_TX_OE;
wire		   DAC1_SYNC_n;
wire		   DAC1_SIn;

wire		   RD_CLK;

wire 			PCE_n;
wire 			DCE_n;
wire 			WR_n;	
wire 			OE_n;
wire  [19:0]	EXT_ADDRS;	
wire			XDATA_CYCL;


assign		   EXT_ADDRS = {4'b0000, PC};              
assign		   XFLASH_CS_n = ~(~PCE_n | ~DCE_n);
assign		   DAC0_SCLK = CPUClock;
assign		   DAC1_SCLK = CPUClock;

assign		   USFR_WREN = WR_EN & ~(~MONITOR_DIRECT & MONITOR_CYCL);
assign         OSC_EN    = 1'b1;

assign		   RESET_IN = ~XRESET_n;         // invert the external reset //倒置的外部复位
assign		   RESET    = RESET_OUT;         // name change  //更改名称

assign         XDBUS_IN = XDBUS;
assign         XPBUS_IN = XDBUS;
assign		   XDBUS = ~WR_n ? (PROG_WR ? PROG_DOUT : XDBUS_OUT) : 8'hzz;

// Note that there are two 8-bit buses; program and data.  You can locate as much or as little program or data
// memory off/on chip.  In this example, both program and external data memory are located off-chip.  Consequently,
// the two buses must be muxed before going off-chip as is the case in this example.
/*请注意，有两个8位的总线，程序和数据。你可以找到尽可能多或尽可能少的程序或数据存储器开/关机芯片。
在这个例子中，无论程序和外部数据存储器位于片外。
因此，必须合并调制两辆公共汽车在去片外正如在这个例子中。
*/
Q8051_CPU CPU( 	  .PC					(PC),							  
  				  .PROG_DIN				(XPBUS_IN), 	// this is the program instruction bus input
  				                                        // 这是程序指令总线输入
  				  .PROG_DOUT			(PROG_DOUT), 	// program write bus (monitor write instructions)
  				                                        // 计划写巴士（显示器写说明）
  				  .PROG_WR				(PROG_WR), 		// internal program write signal // 内部程序写信号                                     
  				  .XDBUS_IN				(XDBUS_IN),		// external data bus input //外部数据总线输入
                  .XDBUS_OUT			(XDBUS_OUT),	// external data bus output//外部数据总线输出

				  .USR_RD_ADDRS			(USR_RD_ADDRS),
				  .USR_WR_ADDRS			(USR_WR_ADDRS),
				  .USR_RD_DATA			(USR_RD_DATA),
				  .USR_WR_DATA			(USR_WR_DATA),
				  .DIRECT_WR			(DIRECT_WR),
				  .DIRECT_RD			(DIRECT_RD),
                  .MONITOR_DIRECT		(MONITOR_DIRECT),
				  .WR_EN				(WR_EN),
				
				  .PCE_n				(PCE_n),	// external program memory chip enable, active low
				                                    // 外部程序存储器芯片使能，低电平有效
				  .DCE_n				(DCE_n),	// external data memory chip enable, active low 
				                                    // 外部数据存储器芯片使能，低电平有效
				  .WR_n					(WR_n),		// external write enable, active low
				                                    // 外部写使能，低电平有效
				  .OE_n					(OE_n),		// external output enable, active low
                                                    // 外部输出使能，低电平有效
				  .Clock_In				(Clock_In),
  				  .CPUClock				(CPUClock), 
  				  .OP_FETCH				(OP_FETCH),
                  .RMW					(RMW),
  				  .IACK					(IACK),
				  .RTI					(RTI),
				  .INT_REQ				(INT_REQ),
				  .VECTOR				(VECTOR),
  				  .RESET_IN				(RESET_IN),
                  .RESET_OUT			(RESET_OUT),
  				  .MONITOR_CYCL			(MONITOR_CYCL),
                  .BREAK_FLAG			(BREAK_FLAG),
				  .RD_CLK				(RD_CLK),		  // this is only used in ALTERA Cyclone implementations
				                                          // 这只是用来实现在Altera旋风
				  .XDATA_CYCL			(XDATA_CYCL),
              	  .TCK  				(TCK), 
                  .TDI  				(TDI),
                  .TDO  				(TDO), 
                  .TMS  				(TMS),
                  .TRSTB				(TRSTB));


// Within USR_SFRs is where you will probably make the most modifications
// You can expand (or reduce) the number of module ports as required for
// your particular application
//在USR_SFRs是你可能会做出最modificationsYou可以扩大（或减少）的模块端口的数目为您的特定应用程序所需

USR_SFRs USR_SFRs(
			   .DIR_RD_ADDRS(USR_RD_ADDRS),	   // O	    User SFR read address //用户阅读的SFR地址		  			  
			   .DIR_WR_ADDRS(USR_WR_ADDRS),	   // O	    User SFR write address //SFR的写地址的用户		  			  
			   .WR_DATA(USR_WR_DATA),		   // I	    User SFR write data bus	//用户SFR的写数据总线	 			 		   	
			   .RD_DATA(USR_RD_DATA),   	   // O		user SFR read data bus	//用户读取数据总线的SFR	 			 		
			   .DIRECT_WR(DIRECT_WR),		   // O		1 = direct data/SFR write cycle; 0 = indirect write
			                                          //1 =直接数据/ SFR的写周期; 0 =间接写 	   	
			   .DIRECT_RD(DIRECT_RD),		   // O		1 = direct data/SFR read  cycle; 0 = indirect read 
			                                          //1 =直接数据/ SFR的读周期; 0 =间接阅读 
			   .CPUClock(CPUClock),			   // O 	Global CPU clock output //全球CPU的时钟输出
			   .WR_EN(USFR_WREN),			   // I		1 = user SFR write enable (write cycle)
			                                          //1 =用户SFR的写使能（写周期）
               .RMW(RMW),					   // I		1 = read-modify-write instruction is in the instruction decoder 
			                                          //1 =读修改写指令在指令解码器
			   .RESET(RESET),				   // I		buffered and gated (by debug module in CPU) global reset 
			                                          //缓冲和门控模块在CPU的调试（）全局复位
			   .RTI(RTI),			 		   // I		Return from Interrupt is in the instruction register
			                                          //从中断返回指令是注册
			   .INT_REQ(INT_REQ),		 	   // O		Interrupt request output to CPU //中断请求输出到CPU
			   .IN_SERVICE(),				   // O 	1 = interrupt is in service //1 =中断服务
			   .VECTOR(VECTOR),				   // O		3-bit vector to CPU (created by appending 3'b011)
			                                          //3位向量处理器（通过附加3'b011创建）
			   .IACK(IACK),		 			   // I		Interrupt acknowledge indicates first opcode of interrupt service routine	 
			                                          //中断承认指示中断服务第一例行操作码
			   .INT0(INT0),					   // I		Standard Interrupt channel 0 input //标准输入通道0中断
			   .INT1(INT1),					   // I		Standard Interrupt channel 1 input //标准中断1输入通道
			   .T0(T0),						   // I		Timer/counter trigger 0 input //定时器/计数器触发输入0
			   .T1(T1),						   // I		Timer/counter trigger 1 input //定时器/计数器1输入触发
			   .PORT0(PORT0),				   // I/O	8-bit I/O port used to drive APA-208 target board LEDs
                                                      //8位I / O口用来驱动阿帕- 208目标板的LED
               .PORT1(PORT1),				   // I/O	8'bit I/O port used to control APA-208 target board LCD
                                                      //8'bit的I / O口用来控制阿帕- 208目标板液晶显示器
               .PORT2(PORT2),				   // I		8'bit input-only port of which 3 bits are used to read APA-208 key pad 
                                                      //8'bit输入唯一的港口，其中3位是用来读取阿帕- 208键盘 
			   .DAC0_TX_OE(DAC0_TX_OE),
			   .DAC0_SYNC_n(DAC0_SYNC_n),
			   .DAC0_SIn(DAC0_SIn),
			
			   .DAC1_TX_OE(DAC1_TX_OE),
			   .DAC1_SYNC_n(DAC1_SYNC_n),
			   .DAC1_SIn(DAC1_SIn));                 

//  ALTERA CYCLONE 4K embedded RAM block instantiation
//  PLL clock multiplier for use with ALTERA Cyclone RAM blocks (due to the fact that they are entirely synchronous.)
//	By multiplying the input clock and using it as the read-side clock to the RAM block, a pseudo-async. read
//  can be created 
// ALTERA公司嵌入式RAM块气旋4K的实例PLL的时钟与Altera旋风RAM块（因为是他们是完全同步使用的倍增器。）
//乘以输入时钟和使用的读端时钟到RAM块，伪异步它。读可以创建

assign RD_CLK = 1'b1;  // comment this line out if implementing design in ALTERA Cyclone
                       // 注释此行是否落实设计在Altera旋风
/*
PLLx8 PLL(
			.inclk0(Clock_In),
			.pllena(1'b1),
			.areset(RESET),
			.c0(RD_CLK),
			.locked());	
			

ram4kx8 ram4kx8(
               .data(PROG_DOUT), 
               .wren((PROG_WR)), 
               .wraddress({PC[11:0]}), 
               .rdaddress({PC[11:0]}),
               .wrclock(CPUClock), 
               .rdclock(RD_CLK),
               .q(RAM_DOUT));

*/





endmodule
