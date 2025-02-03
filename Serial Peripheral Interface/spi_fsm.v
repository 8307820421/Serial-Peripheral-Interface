//`timescale 1ns / 1ps
/*
   -----> SPI Master interface  as this is master interface hence we will develop the master module
   -----> mode 0 (posedge to posedge) 
   -----> typical value for clk (1/2 and 1/4 of clock cycle).
   ----/ The tx_data state is the most important state where salve select low and high decide w.r.t count under the bitcount
         as count required to generate the clock pulse for spi_sclk.
   
*/
module spi_fsm(
     input fpga_clk,
     input fpga_rst,
     
     input tx_en , // intiating the transaction
     output reg spi_mosi,
     output reg spi_ss ,
     output wire sclk   /// spi generated clk
);


/*-----------------------------------required Intermediate counter register--------------------------------------------------------------------------*/
reg spi_clk = 0;
reg [2:0] count = 0;  //0 to 7
integer bit_counter = 0; /// for 8bit data based upon generated sclk equal to spi_clk
/*---------------------------------------------------------------------------------------------------------------------------------------*/

/*-----------------------------------------FSM states required for simple mode spi 0---------------------------------------------------*/
localparam  idle     = 0;
localparam  start_tx = 1;
localparam  tx_data  = 2;  // This state is the most important state where salve select low and high decide w.r.t count under the bitcount
localparam  end_tx   = 3;
reg [2:0] present_state = idle , next_state = idle;
/*---------------------------------------required the din that we need to transmit----------------------------------------------------*/
reg  [7:0] din = 8'b10101010;
/*--------------------------------------------------------------------------------------------------------------------------------------*/

/*---------------------------------------setting counter logic  in each state as per spi need to gnerate the clk----------------------------------------------------*/
always @ (posedge fpga_clk)
begin
     case (next_state)
      idle : begin
        spi_clk <= 0;
      end
      
      start_tx : begin
       if (count <3'b011 || count == 3'b111) // spi clk low for 2 clock cycle and for 4 clock cycle it will be high w.r.t posedge
       begin
          spi_clk <= 1'b1;
       end
       else begin
          spi_clk <= 1'b0;
       end
      end
      
      tx_data : begin
       if (count <3'b011 || count ==3'b111)
       begin
          spi_clk <= 1'b1;
       end
       else begin
          spi_clk <= 1'b0;
       end
      end 
       
      end_tx  : begin
        if (count < 3'b011 ) // 1/3 // 0 to 2
       begin
          spi_clk <= 1'b1;
       end
       else begin
          spi_clk <= 1'b0;
       end
       
      end 
      
      default :spi_clk <= 1'b0;
   endcase
   
end

/*------------------------------------------------------------Reset condition-----------------------------------------------------------------------*/
always @(posedge fpga_clk)
begin
   if (fpga_rst)
   begin
      present_state <= idle;
   end
   else begin
     present_state <= next_state;
   end
end

/*------------------------------------------------------------transaction transmitter logic------------------------------------------------*/
/*
 ---->   Here set the all ouput as per spi logic based (upon present_state).
  --->    Here to FSM logic also work to move from one state to another state or management of state done
            in combitorial block to reduce the latency.
------> remeber when to set spi_ss 1 nad when to low
*/
always @ (*)
begin
   case(present_state)
   idle : begin
    spi_mosi   = 1'b0; 
     spi_ss     = 1'b1;
     
     if (tx_en)
     begin
       next_state = start_tx;
     end
     
     else begin
      next_state  = idle;
     end
     
   end
   
  start_tx : begin    // counter logic required to moved to next state
    spi_ss   = 1'b0;
    if (count == 3'b111)  // ,3,4,5,6 // 7th then come to 6
   begin
       next_state = tx_data;
    end
    else begin
      next_state = start_tx;
    end
    
  end 
  
  tx_data : begin
    spi_mosi   = din[7-bit_counter]; // msb bit based upon bit count
    if (bit_counter != 8)
    begin
      next_state = tx_data;
    end
    else if (bit_counter == 8)begin
     next_state     = end_tx;
     spi_mosi       = 1'b0;
    end
  end
  
  end_tx : begin
  spi_ss   = 1'b1;
  spi_mosi = 1'b0;
      if (count == 3'b111)                // this count keyword set the logic to generate teh spi clk or sclk and
      begin                          // based upon sclk bit counter work hence it will act as major condition during transaction 
        next_state = idle;                            //to move to idle state
      end
      else begin
      next_state = end_tx;
      end
  
  end
    default : next_state = idle;
   endcase
   
end

/*-----------------------------------incrementing and reseting the counter as well as bitcounter logic in required fsm state-------------------*/
always @ (posedge fpga_clk)
begin
   case (present_state)
     idle : begin
       count       <= 0;
       bit_counter <= 0;
     end
     
     start_tx : count <= count + 1;   // here count work not bitcount hence bitcount set to previous state value
     
     tx_data : begin      // in tx data state we need to check the bticounter increment logic and when to increment the bit_counter
         if (bit_counter != 8)
         begin
         /*-------------------------------------------------------------------------------------------------------------------*/
            if (count <3'b111)
            begin
               count <= count + 1; // to generate spi_clk
           end
           else  begin
             count <= 0;
             bit_counter <= bit_counter +1;  // as bit counter work w.r.t generated spi_clk based  upon count hence here condtion set
           end
           /*-------------------------------------------------------------------------------------------------------------------*/ 
         end
     end
     
     end_tx : begin
     count <= count+1;
     bit_counter <= 0;
     end
     
     default : begin
         count      <= 0;
         bit_counter <= 0;
     end
     
   endcase
   
end

assign sclk = spi_clk;

endmodule


   