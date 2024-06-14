// FPGA Top Level

`default_nettype none

 typedef enum logic [2:0] {
    IDLE = 3'b100,
    RUNNING = 3'b001,
    CLEAR = 3'b010
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
  state_t out;
  logic strobe;
  logic strobe1;
  // allow synchronizer/encoder in order to be able to change states
  synckey encode (.clk(hz100), .rst(reset), .in(pb[2:0]), .out(out), .strobe(strobe), .strobe1(strobe1));

  // fsm will change the mode based on the input from synckey
  state_t current_mode;
  fsm changemode (.clk(strobe), .rst(reset), .keyout(out), .state(current_mode));
  assign right[2:0] = current_mode; // check that states are switching properly --- checked!!!
  
  // divide hz100 by 100 to get output of 1x/second
  logic clksecond;
  logic [99:0] clkmax;
  assign clkmax = 100;
  logic pulse;
  clock_divider #(.N(100)) divideby100 (.clk(hz100), .rst(reset), .max(clkmax),
                .pulse(pulse));

  logic [3:0] max;
  assign max = 4'b1001;
  logic [3:0] count;
  logic at_max;
  // instantiate counter to begin when the mode is running
  counter #(.N(4)) counter8 (.clk(pulse), .nrst(!reset), .enable(current_mode == RUNNING), .clear(current_mode == CLEAR), .wrap(1), 
          .max(max), .count(count), .at_max(at_max));
  
  // display count (set max to 9 for now to limit to one segment display)
  logic [55:0] all_displays;
  assign all_displays = {ss7[6:0], ss6[6:0], ss5[6:0], ss4[6:0], ss3[6:0], ss2[6:0], ss1[6:0], ss0[6:0]};
  ssdec displaycount(.in(count), .enable(1), .out(ss0[6:0]));
endmodule

// encoder
module synckey (
    input clk, rst, // clock and reset ports
    input logic [2:0] in,
    output logic [2:0] out,
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
        out = 3'b0;
        case (in)
            3'b100: out = 3'b100; // IDLE
            3'b010: out = 3'b010; // CLEAR
            3'b001: out = 3'b001; // RUNNING
            // all other cases:
            3'b000: out = out;
            3'b011: out = out;
            3'b110: out = out;
            3'b111: out = out;
            3'b101: out = out;
            default: out = out; // Default case
        endcase
        if (out != 0) begin
            strobe1 = 1;
        end
        if (out == 0) begin
          strobe1 = 0;
        end
        if (out == 0 && (in != 3'b001 | in != 3'b000)) begin
          strobe1 = 1;
        end
        else begin strobe1 = strobe1; end
    end
  endmodule

module fsm (
    input logic clk, rst,
    input logic [2:0] keyout,
    output state_t state
  );

    state_t next_state;
    always_ff @ (posedge clk, posedge rst) begin
      if (rst == 1) begin state <= IDLE; end
      else begin state <= next_state; end 
    end

    always_comb begin 
      next_state = state;
      case(state)
      IDLE: if (keyout == 3'b001) begin next_state = RUNNING; end else begin next_state = IDLE; end
      RUNNING: if (keyout == 3'b001) begin next_state = CLEAR; end else begin next_state = RUNNING; end
      CLEAR: if (keyout == 3'b001) begin next_state = IDLE; end else begin next_state = CLEAR; end
      default: next_state = IDLE;
      endcase
    end
  endmodule

/*
Module name: counter
Description: Counts to a flexible amount. Has strobe at max and controls for wrapping, enable, and clear.
*/
module counter
  #(
      parameter N = 4 // Size of counter (i.e. number of bits at the output). Maximum count is 2^N - 1
  )
  (
      input logic clk,            // Clock
      input logic nrst,           // Asynchronous active low reset
      input logic enable,         // Enable, when enable == 1, counter++; else counter = counter
      input logic clear,          // Synchronous active high clear 
      input logic wrap,           // 0: at_max = 1, next_count == 0;  1: at_max = 1, count holds at max 
      input logic [N - 1:0] max,  // Max number of count (inclusive)

      output logic [N - 1:0] count,   // Current count
      output logic at_max         // 1 when counter is at max, otherwise 0
  );

      logic [N - 1:0] next_count;

      always_comb begin
          // set default assignments to avoid a latch
          next_count = count;
          at_max = (count == max);

          if (clear) begin // clear always takes precedence
              next_count = 0;
          end
          else if (enable) begin // else go to enable
              if (at_max) begin
                  if (wrap) begin next_count = 0; end // reset 
                  else begin next_count = count; end // hold
              end 
              
              else begin next_count = count + 1; end // else increment
          end
      end

      //always_ff block to handle the clk and nrst
      always_ff @(posedge clk) begin
          if (!nrst) begin count <= 0; end 
          else begin count <= next_count; end
      end
  endmodule

module ssdec(
    input logic [3:0] in,
    input logic enable, //sss
    output logic [6:0]out
  );

  always_comb begin : displaynum
    out = 7'b0000000;
    if (enable == 1) begin 
      case(in) 
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
        default: out = 7'b0111111;
      endcase
    end
  end

endmodule


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