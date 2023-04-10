`timescale 1ns/1ns

module CPU_SFR_S(
			  DIR_RD_ADDRS,
			  DIR_WR_ADDRS,
			  WR_DATA,				   				
			  RD_DATA,				   				
			  DIRECT_WR,			   				
			  CPUClock,
			  WR_EN,
			  XCHG_INST,
			  MUL_INST,
			  DIV_INST,
			  INC_SP,
			  DEC_SP,
			  ACC,
			  PSW,
			  SP,
			  SP_PLUS_ONE,
			  DPH,
			  DPL,
			  B_REG,
			  RESET,
			  CY_ENABLE,
			  CY_IN,
			  OV_ENABLE,
			  OV_IN,
			  HC_ENABLE,
			  HC_IN,
			  STATE, 
			  B_IS_ZERO,
			  XCHG_ACC_IN,
			  RD_USR_SFR);

input   [7:0] DIR_RD_ADDRS;
input   [7:0] DIR_WR_ADDRS;
input   [7:0] WR_DATA;
output	[7:0] RD_DATA;
input		  DIRECT_WR;
input		  CPUClock;
input		  WR_EN;
input		  XCHG_INST;
input		  MUL_INST;
input		  DIV_INST;
input		  INC_SP;
input		  DEC_SP;
output  [7:0] ACC;
output  [7:0] PSW;
output  [7:0] SP;
output  [7:0] SP_PLUS_ONE;
output  [7:0] DPH;
output  [7:0] DPL;
output  [7:0] B_REG;
input		  RESET;
input		  CY_ENABLE;
input		  CY_IN;
input		  OV_ENABLE;
input		  OV_IN;
input		  HC_ENABLE;
input		  HC_IN;
input  [7:0]  STATE;
output		  B_IS_ZERO;
input  [7:0]  XCHG_ACC_IN;
output		  RD_USR_SFR;

parameter  	  ACC_ADDRS   = 8'hE0;
parameter	  B_ADDRS     = 8'hF0;
parameter	  PSW_ADDRS   = 8'hD0;
parameter	  SP_ADDRS    = 8'h81;
parameter	  DPL_ADDRS   = 8'h82;
parameter	  DPH_ADDRS   = 8'h83;


reg		[7:0] ACC;
reg		[7:0] B_REG;
reg		[7:1] PSWq;
reg		[7:0] SP;

reg           DPH_SEL;
reg           DPL_SEL;

reg		[7:0] RD_DATA;

reg			  RD_USR_SFR;

reg    [15:0] TEMP;
reg     [5:0] TEMP_QUOT;
reg     [7:0] TEMP_REM;
reg    [15:0] TEST1;
reg    [15:0] TEST2;



wire	[7:0] DPH;
wire	[7:0] DPL;

wire   [15:0] DPTR_PLUS_ONE;
wire   [11:0] SFR_SELECTS;			// these are the write selects for ACC
                                    // 这是行政协调会选择写
wire    [2:0] PSW_WR_SELECTS;
wire	[7:0] SP_ADDER;
wire   [15:0] PRODUCT;
wire	[7:0] REMAINDER;
wire	[7:0] QUOTIENT;
wire		  B_IS_ZERO;
wire		  SP_UPDATE;

wire          PSW0;
wire    [7:0] PSW;  

wire  [15:0]  SEL_MUL; 
wire  [15:0]  SHIFTER;

wire          RESULT_1; 
wire          RESULT_2;
wire  [7:0]   RTEMP1; 
wire  [7:0]   RTEMP2; 
wire  [7:0]   RTEMP3;
wire  [8:0]   STEMP1; 
wire  [8:0]   STEMP2;



assign SEL_MUL   = ACC *   (STATE[1] ? B_REG[7:6] 
                           : STATE[2] ? B_REG[5:4]
                           : STATE[3] ? B_REG[3:2]
                                      : B_REG[1:0]);


assign PRODUCT   = SEL_MUL + SHIFTER;
assign SHIFTER   = STATE[1] ? 16'h0 : {TEMP[13:0], 2'b00};



assign RTEMP3    = STATE[1] ? ACC : TEMP_REM;

assign STEMP1    = {1'b0, RTEMP2} - {1'b0, TEST1[7:0]};
assign STEMP2    = {1'b0, RTEMP3} - {1'b0, TEST2[7:0]};

assign RTEMP1    = RESULT_1 ? STEMP1[7:0] : RTEMP2[7:0];
assign RTEMP2    = RESULT_2 ? STEMP2[7:0] : RTEMP3[7:0];

assign RESULT_1  = |TEST1[15:8] ? 1'b0 : !STEMP1[8];
assign RESULT_2  = |TEST2[15:8] ? 1'b0 : !STEMP2[8];

assign QUOTIENT  = {TEMP_QUOT, RESULT_2, RESULT_1};
assign REMAINDER = RTEMP1;


assign SFR_SELECTS    = {DIR_WR_ADDRS, DIRECT_WR, WR_EN, MUL_INST, DIV_INST};
assign PSW_WR_SELECTS = {CY_ENABLE, HC_ENABLE, OV_ENABLE};

assign SP_ADDER    =  SP + (DEC_SP ? 8'hFF : 8'h01);
assign SP_PLUS_ONE =  SP_ADDER[7:0];
assign B_IS_ZERO   = ~|B_REG;

assign SP_UPDATE = INC_SP | DEC_SP;

assign PSW0 =  (^ACC[7:6] ^ ^ACC[5:4]) ^ (^ACC[3:2] ^ ^ACC[1:0]);
assign PSW  = {PSWq[7:1], PSW0};



always @(SFR_SELECTS or WR_DATA) begin
    casex(SFR_SELECTS)
        12'b1000_0010_1_1_0_0 : begin
                                     DPL_SEL = 1'b0;
                                     DPH_SEL = 1'b1; 
                                  end             
                                    
		12'b1000_0011_1_1_0_0 : begin
                                     DPL_SEL = 1'b1;
                                     DPH_SEL = 1'b0; 
                                  end   
                        default : begin
                                     DPL_SEL = 1'b1;
                                     DPH_SEL = 1'b1; 
                                  end
    endcase
end                                                   
                                    

always @(DIR_RD_ADDRS or ACC or B_REG or PSW or SP or DPL or DPH) begin
	casex (DIR_RD_ADDRS)
		ACC_ADDRS	: begin
						RD_USR_SFR = 1'b0;
						RD_DATA = ACC;	
					  end
		B_ADDRS   	: begin
						RD_USR_SFR = 1'b0;
						RD_DATA = B_REG;
					  end
		PSW_ADDRS 	: begin
						RD_USR_SFR = 1'b0;
						RD_DATA = PSW;
					  end
		SP_ADDRS  	: begin
						RD_USR_SFR = 1'b0;
						RD_DATA = SP;
					  end
		DPL_ADDRS 	: begin
						RD_USR_SFR = 1'b0;
						RD_DATA = DPL;
					  end
		DPH_ADDRS 	: begin
						RD_USR_SFR = 1'b0;
						RD_DATA = DPH;
					  end
		default		: begin
						RD_USR_SFR = 1'b1;
						RD_DATA = 8'bxx;
					  end
	endcase
end
	

always @(posedge CPUClock or posedge RESET) begin
	if (RESET) begin
		ACC      <= 8'h00;
		B_REG        <= 8'h00;
		SP       <= 8'h07;
	end
	else begin
		if (XCHG_INST) ACC <= XCHG_ACC_IN;
		else begin
			casex (SFR_SELECTS)
				12'b1000_0001_1_1_0_0 : SP      <= SP_UPDATE ? SP_ADDER : WR_DATA;
				default : begin
							if (SP_UPDATE) SP <= SP_ADDER;
						  end
			endcase	

			casex (SFR_SELECTS)
				12'bxxxx_xxxx_x_x_0_1 : begin
									   	if (STATE[4]) begin
									   		B_REG   <= REMAINDER;
									   		ACC <= QUOTIENT;
									   	end
									  end
				12'bxxxx_xxxx_x_x_1_0 : begin
									   	if (STATE[4]) begin
									   	    B_REG   <= PRODUCT[15:8];
									   	    ACC <= PRODUCT[7:0];
                                          end
									  end
				12'b1110_0000_1_1_0_0 : ACC       <= WR_DATA;
				12'b1111_0000_1_1_0_0 : B_REG     <= WR_DATA;
			endcase
		end
	end
end

always @(posedge CPUClock or posedge RESET) begin
	if (RESET) begin
		PSWq      <= 7'h00;
	end
	else begin
		if ((DIR_WR_ADDRS == 8'hD0) & DIRECT_WR & WR_EN) begin
			case (PSW_WR_SELECTS)
				3'b0_0_0 :  PSWq[7:1] <= WR_DATA[7:1];
				3'b0_0_1 :  PSWq[7:1] <= {WR_DATA[7:3], OV_IN, PSW[1]};
				3'b0_1_0 :  PSWq[7:1] <= {WR_DATA[7], HC_IN, WR_DATA[5:1]};
				3'b0_1_1 :  PSWq[7:1] <= {WR_DATA[7], HC_IN, WR_DATA[5:3], OV_IN, WR_DATA[1]};
				3'b1_0_0 :  PSWq[7:1] <= {CY_IN, WR_DATA[6:1]};
				3'b1_0_1 :  PSWq[7:1] <= {CY_IN, WR_DATA[6:3], OV_IN, WR_DATA[1]};
				3'b1_1_0 :  PSWq[7:1] <= {CY_IN, HC_IN, WR_DATA[5:1]};
				3'b1_1_1 :  PSWq[7:1] <= {CY_IN, HC_IN, WR_DATA[5:3], OV_IN, WR_DATA[1]};
			endcase
        end
        else begin
			casex (PSW_WR_SELECTS)       
				3'b0_0_1 :  PSWq[2] <= OV_IN;
				3'b0_1_0 :  PSWq[6] <= HC_IN;
				3'b0_1_1 :  {PSWq[6], PSWq[2]} <= {HC_IN, OV_IN};
				3'b1_0_0 :  PSWq[7] <= CY_IN;
				3'b1_0_1 :  {PSWq[7], PSWq[2]} <= {CY_IN, OV_IN};
				3'b1_1_0 :  PSWq[7:6] <= {CY_IN, HC_IN};
				3'b1_1_1 :  {PSWq[7:6], PSWq[2]} <= {CY_IN, HC_IN, OV_IN};
            endcase
        end
	end
end

// DIV

always @(STATE or B_REG) begin
    casex(STATE[4:1])
        4'b???1 : begin
                    TEST2 = {1'h0, B_REG, 7'b0000000};
                    TEST1 = {2'h0, B_REG, 6'b000000};
                  end

        4'b??1? : begin
                    TEST2 = {3'h0, B_REG, 5'b00000};
                    TEST1 = {4'h0, B_REG, 4'b0000};
                  end

        4'b?1?? : begin
                    TEST2 = {5'h00, B_REG, 3'b000};
                    TEST1 = {6'h00, B_REG, 2'b00};
                  end

        4'b1??? : begin
                    TEST2 = {7'h00, B_REG, 1'b0};
                    TEST1 = {8'h00, B_REG};
                  end
        default : begin
                    TEST2 = 16'hxx;
                    TEST1 = 16'hxx;
                  end
    endcase
end

always @(posedge CPUClock or posedge RESET) begin
    if (RESET) begin
        TEMP_QUOT <= 6'b000000;
        TEMP_REM  <= 8'h00;
    end 
    else begin
        TEMP_QUOT <= QUOTIENT[5:0];
        TEMP_REM  <= REMAINDER;
    end
end

// MULT

always @(posedge CPUClock or posedge RESET) begin
  if (RESET) TEMP <= 16'h0000;
  else  TEMP <=  PRODUCT;
end


reg [7:0] DPHq;
reg [7:0] DPLq;

assign DPH = DPHq;
assign DPL = DPLq;

always @(posedge CPUClock or posedge RESET) begin
	if (RESET) begin
		DPHq <= 8'h00;
		DPLq <= 8'h00;
	end
	else begin
		if (~DPH_SEL) DPHq <= WR_DATA;
		if (~DPL_SEL) DPLq <= WR_DATA;
	end
end



endmodule