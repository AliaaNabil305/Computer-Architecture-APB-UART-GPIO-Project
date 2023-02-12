module Test_Bench();
  wire clk;
  wire clk_out, en, rst,Ready;
  assign en = 1;
  assign rst = 1;
  wire Tx_Serial_Output;
  reg [31:0] Shift_R;
  reg Tx_Enable=1;
  reg [34:0] tx_data_test;
  reg has_next;
  wire finish_Int;
  reg[31:0] test_recieved;
  reg[31:0]expected_data;
  
  initial begin
    has_next <= 0;
    #10 has_next <= 1;
    Shift_R = 32'b10100010000100110011001000101101;
    #10 has_next <= 0;
    test(Shift_R);
    #10 has_next <= 1;
    Shift_R = 32'b11110010000000000000000000001110;
    #10 has_next <= 0;
    #10 has_next <= 1;
    Shift_R = 32'b10000010000000000000000010101010;
    #10 has_next <= 0;
    #10 has_next <= 1;
    Shift_R = 32'b10000010000000000000000010101010;
    #10 has_next <= 0;
    #10 has_next <= 1;
    Shift_R = 32'b10000010000000000000000010101010;
    #10 has_next <= 0;
  end  
  task test;
  input reg[31:0] expected_data;
  integer i;
  
  begin
    #170;
    for (i = 0; i<35; i = i+1) 
      begin
        tx_data_test[i] <= Tx_Serial_Output;
        #120;
      end
      test_recieved = tx_data_test[32:1];
      
      $display("recieved data %b", test_recieved);
      $display("expected data %b", expected_data);
      $display("recieved parity bit %b", tx_data_test[33]);
      $display("recieved start bit %b, and stop bit %b", tx_data_test[0], tx_data_test[34]);
      
      
    end
  endtask
  ClockGen #(5) c (clk);
  UART_TX_IV #(312) uart_Tx 
  (
  Shift_R,
  clk,
  en,
  rst,
  has_next,
  Tx_Serial_Output,
  clk_out,
  finish_Int,
  Ready
  
  );
endmodule 

