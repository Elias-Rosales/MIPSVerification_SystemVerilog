`include "transaction.sv"

class generator;
  transaction trans, c_trans;
  int count;
  // MAILBOX
  mailbox gen2drive;
  // EVENT
  event ended;
  /* Constructor */
  function new(mailbox gen2drive, event ended);
    this.gen2drive = gen2drive;
    this.ended = ended;
    trans = new();
  endfunction
  
  /* Main Task */
  task main();
    $display("[%0t] ----- :: Executing GEN :: -----", $time);
    repeat(count) begin
      if( !trans.randomize() ) 
        $fatal("[%0t] GEN:: trans randomization failed", $time); 
      /*else begin
        $display("[%0t] GEN:: Put, size=%0d Inst: %h", $time, gen2drive.num(),trans.Instr);
      end*/
      c_trans = trans.do_copy();
      gen2drive.put(c_trans);
    end
    -> ended;
  endtask
endclass