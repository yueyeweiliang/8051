//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 program counter                                        ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   program counter                                            ////
////                                                              ////
////  To Do:                                                      ////
////   nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Teran, simont@opencores.org                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// ver: 1
//

module pc (rst, clk, pc_out, alu, pc_wr_sel, op1, op2, op3, wr, rd, int);

// rst          reset
// clk          clock
// pc_out       output, connected to rom_addr_sel1, it's current rom addres
// alu          input from alu, used in case of jumps (next addres is calculated in alu and written to pc)
// pc_wr_sel    input indicates whitch input will be written to pc in case of writting
// op1          instruction (byte 1) used to calculate next addres
// op2          instruction (byte 2) used in jumps
// op3          instruction (byte 3) used in jumps
// wr           write (active high)
// write_x      output//**
// rd           read: if high calculate next addres else hold current
// int          interrupt (if high don't change outputs -- write to stack)


input [1:0] pc_wr_sel;
input [15:0] alu;
//input [2:0] op1;
input [7:0] op1, op2, op3;

input rst, clk, int, wr, rd;
output pc_out;

reg [15:0] pc_out;

//
//pc            program counter register, save current value
reg [15:0] pc;

//
// wr_lo        write low: used in reti instruction, write only low byte of pc
// ini_buff     interrupt buffer: used to prevent interrupting in the middle of executin instructions
reg wr_lo, int_buff;

always @(pc or op1 or rst or rd)
begin
  if (rst) begin
//
// in cae of reset read value from buffer
    pc_out= pc;
  end else begin
    if (int_buff)
//
//in case of interrupt hold valut, to be written to stack
       pc_out= pc;
    else if (rd) begin
//
// normal execution calculate next value and send it immediate to outputs
        casex (op1)
              `ACALL : pc_out= pc+2;
              `AJMP : pc_out= pc+2;

        //op_code [7:3]
              `CJNE_R : pc_out= pc+3;
              `DJNZ_R : pc_out= pc+2;
              `MOV_DR : pc_out= pc+2;
              `MOV_CR : pc_out= pc+2;
              `MOV_RD : pc_out= pc+2;

        //op_code [7:1]
              `CJNE_I : pc_out= pc+3;
              `MOV_ID : pc_out= pc+2;
              `MOV_DI : pc_out= pc+2;
              `MOV_CI : pc_out= pc+2;

        //op_code [7:0]
              `ADD_D : pc_out= pc+2;
              `ADD_C : pc_out= pc+2;
              `ADDC_D : pc_out= pc+2;
              `ADDC_C : pc_out= pc+2;
              `ANL_D : pc_out= pc+2;
              `ANL_C : pc_out= pc+2;
              `ANL_DD : pc_out= pc+2;
              `ANL_DC : pc_out= pc+3;
              `ANL_B : pc_out= pc+2;
              `ANL_NB : pc_out= pc+2;
              `CJNE_D : pc_out= pc+3;
              `CJNE_C : pc_out= pc+3;
              `CLR_B : pc_out= pc+2;
              `CPL_B : pc_out= pc+2;
              `DEC_D : pc_out= pc+2;
              `DJNZ_D : pc_out= pc+3;
              `INC_D : pc_out= pc+2;
              `JB : pc_out= pc+3;
              `JBC : pc_out= pc+3;
              `JC : pc_out= pc+2;
              `JNB : pc_out= pc+3;
              `JNC : pc_out= pc+2;
              `JNZ : pc_out= pc+2;
              `JZ : pc_out= pc+2;
              `LCALL :pc_out= pc+3;
              `LJMP : pc_out= pc+3;
              `MOV_D : pc_out= pc+2;
              `MOV_C : pc_out= pc+2;
              `MOV_DA : pc_out= pc+2;
              `MOV_DD : pc_out= pc+2;
              `MOV_CD : pc_out= pc+3;
              `MOV_BC : pc_out= pc+2;
              `MOV_CB : pc_out= pc+2;
              `MOV_DP : pc_out= pc+3;
              `ORL_D : pc_out= pc+2;
              `ORL_C : pc_out= pc+2;
              `ORL_AD : pc_out= pc+2;
              `ORL_CD : pc_out= pc+3;
              `ORL_B : pc_out= pc+2;
              `ORL_NB : pc_out= pc+2;
              `POP : pc_out= pc+2;
              `PUSH : pc_out= pc+2;
              `SETB_B : pc_out= pc+2;
              `SJMP : pc_out= pc+2;
              `SUBB_D : pc_out= pc+2;
              `SUBB_C : pc_out= pc+2;
              `XCH_D : pc_out= pc+2;
              `XRL_D : pc_out= pc+2;
              `XRL_C : pc_out= pc+2;
              `XRL_AD : pc_out= pc+2;
              `XRL_CD : pc_out= pc+3;
              default: pc_out= pc+1;
            endcase
//
//in case of instructions that use more than one clock hold current pc
       end else pc_out= pc;
  end
end


//
//case of reading program counter from stack
always @(posedge clk)
  if (wr_lo) wr_lo <= #1 1'b0;

//
//interrupt buffer
always @(posedge clk)
  int_buff <= #1 int;

always @(posedge clk)
begin
  if (rst)
    pc <= #1 `RST_PC;
  else if (wr_lo)
    pc[7:0] <= #1 alu[15:8];
  else begin
    if (wr) begin
//
//case of writing new value to pc (jupms)
      case (pc_wr_sel)
        `PIS_SP: begin
          pc[15:8] <= #1 alu[15:8];
          wr_lo <= #1 1'b1;
        end
        `PIS_ALU: pc <= #1 alu;
        `PIS_I11: pc[10:0] <= #1 {op1[7:5], op2};
        `PIS_I16: pc <= #1 {op2, op3};
      endcase
    end else
//
//or just remember current
      pc <= #1 pc_out;
  end
end

endmodule

