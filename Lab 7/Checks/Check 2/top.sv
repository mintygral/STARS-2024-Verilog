`default_nettype none
// Empty top module

 typedef enum logic [3:0] {
    LS0 = 0, LS1 = 1, LS2 = 2, LS3 = 3, LS4 = 4, LS5 = 5, LS6 = 6, LS7 = 7,
    OPEN = 8,
    ALARM = 9,
    INIT = 10
  } state_t;

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
  

  logic [4:0] out;
  logic strobe;
  state_t state;
  synckey encode(.clk(hz100), 
                 .rst(reset), 
                 .in(pb[19:0]), 
                 .out(out), 
                 .strobe(strobe),
                 .strobe1(blue));
  assign right[4:0] = out;



  state_t current_state;
  fsm unlock(.clk(strobe), 
            .rst(reset), 
            .keyout(out),
            .seq(32'h12345678),
            .state(current_state));
  assign left[3:0] = current_state;
  //assign blue = strobe;
  //ssdec curr_state(.in(current_state), .enable(1), .out(ss0[6:0]));
  
endmodule

module fsm (
  input logic clk, rst, 
  input logic [4:0] keyout, 
  input logic [31:0] seq,
  output state_t state
);
  state_t next_state;
  always_ff @ (posedge clk, posedge rst) begin
    if (rst == 1) begin
      state <= INIT;
    end
    else begin
      state <= next_state;
    end
  end
  
  always_comb begin
    next_state = state;
    case(state)
      INIT: if (keyout == 5'd16) begin next_state = LS0; end // 16 = W
        else begin next_state = INIT; end  
      LS0: if (keyout == 1) begin next_state = LS1; end
        else begin next_state = ALARM; end  
      LS1: if (keyout == 2) begin next_state = LS2; end
        else begin next_state = ALARM; end  
      LS2: if (keyout == 3) begin next_state = LS3;end
        else begin next_state = ALARM; end 
      LS3: if (keyout == 4) begin next_state = LS4;end
        else begin next_state = ALARM; end  
      LS4: if (keyout == 5) begin next_state = LS5;end
        else begin next_state = ALARM; end  
      LS5: if (keyout == 6) begin next_state = LS6;end
        else begin next_state = ALARM; end  
      LS6: if (keyout == 7) begin next_state = LS7; end
        else begin next_state = ALARM; end  
      LS7: if (keyout == 8) begin next_state = OPEN;end  // 8 = open
        else begin next_state = ALARM; end  
      OPEN: if (keyout == 16) begin next_state = LS0; end  // alarm = 9
        //else begin next_state = ALARM; end
      ALARM: begin next_state = ALARM; end
      default: next_state = INIT;
    endcase
  end 
endmodule

// encoder from the last lab
module synckey (
  input clk, rst, // clock and reset ports
  input logic [19:0] in,
  output logic [4:0] out,
  output logic strobe,
  output logic strobe1
);
  logic Q;
  //logic strobe1;


  //assign strobe = Q[1];
  // flip-flop 1
  // this takes the input of the OR'd value of the button inputs as data
  // outputs Q
  always_ff @( posedge clk, posedge rst ) begin 
    if(rst) begin
      Q <= 1'b0;
    end
    else begin
      Q <= | in;
    end
  end

  //flip-flop 2
  // input is Q (from first flipflop)
  // output is strobe
  always_ff @( posedge clk, posedge rst ) begin 
    if(rst) begin
      strobe <= 1'b0;
    end
    else begin
      strobe <= Q;
    end
  end


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
          20'b00000000000000000000: out = 5'b00000; // 0
          default: out = 5'b00000; // Default case
      endcase
      if (out != 0) begin
          strobe1 = 1;
      end
      if (out == 0) begin
        strobe1 = 0;
      end
      if (out == 0 && in ==  20'b00000000000000000001) begin
        strobe1 = 1;
      end
  end
endmodule

module ssdec(
  input logic [3:0] in,
  input logic enable, //sss
  output logic [6:0]out
);

always_comb begin
  out = 7'b0000000;
  if (enable == 1) begin
  case({in})
  4'b0000: begin out = 7'b0111111; end // none 
  4'b0001: begin out = 7'b0000110; end // one
  4'b0010: begin out = 7'b1011011; end // two
  4'b0011: begin out = 7'b1001111; end  // three
  4'b0100: begin out = 7'b1100110; end  // four
  4'b0101: begin out = 7'b1101101; end  // five
  4'b0110: begin out = 7'b1111101; end  // six
  4'b0111: begin out = 7'b0000111; end  // seven
  4'b1000: begin out = 7'b1111111; end  // eight
  4'b1001: begin out = 7'b1100111; end  // nine -- checked!!!
  4'b1010: begin out = 7'b1110111; end  // A
  4'b1011: begin out = 7'b1111100; end  // b
  4'b1100: begin out = 7'b0111001; end  // C 
  4'b1101: begin out = 7'b1011110; end  // d
  4'b1110: begin out = 7'b1111001; end  // E
  4'b1111: begin out = 7'b1110001; end  // F -- checked!!!
  default: begin out = 7'b0000000; end
  endcase
  end
end

endmodule