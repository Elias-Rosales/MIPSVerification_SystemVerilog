`include "environment.sv"

program test(intrf i_intrf);
  
  environment env;
  
  initial begin
    env = new(i_intrf);
    env.gen.count = 100;
    env.run();
  end
endprogram