
########################### Define Top Module ############################
                                                   
set top_module SYS_TOP

##################### Define Working Library Directory ######################
                                                   
define_design_lib work -path ./work

############################# Formality Setup File ##########################
                                                   
set_svf $top_module.svf

################## Design Compiler Library Files #setup ######################

puts "###########################################"
puts "#      #setting Design Libraries          #"
puts "###########################################"

#Add the path of the libraries and RTL files to the search_path variable
lappend search_path /home/IC/tsmc_fb_cl013g_sc/aci/sc-m/synopsys
lappend search_path /home/IC/Projects/System/RTL/ALU
lappend search_path /home/IC/Projects/System/RTL/Clock_Divider
lappend search_path /home/IC/Projects/System/RTL/Clock_Gating
lappend search_path /home/IC/Projects/System/RTL/DATA_SYNC
lappend search_path /home/IC/Projects/System/RTL/BIT_SYNC
lappend search_path /home/IC/Projects/System/RTL/RegFile
lappend search_path /home/IC/Projects/System/RTL/RST_SYNC
lappend search_path /home/IC/Projects/System/RTL/SYS_CTRL
lappend search_path /home/IC/Projects/System/RTL/UART/UART_RX
lappend search_path /home/IC/Projects/System/RTL/UART/UART_TX
lappend search_path /home/IC/Projects/System/RTL/UART/UART_TOP
lappend search_path /home/IC/Projects/System/RTL/Top


set SSLIB "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db"
set TTLIB "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
set FFLIB "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db"

## Standard Cell libraries 
set target_library [list $SSLIB $TTLIB $FFLIB]

## Standard Cell & Hard Macros libraries 
set link_library [list * $SSLIB $TTLIB $FFLIB]  

######################## Reading RTL Files #################################

puts "###########################################"
puts "#             Reading RTL Files           #"
puts "###########################################"

set file_format verilog

read_file -format $file_format ALU.v
read_file -format $file_format ClkDiv.v
read_file -format $file_format CLK_GATE.v
read_file -format $file_format BIT_SYNC.v
read_file -format $file_format DATA_SYNC.v
read_file -format $file_format RegFile.v
read_file -format $file_format RST_SYNC.v
read_file -format $file_format CTRL_RX.v
read_file -format $file_format CTRL_TX.v
read_file -format $file_format SYS_CTRL.v
read_file -format $file_format data_sampling.v
read_file -format $file_format deserializer.v
read_file -format $file_format edge_bit_counter.v
read_file -format $file_format par_chk.v
read_file -format $file_format stp_chk.v
read_file -format $file_format strt_chk.v
read_file -format $file_format UART_RX.v
read_file -format $file_format uart_rx_fsm.v
read_file -format $file_format mux.v
read_file -format $file_format parity_calc.v
read_file -format $file_format Serializer.v
read_file -format $file_format UART_TX.v
read_file -format $file_format uart_tx_fsm.v
read_file -format $file_format UART.v
read_file -format $file_format mux2X1.v
read_file -format $file_format SYS_TOP_dft.v

###################### Defining toplevel ###################################

current_design $top_module

#################### Liniking All The Design Parts #########################
puts "###############################################"
puts "######## Liniking All The Design Parts ########"
puts "###############################################"

link 

#################### Liniking All The Design Parts #########################
puts "###############################################"
puts "######## checking design consistency ##########"
puts "###############################################"

check_design

#################### Define Design Constraints #########################
puts "###############################################"
puts "############ Design Constraints #### ##########"
puts "###############################################"

source ./cons.tcl

#################### Archirecture Scan Chains #########################
puts "###############################################"
puts "############ Configure scan chains ############"
puts "###############################################"



###################### Mapping and optimization ########################
puts "###############################################"
puts "########## Mapping & Optimization #############"
puts "###############################################"


compile -scan

################################################################### 
# Setting Test Timing Variables
################################################################### 

# Preclock Measure Protocol (default protocol)
set test_default_period 100
set test_default_delay 0
set test_default_bidir_delay 0
set test_default_strobe 20
set test_default_strobe_width 0

########################## Define DFT Signals ##########################



############################# Create Test Protocol #####################


                            
###################### Pre-DFT Design Rule Checking ####################



############################# Preview DFT ##############################



############################# Insert DFT ###############################



######################## Optimize Logic post DFT #######################



###################### Design Rule Checking post DFT ###################



#############################################################################
# Write out files
#############################################################################

write_file -format verilog -hierarchy -output netlists/$top_module.ddc
write_file -format verilog -hierarchy -output netlists/$top_module.v
write_sdf  sdf/$top_module.sdf
write_sdc  -nosplit sdc/$top_module.sdc

####################### reporting ##########################################

report_area -hierarchy > reports/area.rpt
report_power -hierarchy > reports/power.rpt
report_timing -delay_type min -max_paths 20 > reports/hold.rpt
report_timing -delay_type max -max_paths 20 > reports/setup.rpt
report_clock -attributes > reports/clocks.rpt
report_constraint -all_violators -nosplit > reports/constraints.rpt

################# starting graphical user interface #######################

#gui_start

#exit
