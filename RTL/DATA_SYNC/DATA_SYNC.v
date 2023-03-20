
/////////////////////////////////////////////////////////////
//////////////////// data synchronizer //////////////////////
/////////////////////////////////////////////////////////////

module DATA_SYNC # ( parameter bus_width = 8 )
(
input    wire                      dest_clk,
input    wire                      dest_rst,
input    wire     [bus_width-1:0]  unsync_bus,
input    wire                      bus_enable,
output   reg      [bus_width-1:0]  sync_bus,
output   reg                       enable_pulse_d
);



//internal connections
reg                     meta_flop   ,
                        sync_flop   ,
                        enable_flop ;
					 
wire                    enable_pulse ;

wire  [bus_width-1:0]   sync_bus_c ;
					 
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
    meta_flop <= bus_enable;
    sync_flop <= meta_flop ;
   end  
 end
 

//----------------- pulse generator --------------------

always @(posedge dest_clk or negedge dest_rst)
 begin
  if(!dest_rst)      // active low
   begin
    enable_flop <= 1'b0 ;	
   end
  else
   begin
    enable_flop <= sync_flop ;
   end  
 end

 
assign enable_pulse = sync_flop && !enable_flop ;


//----------------- multiplexing --------------------

assign sync_bus_c =  enable_pulse ? unsync_bus : sync_bus ;  


//----------- destination domain flop ---------------

always @(posedge dest_clk or negedge dest_rst)
 begin
  if(!dest_rst)      // active low
   begin
    sync_bus <= 'b0 ;	
   end
  else
   begin
    sync_bus <= sync_bus_c ;
   end  
 end
 
//--------------- delay generated pulse ------------

always @(posedge dest_clk or negedge dest_rst)
 begin
  if(!dest_rst)      // active low
   begin
    enable_pulse_d <= 1'b0 ;	
   end
  else
   begin
    enable_pulse_d <= enable_pulse ;
   end  
 end
 

endmodule