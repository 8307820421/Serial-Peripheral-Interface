`timescale 1ns / 1ps
module spi_slave_fsm(
input sclk,
input mosi,
input  ss,

output [7:0] dout,
output done
);

reg  done_reg  = 0;
reg [7:0] data   = 0;
integer   count  = 0;

localparam idle   = 0;
localparam sample = 1;
reg [1:0] state   = 0;


always @ (posedge sclk)
begin
   case(state)    
   idle : begin
    done_reg  <= 0;
    if (ss == 1'b0) // when move to sample state it should be zero as master send during tx data state 
    begin
       state <= sample;
    end
    else begin
       state <= idle;
    end
   end
   
 sample : begin
       if (count < 8)begin
           data  <= {data[6:0],mosi}; // here msb bit data of data [7] replaced with left shift mosi
           count <= count + 1;
           state <= sample;
         end
         
         else  if (count == 8)
         begin
            count <= 0;
            state <= idle;
            done_reg <= 1'b1;
         end
         
       end
       
       default : state = idle;
   endcase
end
    assign dout = data;
    assign done = done_reg;
endmodule
