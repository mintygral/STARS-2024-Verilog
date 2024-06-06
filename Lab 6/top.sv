`default_nettype none
// Empty top module

module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);
  
 // enc20to5 encode(.in(pb[19:0]), .out(right[4:0]), .strobe(red));

endmodule

module enc20to5 (
  input logic [19:0] in,
  output logic [4:0] out,
  output logic strobe
);

always @(in) begin
    out = 0;
    casez (in)
        20'b1zzzzzzzzzzzzzzzzzzz: out = 5'b10011; // 19
        20'b01zzzzzzzzzzzzzzzzzz: out = 5'b10010; // 18
        20'b001zzzzzzzzzzzzzzzzz: out = 5'b10001; // 17
        20'b0001zzzzzzzzzzzzzzzz: out = 5'b10000; // 16
        20'b00001zzzzzzzzzzzzzzz: out = 5'b01111; // 15
        20'b000001zzzzzzzzzzzzzz: out = 5'b01110; // 14
        20'b0000001zzzzzzzzzzzzz: out = 5'b01101; // 13
        20'b00000001zzzzzzzzzzzz: out = 5'b01100; // 12
        20'b000000001zzzzzzzzzzz: out = 5'b01011; // 11
        20'b0000000001zzzzzzzzzz: out = 5'b01010; // 10
        20'b00000000001zzzzzzzzz: out = 5'b01001; // 9
        20'b000000000001zzzzzzzz: out = 5'b01000; // 8
        20'b0000000000001zzzzzzz: out = 5'b00111; // 7
        20'b00000000000001zzzzzz: out = 5'b00110; // 6
        20'b000000000000001zzzzz: out = 5'b00101; // 5
        20'b0000000000000001zzzz: out = 5'b00100; // 4
        20'b00000000000000001zzz: out = 5'b00011; // 3
        20'b000000000000000001zz: out = 5'b00010; // 2
        20'b0000000000000000001z: out = 5'b00001; // 1
        20'b00000000000000000001: out = 5'b00000; // 0
        20'b00000000000000000000: out = 0; // 0
        default: out = 5'b00000; // Default case
    endcase
    if (out != 0) begin
        strobe = 1;
    end
    if (out == 0) begin
      strobe = 0;
    end
end

endmodule