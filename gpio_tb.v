`timescale 1ns/100ps
module gpio_tb();
  reg           PCLK            ; //clock. Rising edge times all transfers on APB
  reg           PRST_N          ; //Reset. The APB reset signal is active LOW
  reg    [ 7:0] PSEL            ; //Select. Indicates that the slave device is selected
  reg           PENABLE         ; //Enable. indecates the second of APB transfer
  reg           PWRITE          ; //Direction. HIGH ->APB write access   LOW -> APB read access
  wire          PREADY          ; //Ready. The slave uses this signal to extend an APB transfer
  wire          PSLVERR         ; //PSLVERR to indicate an error condition on an APB transfer
  reg   [ 3:0]  PSTRB           ; //Write strobes. This signal indicates which byte lanes to update during a write transfer
  reg   [31:0]  PADDR           ; //Address. can be up to 32 bit wide
  reg   [31:0]  PWDATA          ; //Write data.
  wire  [31:0]  PRDATA          ; //Read data.
  reg   [31:0]  GpioIn          ; //gpio input
  wire  [31:0]  GpioOut         ; //gpio output
  wire  [31:0]  GpioOEn         ; //gpio enable
  
  APB_GPIO test_bench(
  .PCLK(PCLK),
  .PRST_N(PRST_N),
  .PSEL(PSEL),
  .PENABLE(PENABLE),
  .PWRITE(PWRITE),
  .PREADY(PREADY),
  .PSLVERR(PSLVERR),
  .PSTRB(PSTRB),
  .PADDR(PADDR),
  .PWDATA(PWDATA),
  .PRDATA(PRDATA),
  .GpioIn(GpioIn),
  .GpioOut(GpioOut),
  .GpioOEn(GpioOEn)
  );
  initial PCLK=1;
  always #5 PCLK = ~PCLK;
  initial
      begin
         PSEL <=2'b10;
         PADDR <= 4'b0000;
         PWRITE <= 1'b1;
         PWDATA <= 0;
         PSTRB <= 4'b1111;
    #10 PENABLE <=1'b1;
    //PRDATA AS OUTPUT AND GPIOIN
    //GpioIn
      #10;
       GpioIn <= 4'h3;
       PWRITE <= 1'b0;
       PRST_N <= 1'b1;
      #10;
       GpioIn <= 4'h5;
       PWRITE <= 1'b0;
       PRST_N <= 1'b1;
      #10;
       GpioIn <= 4'h7;
       PWRITE <= 1'b0;
       PRST_N <= 1'b1;
       #10;
       PWRITE <= 1'b0;
       
     //GPIOOut
      //#20;
       PWDATA <= 4'h1;
       PWRITE <= 1'b1;
       PRST_N <= 1'b1;
       PADDR <= 4'b0001;
       #20;
       PWDATA <= 4'h9;
       PWRITE <= 1'b1;
       PRST_N <= 1'b1;
       PADDR <= 4'b0001;
       #20;
       PWDATA <= 4'h6;
       PWRITE <= 1'b1;
       PRST_N <= 1'b1;
       PADDR <= 4'b0001;
       #20;
       //GPIOOEn
       //#20;
       PWDATA <= 4'hA;
       PWRITE <= 1'b1;
       PRST_N <= 1'b1;
       PADDR <= 4'b0010;
       #20;
       PWDATA <= 4'h4;
       PWRITE <= 1'b1;
       PRST_N <= 1'b1;
       PADDR <= 4'b0010;
       #20;
       PWDATA <= 4'h5;
       PWRITE <= 1'b1;
       PRST_N <= 1'b1;
       PADDR <= 4'b0010;
       #20;

        end
      endmodule