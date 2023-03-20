module SYS_CTRL #(parameter DATA_WIDTH = 32) (

    input                                   clk,
                                            RST,
                                            OUT_Valid,
                                            RdData_valid,
                                            RX_D_VLD,
                                            Busy,

    input   [DATA_WIDTH*2-1:0]              ALU_OUT,
    input   [DATA_WIDTH-1:0]                RdData,
    input   [7:0]                           RX_P_DATA,

    output	reg                             ALU_EN,
                                            CLK_EN,
                                            WrEn,
                                            RdEn,
								            clk_div_en,
    output                                  TX_D_VLD,        
    output  reg		[DATA_WIDTH-1:0]        Address, 
    output  reg		[3:0]                   ALU_FUN,

    output  [DATA_WIDTH-1:0]                WrData,
    output  reg     [7:0]                   TX_P_DATA
);


reg [7:0]                           in_memory [ DATA_WIDTH/8 - 1 :0]  ;   // simple memory with MAD used to save the input data for any width  and will be accessed using the in_ADD_CNTR
reg [ DATA_WIDTH/8 - 1 :0]      	RF_ADDRESS_REG   ;                   // a rgister for the Regfile to save the write/read address 
wire                            	in_ADD_CNTR_valid;                  //  flag that tells that the counter that genrates the addresses of the memory has finshed counting
                                
reg                                 in_ADD_CNTR_en	,      // Outputs from the RX FSM
                                    in_ADD_CNTR_rst	,    
                                    ADDRESS_EN      ,    
                                    REGs            ,    
                                    MUX_CTRL        ,  
                                    ALU_FUN_En      ;  
                                


wire [ DATA_WIDTH - 1 :0]       	mux;
reg     [3:0]                      	state ; /// for RX FSM
reg     [1:0]                       tx_state;
reg  [DATA_WIDTH - 1  :0]			data;
reg [$clog2(DATA_WIDTH/8) :0]   TX_CNTR ; 
wire                             TX_CNTR_RST ,
                                TX_CNTR_EN  ;
reg     [7:0]                   TX_DATA_MEMORY [2*DATA_WIDTH/8-1:0] ;        
reg     [DATA_WIDTH*2-1:0]      TX_FULL_DATA    ;                                                 // the data to be sent to the UART either from RF or the ALU
wire    [DATA_WIDTH*2-1:0]      ALU_REG_MUX     ;
integer i,j,k,ii,jj,kk;



//-----------------------------------input  Address CNTR -------------------------------------\\\
reg [ $clog2(DATA_WIDTH/8) :0] in_ADD_CNTR ;

always @(posedge RX_D_VLD ) begin
    
    in_memory[in_ADD_CNTR] <= RX_P_DATA;
    
    if (in_ADD_CNTR_rst)
        in_ADD_CNTR <= 0;

    else if (in_ADD_CNTR_en)                                      /// this will come from an FSM
        in_ADD_CNTR <= in_ADD_CNTR + 1 ;   
        
