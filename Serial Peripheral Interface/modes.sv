`timescale 1ns / 1ps
/*

1)  Here  the  firstly the CPOL logic have been written .
2)  Then secondly the CPHA logic is written to know about the operation
    of SPI with different modes (1,2,3,4).
3)  The (1) and (2) combine to make the master CPHA logic as based upon the CPHA 
    the modes will decide with (CPOL (0,1)).
4)  After this , the CPHA slave logic need to write so that the master sends the data based upon the 
    the modes and slave accept the data.
   
*/  

/*--------------------------------------------------------------------------------------------*/

/*
 // Here we are observing the CPOL and CPHA Behavious based upon the modes.
 
 //    intially we have set the:-
 
 //    cases:-
 
         1) mode 3 (11).--->  (CPOL  = 1,   CPHA   = 1)
         2) mode 1 (01) --->  (CPOL  = 0,   CPHA   = 1)
         3) mode 2 (10) --->  (CPOL  = 1,   CPHA   = 0)
         4) mode 0 (00) --->  (CPOL  = 0,   CPHA   = 0) 
              
 //   then based upon the cases mode 2. mode 1.mode 0 the output waveform operate.
 
 // firstly CPOL logic for detection of edges and generation of SCLK based upon CPOL
 
*/

/*--------------------------------------------------------------------------------------------*/

`timescale 1ns / 1ps
module modes();
//parameter half_clk_period = 2;
//parameter clk_count  = [$clog2(half_clk_period*2)-1:0];
//parameter clk_edges = (total_data_bits*2);

reg ready = 1;
integer spi_edges  = 0;
reg [1:0] clk_count = 0; // edges count // 4 clock cycle
reg spi_l = 0; // leading edge
reg spi_t = 0; // trailing edge
reg sclk  = 0;//1; // initiaally it is active
reg clk   = 0;
reg cpol  = 0;//1;  // inntially cpol == 1'b0 set //mode 0 
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
   /////
   else if (spi_edges > 0)    // when start = 0 and spi_edge >0;
   begin
      spi_l     <= 1'b0;
      spi_t     <= 0;
      ////
      if (clk_count == 1)   // clk_counter plays a key role //
      begin
         spi_l     <= 1'b1;
         sclk      <= ~sclk;
         spi_edges <= spi_edges - 1;
         clk_count <= clk_count + 1;
      end
      ////////
      else if (clk_count == 3)
      begin
         spi_t <= 1'b1;
         sclk <= ~sclk;
         spi_edges <= spi_edges - 1;
         clk_count <= clk_count + 1;
      end
      //////
      else begin
        clk_count <= clk_count + 1;
      end
   /////// 
   end
   
 else 
 begin
        ready <= 1'b1;
        spi_l <= 1'b0;
        spi_t <= 1'b0;
        sclk  <= cpol;
 end  
end

/*--------------------------------------------------------------------------------------------------------------------------------------*/

/*------------------------------------FROM HERE CPHA LOGIC--------------------------------------------------------------------------------------------------*/
reg mosi = 0;
reg cpha = 0;// 1;  // initially mode 0 
reg [7:0] tx_data = 8'b10101010;
reg [2:0] bit_count = 3'b111;
reg [2:0] state = 0;
reg cs = 1;//0;
integer count = 0;
//reg start = 0; 
//reg clk = 0;
/*--------------------------------------------------------------------------------------------------------------------------------------*/
//always #5 clk = ~clk;
//initial begin
//@(posedge clk);
//start = 0;
//@(posedge clk ) ;
//start = 1;
//end

/*--------------------------------------------------------------------------------------------------------------------------------------*/

always @ (posedge clk)
begin
case(state)
0: begin
       if (start)
       begin
           if (!cpha)  // 0
           begin
              state <= 1;
              cs    <= 0;
           end
           else begin  // delay occus if cpha 1
             state <= 3;
             cs    <= 0;
           end
      end
       else 
       state <= 0;
end

/*--------------------------------------------------------------------------------------------------------------------------------------*/
1: begin
   if (count <3)
   begin
     count <= count + 1;
     state <= 1;
     mosi <= tx_data[bit_count]; //MSB
   end
  else begin
    count <= 0;
    if (bit_count !=0)
    begin
      bit_count <= bit_count - 1; // until bit count 0 so that all bits accessed
      state <= 1;
    end
    else begin
      state <= 2;
    end
  end 
end

/*--------------------------------------------------------------------------------------------------------------------------------------*/
2: begin
  cs <=1'b1;
  bit_count <= 3'b111;
  state <= 0;
  mosi <= 1'b0;
end

/*--------------------------------------------------------------------------------------------------------------------------------------*/
3: begin   // if CPHA 1 then delay occurs hence used the states vacant ot introduce the delay
  state <= 4;
end

/*--------------------------------------------------------------------------------------------------------------------------------------*/
4: begin
  state <= 1;
end

/*--------------------------------------------------------------------------------------------------------------------------------------*/
 endcase
end

// cpha slave logic 
reg [7:0] rx_data = 7'h0;
integer r_count = 0;

always @ (posedge sclk) // based upon sclk will work
begin
  if (cs == 1'b0)
  begin
      if (r_count < 8 ) begin        // as 8 bit receving
         rx_data <= {rx_data[6:0],mosi};
         r_count <= r_count+1;
      end
      else begin
        r_count <= 8'h0;
      end
   end
  
end

endmodule

/*-------------------------------------------------------------------------------------------------------------------------------------*/

