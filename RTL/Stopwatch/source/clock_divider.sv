
module clock_divider 
  #(
      parameter N = 4 // divide by 
  )
  (
    input clk, rst, 
    input [N - 1: 0] max,
    output pulse
  );

    logic [N - 1:0] count;
    counter #(.N(N)) divby100 (.clk(clk), .nrst(!rst), .enable(1), .clear(0), .wrap(1), 
            .max(max), .count(count), .at_max(pulse));
endmodule