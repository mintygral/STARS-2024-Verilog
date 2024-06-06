// testbench
`timescale 1ms/10ps
module tb;
  logic [19:0] in;
  logic [4:0] out;
  logic strobe;

  enc20to5 encode(.in(in), .out(out), .strobe(strobe));

  initial begin
    $dumpfile("sim.vcd");
    $dumpvars(0, tb);
    in = 20'b0;
    #1;
    for (integer i=0; i<=19; i++) begin
     in[i] = 1;
      #1;
      $display("in=%b, out=%b, strobe=%b", in, out, strobe);  // checked!! this part works!
    end


    // reset to 0
    // custom cases 
    
    in = 20'b0;
    // for (integer j=0; j<3; j++) begin
    //   in = 20'b0;
    //   integer rand1 = $random % 20;
    //   integer rand2 = $random % 20;
    //   in[rand1] = 1;
    //   in[rand2] = 1;
    //   $display("in=%b, out=%b, strobe=%b", in, out, strobe);
    // end
    
    $display("in=%b, out=%b, strobe=%b", in, out, strobe);
    in = 20'b01000000001000000000;
    $display("in=%b, out=%b, strobe=%b", in, out, strobe);
    #1;

    in = 20'b00000000010000010000;
    $display("in=%b, out=%b, strobe=%b", in, out, strobe);
    #1;

    in = 20'b00000000000000000011;
    $display("in=%b, out=%b, strobe=%b", in, out, strobe);
    #1;
    
    // // Output of custom cases
    // // in=01000000001000000000, out=10011, strobe=1 
    // // in=00000000010000010000, out=10011, strobe=1
    // // in=00000000000000000011, out=10011, strobe=1
    
  end


endmodule
