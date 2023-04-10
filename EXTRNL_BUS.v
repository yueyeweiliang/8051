module EXTRNL_BUS (	 Clock_In, 
					 RESET, 
					 DCE_n, 
					 PCE_n, 
					 OE_n, 
					 WR_n,
					 CPUClock,
					 INST_REG,
					 MONITOR_INST);

input Clock_In;
input RESET;
output DCE_n;
output PCE_n;
output OE_n;
output WR_n;
output CPUClock;
input [10:0] INST_REG;
input [2:0]  MONITOR_INST;

parameter	 MPROG_RD	   =  	3'b001;					// monitor program read 
                                                        // ��س����ȡ
parameter	 MPROG_WR	   =  	3'b010;		    		// monitor program write
                                                        //  ��ʾ������д��  
parameter	 MDATA_RD	   =  	3'b011;					// monitor data read 
                                                        // ������ݶ�ȡ
parameter	 MDATA_WR	   =  	3'b100;					// monitor data write
                                                        // �������д��
parameter	 MXTRN_RD	   =  	3'b101;					// monitor external read
                                                        // ����ⲿ�Ķ�
parameter	 MXTRN_WR	   =  	3'b110;					// monitor external write
                                                        // ����ⲿд 
parameter	 MCLR_BRK	   =  	3'b111;					// monitor return from breakpoint 
                                                        // ���жϵ㷵�ؼ��
parameter	MON_INST	   = 	11'b1_0_0_xxxx_xxxx;	// Monitor Instruction
                                                        // ���ָ��
parameter	EXCEPTION	   = 	11'b0_1_0_xxxx_xxxx;	// Exception ����
parameter	BREAK_MODE	   =	11'b0_0_1_xxxx_xxxx;	// Break mode�ж�ģʽ

parameter	MOVC_A_aA_DPTR =	11'b0_0_0_1001_0011;	// move A <= ((A) + (DPTR))
parameter	MOVC_A_aA_PC   =	11'b0_0_0_1000_0011;	// move A <= ((A) + (PC))
		     
parameter	MOVX_A_aRi	   =	11'b0_0_0_1110_001x;	// move A <= ((Ri))
parameter	MOVX_A_DPTR	   =	11'b0_0_0_1110_0000;	// move A <= ((DPTR))
parameter	MOVX_aRi_A	   =	11'b0_0_0_1111_001x;	// move ((Ri)) <= A
parameter	MOVX_DPTR_A	   =	11'b0_0_0_1111_0000;	// move ((DPTR)) <= A


reg [2:0]	uSTATE;
reg			PCE_n;
reg			DCE_n;
reg			WR_n;
reg			OE_n;
reg			CPUClock;

wire [2:0]	uSTATE_PLUS_ONE;


assign		uSTATE_PLUS_ONE = uSTATE + 3'b001;

