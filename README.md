# ASICs_design_Diploma
## Digital IC Design Diploma (Under supervision of [Eng. Ali El-Temsah](https://www.linkedin.com/in/ali-m-eltemsah-25a81b12a?lipi=urn%3Ali%3Apage%3Ad_flagship3_profile_view_base_contact_details%3By9gTwZ%2BrT5a28T21IwX9ww%3D%3D) )
###	Content: -
-	Efficient RTL Coding Using Verilog language
-	Building Advanced Self-checking Verilog Test-bench
-	TCL Scripting Language
-	Static Timing Analysis
-	Low Power Design Techniques
-	Clock Domain Crossing
-	RTL Synthesis on Design Compiler
-	Design For Testing (DFT) Insertion
-	Formal Verification Post-Synthesis & Post-DFT & Post-PnR
-	ASIC Flow including (Floorplanning, Pin Placement, Clock Tree Synthesis,      
- Placement, Routing, Timing Closure, Chip Finishing, Sign Off)
- Post-Layout Verification (Gate Level Simulation)
##	Final Project: “RTL to GDS Implementation of Low Power Configurable Multi Clock Digital System” 
![image](https://user-images.githubusercontent.com/90535558/226434844-946a2d03-57db-4bde-b90f-e589d1f495f6.png)

Description: It is responsible of receiving commands through UART receiver to do different system functions as register file reading/writing or doing some processing using ALU block and send result as well as CRC bits of result using 4 bytes frame through UART transmitter communication protocol.                 
### Project phases: -
-	RTL Design from Scratch of system blocks (ALU, Register File, Synchronous FIFO, Integer Clock Divider, Clock Gating, Synchronizers, Main Controller, UART TX, UART RX).
- Integrate and verify functionality through self-checking testbench. 
- Constraining the system using synthesis TCL scripts.
- 	Synthesize and optimize the design using design compiler tool.
- Analyze Timing paths and fix setup and hold violations.
- 	Verify Functionality equivalence using Formality tool
- Physical implementation of the system passing through ASIC flow phases and generate the GDS File.
- Verify functionality post-layout considering the actual delays. 

### EDA Tools used
- ModelSim
- design compiler 
- formality 
- innovus 
  
