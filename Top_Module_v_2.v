////////////////////////////////////////////////////////////////////////////////// 
// Create Date:  04/01/2023 
// Design Name:  APB_GPIO_UART
// Module Name:  Top_Module_v_2
// Project Name: GPIO_UART connection using APB Bus implemented in Velilog
// 
// Description: GPIO_UART connection using APB Bus implemented in Velilog
// 
// Team Members: 1- Alaa Salah Abd El-Fattah Haredy
//               2- Youssef Emad 
//               3- Malek Abdelrhman Hassan	
//               4- Aliaa Nabil Mahmoud	
//               5- Andrew Adel Hosny Goued	
//               6- Sewar Abdullah Askar
//////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////
//////////////// Module Difinition ///////////////////// 
////////////////////////////////////////////////////////
module Top_Module_v_2 #(parameter DATA_WIDTH = 'd32,  ADDRESS_WIDTH = 'd32, STRB_WIDTH = 'd4, SLAVES_NUM = 'd8)
                        (
                        input  wire                      PCLK       ,
                        input  wire                      PRESETn    ,
                        input  wire  [ADDRESS_WIDTH-1:0] IN_ADDR    ,
                        input  wire  [DATA_WIDTH-1:0]    IN_DATA    ,
                        //input  wire  [DATA_WIDTH-1:0]    PRDATA     ,  internal signal
                        input  wire  [2:0]               IN_PROT    ,
                        input  wire                      IN_WRITE   ,
                        input  wire  [STRB_WIDTH-1:0]    IN_STRB    ,
                        input  wire                      Transfer   ,
                        //input  wire                      PREADY     ,  internal wire bcs you get it from slave
                        //input  wire                      PSLVERR    ,
                        input  wire     [DATA_WIDTH-1:0] GPIO_in,
                        input wire                       serial_in,
                      
                        output reg                       OUT_SLVERR ,
                        output reg   [DATA_WIDTH-1:0]    OUT_RDATA  ,
                        output reg   [DATA_WIDTH-1:0]    GpioOEn,
                        output reg   [DATA_WIDTH-1:0]    Gpio_out,
                        output wire                      serial_out
                        );
                        
///////////////////////////////////////////////////////////////////////////////////
//////////////////////Internal wires connection needed/////////////////////////////
/////////////////////////////////////////////////////////////////////////////////// 

wire ready_internal,ready_gpio,ready_uart;
wire [DATA_WIDTH-1:0] GpioOut;
wire [DATA_WIDTH-1:0] Gpio_OEn;
wire [SLAVES_NUM-1:0] select_internal;
wire enable_internal,write_internal;
wire [STRB_WIDTH-1:0] strobes_internal;
wire [ADDRESS_WIDTH-1:0] add_internal;
wire [DATA_WIDTH-1:0]  write_data,read_data,read_data_gpio,read_data_uart;
wire [DATA_WIDTH-1:0] read_out;
wire slverr_out;
wire PSLVERR;

assign ready_internal = (select_internal[1] && !select_internal[0])? ready_gpio : (select_internal[0] && !select_internal[1])? ready_uart : 0;
assign read_data = (select_internal[1] && !select_internal[0])? read_data_gpio : (select_internal[0] && !select_internal[1])? read_data_uart : 0;
//////////////////////////////////////////////////////
///////////////// GPIO connect ///////////////////////
//////////////////////////////////////////////////////
  
  APB_GPIO APB_to_connect(
  .PCLK(PCLK),
  .PRST_N(PRESETn),
  .PSEL(select_internal),
  .PENABLE(enable_internal),
  .PWRITE(write_internal),
  .PREADY(ready_gpio),
  .PSLVERR(PSLVERR),
  .PSTRB(strobes_internal),
  .PADDR(add_internal),
  .PWDATA(write_data),
  .PRDATA(read_data_gpio),
  .GpioIn(GPIO_in),
  .GpioOut(GpioOut),//1 --> add[7:0]
  .GpioOEn(Gpio_OEn)//2 --> add[7:0]
  );
//wire [DATA_WIDTH-1:0] GpioOut;
//wire [DATA_WIDTH-1:0] GpioOEn;
always @(*)
begin
Gpio_out <=  GpioOut;
GpioOEn  <=  Gpio_OEn;
OUT_SLVERR <=slverr_out;
OUT_RDATA  <= read_out;
end
///////////////////////////////////////////////////////////////////////////////////
//////////////////////////////UART Connect/////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
UART_SLAVE uart_apb_connect(
  strobes_internal,
  select_internal,
  write_internal,
  enable_internal,
  write_data,
  add_internal,
  PCLK,
  serial_in,
  read_data_uart,
  ready_uart,
  serial_out
);

///////////////////////////////////////////////////////////////////////////////////
//////////////////////////////APB_Master instantiation/////////////////////////////
/////////////////////////////////////////////////////////////////////////////////// 
 APB_MASTER #(.DATA_WIDTH(DATA_WIDTH),  .ADDRESS_WIDTH(ADDRESS_WIDTH), .STRB_WIDTH(STRB_WIDTH), .SLAVES_NUM(SLAVES_NUM))
 APB_MASTER_connect_GPIO (
 .PCLK(PCLK),
 .PRESETn(PRESETn),
 .IN_ADDR(IN_ADDR),
 .IN_DATA(IN_DATA),
 .PRDATA(read_data),
 .IN_WRITE(IN_WRITE),
 .Transfer(Transfer),
 //.PREADY(PREADY_TB),
 .PREADY(ready_internal),
 .PSLVERR(PSLVERR),
 .IN_PROT(IN_PROT),
 .IN_STRB(IN_STRB),
 
 .PPROT(PPROT),
 .PSTRB(strobes_internal),
 //.OUT_SLVERR(OUT_SLVERR),
 .OUT_SLVERR(slverr_out),  
 //.OUT_RDATA(OUT_RDATA),
 .OUT_RDATA(read_out),
 .PADDR(add_internal),
 .PWDATA(write_data),
 .PWRITE(write_internal),
 .PENABLE(enable_internal),
 .PSEL(select_internal)
 );
 
 endmodule
                      