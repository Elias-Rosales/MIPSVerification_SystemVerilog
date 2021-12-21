//`include "imem.sv"
`include "regfile.sv"
`include "signextend.sv"
`include "alu.sv"
`include "dmem.sv"
`include "mux2.sv"
`include "control_unit.sv"
`include "mux4.sv"
`include "register.sv"
`include "mux2_5bits.sv"

module mips_vf(
  input             clk, 
  input 			reset,
  input  	[31:0] 	Instr,
  output	[4:0]	A3,
  output	[31:0]	WD3,
  output	[31:0]  ALUResult,
  output	[31:0]  ALUOut,
  output    [3:0]	p_state,
  output	[31:0]	Next_PC,
  output			zero,
  output			RegWrite,
  output	[31:0]	B,
  output    [31:0]  PC);
  
  /* PC Register */
  wire        PCEn;
  
  /* Instructor memory */
  wire [31:0] InstrReg;
  wire        IRWrite;
  
  /*Register memory, Sign Extend and JTA */
  wire [4:0]  A1;
  wire [4:0]  A2;
  wire [4:0]  Mux15_11;
  wire [5:0]  Op, Funct;
  wire [15:0] Imm;
  wire [25:0] JTA;
  wire [31:0] RD1,RD2,SignImm;
  
  /* Control Unit */
  wire        RegDst;
  wire		  MemtoReg;
  wire		  MemWrite;
  wire		  ALUSrcA;
  wire [1:0]  ALUSrcB, PCSrc;
  wire [2:0]  ALUControl;
  
  /* ALU and ALUReg */
  wire [31:0] A;
  wire [31:0] ReadData;
  wire [31:0] SrcA;
  wire [31:0] SrcB;
  wire [31:0] PCJump;
  
  /* Instruction partition */
  assign A1 		= InstrReg[25:21];
  assign A2 		= InstrReg[20:16];
  assign Mux15_11 	= InstrReg[15:11];
  assign Imm 		= InstrReg[15:0];
  assign JTA 		= InstrReg[25:0];
  assign Op 		= InstrReg[31:26];
  assign Funct 		= InstrReg[5:0];
  assign PCJump 	= {PC[31:26],JTA};
  
  //===================================================================
  // MODULES
  //===================================================================
  /* Control Unit */
  control_unit		CU(clk,reset,zero,Funct,Op,IRWrite,RegDst,MemtoReg,RegWrite,
                       ALUSrcA,MemWrite,PCEn,ALUSrcB,PCSrc,ALUControl,p_state);
  /* PC */
  register			R1(clk,reset,PCEn,Next_PC,PC);
  /* Instruction Memory */
  //imem				IM(PC,Instr);
  register			R2(clk,reset,IRWrite,Instr,InstrReg);
  /* Muxes before RegMem */
  mux2_5bits		M1(A2,Mux15_11,RegDst,A3);
  mux2				M2(ALUOut,ReadData,MemtoReg,WD3);
  /* Register Memory */
  regfile			RM(clk,RegWrite,reset,A1,A2,A3,WD3,RD1,RD2);
  register			R3(clk,reset,1'b1,RD1,A);
  register			R4(clk,reset,1'b1,RD2,B);
  /* Sign Extend */
  signextend		SE(Imm,SignImm);
  /* Muxes before ALU */
  mux2				M3(PC,A,ALUSrcA,SrcA);
  mux4				M4(B,32'b1,SignImm,SignImm,ALUSrcB,SrcB);
  /* ALU */
  alu				ALU(SrcA,SrcB,ALUControl,zero,ALUResult);
  register			R5(clk,reset,1'b1,ALUResult,ALUOut);
  /* Data Mem */
  dmem				DM(clk,reset,MemWrite,ALUOut,B,ReadData);
  mux4				M5(ALUResult,ALUOut,PCJump,32'bX,PCSrc,Next_PC);
  
endmodule