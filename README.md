# Serial-Peripheral-Interface

# 1) FOLDER SERIAL PERIPHERAL INTERFACE :-

This folder contain the simple SPI master and slave interface with top module connectivity by consdering 100 mhz system clock .

# PIN DESCRIPTION of SPI PROTOCOL :-

     input fpga_clk   -----> Here we suppose the 100mhz system clock for entire system.
     
     input fpga_rst   -----> This is act as reset pin.
     
     input tx_en      ------> This is used to initiate the transaction.
     
     output reg spi_mosi ----> This is Master output slave  input pin .
     
     output reg spi_ss , ----> This slave select that plays a significant role to enable the transaction or select the slave device.
     
     output wire sclk    -----> This act as sclk pin that will generate in serial periheral interface protocol to operate the master and 
                                slave.

# 2) DAISY CHAIN FOLDER :-

Here we have developed the single master with single slave for daisy chain configuartion that produce high throughput but have
latnecy of 8 clock cycle from master to slave and this latency of 8 clock cycle will increase if we assume two slave by multiple of 8.

