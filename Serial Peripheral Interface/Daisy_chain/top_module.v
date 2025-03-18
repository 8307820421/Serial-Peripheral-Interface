`timescale 1ns / 1ps
module top_module(

    input clk,
    input newd,
    input  [7:0] din,
    output [7:0] dout,
        /*---------------------------------------------------------------net decleration-----------------------------------------------------*/
    input   sdi_w,  // master output(sdo) connect with this wire to slave input
    output  sdo_w,  // slave output connect with this declared wire to master input
    input   sclk_w, // sclk master connect with this wire to slave input 
    input   cs_w    // cs master connect with this wire to slave input
    );
    
  
  /*---------------------------------------------------------------------------------------------*/
 /*
   master instantiation
   
input clk,
input sdi_in,
input newd,
input [7:0] din_in,
output reg sdo_out,
output reg cs_sel,
output sclk_m,
output [7:0] dout_m
 */
 dasiy_chain_master master(
    .clk(clk),
    .sdi(sdo_w),  // slave connect to input 
    .newd(newd),
    .din(din),//
    .sdo(sdi_w),//
    .cs(cs_w), // 
    .sclk(sclk_w),
    .dout(dout) 
  );


  /*---------------------------------Slave Instantiation---------------------------------------*/
  /*
   input sclk,
  input sdi,
  input cs,
  output reg sdo // for second slave it will act as input
  */
  daisy_chain_slave slave(
   .sclk(sclk_w),
   .sdi(sdi_w),
   .cs(cs_w),
   .sdo(sdo_w)
  );
endmodule
