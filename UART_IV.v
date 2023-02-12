module UART_TX_IV
  #(parameter Baud_R = 312)
  (
  input [31:0] data_to_transition,
  input clock,
  input enable,
  input rst,
  input has_next,
  output wire Tx_Serial_Output,
  output wire bit_clock,
  output reg Finish_int,
  output wire READY
  );
  
  reg Tx_Enable, Tx_Buffer_Empty;
  reg [31:0] Buffer_Reg;
  wire Tx_Complete;
  reg[31:0] Buffer_of_Words [0:3];
  reg [1:0] PC_Buffer;
  reg [1:0] size;

  assign READY = ~(PC_Buffer == 2'b11);
  initial begin
    Tx_Buffer_Empty <= 1'b1;
    PC_Buffer <=0;
    size <= 0;
    Finish_int <= 1;
  end
  // get data to transition from bus and store it in Buffer of word until fetched by Shift_Register
  always @(posedge clock)
    begin
      if (has_next && enable)
        begin
          // if APB need to send Word but Word_buffer is Full
          if (size != 2'b11)
            //BUSYy  = 1'b1;
          // if Word Buffer have Position to store it

            begin
              Buffer_of_Words[size] <= data_to_transition;
              size <= size+1;
              Finish_int <= 0;
            end
			   end
			if (Tx_Complete == 1 && Tx_Buffer_Empty == 1 && ~(PC_Buffer == 0))
			  begin
			   	size <= 0;
			   	Finish_int <= 1;
			  end
			
    end
  
  // when Finish sending all the Buffer, disable Shift
  always @(bit_clock)
    begin
      if (enable)
        begin
      // if Buffer empty and I has data in Word_Buffer => full Buffer and down Buffer_Empty
          if ( Tx_Buffer_Empty == 1 && (PC_Buffer < size) && bit_clock == 0)
            begin
              Buffer_Reg[31:0] <= Buffer_of_Words[PC_Buffer];
              
              Tx_Buffer_Empty <= 0;
              Tx_Enable <= 1;
            end
      // if shift_reg finish and Buffer has Bytes => Transfer Data to Shift and enabe it
          else if (Tx_Buffer_Empty == 0 && Tx_Complete == 1 && bit_clock == 1)
            begin
              PC_Buffer <= PC_Buffer +1;
              Tx_Buffer_Empty <= 1;
            end
          // if end transfer all data, disable shift_reg and rst memory
          else if (Tx_Buffer_Empty == 1 && Tx_Complete == 1)   
            begin
              PC_Buffer <= 0;
              Tx_Enable <= 0;
				    end
        end
    end
  Clock_Divider #(5) Baud_Rate (bit_clock ,clock ,rst,enable);
  Shift_Register SR (Tx_Serial_Output, Tx_Complete, Buffer_Reg, bit_clock, rst, Tx_Enable);
endmodule
