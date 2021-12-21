interface intrf(input logic clk,reset);
  
  logic	[31:0] 	Instr;
  logic [31:0]	ALUResult;
  logic [31:0]	ALUOut;
  logic [31:0]	WD3;
  logic [4:0]	A3;
  logic [3:0]	p_state;
  logic [31:0]  PC;
  logic	[31:0]	Next_PC;
  logic	[31:0]	B;
  logic			zero;
  logic			RegWrite;
  
  // Driver clocking block
  // Signals specified inside the clocking 
  // block will be sampled, driven with 
  // respect to the clock.
  clocking driver_cb @(posedge clk);
    // skew
    default input #100ps output #100ps;
    // PORTS
    output 	Instr;
	input	ALUResult;
    input	ALUOut;
    input	p_state;
    output	PC;			
    input	Next_PC;
    input	B;
    input	zero;
    input	WD3;
    input	A3;
    input	RegWrite;
  endclocking
  
  clocking monitor_cb @(posedge clk);
    // skew
    default input #100ps output #100ps;
    // PORTS
    input 	Instr;
	input	ALUResult;
    input	ALUOut;
    input	p_state;
    input   PC;
    input	Next_PC;
    input	B;
    input	zero;
    input	WD3;
    input	A3;
    input	RegWrite;
  endclocking
  
  //driver modport
  modport DRIVER  (clocking driver_cb,input clk,reset);
  
  //monitor modport  
  modport MONITOR (clocking monitor_cb,input clk,reset);
    
endinterface
    