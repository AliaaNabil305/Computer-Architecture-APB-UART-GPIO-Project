module Clock_Divider #(parameter DIVIDER)
(clock_out ,clock_in ,reset,enable);

  input clock_in, reset, enable;
  output reg clock_out=0;
  reg[15:0]count=0;

  always@(negedge clock_in,negedge reset)
  begin
    if (!reset)
    begin
      clock_out<=0;
    end
    else if (enable == 0)
      clock_out<= 0;
      
    else if(count==DIVIDER)
    begin
      count=0;
      clock_out<=~clock_out;
    end
    else
    begin
      count=count+1;
      clock_out<=clock_out;
    end
  end

endmodule