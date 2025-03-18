`timescale 1ns / 1ps

module top_module_tb();
   reg clk = 0;
   reg newd = 0;
   reg  [7:0] din = 0;
   wire [7:0] dout ;
   
top_module dut(
    .clk(clk),
    .newd(newd),
    .din(din),
    .dout(dout)
);  
always #5 clk = ~clk;
  
initial begin
repeat (5) @ (posedge clk);  // here newd deassertion depend upon the sclk master
newd   = 1'b1;
din    = $urandom;
@(posedge dut.master.sclk);
newd   = 1'b0;
@(posedge dut.master.cs);
$stop;
end 
   
endmodule
