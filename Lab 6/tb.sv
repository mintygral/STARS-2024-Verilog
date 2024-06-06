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

    // for loop to test all possible inputs
    for (integer i=0; i<=15; i++) begin
      for (integer j=0; j<=9; j++) begin
        for (integer k=0; k<=1; k++) begin
          A = i; B = j; Cin = k;
          #1;
          $display("A=%b, B=%b, Cin=%b, Cout=%b, S=%b", A,B,Cin,Cout,S);
        end
      end
    end

    #1 $finish;
  end

endmodule
