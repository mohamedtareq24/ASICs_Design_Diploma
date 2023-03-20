
####################################################################################
# Constraints
# ----------------------------------------------------------------------------
#
# 0. Design Compiler variables
#
# 1. Master Clock Definitions
#
# 2. Generated Clock Definitions
#
# 3. Clock Uncertainties
#
# 4. Clock Latencies 
#
# 5. Clock Relationships
#
# 6. #set input/output delay on ports
#
# 7. Driving cells
#
# 8. Output load

####################################################################################
           #########################################################
                  #### Section 0 : DC Variables ####
           #########################################################
#################################################################################### 

# Prevent assign statements in the generated netlist (must be applied before compile command)
set_fix_multiple_port_nets -all -buffer_constants -feedthroughs

####################################################################################
           #########################################################
                  #### Section 1 : Clock Definition ####
           #########################################################
#################################################################################### 
# 1. Master Clock Definitions 
# 2. Generated Clock Definitions
# 3. Clock Latencies
# 4. Clock Uncertainties
# 4. Clock Transitions
####################################################################################

#1. Master Clocks
set CLK1_NAME REF_CLK
set CLK1_PER 20
set CLK2_NAME UART_RX_CLK
set CLK2_PER 100
set CLK3_NAME SCAN_CLK
set CLK3_PER 200
set CLK_SETUP_SKEW 0.2
set CLK_HOLD_SKEW 0.1

create_clock -name $CLK1_NAME -period $CLK1_PER -waveform "0 [expr $CLK1_PER/2]" [get_ports REF_CLK]
set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks $CLK1_NAME]
set_clock_uncertainty -hold $CLK_HOLD_SKEW  [get_clocks $CLK1_NAME]

create_clock -name $CLK2_NAME -period $CLK2_PER -waveform "0 [expr $CLK2_PER/2]" [get_ports UART_CLK]
set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks $CLK2_NAME]
set_clock_uncertainty -hold $CLK_HOLD_SKEW  [get_clocks $CLK2_NAME]

create_clock -name $CLK3_NAME -period $CLK3_PER -waveform "0 [expr $CLK3_PER/2]" [get_ports SCAN_CLK]
set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks $CLK3_NAME]
set_clock_uncertainty -hold $CLK_HOLD_SKEW  [get_clocks $CLK3_NAME]

#2. Generated clocks

create_generated_clock -master_clock $CLK2_NAME -source [get_ports UART_CLK] \
                       -name "UART_TX_CLK" [get_port U0_ClkDiv/o_div_clk] \
                       -divide_by 8

create_generated_clock -master_clock $CLK1_NAME -source [get_ports REF_CLK] \
                       -name "ALU_CLK" [get_port U0_CLK_GATE/GATED_CLK] \
                       -divide_by 1

####################################################################################
           #########################################################
             #### Section 2 : Clocks Relationship ####
           #########################################################
####################################################################################

set_clock_groups -name "Functional Clocks" \
                 -asynchronous \
                 -group [get_clocks {UART_RX_CLK UART_TX_CLK}] \
                 -group [get_clocks {REF_CLK ALU_CLK}] \
                 -group [get_clocks {SCAN_CLK}] 

####################################################################################
           #########################################################
             #### Section 3 : #set input/output delay on ports ####
           #########################################################
####################################################################################

set in_delay  [expr 0.2*$CLK2_PER]
set out_delay [expr 0.2*$CLK2_PER]

#Constrain Input Paths
set_input_delay $in_delay -clock $CLK2_NAME [get_port UART_RX_IN]

#Constrain Output Paths
set_output_delay $out_delay -clock $CLK2_NAME [get_port UART_TX_O]

####################################################################################
           #########################################################
                  #### Section 4 : Driving cells ####
           #########################################################
####################################################################################

set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M -pin Y [get_port UART_RX_IN]

####################################################################################
           #########################################################
                  #### Section 5 : Output load ####
           #########################################################
####################################################################################

set_load 75 [get_port UART_TX_O]

####################################################################################
           #########################################################
                 #### Section 6 : Operating Condition ####
           #########################################################
####################################################################################

# Define the Worst Library for Max(#setup) analysis
# Define the Best Library for Min(hold) analysis

set_operating_conditions -min_library "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -min "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -max_library "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c" -max "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c"

####################################################################################
           #########################################################
                  #### Section 7 : wireload Model ####
           #########################################################
####################################################################################

set_wire_load_model -name tsmc13_wl30 -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c

####################################################################################
           #########################################################
                  #### Section 8 : premapped cells ####
           #########################################################
####################################################################################

set_dont_touch [get_cells U0_CLK_GATE/U0_TLATNCAX12M]

####################################################################################

