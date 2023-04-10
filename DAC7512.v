module DAC7512 (BlockSel,
			   RegSel,
			   CPUWR,
			   CPUClock,
			   DIn,
			   SYNC_n,
			   SIn,
			   TxD_OE,
			   Reset);


input BlockSel;
input RegSel;
input CPUWR;
input CPUClock;
input [7:0] DIn;
output SYNC_n;
output SIn;
output TxD_OE;  //ACIA transmit output enable //发送输出使北极气候影响评价
input Reset;

reg [7:0] DAC_8MSBs;
reg [5:0] DAC_Cntrl_4LSBs;
reg [15:0] DAC_TDR;
reg [4:0] DAC_BIT_CNTR;
reg DAC_TDR_NOT_EMPTY;
reg SYNC_n;
reg TxD_OE;
reg [1:0] Cntrl_Buf;

wire SIn;

assign SIn = DAC_TDR[15];

always @(posedge CPUClock or posedge Reset) begin
 if (Reset) begin
	DAC_8MSBs <= 8'h00;
	DAC_Cntrl_4LSBs <= 	6'b00_0000;	
	Cntrl_Buf <= 2'b00;
	DAC_TDR <= 16'h0000;
	DAC_BIT_CNTR <= 5'b10000;
	DAC_TDR_NOT_EMPTY <= 1'b1;
	SYNC_n <= 1'b1;
	TxD_OE <= 1'b0;
 end
 else begin


	if (BlockSel & ~RegSel & CPUWR) DAC_Cntrl_4LSBs[5:0] <= DIn[5:0];
	
	if (BlockSel & RegSel & CPUWR) begin
		DAC_8MSBs <= DIn;
		DAC_TDR_NOT_EMPTY <= 1'b1;
	end
	else begin
		casex (DAC_BIT_CNTR[4:0])
			5'b10000 : begin
				         if (DAC_TDR_NOT_EMPTY) begin
							SYNC_n <= 1'b0;
							DAC_TDR_NOT_EMPTY <= 1'b0;
							DAC_TDR[15:0] <= {2'b00, DAC_Cntrl_4LSBs[5:4], DAC_8MSBs[7:0], DAC_Cntrl_4LSBs[3:0]};
				         	Cntrl_Buf[1:0] <= DAC_Cntrl_4LSBs[5:4];
							DAC_BIT_CNTR  <= DAC_BIT_CNTR - 1'b1;
				         end							
					   end
			5'b01111,
			5'b01110,
			5'b01101,
			5'b01100,
			5'b01011,
			5'b01010,
			5'b01001,
			5'b01000,
			5'b00111,
			5'b00110,
			5'b00101,
			5'b00100,
			5'b00011,
			5'b00010 : begin
							DAC_BIT_CNTR  <= DAC_BIT_CNTR - 1'b1;
							DAC_TDR[15:0] <= {DAC_TDR[14:0], 1'b0};
					   end

			5'b00001 : begin
							DAC_BIT_CNTR  <= DAC_BIT_CNTR - 1'b1;
							DAC_TDR[15:0] <= {DAC_TDR[14:0], 1'b0};
							if (~(&Cntrl_Buf[1:0])) TxD_OE <= 1'b0;
					   end
						
			5'b00000 : begin
							SYNC_n <= 1'b1;
							DAC_BIT_CNTR <= 5'b10000;
							if (&Cntrl_Buf[1:0]) TxD_OE <= 1'b1;
					   end

			default :  begin
							SYNC_n <= 1'b1;
							DAC_BIT_CNTR <= 5'b10000;
							DAC_TDR_NOT_EMPTY <= 1'b0;
					   end
		endcase
	end
  end
end

endmodule // DAC7512






