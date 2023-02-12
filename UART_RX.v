
module UART_RX 
  #(parameter TICK = 10416)
  (
   input        enable,
   input        clk,
   input        rst,
   input        serial_in,      //receiver input
   output       READY, 
   output [31:0] parallel_out   //receiver output
   
   );
  parameter width_of_bits =32;
  parameter idle_state         = 3'b00;
  parameter start_state = 3'b001;
  parameter receive_state = 3'b010;
  parameter parity_state = 3'b011;
  parameter stop_state  = 3'b100;
  
  
  reg [width_of_bits-1:0]     shift_register  = 0; 
  reg           serial_in_reg   = 1'b1;
  reg [31:0]     clk_counter = 0;
  reg [4:0]     index_of_bit   = 0;          //to track the position of current bit
  reg           RX_Complete_reg= 0;
  reg [2:0]     current_state     = 0;

  always @(posedge clk)
      serial_in_reg <= serial_in;
  
 
  always @(posedge clk,negedge rst)
    begin
       if(enable)
        begin
        if(current_state == idle_state)
          begin
            //clear Registers
            index_of_bit   <= 0;
            RX_Complete_reg<= 1'b0;
            clk_counter <= 0;
            
            if (serial_in_reg == 1'b0)     
              current_state <= start_state;
            else
              current_state <= idle_state;
          end
         
        //  start bit detection
        else if (current_state == start_state)
          begin
            if (clk_counter == (TICK-1/2))
              begin
                if (serial_in_reg == 1'b0)
                  begin
                    clk_counter <= 0;  
                    current_state <= receive_state;
                  end
                else
                  current_state <= idle_state;
              end
            else
              begin
                clk_counter <= clk_counter + 1;
                current_state     <= start_state;
              end
          end   
          
          //receive data bits state      
        else if (current_state == receive_state)
          begin
            if (clk_counter < TICK-1)
              begin
                clk_counter <= clk_counter + 1;
                current_state     <= receive_state;
              end
            else
              begin
                clk_counter   <= 0;
                shift_register[index_of_bit] <= serial_in_reg;
                if (index_of_bit < (width_of_bits-1))
                  begin
                    index_of_bit <= index_of_bit + 1; //shifting
                    current_state   <= receive_state;
                  end
                else
                  begin
                    index_of_bit <= 0;
                    current_state   <= parity_state;
                  end
              end
          end
        else if (current_state == parity_state)
          begin
            if (clk_counter < TICK-1)
              begin
                clk_counter <= clk_counter + 1;
                current_state     <= parity_state;
              end
            else
              begin
                    clk_counter <= 0;  
                    current_state <= stop_state;
              end
          end
           //stop bit detection 
        else if (current_state == stop_state)
          begin
            if (clk_counter < TICK-1)
              begin
                clk_counter <= clk_counter + 1;
                current_state     <= stop_state;
              end
            else
              begin
                RX_Complete_reg<= 1'b1;
                clk_counter <= 0;
                #(300)
                shift_register <= 32'b0;
                current_state <= idle_state;
                RX_Complete_reg   <= 1'b0;
              end
          end
        else 
          current_state = idle_state;
    end 
   end
  assign READY   = RX_Complete_reg;
  assign parallel_out = shift_register;
endmodule
