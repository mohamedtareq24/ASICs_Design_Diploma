
module uart_rx_fsm  # ( parameter DATA_WIDTH = 8 ) (

 input   wire                  CLK,
 input   wire                  RST,
 input   wire                  S_DATA,
 input   wire                  parity_enable, 
 input   wire   [3:0]          bit_count,
 input   wire   [2:0]          edge_count,
 input   wire                  par_err,
 input   wire                  stp_err, 
 input   wire                  strt_glitch,
 output  reg                   strt_chk_en,  
 output  reg                   edge_bit_en, 
 output  reg                   deser_en, 
 output  reg                   par_chk_en, 
 output  reg                   stp_chk_en,
 output  reg                   dat_samp_en,
 output  reg                   data_valid
);


// gray state encoding
localparam  [2:0]      IDLE     = 3'b000 ,
                       start    = 3'b001 ,
					   data     = 3'b011 ,
					   parity   = 3'b010 ,
					   stop     = 3'b110 ,
					   err_chk  = 3'b111 ,
					   data_vld = 3'b101 ;

reg         [2:0]      current_state , next_state ;
			

//state transiton 
always @ (posedge CLK or negedge RST)
 begin
  if(!RST)
   begin
    current_state <= IDLE ;
   end
  else
   begin
    current_state <= next_state ;
   end
 end
 

// next state logic
always @ (*)
 begin
  case(current_state)
  IDLE   : begin
             if(!S_DATA)
			  next_state = start ;
			else
			  next_state = IDLE ; 			
           end
  start  : begin
             if(bit_count == 4'd0 && edge_count == 3'd7)
			   begin
			    if(!strt_glitch)                    // check that start bit not a glitch
				 begin
			      next_state = data ;
                 end
                else 
                 begin
 			      next_state = IDLE ;       
                 end		
               end
			 else
			   begin
			    next_state = start ; 			
               end			  
           end
  data   : begin
             if(bit_count == 4'd8 && edge_count == 3'd7)
			   begin
			     if(parity_enable)
				   begin
			        next_state = parity ;
				   end 
                 else
				   begin
			        next_state = stop ;
                   end					
               end
			 else
			   begin
			    next_state = data ; 			
               end			  
           end 
  parity : begin
             if(bit_count == 4'd9 && edge_count == 3'd7)
			   begin
			    next_state = stop ; 
               end
			 else
			   begin
			    next_state = parity ; 			
               end			  
           end
  stop   : begin
             if(bit_count == 4'd10 && edge_count == 3'd5)
			   begin
			    next_state = err_chk ; 
               end
			 else
			   begin
			    next_state = stop ; 			
               end			  
           end	
  err_chk   : begin
               if(par_err | stp_err)
			   begin
			    next_state = IDLE ; 
               end
			 else
			   begin
			    next_state = data_vld ; 	    				
               end			  
             end	
  data_vld : begin
              if(!S_DATA)
			   next_state = start ;
			  else
			   next_state = IDLE ; 						
             end			  		   
  default: begin
			 next_state = IDLE ; 
           end	
  endcase                 	   
 end 

 
// output logic
always @ (*)
 begin
  edge_bit_en = 1'b0 ;
  dat_samp_en = 1'b0 ;  
  deser_en    = 1'b0 ; 
  par_chk_en  = 1'b0 ; 
  stp_chk_en  = 1'b0 ;
  data_valid  = 1'b0 ;
  strt_chk_en = 1'b0 ;
  case(current_state)
  IDLE   : begin
             if(!S_DATA)
			  begin
               edge_bit_en = 1'b1 ; 
               deser_en    = 1'b0 ; 
               par_chk_en  = 1'b0 ; 
               stp_chk_en  = 1'b0 ;	
			   strt_chk_en = 1'b1 ;
               dat_samp_en = 1'b1 ; 			   
			  end 
			else
			  begin
			   strt_chk_en = 1'b0 ;
               edge_bit_en = 1'b0 ; 
               deser_en    = 1'b0 ; 
               par_chk_en  = 1'b0 ; 
               stp_chk_en  = 1'b0 ;
               dat_samp_en = 1'b0 ; 			   
			  end  			
           end
  start  : begin
			 strt_chk_en = 1'b1 ;  
             edge_bit_en = 1'b1 ; 
             deser_en    = 1'b0 ; 
             par_chk_en  = 1'b0 ; 
             stp_chk_en  = 1'b0 ;
             dat_samp_en = 1'b1 ;			 
           end
  data   : begin
             edge_bit_en = 1'b1 ; 
             deser_en    = 1'b1 ; 
             par_chk_en  = 1'b0 ; 
             stp_chk_en  = 1'b0 ;
             dat_samp_en = 1'b1 ;			 
           end
  parity : begin
             edge_bit_en = 1'b1 ; 
             deser_en    = 1'b0 ; 
             par_chk_en  = 1'b1 ; 
             stp_chk_en  = 1'b0 ;
             dat_samp_en = 1'b1 ;				 
           end
  stop   : begin
             edge_bit_en = 1'b1 ; 
             deser_en    = 1'b0 ; 
             par_chk_en  = 1'b0 ; 
             stp_chk_en  = 1'b1 ;
             dat_samp_en = 1'b1 ;				 
           end	
  err_chk: begin
             edge_bit_en = 1'b0 ; 
             deser_en    = 1'b0 ; 
             par_chk_en  = 1'b0 ; 
             stp_chk_en  = 1'b0 ;
             dat_samp_en = 1'b1 ;				 
           end	
  data_vld:begin
             edge_bit_en = 1'b0 ; 
             deser_en    = 1'b0 ; 
             par_chk_en  = 1'b0 ; 
             stp_chk_en  = 1'b0 ;
             data_valid  = 1'b1 ;
             dat_samp_en = 1'b0 ;				 
           end			   
  default: begin
             edge_bit_en = 1'b0 ; 
             deser_en    = 1'b0 ; 
             par_chk_en  = 1'b0 ; 
             stp_chk_en  = 1'b0 ;	
			 data_valid  = 1'b0 ;
             dat_samp_en = 1'b0 ;				 
		   end 
  endcase                 	   
 end 

endmodule
 
