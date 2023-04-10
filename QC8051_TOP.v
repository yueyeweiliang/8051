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
  			                              //CPU�ĳ�����������ⲿ��ַ������Ѱ汾ֻ���ڵ�11λ��
  			   XDBUS,			// I/O/Z    external Flash data bus	 //����һɲ����������	    
  			   OE_n,			// O	   	external Flash active low read control  (OE_n) 
  			                              //����һɲ�ǻ�Ծ������˿���(OE_n)  
  			   WR_n,			// O		external Flash active low write control (WE_n)
  			                              //�ⲿ����͵�ƽд���ƣ�WE_n��
			   XFLASH_CS_n,		// O		external Flash active low chip select   (CE_n)
			                              //�ⲿ����оƬ�͵�ƽѡ��CE_n��
  			   Clock_In, 		// I		External clock input //�ⲿʱ������
   			   OP_FETCH,		// O		CPU op-code fetch output (1 = op-fetch) indicates 1st byte of instruction
			                              //CPU�����������ȡ�����1 =������ȡ����ʾ��ѧ��һ�ֽ�
			   BREAK_FLAG,		// O		1 = S/W or H/W breakpoint detected //1 =��S / W��H / W�Ķϵ���
			   MONITOR_CYCL,	// O		1 = current CPU cycle is a monitor cycle //1 =��ǰCPUѭ��������һ��������
  			   XRESET_n,		// I		active low reset input (connected to key button 4)
  			                              //����Ч��λ���루���ӵ��ؼ���ť4��
			   PORT0,			// O		8-bit (readable) output port (connected to LEDs
			                              //8λ���ɶ�������˿ڣ����ӵ�LED
               PORT1,			// O 		8-bit (readable) output port (connected to LCD data/control lines
                                          //8λ���ɶ�������˿ڣ����ӵ�Һ����ʾ������/������
               PORT2,			// I		8-bit input-only port (LSBs connected to 3-button keypad)
                                          //8λ����Ψһ�ĸۿڣ����ӵ�3�����������Чλ��
               CPUClock,		// O		CPUClock output   CPUClock���
               OSC_EN,			// O		target board oscillator enable = 1  //Ŀ���������ʹ= 1
			   T0,				// I		Timer/counter0 trigger input  //Timer/counter0��������
			   T1,				// I		Timer/counter1 trigger input  //Timer/counter1��������
			   INT0,			// I		Interrupt 0 input  //�ж�0����
			   INT1,			// I 		Interrupt 1 input  //�ж�1����
			
	 		   DAC0_SCLK,		// O		DAC 0 Serial Clock //DAC�Ĵ���ʱ��0
			   DAC0_SYNC_n,		// O		DAC 0 Sync output  //DAC��ͬ�����0
			   DAC0_SIn,		// O 		DAC 0 Serial data output  //DAC�Ĵ����������0
			
			   DAC1_SCLK,		// O		DAC 1 Serial Clock  //DAC�Ĵ���ʱ��1
			   DAC1_SYNC_n,		// O		DAC 1 Sync output   //DAC��ͬ�����1
			   DAC1_SIn,		// O 		DAC 1 Serial data output  //DAC�Ĵ����������1
			
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

assign		   RESET_IN = ~XRESET_n;         // invert the external reset //���õ��ⲿ��λ
assign		   RESET    = RESET_OUT;         // name change  //��������

assign         XDBUS_IN = XDBUS;
assign         XPBUS_IN = XDBUS;
assign		   XDBUS = ~WR_n ? (PROG_WR ? PROG_DOUT : XDBUS_OUT) : 8'hzz;

// Note that there are two 8-bit buses; program and data.  You can locate as much or as little program or data
// memory off/on chip.  In this example, both program and external data memory are located off-chip.  Consequently,
// the two buses must be muxed before going off-chip as is the case in this example.
/*��ע�⣬������8λ�����ߣ���������ݡ�������ҵ������ܶ�򾡿����ٵĳ�������ݴ洢����/�ػ�оƬ��
����������У����۳�����ⲿ���ݴ洢��λ��Ƭ�⡣
��ˣ�����ϲ�������������������ȥƬ����������������С�
*/
Q8051_CPU CPU( 	  .PC					(PC),							  
  				  .PROG_DIN				(XPBUS_IN), 	// this is the program instruction bus input
  				                                        // ���ǳ���ָ����������
  				  .PROG_DOUT			(PROG_DOUT), 	// program write bus (monitor write instructions)
  				                                        // �ƻ�д��ʿ����ʾ��д˵����
  				  .PROG_WR				(PROG_WR), 		// internal program write signal // �ڲ�����д�ź�                                     
  				  .XDBUS_IN				(XDBUS_IN),		// external data bus input //�ⲿ������������
                  .XDBUS_OUT			(XDBUS_OUT),	// external data bus output//�ⲿ�����������

				  .USR_RD_ADDRS			(USR_RD_ADDRS),
				  .USR_WR_ADDRS			(USR_WR_ADDRS),
				  .USR_RD_DATA			(USR_RD_DATA),
				  .USR_WR_DATA			(USR_WR_DATA),
				  .DIRECT_WR			(DIRECT_WR),
				  .DIRECT_RD			(DIRECT_RD),
                  .MONITOR_DIRECT		(MONITOR_DIRECT),
				  .WR_EN				(WR_EN),
				
				  .PCE_n				(PCE_n),	// external program memory chip enable, active low
				                                    // �ⲿ����洢��оƬʹ�ܣ��͵�ƽ��Ч
				  .DCE_n				(DCE_n),	// external data memory chip enable, active low 
				                                    // �ⲿ���ݴ洢��оƬʹ�ܣ��͵�ƽ��Ч
				  .WR_n					(WR_n),		// external write enable, active low
				                                    // �ⲿдʹ�ܣ��͵�ƽ��Ч
				  .OE_n					(OE_n),		// external output enable, active low
                                                    // �ⲿ���ʹ�ܣ��͵�ƽ��Ч
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
				                                          // ��ֻ������ʵ����Altera����
				  .XDATA_CYCL			(XDATA_CYCL),
              	  .TCK  				(TCK), 
                  .TDI  				(TDI),
                  .TDO  				(TDO), 
                  .TMS  				(TMS),
                  .TRSTB				(TRSTB));


