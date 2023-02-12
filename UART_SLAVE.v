module UART_SLAVE(
input wire[3:0] PSTRB,
input wire[7:0] PSEL,
input wire PWRITE,
input wire PENABLE,
input wire[31:0] PWDATA,
input wire[31:0] PADDR,
input wire clk,
input wire serial_in,

output reg [31:0] PRDATA,
output wire READY,
output wire Tx_Serial_Output
);
  reg READY_reg;
  reg [31:0] data;
  reg Tx_Enable=1;
  reg has_next;
  wire finish_Int;
  wire clk_out, en, rst;
  //wire Tx_Serial_Output;
  wire selected;
  wire [31:0] tested_parallel_out; // data that out from RX
  //reg write_selected;
  wire W_READY;
  wire R_READY;
  
  assign en = 1;
  assign rst = 1;
  
 
  
  parameter baud_clks    = 10416;//related to baud rate
  parameter UART_ADDR = 'b00000001;
  assign selected = PSEL[0];
  initial begin
    data = 0;
  end
    
  always@(posedge clk)
  begin
    if((PADDR == UART_ADDR) && (selected))
      begin
        if (PENABLE) 
          begin
            // read from bus to transmit it out on serial wire
            if (PWRITE)
              begin
                has_next <= 1;
                data[7:0] = PSTRB[0] ? PWDATA[7:0]: data[7:0];
                data[15:8] = PSTRB[1] ? PWDATA[15:8]: data[15:8];
                data[23:16] = PSTRB[2] ? PWDATA[23:16]: data[23:16];
                data[31:24] = PSTRB[3] ? PWDATA[31:24]: data[31:24];  
                

              end
            else
              begin
      	          if( R_READY )
	                 begin
	              		   PRDATA[7:0] = PSTRB[0] ? tested_parallel_out[7:0]: PRDATA[7:0];
            		       PRDATA[15:8] = PSTRB[1] ? tested_parallel_out[15:8]: PRDATA[15:8];
              		     PRDATA[23:16] = PSTRB[2] ? tested_parallel_out[23:16]: PRDATA[23:16];
              		     PRDATA[31:24] = PSTRB[3] ? tested_parallel_out[31:24]: PRDATA[31:24];  
           	       end 
              end
          end
        else
          begin
            has_next <= 0;
            
          end
        
          
      end
  end
  
  //MUX to select READY
  always @(posedge clk) begin
    READY_reg = (PWRITE) ? W_READY : R_READY;
  end
  assign READY =  READY_reg;
  
  
  
 UART_TX_IV #(312) uart_Tx 
  (
  data,
  clk,
  en,
  rst,
  has_next,
  Tx_Serial_Output,
  clk_out,
  finish_Int,
  W_READY //To be selected
  );
  
  
  
  /*

  UART_RX #( .TICK(baud_clks)) UART_RX_INST   //  10416
    (
     .enable(en),
     .clk(clk),
     .rst(rst),
     .serial_in(serial_in),
     .READY(R_READY), 
     .parallel_out(tested_parallel_out)
    );
*/
endmodule