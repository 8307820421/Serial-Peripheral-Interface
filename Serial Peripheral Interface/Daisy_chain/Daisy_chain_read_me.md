# ------------------------------------------------------SINGLE SLAVE SINGLE MASTER INTERFACE-------------------------------------------

daisy_chain_master MODULE :-> 
-----------------------------

  Here the data_in is an external port to receive the data and then send the data through
  (sdo --> output port) to collect the data via 8 clock cycle at each location . As
  somewhat the counter acting as an array . 
  
  Hence here you can see two FSM block to sample the data and then another to receive the data
  as sdo of master connected as input to sdi of slave.
  
# Port Description :->
  ------------------

    input clk        ----> system generated clk (through testbench) 
    input newd       ----> external port to enbale the transaction for receving the data from external device.
    input [7:0] din  ----> external port to taking data.
    input sclk      -----> SPI clk generated based upon 100 mhz but here period taken short to view the output in simulation.
    input sdi        ----> serial data input (where output (sdo connect to this port). this play key role to accept the slave output.
    output sdo       ----> output serial data that goes as input to slave.
    output [7:0] dout ---> this will cobmbine the output from slave(or input sdi)  (for 8 clock pulse) in wait state.
    

-------------------------------------------------------------------------------------------------------------------------------------------

# daisy_chain_slave MODULE :->
----------------------------
   Here In the waveform when you observed the output in slave then from the 9th clock pulse
   You will get the data as there is 8 clock cycle latency required to collect the data.
   
# Port Description :->
--------------------------- 

    input sclk -----> This controlled by master.
    input cs   -----> This also controlled by master (here this will intially high then up to 8 clock pulse  goes  low to receive the data 
                      or send the data)
    input sdi, ------> This taken the data from the master sdo (serial data output).
    output sdo  ------> This access the data from sdi and send to master.

