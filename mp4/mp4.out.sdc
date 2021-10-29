## Generated SDC file "mp4.out.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.1.0 Build 625 09/12/2018 SJ Standard Edition"

## DATE    "Fri Oct 29 12:08:51 2021"

##
## DEVICE  "EP2AGX45DF25I3"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk} -period 10.000 -waveform { 0.000 5.000 } [get_ports {clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {clk}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[9]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[10]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[11]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[12]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[13]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[14]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[15]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[16]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[17]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[18]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[19]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[20]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[21]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[22]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[23]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[24]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[25]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[26]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[27]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[28]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[29]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[30]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_rdata[31]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_resp}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[9]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[10]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[11]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[12]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[13]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[14]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[15]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[16]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[17]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[18]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[19]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[20]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[21]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[22]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[23]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[24]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[25]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[26]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[27]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[28]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[29]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[30]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_rdata[31]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_resp}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {rst}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[29]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[30]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_address[31]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_byte_enable[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_byte_enable[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_byte_enable[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_byte_enable[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_read}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[29]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[30]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_wdata[31]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {dmem_write}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[29]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[30]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_address[31]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_read}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

