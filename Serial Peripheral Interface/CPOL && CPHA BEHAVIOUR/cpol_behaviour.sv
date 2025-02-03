/*
   ---> sclk pin of spi ---->1/4 of sytstem clk .
   if clk = 5ns
       freq = 1/5ns = 50mhz
      then total period = 4*5 = 20ns for spi sclk
      Hence clk_count count up to 4 clk cycle w.r.t posedge
      and thus for two clk cycle it will low and for other two clk cycle it will high.
      
 -----> leading edge is (low to high transittion w.r.t clk). (0 to 1)
 ---->  trailing edge is (high to low transition w.r.t clk). (1 to 0)
 
*/
`timescale 1ns / 1ps
module cpol_behaviour();
//parameter half_clk_period = 2;
//parameter clk_count  = [$clog2(half_clk_period*2)-1:0];
//parameter clk_edges = (total_data_bits*2);

reg ready = 1;
integer spi_edges  = 0;
//reg start = 0;
reg [1:0] clk_count = 0;
reg spi_l = 0; // leading edge
reg spi_t = 0; // trailing edge
reg sclk  = 1; // initiaally it is active
reg clk   = 0;
reg cpol  = 1;  // inntially cpol == 1'b1 set
reg start = 0; // to indicate the start of posedge (leading edge)

/*------------------------------------------------------stimuli gen for clk---------------------------------------------------------------------------------*/
always #5 clk = ~clk;

initial begin
@(posedge clk);  // leading edge w.r.t. clk start changes
start = 1;
@(posedge clk);  // eading edge w.r.t. clk start goes low
start = 0;
end

/*-------------------------------------------------- --Logic for sclk-----------------------------------------------------------------------*/
always @(posedge clk)
begin
   if (start == 1'b1)   // first posedge clk edge
   begin
      ready     <= 1'b0;
      spi_edges <= 16;  // 16 bit edges of clk value store 
      sclk      <= cpol; // clock polarity
   end
   else if (spi_edges > 0)    // when start = 0 and spi_edge >0;
   begin
      spi_l     <= 1'b0;
      spi_t     <= 0;
      if (clk_count == 1)   // clk_counter plays a key role //
      begin
         spi_l     <= 1'b1;
         sclk      <= ~sclk;
         spi_edges <= spi_edges - 1;
         clk_count <= clk_count + 1;
      end
      
      else if (clk_count == 3)
      begin
         spi_t <= 1'b1;
         sclk <= ~sclk;
         spi_edges <= spi_edges - 1;
         clk_count <= clk_count + 1;
      end
      
      else begin
        clk_count <= clk_count + 1;
      end
      
   end
   
 else 
 begin
        ready <= 1'b1;
        spi_l <= 1'b0;
        spi_t <= 1'b0;
        sclk      <= cpol;
 end  
end

endmodule

/*-------------------------------------------------------------------------------------------------------------------------------------*/

