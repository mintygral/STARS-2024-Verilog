`timescale 1ms/10ps
module tb;

// inputs
logic clk;
logic rst;
logic [19:0] in;


initial clk = 0;
always clk = #50 ~clk;

// outputs
logic [4:0] out;
logic strobe;
// logic [7:0] data;

synckey testing (.clk(clk), .rst(rst), .in(in), .out(out), .strobe(strobe));

initial begin 
    $dumpfile("sim.vcd");
    $dumpvars(0, tb);
    #10;
    rst = 0; 
    // clk = 0; 
    in = 20'b0; // set inputs to 0
    toggle_rst();

    // for loop to iterate over all possible test cases
    //logic [19:0] temp;
    // for (in = 20'b0; in <= 20'hFFFFF; in++) begin
    //     $display("in = %b, out = %b, reset = %b, clock = %b", in, out, rst, clk);
    //     #10;
    //  end
    #10;
    for (integer i=0; i<=19; i++) begin
     in[i] = 1;
      #1;
      $display("in = %b, out = %b, reset = %b, clock = %b", in, out, rst, clk);
    end
    #10
    in = 20'b00000000000000000011;
    #10;
    if (out != 5'b00001) begin
        $display("incorrect in = %b, out = %b, reset = %b, clock = %b", in, out, rst, clk);
    end

    #10
    in = 20'b10000000000000000011;
    #10;
    if (out != 5'b10011) begin
        $display("incorrect in = %b, out = %b, reset = %b, clock = %b", in, out, rst, clk);
    end
    // #10
    // in = 20'b001;
    // #10;
    // if (out != 5'b10011) begin
    //     $display("incorrect in = %b, out = %b, reset = %b, clock = %b", in, out, rst, clk);
    // end


    #1 $finish;
    $display("Simulation finished.");
end

task toggle_rst;
    rst = 1; #10;
    rst = 0; #10;
endtask

endmodule

