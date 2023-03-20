
/////////////////////////////////////////////////////////////
/////////////////////// Clock Gating ////////////////////////
/////////////////////////////////////////////////////////////

module RST_SYNC (
input    wire     RST,
input    wire     CLK,
output   wire     SYNC_RST
);

//internal connections
reg     meta_flop ,
        sync_flop ;

//double flop synchronizer
always @(posedge CLK or negedge RST)
 begin
  if(!RST)      // active low
   begin
    meta_flop <= 1'b0 ;
    sync_flop <= 1'b0 ;	
   end
  else
   begin
    meta_flop <= 1'b1 ;
    sync_flop <= meta_flop ;
   end  
 end
 
 
assign  SYNC_RST = sync_flop ;



endmodule