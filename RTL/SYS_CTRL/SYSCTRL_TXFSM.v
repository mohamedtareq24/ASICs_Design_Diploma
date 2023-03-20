module SYSCTRL_TXFSM #(parameter DATA_WIDTH = 32)(
input                               clk,
                                    RST,
                                    RdData_valid,
                                    OUT_Valid,
            
input  [$clog2(DATA_WIDTH/8) :0]    TX_CNTR , 

output  reg                            TX_CNTR_RST ,
                                    TX_CNTR_EN  ,
                                    TX_D_VLD
);
localparam      SEND_IDLE       = 0,
                RF_TX_CNTR_EN   = 1,
                ALU_TX_CNTR_EN  = 2;

reg [1:0]tx_state;

always @(posedge clk)
begin
    if (RST)
        tx_state <= SEND_IDLE ;
    else
        case (tx_state)
            SEND_IDLE       :  if (RdData_valid)
                                    tx_state <= RF_TX_CNTR_EN;
                                else if (OUT_Valid)
                                    tx_state <= ALU_TX_CNTR_EN;
            
            RF_TX_CNTR_EN   :   if (TX_CNTR == DATA_WIDTH / 8 )
                                    tx_state <= SEND_IDLE ;

            ALU_TX_CNTR_EN  :   if (TX_CNTR == DATA_WIDTH / 4 )
                                    tx_state <= SEND_IDLE ;
        endcase        
end


always @(*) begin
    TX_CNTR_EN  = 0 ;
    TX_CNTR_RST = 0 ;
    TX_D_VLD    = 0 ;
    case (tx_state)
        SEND_IDLE       :   begin
                                TX_CNTR_EN  = 0;
                                TX_CNTR_RST = 1;
                                TX_D_VLD    = 0;
                            end       
        
        RF_TX_CNTR_EN   :   begin
                                TX_CNTR_EN  = 1;
                                TX_CNTR_RST = 0;
                                TX_D_VLD    = 1;
                            end       

        ALU_TX_CNTR_EN  :   begin
                                TX_CNTR_EN  = 1;
                                TX_CNTR_RST = 0;
                                TX_D_VLD    = 1;
                            end     
    endcase
end
endmodule