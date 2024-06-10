`timescale 1ms/10ps

// typedef enum logic [3:0] {
// LS0=0, LS1=1, LS2=2, LS3=3, LS4=4, LS5=5, LS6=6, LS7=7,
// OPEN=8, ALARM=9, INIT=10
// } state_t;
module tb;
//state_t state;
logic clk, rst, en;
logic [4:0] in;
logic [31:0] out;

sequence_sr seq0(.clk(clk), .rst(rst), . en(en), .in(in), .out(out));

initial clk = 0;
always clk = #5 ~clk;


task power_on_reset;
 rst = 0;

 #10;
 rst = 1; 
  #10;
 rst = 0;

endtask


initial begin
 $dumpfile("sim.vcd");
 $dumpvars(0, tb);
 rst = 1'b1;
 en = 1;



 @(posedge clk);
 power_on_reset();
 in = 5'd4;
 #10;
 in = 5'd5;
 #10;
 in = 5'd6;
 #10;
 in = 5'd7;
 #10;

 $finish;

end

endmodule

// module sequence_sr (
//  input logic clk, rst, en,
//  input logic [4:0] in,
//  output logic [31:0] out
//  );

//  // logic [31:0]next_out;

//  // assign next_out = 32'b0;

//  always_ff @(posedge clk, posedge rst ) begin
//      if (rst) begin
//        out <= 0;
//      end else begin
//        out <= (en == 1 && in < 5'd16) ? {out[27:0], in[3:0]} : out;
//      end
//  end

 
// endmodule


