module ClockGen 
#( parameter x)
(
  output reg Clock
);
  initial
    Clock = 0;
  always
    #x Clock <= ~Clock;
endmodule
