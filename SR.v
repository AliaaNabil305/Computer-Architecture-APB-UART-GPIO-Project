module SR(
  output reg Tx_Serial_Output,
  output reg Tx_Complete,
  output reg[6:0] Index_of_bit,
  output reg [4:0] r_Tx_Data, // 31
  
  input wire [4:0] Shift_R, // 31
  input clk,
  input rst,
  input newData,
  input Tx_Enable
  );
  
  //reg [6:0] Index_of_bit = 0;
  
  initial begin
    Index_of_bit <=7'b0;
  end
  
  always @(posedge clk)
  begin
    if (Tx_Enable == 1)
    begin
      Index_of_bit <= Index_of_bit +1'b1;
      if ((Index_of_bit == 0))
        begin
          Tx_Complete <= 0;
          r_Tx_Data[4:0] <= Shift_R[4:0];
        end
      else if (Index_of_bit < 6)  // 33
        begin
          Tx_Serial_Output <= r_Tx_Data[0];
          r_Tx_Data[3:0] <= r_Tx_Data[3:1]; // 30
          
        end
      else if (Index_of_bit == 6) // 32
        begin
          Tx_Serial_Output <= ^Shift_R; //33
 
        end
      else if (Index_of_bit == 7) // 34
        begin
          Tx_Serial_Output <= 1'b1; 
        end
      else if (Index_of_bit == 8) // 35
        begin
          Tx_Complete <= 1;
          Index_of_bit <= 0;
        end
    end
  end
endmodule

module Shift(
  output reg Tx_Serial_Output,
  output reg Tx_Complete,

  input wire [31:0] Buffer,
  input clk,
  input rst,
  input Tx_Enable
  );
  parameter a = 3'b000;
  parameter b = 3'b101;
  parameter cc = 3'b110;
  reg [6:0] Index_of_bit;
  reg[31:0] Shift_R;
  wire x;
  assign x = {Index_of_bit[5],Index_of_bit[1],Index_of_bit[0]};
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

        case (x)
        a: begin
            Tx_Complete <= 0;
            Tx_Serial_Output <= 1'b0;
            Shift_R[31:0] <= Buffer[31:0];
          end
      // send Parity bit
        b: begin
            Tx_Serial_Output <= ^Shift_R;
        end
      // send stop bit rise Complete_Interrupt
        cc: begin
            Tx_Serial_Output <= 1'b1;
            Tx_Complete <= 1;
            Index_of_bit <= 0;
          end
      // data bits
        default: begin
            Tx_Serial_Output <= Shift_R[0];
            Shift_R[31:0] <= Shift_R[31:1];
          end
        endcase

    end
  end
endmodule
