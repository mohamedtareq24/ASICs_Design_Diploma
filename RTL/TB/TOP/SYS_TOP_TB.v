
`timescale 1ns/1ps

module SYS_TOP_TB ();

//parameters
parameter DATA_WIDTH  = 8 ;
parameter REF_CLK_PER = 20 ;
parameter UART_RX_CLK_PER = 100 ;     
parameter WR_NUM_OF_FRAMES = 3 ;
parameter RD_NUM_OF_FRAMES = 2 ;
parameter ALU_WP_NUM_OF_FRAMES = 4 ;
parameter ALU_NP_NUM_OF_FRAMES = 2 ; 

//Testbench Signals
reg                                RST_N;
reg                                UART_CLK;
reg                                REF_CLK;
reg                                UART_RX_IN;
wire                               UART_TX_O;

reg   [WR_NUM_OF_FRAMES*11-1:0]       WR_CMD     = 'b10_01110111_0_10_00000101_0_10_10101010_0 ;
reg   [RD_NUM_OF_FRAMES*11-1:0]       RD_CMD     = 'b11_00000010_0_10_10111011_0    ;
reg   [ALU_WP_NUM_OF_FRAMES*11-1:0]   ALU_WP_CMD = 'b11_00000001_0_10_00000011_0_10_00000101_0_10_11001100_0 ;
reg   [ALU_NP_NUM_OF_FRAMES*11-1:0]   ALU_NP_CMD = 'b11_00000001_0_10_11011101_0 ;


reg                         TX_CLK_TB;
reg                         Data_Stimulus_En;
reg   [5:0]                 count = 6'b0 ;



//Initial 
initial
 begin

//initial values
UART_CLK          = 1'b0   ;
TX_CLK_TB         = 1'b0   ;
REF_CLK           = 1'b0   ;
RST_N             = 1'b1   ;    // rst is deactivated
UART_RX_IN        = 1'b1   ;

//Reset the design
#5
RST_N = 1'b0;    // rst is activated
#5
RST_N = 1'b1;    // rst is deactivated

#20 
Data_Stimulus_En = 1'b1 ;


#400000

$stop ;

end

always @ (posedge DUT.U0_ClkDiv.o_div_clk)
 begin
  if(Data_Stimulus_En && count < 6'd22 )
   begin
    UART_RX_IN <=  RD_CMD[count] ;
	count <= count + 6'b1 ;
   end	
  else
    UART_RX_IN <= 1'b1 ;  
 end
 
 
// REF Clock Generator
always #(REF_CLK_PER/2) REF_CLK = ~REF_CLK ;

// UART RX Clock Generator
always #(UART_RX_CLK_PER/2) UART_CLK = ~UART_CLK ;


// Design Instaniation
SYS_TOP DUT (
.UART_CLK(UART_CLK),
.REF_CLK(REF_CLK),
.RST_N(RST_N),
.UART_RX_IN(UART_RX_IN),
.UART_TX_O(UART_TX_O)
);


endmodule