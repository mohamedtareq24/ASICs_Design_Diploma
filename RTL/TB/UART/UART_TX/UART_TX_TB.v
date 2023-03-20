module UART_TX_TB ();


//Testbench Signals
reg                  CLK_TB;
reg                  RST_TB;
reg     [7:0]        P_DATA_TB;
reg                  Data_Valid_TB;
reg                  parity_enable_TB;
reg                  parity_type_TB; 
wire                 S_DATA_TB;
wire                 busy_TB;



//Initial 
initial
 begin

//initial values
CLK_TB            = 1'b0   ;
RST_TB            = 1'b1   ;    // rst is deactivated
P_DATA_TB         = 8'hAA  ;
parity_enable_TB  = 1'b1   ;
parity_type_TB    = 1'b0   ;
Data_Valid_TB     = 1'b0   ;

//Reset the design
#5
RST_TB = 1'b0;    // rst is activated
#5
RST_TB = 1'b1;    // rst is deactivated


#10
Data_Valid_TB     = 1'b1   ;
#20
Data_Valid_TB     = 1'b0   ;



#2000

$stop ;

end
 
 
// Clock Generator
always #10 CLK_TB = ~CLK_TB ;


// Design Instaniation
UART_TX DUT (
.CLK(CLK_TB),
.RST(RST_TB),
.P_DATA(P_DATA_TB),
.Data_Valid(Data_Valid_TB),
.parity_enable(parity_enable_TB),
.parity_type(parity_type_TB),
.S_DATA(S_DATA_TB), 
.busy(busy_TB)
);

endmodule