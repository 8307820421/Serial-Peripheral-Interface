`timescale 1ns / 1ps


module dasiy_chain_master(
input clk,
input sdi, // act as miso (master input from slave output) // maaster pin 
input newd,  // global
input [7:0] din, // global
output reg sdo, // act as (mosi (master output to sdi slave input)) master pin
output reg cs, //  master cs
output sclk,   // master sclk
output [7:0] dout // to see the output final coming from din  (global)
 );
 
reg [7:0] dout_o =  0;
/*-------------------------------------------------------logic for sclk gen---------------------------------------------------------------------------*/
reg [1:0] scount = 0;
reg sclk_t = 0;

always @(posedge clk)
begin
   if (scount <3 )
   begin
      scount <= scount + 1;
   end
   else begin
     scount <= 0;
     sclk_t <= ~sclk_t;
   end
end
/*-------------------------------------------------------send data-------------------------------------------------------------------------------*/
/*
   ---> first sample the data(as coming)
   ---> second send the data
   ---> wait for specific clock pulse for new data then move to sample;
  
   sample--->send--->wait
*/

reg [7:0] data_in = 0;
reg [3:0] count   = 0; // to sample and send data

localparam sample = 0;
localparam send   = 1;
localparam wait_t = 2;

reg [1:0] state  = sample;
reg [7:0] din_t  = 0;

always @ (posedge sclk)
begin
   case (state)
   sample : begin
          if (newd == 1'b1)
          begin
             din_t  <= din;
             state <= send ;
             count <= 1;  
             cs    <= 1'b0;
             sdo   <= din[0];
          end
          else begin
            state <= sample;
            cs    <= 1'b1;
          end
   end
   
   send : begin
        if (count <= 7)
        begin
           sdo <= din_t [count];
           count <= count + 1;
        end
        else begin
          count <= 0;
          state <= wait_t ;
          cs    <= 1'b0;
        end
   end
   
   wait_t : begin
         if (count <= 7)
         begin
            count <= count + 1;
         end
         else begin
            count <= 0;
            state <= sample;
            cs    <= 1'b1;
         end
       end
   endcase
end

/*-----------------------------------------------fsm for receving data(collect) serially----------------------------------------------------------*/
/*
  --> Here the tx fsm of spi master (daisy chain transmitting the data parallely) as input
  --> then store the output as serially at reception side in master
  idle -->wait--->collect
*/
localparam  idle_o    = 0;
localparam   wait_o   = 1;
localparam  collect_o = 2;
reg [3:0] count_o = 0;
reg [1:0] state_o = idle_o;

//reg [7:0] dout_o =  0;

always @(posedge sclk)
begin
     case (state_o)
       idle_o : begin
          if(newd == 1'b1)
          begin
            state_o <= wait_o;
          end
          else begin
           state_o  <= idle_o;
          end
      end
      wait_o :begin
         if (count_o <= 7)
         begin
            count_o <= count_o+1;
            state_o <= wait_o;
         end
         else begin
           state_o <= collect_o;
           count_o <= 0;
         end
      end
      
      collect_o : begin
            if(count_o <= 7)
            begin
              dout_o [count_o] <= sdi;
              count_o <= count_o + 1;
              state_o  <= collect_o;
            end
            else begin
              count_o <= 0;
              state_o <= idle_o;
            end
      end
      
      default:;
    endcase
end

assign sclk = sclk_t;
assign dout = ((count==8) && state == wait_t)?dout_o : 8'h00;

endmodule
/*-----------------------------------------------------------------------------------------------------------------------------------------*/

