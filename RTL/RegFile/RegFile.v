
module RegFile #(parameter WIDTH = 8, DEPTH = 16, ADDR = 4 )

(
input    wire                CLK,
input    wire                RST,
input    wire                WrEn,
input    wire                RdEn,
input    wire   [ADDR-1:0]   Address,
input    wire   [WIDTH-1:0]  WrData,
output   reg    [WIDTH-1:0]  RdData,
output   reg                 RdData_VLD,
output   wire   [WIDTH-1:0]  REG0,
output   wire   [WIDTH-1:0]  REG1,
output   wire   [WIDTH-1:0]  REG2,
output   wire   [WIDTH-1:0]  REG3
);

integer I ; 
  
// register file of 8 registers each of 16 bits width
reg [WIDTH-1:0] regArr [DEPTH-1:0] ;    

always @(posedge CLK or negedge RST)
 begin
   if(!RST)  // Asynchronous active low reset 
    begin
	 RdData_VLD <= 1'b0 ;
	 RdData     <= 1'b0 ;
      for (I=0 ; I < DEPTH ; I = I +1)
        begin
		 if(I==2)
          regArr[I] <= 'b001000_01 ;
		 else if (I==3) 
          regArr[I] <= 'b0000_1000 ;
         else
          regArr[I] <= 'b0 ;		 
        end
     end
   else if (WrEn && !RdEn) // Register Write Operation
     begin
      regArr[Address] <= WrData ;
     end
   else if (RdEn && !WrEn) // Register Read Operation
     begin    
       RdData <= regArr[Address] ;
	   RdData_VLD <= 1'b1 ;
     end  
   else
     begin
	   RdData_VLD <= 1'b0 ;
     end	 
  end

assign REG0 = regArr[0] ;
assign REG1 = regArr[1] ;
assign REG2 = regArr[2] ;
assign REG3 = regArr[3] ;


endmodule