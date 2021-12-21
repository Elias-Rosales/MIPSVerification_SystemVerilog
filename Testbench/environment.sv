`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

class environment;
  //Instances
  generator 	gen;
  driver    	driv;
  monitor		mon;
  scoreboard	scb;
  //mailbox
  mailbox 	gen2drive;
  mailbox	mon2scb;
  //event
  event gen_ended;
  //virtual interface
  virtual intrf vif;
  // Constructor
  function new(virtual intrf vif);
    this.vif	= vif;
    //mailbox
    gen2drive 	= new();
    mon2scb 	= new();
    //instances
    gen 	= new(gen2drive, gen_ended);
    driv	= new(vif, gen2drive);
    mon		= new(vif, mon2scb);
    scb		= new(mon2scb);
  endfunction
  
  //pretest
  task pre_test();
    driv.reset();
  endtask
  
  task test();
    fork 
      gen.main();
      driv.main();
      mon.main();
      scb.main();
    join_any
  endtask
  
  task post_test();
    wait(gen.count == driv.num_transactions);
  endtask
  
  task report();
    $display("\n--- SystemVerilog Summary ---\n");
    $display("** Report counts");
    $display("SV_TEST    : %d",scb.no_transactions);
    $display("SV_ERROR   : %d",scb.errors);
    $display("SV_WARNING : %d",scb.warning);
    $display("** Report instructions");
    $display("[R-TYPE] : %d",scb.c_rtype);
    $display("[JUMP]   : %d",scb.c_jump);
    $display("[BEQ]    : %d",scb.c_beq);
    $display("[ADDI]   : %d",scb.c_addi);
    $display("[LW]     : %d",scb.c_lw);
    $display("[SW]     : %d",scb.c_sw);
  endtask
  
  //run
  task run;
    $display("************************************************");
    pre_test();
    test();
    post_test();
    report();
    $display("************************************************");
    $finish;
  endtask
endclass