// Within USR_SFRs is where you will probably make the most modifications
// You can expand (or reduce) the number of module ports as required for
// your particular application
//��USR_SFRs������ܻ�������modificationsYou�������󣨻���٣���ģ��˿ڵ���ĿΪ�����ض�Ӧ�ó�������

USR_SFRs USR_SFRs(
			   .DIR_RD_ADDRS(USR_RD_ADDRS),	   // O	    User SFR read address //�û��Ķ���SFR��ַ		  			  
			   .DIR_WR_ADDRS(USR_WR_ADDRS),	   // O	    User SFR write address //SFR��д��ַ���û�		  			  
			   .WR_DATA(USR_WR_DATA),		   // I	    User SFR write data bus	//�û�SFR��д��������	 			 		   	
			   .RD_DATA(USR_RD_DATA),   	   // O		user SFR read data bus	//�û���ȡ�������ߵ�SFR	 			 		
			   .DIRECT_WR(DIRECT_WR),		   // O		1 = direct data/SFR write cycle; 0 = indirect write
			                                          //1 =ֱ������/ SFR��д����; 0 =���д 	   	
			   .DIRECT_RD(DIRECT_RD),		   // O		1 = direct data/SFR read  cycle; 0 = indirect read 
			                                          //1 =ֱ������/ SFR�Ķ�����; 0 =����Ķ� 
			   .CPUClock(CPUClock),			   // O 	Global CPU clock output //ȫ��CPU��ʱ�����
			   .WR_EN(USFR_WREN),			   // I		1 = user SFR write enable (write cycle)
			                                          //1 =�û�SFR��дʹ�ܣ�д���ڣ�
               .RMW(RMW),					   // I		1 = read-modify-write instruction is in the instruction decoder 
			                                          //1 =���޸�дָ����ָ�������
			   .RESET(RESET),				   // I		buffered and gated (by debug module in CPU) global reset 
			                                          //������ſ�ģ����CPU�ĵ��ԣ���ȫ�ָ�λ
			   .RTI(RTI),			 		   // I		Return from Interrupt is in the instruction register
			                                          //���жϷ���ָ����ע��
			   .INT_REQ(INT_REQ),		 	   // O		Interrupt request output to CPU //�ж����������CPU
			   .IN_SERVICE(),				   // O 	1 = interrupt is in service //1 =�жϷ���
			   .VECTOR(VECTOR),				   // O		3-bit vector to CPU (created by appending 3'b011)
			                                          //3λ������������ͨ������3'b011������
			   .IACK(IACK),		 			   // I		Interrupt acknowledge indicates first opcode of interrupt service routine	 
			                                          //�жϳ���ָʾ�жϷ����һ���в�����
			   .INT0(INT0),					   // I		Standard Interrupt channel 0 input //��׼����ͨ��0�ж�
			   .INT1(INT1),					   // I		Standard Interrupt channel 1 input //��׼�ж�1����ͨ��
			   .T0(T0),						   // I		Timer/counter trigger 0 input //��ʱ��/��������������0
			   .T1(T1),						   // I		Timer/counter trigger 1 input //��ʱ��/������1���봥��
			   .PORT0(PORT0),				   // I/O	8-bit I/O port used to drive APA-208 target board LEDs
                                                      //8λI / O��������������- 208Ŀ����LED
               .PORT1(PORT1),				   // I/O	8'bit I/O port used to control APA-208 target board LCD
                                                      //8'bit��I / O���������ư���- 208Ŀ���Һ����ʾ��
               .PORT2(PORT2),				   // I		8'bit input-only port of which 3 bits are used to read APA-208 key pad 
                                                      //8'bit����Ψһ�ĸۿڣ�����3λ��������ȡ����- 208���� 
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
// ALTERA��˾Ƕ��ʽRAM������4K��ʵ��PLL��ʱ����Altera����RAM�飨��Ϊ����������ȫͬ��ʹ�õı���������
//��������ʱ�Ӻ�ʹ�õĶ���ʱ�ӵ�RAM�飬α�첽���������Դ���

assign RD_CLK = 1'b1;  // comment this line out if implementing design in ALTERA Cyclone
                       // ע�ʹ����Ƿ���ʵ�����Altera����
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