always @(posedge Clock_In or posedge RESET) begin
	if (RESET) begin
		CPUClock 	<= 1'b1;
		uSTATE 		<= 3'b000;
		PCE_n		<= 1'b1;
		DCE_n		<= 1'b1;
		WR_n		<= 1'b1;
		OE_n		<= 1'b1;
	end
	else begin
	
		casex(INST_REG)
		
			MOVX_A_aRi,
			MOVX_A_DPTR		: begin
								case(uSTATE)
								3'h0 :  begin
											uSTATE <= uSTATE_PLUS_ONE;
											DCE_n <= 1'b0;
											OE_n <= 1'b0;
										end
								3'h1 :  begin
											uSTATE <= uSTATE_PLUS_ONE;
											CPUClock <= 1'b0;
										end									
								3'h2 :  begin
											uSTATE <= uSTATE_PLUS_ONE;
										end									
								3'h3 :  begin
											uSTATE <= uSTATE_PLUS_ONE;
											CPUClock <= 1'b1;
										end									
								3'h4 :  begin
											uSTATE <= uSTATE_PLUS_ONE;
										end		
								3'h5 :  begin
											uSTATE <= uSTATE_PLUS_ONE;
											CPUClock <= 1'b0;
										end									
								3'h6 :  begin
											uSTATE <= uSTATE_PLUS_ONE;
										end		
								3'h7 :  begin
											uSTATE <= 3'b000;
											DCE_n <= 1'b1;
											OE_n <= 1'b1;
											CPUClock <= 1'b1;
										end									
							  endcase
							end
			MOVC_A_aA_PC,
			MOVC_A_aA_DPTR  : begin
								case(uSTATE)
								3'h0 :  begin
											uSTATE <= uSTATE_PLUS_ONE;
											PCE_n <= 1'b0;
											OE_n <= 1'b0;
										end									
								3'h1 :  begin
											uSTATE <= uSTATE_PLUS_ONE;
											CPUClock <= 1'b0;
										end									
								3'h2 :  begin
											uSTATE <= uSTATE_PLUS_ONE;
										end									
								3'h3 :  begin
											uSTATE <= uSTATE_PLUS_ONE;
											CPUClock <= 1'b1;
										end									
								3'h4 :  begin
											uSTATE <= uSTATE_PLUS_ONE;
										end		
								3'h5 :  begin
											uSTATE <= uSTATE_PLUS_ONE;
											CPUClock <= 1'b0;
										end									
								3'h6 :  begin
											uSTATE <= uSTATE_PLUS_ONE;
										end		
								3'h7 :  begin
											uSTATE <= 3'b000;
											PCE_n <= 1'b1;
											OE_n <= 1'b1;
											CPUClock <= 1'b1;
										end									
							  endcase
							end
			
			MOVX_DPTR_A,
			MOVX_aRi_A		: begin
								case(uSTATE)
								3'h0 :  begin
											uSTATE <= uSTATE_PLUS_ONE;
											DCE_n <= 1'b0;
										end									
								3'h1 :  begin
											uSTATE <= uSTATE_PLUS_ONE;
											CPUClock <= 1'b0;
											WR_n <= 1'b0;
										end									
								3'h2:  begin
											uSTATE <= uSTATE_PLUS_ONE;
										end									
								3'h3 :  begin
											uSTATE <= uSTATE_PLUS_ONE;
											CPUClock <= 1'b1;
										end									
								3'h4 :  begin
											uSTATE <= uSTATE_PLUS_ONE;
										end		
								3'h5 :  begin
											uSTATE <= uSTATE_PLUS_ONE;
											CPUClock <= 1'b0;
										end									
								3'h6 :  begin
											uSTATE <= uSTATE_PLUS_ONE;
											WR_n <= 1'b1;
										end		
								3'h7 :  begin
											uSTATE <= 3'b000;
											DCE_n <= 1'b1;
											CPUClock <= 1'b1;
										end									 
							  endcase
							end

			MON_INST,
			BREAK_MODE : begin
							casex (MONITOR_INST)
						 		MPROG_WR  :	begin
												case(uSTATE)
												3'h0 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
															PCE_n <= 1'b0;
														end									
												3'h1 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
															CPUClock <= 1'b0;
															WR_n <= 1'b0;
														end									
												3'h2 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
														end									
												3'h3 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
															CPUClock <= 1'b1;
														end									
												3'h4 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
														end		
												3'h5 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
															CPUClock <= 1'b0;
														end									
												3'h6 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
															WR_n <= 1'b1;
														end		
												3'h7 :  begin
															uSTATE <= 3'b000;
															PCE_n <= 1'b1;
															CPUClock <= 1'b1;
														end									 
												endcase
											end
						 		MXTRN_WR  :	begin
												case(uSTATE)
												3'h0 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
															DCE_n <= 1'b0;
														end									
												3'h1 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
															CPUClock <= 1'b0;
															WR_n <= 1'b0;
														end									
												3'h2 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
														end									
												3'h3 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
															CPUClock <= 1'b1;
														end									
												3'h4 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
														end		
												3'h5 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
															CPUClock <= 1'b0;
														end									
												3'h6 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
															WR_n <= 1'b1;
														end		
												3'h7 :  begin
															uSTATE <= 3'b000;
															DCE_n <= 1'b1;
															CPUClock <= 1'b1;
														end		
												endcase							
											end
						 		MPROG_RD  :	begin
												case(uSTATE)
												3'h0 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
															PCE_n <= 1'b0;
															OE_n <= 1'b0;
														end									
												3'h1 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
															CPUClock <= 1'b0;
														end									
												3'h2 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
														end									
												3'h3 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
															CPUClock <= 1'b1;
														end									
												3'h4 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
														end		
												3'h5 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
															CPUClock <= 1'b0;
														end									
												3'h6 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
														end		
												3'h7 :  begin
															uSTATE <= 3'b000;
															PCE_n <= 1'b1;
															OE_n <= 1'b1;
															CPUClock <= 1'b1;
														end		
												endcase							
											end
						 		MXTRN_RD  :	begin
												case(uSTATE)
												3'h0 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
															DCE_n <= 1'b0;
															OE_n <= 1'b0;
														end									
												3'h1 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
															CPUClock <= 1'b0;
														end									
												3'h2 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
														end									
												3'h3 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
															CPUClock <= 1'b1;
														end									
												3'h4 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
														end		
												3'h5 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
															CPUClock <= 1'b0;
														end									
												3'h6 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
														end		
												3'h7 :  begin
															uSTATE <= 3'b000;
															DCE_n <= 1'b1;
															OE_n <= 1'b1;
															CPUClock <= 1'b1;
														end	
												endcase								
											end
									default: begin
												case(uSTATE)
												3'h0,
												3'h4 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
														end									
												3'h1,
												3'h5 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
															CPUClock <= 1'b0;
														end									
												3'h2,
												3'h6 :  begin
															uSTATE <= uSTATE_PLUS_ONE;
														end									
												3'h3,
												3'h7 :  begin
															uSTATE <= 3'b000;
															CPUClock <= 1'b1;
														end	
												endcase		
											end									
		
							endcase
						 end
			default   : begin
							case(uSTATE)
							3'h0,
							3'h4 :  begin
										uSTATE <= uSTATE_PLUS_ONE;
										PCE_n <= 1'b0;
										OE_n <= 1'b0;
									end									
							3'h1,
							3'h5 :  begin
										uSTATE <= uSTATE_PLUS_ONE;
										CPUClock <= 1'b0;
									end									
							3'h2,
							3'h6 :  begin
										uSTATE <= uSTATE_PLUS_ONE;
									end									
							3'h3,
							3'h7 :  begin
										uSTATE <= 3'b000;
										PCE_n <= 1'b1;
										OE_n <= 1'b1;
										CPUClock <= 1'b1;
									end	
							endcase										
						end						
		endcase
		
	end
end										    


endmodule