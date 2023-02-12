module Shift_Register(
  output reg Tx_Serial_Output,
  output reg Tx_Complete,

  input wire [31:0] Buffer,
  input clk,
  input rst,
  input Tx_Enable
  );
  
  reg [6:0] Index_of_bit;
  reg[31:0] Shift_R;
  reg parity;
  initial begin
    Index_of_bit <=7'b0;
    Tx_Complete <= 1'b1;
  end
  
  always @(posedge clk)
  begin
    if (Tx_Enable == 1)
    begin
      Index_of_bit <= Index_of_bit +1'b1;
      // send Start Bit
      
      if (Index_of_bit == 0)
        begin
          Tx_Complete <= 0;
          Tx_Serial_Output <= 1'b0;
          Shift_R[31:0] <= Buffer[31:0];
          parity <= ^Buffer;
        end
      // send data bits
      else if (Index_of_bit < 33)
        begin
          Tx_Serial_Output <= Shift_R[0];
          Shift_R[31:0] <= Shift_R[31:1];
        end
      // send Parity bit
      else if (Index_of_bit == 33)
        begin
          Tx_Serial_Output <= parity;
        end
      // send stop bit rise Complete_Interrupt
      else if (Index_of_bit == 34)
        begin
          Tx_Serial_Output <= 1'b1;
          Tx_Complete <= 1;
          Index_of_bit <= 0;
        end
    end
  end
endmodule