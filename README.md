# Serial-Peripheral-Interface

# 1) FOLDER SERIAL PERIPHERAL INTERFACE :-

This folder contain the simple SPI master and slave interface with top module connectivity by consdering 100 mhz system clock .

# PIN DESCRIPTION of SPI PROTOCOL (MASTER):-

     input fpga_clk   -----> Here we suppose the 100mhz system clock for entire system.
     
     input fpga_rst   -----> This is act as reset pin.
     
     input tx_en      ------> This is used to initiate the transaction.
     
     output reg spi_mosi ----> This is Master output slave  input pin .
     
     output reg spi_ss , ----> This slave select that plays a significant role to enable the transaction or select the slave device.
     
     output wire sclk    -----> This act as sclk pin that will generate in serial periheral interface protocol to operate the master and 
                                slave.

# PIN DESCRIPTION of SPI PROTOCOL (SLAVE):- Based upon the master inerface.

     input sclk        -------->  This pin controlled through master .
     
     input mosi        ---------> This also connected through master.
     
     input  ss         ---------> This is also connected through master as slave select plays key role to take the data from master.
     
     output [7:0] dout -------->  Data receiving from master.
     
     output done       -------->  Acknowedge that output received

# PIN DESCRIPTION of SPI PROTOCOL (TOP MODULE) :- To connect master to slave.

   input clk       ------> global pin(clock).
   
   input rst       ------> global pin(reset).
   
   input tx_en     ------> global pin(intiate the transaction).
   
   output [7:0] dout-----> 8 bit data output.
   
   output done     ------> acknoweldge to receive the output.

     
# 2) DAISY CHAIN FOLDER :-

Here we have developed the single master with single slave for daisy chain configuartion that produce high throughput but have
latnecy of 8 clock cycle from master to slave and this latency of 8 clock cycle will increase if we assume two slave by multiple of 8.

# The Daisy Chain folder also contain the master and slave with top module interface . And the description is given inside into it.


