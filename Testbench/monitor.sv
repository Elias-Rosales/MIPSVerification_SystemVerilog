`define MON_IF vif.MONITOR.monitor_cb

class monitor;
  
  //creating virtual interface handle
  virtual intrf vif;
  
  //creating mailbox handle
  mailbox mon2scb;
  
  //constructor
  function new(virtual intrf vif,mailbox mon2scb);
    //getting the interface
    this.vif = vif;
    //getting the mailbox handles from  environment 
    this.mon2scb = mon2scb;
  endfunction
  
  //Samples the interface signal and send the sample packet to scoreboard
  task main;
    forever begin
      transaction trans;
      trans = new();
      @(posedge vif.MONITOR.clk);
        trans.Instr 	= `MON_IF.Instr;
      	trans.ALUResult = `MON_IF.ALUResult;
        trans.ALUOut 	= `MON_IF.ALUOut;
        trans.p_state 	= `MON_IF.p_state;
        trans.PC 		= `MON_IF.PC;
      	trans.Next_PC	= `MON_IF.Next_PC;
        trans.B			= `MON_IF.B;
      	trans.zero		= `MON_IF.zero;
        trans.A3		= `MON_IF.A3;
      	trans.WD3		= `MON_IF.WD3;
      	trans.RegWrite	= `MON_IF.RegWrite;
        mon2scb.put(trans);
    end
  endtask
endclass