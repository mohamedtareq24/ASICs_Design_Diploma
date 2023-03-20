module UART_RX_TB ();

//parameters
parameter DATA_WIDTH = 8 ; 
parameter PRESCALE_WIDTH = 5 ;

//Testbench Signals
reg                         RX_CLK_TB;
reg                         RST_TB;
reg                         RX_IN_TB;
reg   [PRESCALE_WIDTH-1:0]  Prescale_TB;
reg                         parity_enable_TB;
reg                         parity_type_TB;
wire  [DATA_WIDTH-1:0]      P_DATA_TB; 
wire                        data_valid_TB;


reg                         TX_CLK_TB;
reg                         Data_Stimulus_En;
reg   [5:0]                 count ;
//reg   [21:0]                Data = 22'b1101111101010010101010 ;
reg   [21:0]                Data = 22'b10011111010_10010101010 ;

//Initial 
initial
 begin

//initial values
Data_Stimulus_En  = 1'b0   ;
count             = 4'b0   ;
RX_CLK_TB         = 1'b1   ;
TX_CLK_TB         = 1'b0   ;
RST_TB            = 1'b1   ;    // rst is deactivated
Prescale_TB       = 'b1000 ;
parity_enable_TB  = 1'b1   ;
parity_type_TB    = 1'b0   ;
RX_IN_TB          = 1'b1   ;

//Reset the design
#5
RST_TB = 1'b0;    // rst is activated
#5
RST_TB = 1'b1;    // rst is deactivated

#20 
Data_Stimulus_En = 1'b1 ;


#4000

$stop ;

end

always @ (posedge TX_CLK_TB)
 begin
  if(Data_Stimulus_En && count < 6'd22 )
   begin
    RX_IN_TB <= Data[count] ;
	count <= count + 3'b1 ;
   end	
  else
    RX_IN_TB <= 1'b1 ;  
 end
 
 
// Clock Generator
always #10 RX_CLK_TB = ~RX_CLK_TB ;

always #80 TX_CLK_TB = ~TX_CLK_TB ;

// Design Instaniation
UART_RX DUT (
.CLK(RX_CLK_TB),
.RST(RST_TB),
.RX_IN(RX_IN_TB),
.Prescale(Prescale_TB),
.parity_enable(parity_enable_TB),
.parity_type(parity_type_TB),
.P_DATA(P_DATA_TB), 
.data_valid(data_valid_TB)
);

endmodule