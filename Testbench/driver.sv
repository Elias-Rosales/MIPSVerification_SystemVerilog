/*NOTES:
 *R-Type : and $v0, $t0, $t1  32'h01091024
 */

`define DRIVER_INTF vif.DRIVER.driver_cb

class driver;
  
  int num_transactions;
  
  virtual intrf vif;
  
  mailbox gen2drive;
  
  /* Constructor */
  function new(virtual intrf vif, mailbox gen2drive);
    this.vif = vif;
    this.gen2drive = gen2drive;
  endfunction
  
  /* Task Reset */
  task reset;
    wait (vif.reset);
    $display("[%0t] ----- [DRIVER] Reset Started -----", $time);
    `DRIVER_INTF.PC <= 32'h20;
    `DRIVER_INTF.Instr <= 32'h08000020;   
    $info("Reset Values PC: 0x%h INSTRUCTION: 0x%h",32'h20,32'h08000020);
    wait(!vif.reset);
    $display("[%0t] ----- [DRIVER] Reset Ended   -----", $time);
  endtask
  
  task drive;
    transaction trans =new();
    @(posedge vif.DRIVER.clk);
    if (vif.p_state == 0) begin
      gen2drive.get(trans);
      //$display("[%0t] :: [DRIVER-TRANSFER: %0d] :: -----",$time,num_transactions);
      `DRIVER_INTF.Instr <= trans.Instr;
      //$display("-----------------------------------------");
      num_transactions++;
    end
  endtask
  
  task main;
    forever begin
      fork
        //Thread-1: Waiting for reset
        begin
          wait(vif.reset);
        end
        //Thread-2: Calling drive task
        begin
          forever begin
              drive();
            end
        end
      join_any
      disable fork;
    end
  endtask
endclass