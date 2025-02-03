`timescale 1ns / 1ps

module top_module_spi(
   input clk,rst,tx_en,
   output [7:0] dout,
   output done
    );
    
 //nets//  
wire sclk, ss, mosi;
spi_fsm dut_m (clk,rst,tx_en, mosi,ss,sclk); // sequence matters how you decalre in your master mode
spi_slave_fsm dut_s(sclk,mosi,ss,dout,done); // slave sequence also matters

endmodule

/*
  first decalre the input then declare the output.
  the slave input will be the master output 
  the slave output will be their own output register
  Be carefully  instantiate your module during decalring the registers with in sequence.
  Nets you can declare in any sequence but you eed to clear or make them perfect with
  your master and slave with proper sequence.
*/