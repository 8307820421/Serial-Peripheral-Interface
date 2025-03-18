/*
   ----> In slave we are working with single slave as there are 8 clock cycle required to recept the data from the master
         hence it will wait for the 8 clock pulse to took the data from sdi to data_in via right shift by lsb bit.
   -----> After this , in collect state it will collect the output that will refelceted in sdo with respect to count and sdo.
   
   ----> Once the data taken via master now its output will send back to master output (sdo). Hence there are twwo fsm used.
*/
`timescale 1ns / 1ps
module daisy_chain_slave(
  input sclk,
  input sdi,
  input cs,
  output reg sdo // for second slave it will act as input
    );
    
/// -----------------------------------------------receive data serially from the master at slave side----------------------------///

reg [7:0] data_in = 0;
reg [3:0] count   = 0;
reg newd          = 0;
reg [7:0] dout_t  = 0;

localparam idle = 0;
localparam collect = 1;

reg [1:0]state = idle ;
/*------------------------------------fsm to collect data bits-------------------------------------------------------------------------------------------------------*/
always @ (negedge sclk)
begin
  case (state)
/*-------------------------------------------------------------------------------------------------------------------------------------------*/
    idle : begin
          newd<= 1'b0;
          if (cs == 1'b0)
          begin
            data_in[7:0] <= {sdi,data_in[7:1]};
            count        <= 1;
            state        <= collect;
          end
          else begin
           state         <= idle;
          end
    end
/*-------------------------------------------------------------------------------------------------------------------------------------------*/
   collect  : begin
         if (count <= 7)
         begin
            data_in[7:0] <= {sdi,data_in[7:1]};
            state        <= collect;
            count        <= count + 1;
         end
         else begin
           state        <= idle;
           count        <= 0;
           newd         <= 1'b1;
           dout_t       <= data_in;
         end
   end 
/*-------------------------------------------------------------------------------------------------------------------------------------------*/
   default : state <= idle;
  endcase
end

/*----------------------------------fsm for send data serially  as input for master-----------------------------------------------------------*/
localparam  idle_o  = 0;
localparam  send_o  = 1;
reg [1:0] state_o   = idle;

reg [3:0] count_o = 0;

always @ (negedge sclk)
begin
  case(state_o)
/*-------------------------------------------------------------------------------------------------------------------------------------------*/
    idle : begin
       if (newd == 1'b1 && cs == 1'b0)
       begin
          state_o    <= send_o;
          count_o    <= 1;   /// this taken 1 so that when count 0 then cs high when cs high then no transmission or send.
          sdo        <= dout_t[0]; // every time right shift occured through the lsb[0] location as array
       end
       
       else begin
         state_o     <= idle_o;
       end
    end
/*----------------------------------------------finally sending the data---------------------------------------------------------------------------------------------*/
   send_o : begin
         if (count_o <= 7)
         begin
            sdo <= dout_t [count_o];
            count_o <= count_o + 1;
            state_o <= send_o;
         end
         
         else begin
             count_o <= 0;
            state_o <= idle_o;
         end
   end 
/*-------------------------------------------------------------------------------------------------------------------------------------------*/
   default : ;
  endcase
end
endmodule
