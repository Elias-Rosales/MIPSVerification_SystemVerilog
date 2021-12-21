`timescale 1ns/100ps
`include "interface.sv"
`include "test.sv"

module mips_vf_tb();
  reg clk,reset;
  
  intrf intf(clk,reset);
  test 	t1(intf);
  
  mips_vf 	DUT(.clk(intf.clk),
                .reset(intf.reset),
                .Instr(intf.Instr),
                .ALUResult(intf.ALUResult),
                .ALUOut(intf.ALUOut), 
                .p_state(intf.p_state),
                .Next_PC(intf.Next_PC),
                .B(intf.B),
                .zero(intf.zero),
                .PC(intf.PC),
                .A3(intf.A3),
                .RegWrite(intf.RegWrite),
                .WD3(intf.WD3));
  
  //clock generation
  always #5 clk = ~clk;
  
  //reset Generation
  initial begin
    clk = 1;
    reset = 1; #5;
    reset =0;
  end
  
  //enabling the wave dump
  initial begin 
    $dumpfile("dump.vcd"); 
    $dumpvars();
  end
endmodule