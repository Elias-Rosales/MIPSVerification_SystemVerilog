class scoreboard;
  //creating mailbox handle
  mailbox mon2scb;
  //used to count the number of transactions
  int no_transactions;
  // counters
  int errors;
  int warning;
  int c_rtype;
  int c_jump;
  int c_beq;
  int c_addi;
  int c_lw;
  int c_sw;
  //reg data memory
  reg [31:0] ram[DMEMORY_WIDTH-1:0];
  //reg refile memory
  reg [31:0] rf[31:0];
  //temporal for data
  reg [31:0] temp;

  /* constructor */
  function new(mailbox mon2scb);
    //getting the mailbox handles from  environment 
    this.mon2scb = mon2scb;
    $readmemh("reg_memory.list", rf);
    $readmemh("data_memory.list",ram);
  endfunction

  /* Main Task*/
  task main;
    transaction trans;
    forever begin
        mon2scb.get(trans);
        case(trans.p_state)
        7: /* R-TYPE */
        begin
            c_rtype++;
            $display("------ :: [R-TYPE] INS = 0x%h :: ------",trans.Instr);
            case(trans.Instr[5:0]) //funct
                6'b100000: //ADD
                    if((rf[trans.Instr[25:21]] + rf[trans.Instr[20:16]]) == trans.ALUOut) begin
                        $display("---- [ADD] :: Result is as Expected :: ----");
                        $display("------------------------------------");
                    end
                    else begin
                        $error("---- [ADD] :: Wrong Result :: ----");
                        $display("[ADD] :: EXPECTED = %0h",(rf[trans.Instr[25:21]] + rf[trans.Instr[20:16]]));
                        $display("[ADD] :: ACTUAL = %0h",trans.ALUOut);
                        $display("------------------------------------");
                      	errors++;
                    end
                6'b100010:	//SUB
                    if((rf[trans.Instr[25:21]] - rf[trans.Instr[20:16]]) == trans.ALUOut) begin
                        $display("---- [SUB] :: Result is as Expected :: ----");
                        $display("------------------------------------");
                    end
                    else begin
                        $error("---- [SUB] :: Wrong Result :: ----");
                        $display("[SUB] :: EXPECTED = %0h",(rf[trans.Instr[25:21]] - rf[trans.Instr[20:16]]));
                        $display("[SUB] :: ACTUAL = %0h",trans.ALUOut);
                        $display("------------------------------------");
                      	errors++;
                    end
                6'b100100:	//AND
                    if((rf[trans.Instr[25:21]] & rf[trans.Instr[20:16]]) == trans.ALUOut) begin
                        $display("---- [AND] :: Result is as Expected :: ----");
                        $display("------------------------------------");
                    end
                    else begin
                        $error("---- [AND] :: Wrong Result :: ----");
                        $display("[AND] :: EXPECTED = %0h",(rf[trans.Instr[25:21]] & rf[trans.Instr[20:16]]));
                        $display("[AND] :: ACTUAL = %0h",trans.ALUOut);
                        $display("------------------------------------");
                      	errors++;
                    end
                6'b100101:	//OR
                    if((rf[trans.Instr[25:21]] | rf[trans.Instr[20:16]]) == trans.ALUOut) begin
                        $display("---- [OR] :: Result is as Expected :: ----");
                        $display("------------------------------------");
                    end
                    else begin
                        $error("---- [OR] :: Wrong Result :: ----");
                        $display("[OR] :: EXPECTED = %0h",(rf[trans.Instr[25:21]] | rf[trans.Instr[20:16]]));
                        $display("[OR] :: ACTUAL = %0h",trans.ALUOut);
                        $display("------------------------------------");
                      	errors++;
                    end
                6'b101010:	//SLT
                    begin
                        if(rf[trans.Instr[25:21]] < rf[trans.Instr[20:16]]) begin
                            if(trans.ALUOut == 32'b1) begin
                                $display("---- [SLT] :: Result is as Expected :: ----");
                                $display("------------------------------------");
                            end
                            else begin
                                $error("---- [SLT] :: Wrong Result :: ----");
                                $display("[SLT] :: EXPECTED = 32'b1");
                                $display("[SLT] :: ACTUAL = %0h",trans.ALUOut);
                                $display("------------------------------------");
                                errors++;
                            end
                        end
                        else begin
                            if(trans.ALUOut == 32'b0) begin
                                $display("---- [SLT] :: Result is as Expected :: ----");
                                $display("------------------------------------");
                            end
                            else begin
                                $error("---- [SLT] :: Wrong Result :: ----");
                                $display("[SLT] :: EXPECTED = 32'b0");
                                $display("[SLT] :: ACTUAL = %0h",trans.ALUOut);
                                $display("------------------------------------");
                                errors++;
                            end
                        end
                    end
                default:
                    $display("------ :: UNEXPECTED FUNCT [R-TYPE]:: ------");
            endcase // endcase for funct
        end
        11: /* JUMP */
        begin
            c_jump++;
            $display("------ :: [J] INS = 0x%h :: ------",trans.Instr);
            if(trans.Next_PC == {trans.PC[31:26],trans.Instr[25:0]}) begin
                $display("---- [J] :: Result is as Expected :: ----");
                $display("------------------------------------");
            end
            else begin
                $error("---- [J] :: Wrong Result :: ----");
                $display("[J] :: EXPECTED = %0h", {trans.PC[31:26],trans.Instr[25:0]});
                $display("[J] :: ACTUAL = %0h",trans.Next_PC);
                $display("------------------------------------");
                errors++;
            end
        end
        5: /* SW */
        begin
            c_sw++;
            $display("------ :: [SW] INS = 0x%h :: ------",trans.Instr);
            $readmemh("data_memory.list",ram);
            if(trans.ALUOut < 0 || trans.ALUOut > DMEMORY_WIDTH) begin
                $warning("---- Address out of range for [SW] function ----");
                $display("---- Function doesn't affect the memories. ----");
                $display("------------------------------------");
                warning++;
            end
            else begin
                if(ram[trans.ALUOut] == trans.B) begin
                    $display("---- [SW] :: Result is as Expected :: ----");
                    $display("------------------------------------");
                end
                else begin
                    $error("---- [SW] :: Wrong Result :: ----");
                    $display("[SW] :: EXPECTED = %0h",trans.B);
                    $display("[SW] :: ACTUAL = %0h",ram[trans.ALUOut]);
                    $display("------------------------------------");
                    errors++;
                end
            end
        end
        8: /* BEQ */
        begin
            c_beq++;
            $display("------ :: [BEQ] INS = 0x%h :: ------",trans.Instr);
            if((rf[trans.Instr[25:21]] - rf[trans.Instr[20:16]]) == 32'b0) begin
                if(trans.zero && trans.Next_PC == trans.ALUOut) begin
                    $display("---- [BEQ] :: Result is as Expected :: ----");
                    $display("------------------------------------");
                end
                else begin
                    $error("---- [BEQ] :: Wrong Result :: ----");
                    $display("[BEQ] :: EXPECTED [ZERO,ALUOut] = [1'b1,%0h]", trans.ALUOut);
                    $display("[BEQ] :: ACTUAL [ZERO,ALUOut] = [%0h,%0h]",trans.zero,trans.ALUOut);
                    $display("------------------------------------");
                    errors++;
                end
            end
            else begin
                if (!trans.zero) begin
                    $display("---- [BEQ] :: Result is as Expected :: NB ----");
                    $display("------------------------------------");
                end
                else begin
                    $error("---- [BEQ] :: Wrong Result :: ----");
                    $display("[BEQ] :: EXPECTED ZERO = 1'b0");
                    $display("[BEQ] :: ACTUAL ZERO = %0h",trans.zero);
                    $display("------------------------------------");
                    errors++;
                end
            end
        end
        10: /* ADDI */
        begin
            c_addi++;
            $display("------ :: [ADDI] INS = 0x%h :: ------",trans.Instr);
            if(rf[trans.Instr[25:21]] + {{16{trans.Instr[15]}},trans.Instr[15:0]} == trans.WD3) begin
                if (trans.Instr[20:16] == trans.A3) begin
                    $display("---- [ADDI] :: Result is as Expected :: ----");
                    $display("------------------------------------");
                end
                else begin
                    $error("---- [ADDI] :: Wrong Result :: ----");
                    $display("[ADDI] :: EXPECTED A3 = %0h",trans.Instr[20:16]);
                    $display("[ADDI] :: ACTUAL A3 = %0h",trans.A3);
                    $display("------------------------------------");
                    errors++;
                end
            end
            else begin
                $error("---- [ADDI] :: Wrong Result :: ----");
                $display("[ADDI] :: EXPECTED WD3  = %0h",rf[trans.Instr[25:21]] + {{16{trans.Instr[15]}},trans.Instr[15:0]});
                $display("[ADDI] :: ACTUAL WD3 = %0h",trans.WD3);
                $display("------------------------------------");
                errors++;
            end
        end
        4: /* LW */
        begin
            c_lw++;
            if((rf[trans.Instr[25:21]] + {{16{trans.Instr[15]}},trans.Instr[15:0]}) < 0 ||
              (rf[trans.Instr[25:21]] + {{16{trans.Instr[15]}},trans.Instr[15:0]}) > DMEMORY_WIDTH-1)
            begin
                temp = 32'h0;
                $warning("---- Address out of range for [LW] function ----");
                warning++;
            end
            else begin
                temp = ram[rf[trans.Instr[25:21]] + {{16{trans.Instr[15]}},trans.Instr[15:0]}];
            end
            $display("------ :: [LW] INS = %h :: ------",trans.Instr);
            if (trans.RegWrite) begin
                ram[trans.A3] = trans.WD3;
                if(temp==trans.WD3) begin
                    $display("---- [LW] :: Result is as Expected :: ----");
                    $display("------------------------------------");
                end
                else begin
                    $error("---- [LW] :: Wrong Result :: ----");
                    $display("[LW] :: EXPECTED data = %0h",temp);
                    $display("[LW] :: ACTUAL data = %0h",trans.WD3);
                    $display("------------------------------------");
                    errors++;
                end
            end
            else begin
                $error("---- [LW] :: Wrong Result :: ----");
                $display("[LW] :: EXPECTED RegWrite = 1'b1");
                $display("[LW] :: ACTUAL RegWrite = %0h",trans.RegWrite);
                $display("------------------------------------");
                errors++;
            end
        end
        default:
            continue; 
        endcase // end case for trans.p_state
      	$readmemh("reg_memory.list", rf);
      	$readmemh("data_memory.list",ram);
        no_transactions++;
    end
  endtask
endclass