end
assign  mux = (MUX_CTRL) ?    {31'b0,REGs}  :   data ; // always read from that simple memory   
assign  in_ADD_CNTR_valid = (in_ADD_CNTR == DATA_WIDTH/8-1) ;   // will be used as input for the FSM

//-----------------------------------------END -----------------------------------------------------


always @(*)   // this for loop is to read  the data of the memory bit by bit wich will be put in the temp variable data 
begin
    for (i = 0; i < DATA_WIDTH ; i = i + 1) 
        begin
            if (i % 8 ==0 ) k = k +1;
            j = i % 8 ;  
            data[i] = in_memory[k][j];      // for example if the data width is 32 bits the memory will have 4 words * 8 bytes and data will be 32 bits 
        end

end

always @(posedge clk) begin             /// Registing the address according to ADDRESS_EN from RX_FSM
            if (RST)
                    Address  <= 0 ;

            else if (ADDRESS_EN)
                    Address  <=  mux;

            else if (ALU_FUN_En)            // FSM output 
                ALU_FUN <= in_memory[0][3:0];
end

// assign Address = RF_ADDRESS_REG ;           // outputting the Adrress after being registerd 


//----------------------------------------------RX_FSM-------------------------------
localparam      OP_CODE         = 0,
                /// type 1 CMD
                RF_WR_Address   = 1,
                RF_WR_Data      = 2,
                /// type 2 CMD
                RF_Rd_Address   = 3,
                RF_Read         = 4,
                /// type 3 CMD
                OP_A            = 5,
                OP_B            = 6,
                ALU_FUN_state   = 7,
                ALU_Compute     = 8;
                /// type 4 CMD 


always @(posedge clk ) begin
    if (RST)
        state <=    OP_CODE;
    else
        case(state)
            OP_CODE         :   if(RX_D_VLD & in_memory[0] == 8'hAA)
                                    state <= RF_WR_Address;
                                else if (RX_D_VLD & in_memory[0] == 8'hBB)
                                    state <= RF_Rd_Address;
                                else if (RX_D_VLD & in_memory[0] == 8'hCC)
                                    state <= OP_A;
                    
            RF_WR_Address   :   if (in_ADD_CNTR_valid)
                                    state <= RF_WR_Data;


            RF_WR_Data      :   if (in_ADD_CNTR_valid)
                                    state <= OP_CODE;

                        ///////////////////////

            RF_Rd_Address   :   if (in_ADD_CNTR_valid)
                                    state <= RF_Read;

            
            RF_Read         :   if (in_ADD_CNTR_valid)
                                    state <= OP_CODE;

                        ////////////////////
        
            OP_A            :   if(in_ADD_CNTR_valid)
                                    state <= OP_B;

            OP_B            :   if(in_ADD_CNTR_valid)
                                    state <= ALU_FUN_state;

            ALU_FUN_state   :   if(RX_D_VLD)                // the func is only 1 frame 
                                    state <= ALU_Compute;

            ALU_Compute     :   state <= OP_CODE ;

                    ////////////////////////

        endcase
end

always @(*) begin                                   /// output always block 
    WrEn                = 0;
    in_ADD_CNTR_en      = 0;
    in_ADD_CNTR_rst     = 0;
	ALU_EN				= 0;
    ADDRESS_EN          = 0;
	CLK_EN				= 0;
    REGs                = 4'b0;
    MUX_CTRL            = 0;
    ALU_FUN_En          = 0;
    RdEn                = 0;



    case (state)
        OP_CODE         :   begin 
                                in_ADD_CNTR_rst     = 1;
                            end 

        RF_WR_Address   :  begin 
                                in_ADD_CNTR_en      = 1;
                                ADDRESS_EN          = 1;
                                CLK_EN              = 1;          
                            end 
        
        RF_WR_Data      :  begin
                                WrEn                = 1;
                            end

        RF_Rd_Address   :   begin
                                ADDRESS_EN          = 1;
                            end
        
        RF_Read         :   begin
                                RdEn                = 1;
                                ADDRESS_EN          = 1;
                            end 
        
        OP_A            :   begin
                                REGs                = 0;
                                WrEn                = 1;
                                MUX_CTRL            = 1;
                            end

        OP_B            :   begin
                                REGs                = 1;
                                WrEn                = 1;
                                MUX_CTRL            = 1;
                            end

        ALU_FUN_state   :   begin
                                ALU_FUN_En          = 1;
                            end

        ALU_Compute     :   begin
                                ALU_EN              = 1;
                            end  
    endcase
    
end

//--------------------------------------END of RX FSM ---------------------------------------------

//-------------------------------------TX_CNTR--------------------------------------------  /// A conuter to genrate byte addresses for the UART TX  it takes UART busy as a clk
// reg [$clog2(DATA_WIDTH/8) :0]   TX_CNTR ; 
// reg                             TX_CNTR_RST ,
//                                 TX_CNTR_EN  ;
// reg     [7:0]                   TX_DATA_MEMORY [DATA_WIDTH/8-1:0] ;        
// reg     [DATA_WIDTH*2-1:0]      TX_FULL_DATA    ;                                                 // the data to be sent to the UART either from RF or the ALU
// wire    [DATA_WIDTH*2-1:0]      ALU_REG_MUX     ;

assign ALU_REG_MUX = (RdData_valid) ? {RdData,RdData} : ALU_OUT[2*DATA_WIDTH-1:0] ;

always @(posedge clk)   // this for loop is to read  the data of the memory bit by bit wich will be put in the temp variable data 
begin
    for (ii = 0; ii < 2*DATA_WIDTH ; ii = ii + 1) 
        begin
            if (ii % 8 ==0 ) kk = kk +1;
            jj = ii % 8 ;  
            TX_DATA_MEMORY[kk][jj] = ALU_REG_MUX [ii];      // for example if the data width is 32 bits the memory will have 4 words * 8 bytes and data will be 32 bits 
        end

end
always @(posedge clk ) begin
        TX_P_DATA   <=   TX_DATA_MEMORY [TX_CNTR]; 
end
always @(negedge Busy)
    begin
        if(TX_CNTR_RST)
            TX_CNTR <= 0;
        else if (TX_CNTR_EN)
            TX_CNTR <= TX_CNTR +1 ;
    end

//-------------------------------------------TX_FSM---------------------------------
 SYSCTRL_TXFSM  TX_FSM(                               clk,
                                    RST,
                                    RdData_valid,
                                    OUT_Valid,
            
                            TX_CNTR , 
                            TX_CNTR_RST ,
                                    TX_CNTR_EN  ,
                                    TX_D_VLD
);
//----------------------------------------------------------------------------------

assign WrData  = data   ;





endmodule //SYS_CTRL