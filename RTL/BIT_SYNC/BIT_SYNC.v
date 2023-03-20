
/////////////////////////////////////////////////////////////
///////////////////// bit synchronizer //////////////////////
/////////////////////////////////////////////////////////////

module BIT_SYNC # ( parameter bus_width = 8 )
(
input    wire                      dest_clk,
input    wire                      dest_rst,
input    wire                      unsync_bit,
output   wire                      sync_bit
);


reg              meta_flop  , 
                 sync_flop  ;
					 
//----------------- double flop synchronizer --------------

always @(posedge dest_clk or negedge dest_rst)
 begin
  if(!dest_rst)      // active low
   begin
    meta_flop <= 1'b0 ;
    sync_flop <= 1'b0 ;	
   end
  else
   begin
    meta_flop <= unsync_bit;
    sync_flop <= meta_flop ;
   end  
 end
 


assign  sync_bit = sync_flop ;



endmodule