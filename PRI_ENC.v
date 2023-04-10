module PRI_ENC8 (
				 INT_SRC, 
				 INT_ENABL, 
				 INT_PRIORITY,
				 VECTOR, 
				 CPUClock, 
				 RESET, 
				 RTI, 
				 IACK, 
				 INT_REQ, 
				 IACK_EXT0,
				 IACK_TIMR0,
				 IACK_EXT1,
				 IACK_TIMR1,
				 IN_SERVICE);

input [7:0] 	INT_SRC;  		// interrupt request inputs 1 = highest priority
                                // 中断请求输入1 =最高优先级
input [7:0] 	INT_ENABL;
input [7:0]	  	INT_PRIORITY;
output [2:0] 	VECTOR;		    // encoded interrupt output 编码的中断输出
input			CPUClock;
input			RESET;
input			RTI;
input			IACK;
output			INT_REQ;
output			IACK_EXT0;
output			IACK_TIMR0;
output			IACK_EXT1;
output			IACK_TIMR1;
output			IN_SERVICE;

reg [2:0] 	VECTOR;
reg [2:0]   VECTORq;

reg     	IN_SERVIC_H;
reg     	IN_SERVIC_L;

reg			INT_REQ_H;
reg			INT_REQ_L;

wire		INT_REQ;

wire		IACK_EXT0;
wire		IACK_TIMR0;
wire		IACK_EXT1;
wire		IACK_TIMR1;
wire		IN_SERVICE;


assign		IACK_EXT0  = IACK & (VECTORq == 3'b000);
assign		IACK_TIMR0 = IACK & (VECTORq == 3'b001);
assign		IACK_EXT1  = IACK & (VECTORq == 3'b010);
assign		IACK_TIMR1 = IACK & (VECTORq == 3'b011);

assign 		INT_REQ = INT_REQ_H | INT_REQ_L;
assign		IN_SERVICE =  IN_SERVIC_H | IN_SERVIC_L;

reg INT_REQ_Hq;
always @(posedge CPUClock or posedge RESET) begin
	if (RESET) begin
		IN_SERVIC_H <= 1'b0;
		IN_SERVIC_L <= 1'b0;
		VECTORq <= 3'b000;
		INT_REQ_Hq <= 1'b0;
	end	
	else begin
		INT_REQ_Hq <= INT_REQ_H;
		VECTORq <= VECTOR;
		if (IACK) begin
			if (INT_REQ_Hq) IN_SERVIC_H <= 1'b1;
			else IN_SERVIC_L <= 1'b1;
		end
		else if (RTI) begin
			if  (IN_SERVIC_H) IN_SERVIC_H <= 1'b0;
			else IN_SERVIC_L <= 1'b0;
		end
	end
end


always @(INT_ENABL or INT_SRC or IN_SERVIC_H or IN_SERVIC_L or INT_PRIORITY or RTI or IACK) begin
	if (INT_ENABL[7] & ~RTI & ~IACK & ~IN_SERVIC_H) begin						    
		if      (INT_SRC[0] & INT_ENABL[0] & INT_PRIORITY[0]) begin
												VECTOR = 3'b000;	// EXT0 
												INT_REQ_H = 1'b1;
												INT_REQ_L = 1'b0;
										end
		else if (INT_SRC[1] & INT_ENABL[1] & INT_PRIORITY[1]) begin
												VECTOR = 3'b001;
												INT_REQ_H =  1'b1;
												INT_REQ_L = 1'b0;
											end

		else if (INT_SRC[2] & INT_ENABL[2] & INT_PRIORITY[2]) begin
												VECTOR = 3'b010;
												INT_REQ_H = 1'b1;
												INT_REQ_L = 1'b0;
											end

		else if (INT_SRC[3] & INT_ENABL[3] & INT_PRIORITY[3]) begin
												VECTOR = 3'b011;
												INT_REQ_H = 1'b1;
												INT_REQ_L = 1'b0;
											end
		else if (INT_SRC[4] & INT_ENABL[4] & INT_PRIORITY[4]) begin
												VECTOR = 3'b100;
												INT_REQ_H = 1'b1;
												INT_REQ_L = 1'b0;
											end
		else if (INT_SRC[5] & INT_ENABL[5] & INT_PRIORITY[5]) begin
												VECTOR = 3'b101;
												INT_REQ_H = 1'b1;
												INT_REQ_L = 1'b0;
											end
		else if (INT_SRC[6] & INT_ENABL[6] & INT_PRIORITY[6]) begin
												VECTOR = 3'b110;
												INT_REQ_H = 1'b1;
												INT_REQ_L = 1'b0;
											end
		else if (INT_SRC[0] & INT_ENABL[0] & ~IN_SERVIC_L) begin
												VECTOR = 3'b000;	// EXT0 
												INT_REQ_H = 1'b0;
												INT_REQ_L = 1'b1;
											end
		else if (INT_SRC[1] & INT_ENABL[1] & ~IN_SERVIC_L) begin
												VECTOR = 3'b001;
												INT_REQ_H = 1'b0;
												INT_REQ_L = 1'b1;
											end
		else if (INT_SRC[2] & INT_ENABL[2] & ~IN_SERVIC_L) begin
												VECTOR = 3'b010;
												INT_REQ_H = 1'b0;
												INT_REQ_L = 1'b1;
											end
		else if (INT_SRC[3] & INT_ENABL[3] & ~IN_SERVIC_L) begin
												VECTOR = 3'b011;
												INT_REQ_H = 1'b0;
												INT_REQ_L = 1'b1;
											end
		else if (INT_SRC[4] & INT_ENABL[4] & ~IN_SERVIC_L) begin
												VECTOR = 3'b100;
												INT_REQ_H = 1'b0;
												INT_REQ_L = 1'b1;
											end
		else if (INT_SRC[5] & INT_ENABL[5] & ~IN_SERVIC_L) begin
												VECTOR = 3'b101;
												INT_REQ_H = 1'b0;
												INT_REQ_L = 1'b1;
											end
		else if (INT_SRC[6] & INT_ENABL[6] & ~IN_SERVIC_L) begin
												VECTOR = 3'b110;
												INT_REQ_H = 1'b0;
												INT_REQ_L = 1'b1;
											end
		else begin 
				VECTOR = 3'b000;
				INT_REQ_H = 1'b0;
				INT_REQ_L = 1'b0;
			 end
	end
	else begin
		VECTOR = 3'b000;
		INT_REQ_H = 1'b0;
		INT_REQ_L = 1'b0;
	end
end

endmodule // PRI_ENC8
