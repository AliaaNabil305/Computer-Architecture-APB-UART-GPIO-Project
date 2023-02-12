//================================================================================
// Filename           : apb_gpio.v
// Author             : Malek and Aliaa
// Created On         : 2022-12-15 
// Last Modified      : 2022-12-31
// Description        : gpio driver that is applicable for the apb bus                 
//================================================================================

`timescale 1ns/100ps

module APB_GPIO(
input              PCLK            , //clock. Rising edge times all transfers on APB
input              PRST_N          , //Reset. The APB reset signal is active LOW
input       [ 7:0] PSEL            , //Select. Indicates that the slave device is selected
input              PENABLE         , //Enable. indecates the second of APB transfer
input              PWRITE          , //Direction. HIGH ->APB write access   LOW -> APB read access
output  reg        PREADY          , //Ready. The slave uses this signal to extend an APB transfer
output             PSLVERR         , //PSLVERR to indicate an error condition on an APB transfer
input       [ 3:0] PSTRB           , //Write strobes. This signal indicates which byte lanes to update during a write transfer
input       [31:0] PADDR           , //Address. can be up to 32 bit wide
input       [31:0] PWDATA          , //Write data.
output      [31:0] PRDATA          , //Read data.
input       [31:0] GpioIn          , //gpio input
output      [31:0] GpioOut         , //gpio output
output      [31:0] GpioOEn           //gpio enable
);
parameter     GPIO_ADDR     = 8'b00000001 ;
parameter     GPIO_DIR_ADDR = 8'b00000010 ;

reg    [31:0] INREG           ;  // input regester    
reg    [31:0] OUTREG          ;  // output regester
reg    [31:0] DIRREG          ;  // direction (control) regester


//Input registers, to prevent metastability
reg    [31:0] GpioInQ1        ;  
reg    [31:0] GpioInQ2        ;


assign PSLVERR  = 1'b0        ; //Never an error

/*==============================================
  always block for reading 
===============================================*/
always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        //restet all read regesters
        GpioInQ1 <=  32'b0 ;
        GpioInQ2 <=  32'b0 ;
        INREG    <=  32'b0 ;
    end
    else begin
        //to prevent metastability we make this series
        //check fir more info: shorturl.at/hlsDR
        GpioInQ1 <=  GpioIn   ;
        GpioInQ2 <=  GpioInQ1 ;
        INREG    <=  GpioInQ2 ;
    end
end

/*==============================================
  always block for choosing whitch regester to get the output
  address (1) for GpioOut
  address (2) for GpioOEn
===============================================*/
always @(posedge PCLK or negedge PRST_N) begin
    if (!PRST_N) begin
        OUTREG <=  32'b0  ;
        DIRREG <=  32'b0  ;
    end
    else begin
        if(PSEL[1] & PWRITE) begin
            case(PADDR[7:0]) 
                GPIO_ADDR      : begin 
                                  if(PENABLE)
                                    begin 
                                       OUTREG[7:0] = PSTRB[0] ? PWDATA[7:0] : OUTREG[7:0];
                                       OUTREG[15:8] = PSTRB[1] ? PWDATA[15:8] : OUTREG[15:8];
                                       OUTREG[23:16] = PSTRB[2] ? PWDATA[23:16] : OUTREG[23:16];
                                       OUTREG[31:24] = PSTRB[3] ? PWDATA[31:24] : OUTREG[31:24]; 
                                    end 
                                  end
                
                GPIO_DIR_ADDR  : begin 
                                  if(PENABLE)
                                    begin 
                                       DIRREG[7:0] = PSTRB[0] ? PWDATA[7:0] : DIRREG[7:0];
                                       DIRREG[15:8] = PSTRB[1] ? PWDATA[15:8] : DIRREG[15:8];
                                       DIRREG[23:16] = PSTRB[2] ? PWDATA[23:16] : DIRREG[23:16];
                                       DIRREG[31:24] = PSTRB[3] ? PWDATA[31:24] : DIRREG[31:24]; 
                                    end 
                                  end 
            endcase
        end
    end
end

/*========================================================
implement PREADY signal 
===========================================================*/

          always @(*)
       begin
         if(!PRST_N)
              PREADY = 0;
          else
	  if(PSEL && !PENABLE && !PWRITE)
	     begin PREADY = 0; end
	         
	  else if(PSEL && PENABLE && !PWRITE)
	     begin  
	     PREADY = 1;               
	       end
          else if(PSEL && !PENABLE && PWRITE)
	     begin  PREADY = 0; end

	  else if(PSEL && PENABLE && PWRITE)
	     begin  
	           PREADY = 1;
	     end

         else PREADY = 0;
    end


assign GpioOEn = DIRREG ;
assign GpioOut = OUTREG ;
assign PRDATA  = INREG ;

endmodule