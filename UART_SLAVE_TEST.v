module UART_SLAVE_TEST();
  reg[3:0] PSTRB;
  reg[7:0] PSEL;
  reg PWRITE;
  reg PENABLE;
  reg[31:0] PWDATA;
  wire[31:0] PRDATA;
  reg[31:0] PADDR;
  reg tested_serial_in = 1;
  //reg OUT_SLVER;
  wire clk;

  wire READY;
  //Uart Rx receiver data from peripheral
  //for clock frequncy 100MHz and baud rate 9600
  parameter clk_time = 10;
  parameter baud_clks    = 10416;
  parameter bit_time      = 105000;
  parameter width_of_bits =32;
    task write_data;
    input [width_of_bits-1:0] tested_data_holder;
    integer     counter;
    begin
      
      // Send Start Bit
      tested_serial_in <= 1'b0;
      #(bit_time);
      
      
      // Send Data Byte
      for (counter=0; counter<width_of_bits; counter=counter+1)
        begin
          tested_serial_in <= tested_data_holder[counter];
          #(bit_time);
        end
      // Send parity
      tested_serial_in <= 1'b0;
      #(bit_time);
      
      // Send Stop Bit
      tested_serial_in <= 1'b1;
      #(bit_time);
     end
  endtask // write_data
  
  initial 
    begin
  
   PSTRB = 'b0001;
    PSEL <= 'b00000001;
    PADDR = 'b1;
    PWRITE = 1;
    PENABLE <= 0;
    #20 PENABLE <= 1;
    PWDATA = 32'b10100010000000000000000000101101;
    #20 PENABLE <= 0;
    #10 PENABLE <= 1;
    PSTRB = 'b1010;
    PWDATA = 32'b11110010000000000000000000001110;
    #10 PENABLE <= 0;
    #10 PENABLE <= 1;
    
    
    // Test Read operation
    PSTRB = 'b0001;
    PSEL <= 'b00000001;
    PADDR = 'b1;
    PWRITE = 0;
    PENABLE <= 1;
    write_data(32'hAAAAAAAF);
    
    //#10 PENABLE <= 0;
    end
 ClockGen #((clk_time/2)) c (clk);
 UART_SLAVE utxs(
  PSTRB,
  PSEL,
  PWRITE,
  PENABLE,
  PWDATA,
  PADDR,
  clk,
  tested_serial_in,
  PRDATA,
  READY
);

endmodule
