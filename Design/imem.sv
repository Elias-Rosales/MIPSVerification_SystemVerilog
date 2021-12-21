module imem(
  input     [31:0]  addr,
  output    [31:0]  data);
  
  reg [31:0] rom[99:0];
  
  initial begin
    $readmemh("inst_memory.list",rom);
  end
  
  assign data = rom[addr];
endmodule
  