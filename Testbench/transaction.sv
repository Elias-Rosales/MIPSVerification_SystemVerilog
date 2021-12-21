class transaction;
  rand bit			clk;
  rand bit			reset;
  rand bit	[31:0] 	Instr;
  bit		[4:0]	A3;
  bit		[31:0]	WD3;
  bit		[31:0]	ALUResult;
  bit		[31:0]	ALUOut;
  bit  		[3:0]	p_state;
  bit   	[31:0]  PC;
  bit		[31:0]	Next_PC;
  bit		[31:0]	B;
  bit				zero;
  bit				RegWrite;
  
  typedef enum {R, J, beq, addi, sw, lw} opcode; 
  
  typedef enum {add = 32, sub = 34, and_ = 36, or_ = 37, slt =42} funct;

  randc opcode op;
  randc funct fn;
  
  constraint op_values {
    (op == lw) -> Instr[31:26] == 35;
    (op == lw) -> Instr[25:21] inside {[8:25]};    //reg 8-25
    (op == lw) -> Instr[20:16] inside {[8:25]};    //reg 8-25
    (op == lw) -> Instr[15:0]  inside {[0:10],[16'hfff0:16'hffff]};	
    
    (op == sw) -> Instr[31:26] == 43;
    (op == sw) -> Instr[25:21] inside {[8:25]};    //reg 8-25
    (op == sw) -> Instr[20:16] inside {[8:25]};    //reg 8-25
    (op == sw) -> Instr[15:0]  inside {[0:10],[16'hfff0:16'hffff]};
    
    (op == beq) -> Instr[31:26] == 4;
    (op == beq) -> Instr[25:21] inside {[8:25]};   //reg 8-25
    (op == beq) -> Instr[20:16] inside {[8:25]};   //reg 8-25
    (op == beq) -> Instr[15:0]  inside {[0:10],[16'hfff0:16'hffff]};
    
    (op == addi) -> Instr[31:26] == 8;
    (op == addi) -> Instr[25:21] inside {[8:25]};   //reg 8-25
    (op == addi) -> Instr[20:16] inside {[8:25]};   //reg 8-25
    (op == addi) -> Instr[15:0]  inside {[0:32],[16'hffe0:16'hffff]}; //Values from -32 to 32 
    
    (op == J) -> Instr[31:26] == 2;					//j
    (op == J) -> Instr[25:0]  inside{[0:99]};		//addr range[0:99]
    
    (op == R) -> Instr[31:26] == 0;
    (op == R) -> Instr[25:21] inside {[8:25]};     //reg 8-25
    (op == R) -> Instr[20:16] inside {[8:25]};     //reg 8-25
    (op == R) -> Instr[15:11] inside {[8:25]};     //reg 8-25 
    (op == R) -> Instr[10:6]  == 0;                //shamt
    (op == R) -> Instr[5:0]   == fn;               //add,sub,and,or,slt
  }
  
  /*function void post_randomize();
    if (Instr[31:26] == 2) begin
      	$display("---- [%0t] :: [J] :: INST = %h ----",$time,Instr);
        $display("[J] :: addr = %d",Instr[25:0]);
    end
    else if (Instr[31:26] == 0) begin
      	$display("---- [%0t] :: [R] :: INST = %h ----",$time,Instr);
        $display("[R] :: rs = %d",Instr[25:21]);
        $display("[R] :: rt = %d",Instr[20:16]);
        $display("[R] :: rd = %d",Instr[15:11]);
        $display("[R] :: sh = %d",Instr[10:6]);
        $display("[R] :: fc = %d",Instr[5:0]);
    end
    else if (Instr[31:26] == 35) begin
      	$display("---- [%0t] :: [LW] :: INST = %h ----",$time,Instr);
        $display("[LW] :: rs = %d",Instr[25:21]);
        $display("[LW] :: rt = %d",Instr[20:16]);
        $display("[LW] :: IM = %d",Instr[15:0]);
    end
    else if (Instr[31:26] == 43) begin
      	$display("---- [%0t] :: [SW] :: INST = %h ----",$time,Instr);
        $display("[SW] :: rs = %d",Instr[25:21]);
        $display("[SW] :: rt = %d",Instr[20:16]);
        $display("[SW] :: IM = %d",Instr[15:0]);
    end
    else if (Instr[31:26] == 4) begin
      	$display("---- [%0t] :: [BEQ] :: INST = %h ----",$time,Instr);
        $display("[BEQ] :: rs = %d",Instr[25:21]);
        $display("[BEQ] :: rt = %d",Instr[20:16]);
        $display("[BEQ] :: IM = %d",Instr[15:0]);
    end
    else if (Instr[31:26] == 8) begin
      	$display("---- [%0t] :: [ADDI] :: INST = %h ----",$time,Instr);
        $display("[ADDI] :: rs = %d",Instr[25:21]);
        $display("[ADDI] :: rt = %d",Instr[20:16]);
        $display("[ADDI] :: IM = %d",Instr[15:0]);
    end
    $display("-----------------------------------");
  endfunction*/
  
  //deep copy method
  function transaction do_copy();
    transaction trans;
    trans = new();
  	trans.clk 		= this.clk;
  	trans.reset 	= this.reset;
  	trans.Instr 	= this.Instr;
  	trans.ALUResult = this.ALUResult;
    trans.ALUOut 	= this.ALUOut;
  	trans.p_state 	= this.p_state;
  	trans.PC		= this.PC;
    trans.Next_PC	= this.Next_PC;
    trans.B			= this.B;
    trans.zero		= this.zero;
    trans.A3		= this.A3;
    trans.WD3		= this.WD3;
    trans.RegWrite	= this.RegWrite;
    return trans;
  endfunction
endclass


