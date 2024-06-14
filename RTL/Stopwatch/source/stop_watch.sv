/*
    Module Name: stop_watch
    Description: Very simple stop watch
*/

 typedef enum logic [2:0] {
    IDLE = 3'b100,
    RUNNING = 3'b001,
    CLEAR = 3'b010
 } state_t;


module stop_watch (
    input logic clk, nRst_i,
    input logic button_i,
    output logic [2:0] mode_o,
    output logic [4:0] time_o
);
  // fsm will change the mode based on the input from synckey
//   state_t mode_o;
  fsm changemode (.clk(clk), .rst(!nRst_i), .keyout(button_i), .state(mode_o));
//   assign left[2:0] = mode_o; // check that states are switching properly --- checked!!!
  
  // divide hz100 by 100 to get output of 1x/second
  logic clksecond;
  logic [99:0] clkmax;
  assign clkmax = 100;
  logic pulse;
  clock_divider #(.N(100)) divideby100 (.clk(clk), .rst(!nRst_i), .max(clkmax), .pulse(pulse));

  logic [4:0] max;
  assign max = 5'b11111;
  logic [4:0] count;
  logic at_max;
  // instantiate counter to begin when the mode is running
  counter #(.N(5)) counter8 (.clk(pulse), .nrst(nRst_i), .enable(mode_o == RUNNING), .clear(mode_o == CLEAR), .wrap(1), 
          .max(max), .count(count), .at_max(at_max));
endmodule

module fsm (
    input logic clk, rst,
    input logic keyout,
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
      IDLE: if (keyout) begin next_state = RUNNING; end else begin next_state = IDLE; end
      RUNNING: if (keyout) begin next_state = CLEAR; end else begin next_state = RUNNING; end
      CLEAR: if (keyout) begin next_state = IDLE; end else begin next_state = CLEAR; end
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
    input logic [4:0] in,
    input logic enable,
    output logic [6:0]out
  );
  
  logic [4:0] in_temp;
  always_comb begin : decrease_in
    // in_temp = in;
    if (in < 10) begin in_temp = in; end
    else if (in < 20  && in > 10) begin in_temp = in - 10; end
    else if (in < 30  && in > 20) begin in_temp = in - 20; end
    else if (in > 30) begin in_temp = in - 30; end
    else begin in_temp = 5'b0; end
  end

  always_comb begin : displaynum
    out = 7'b0000000;
    if (enable == 1) begin 
      case(in_temp) 
        5'b00000: begin out = 7'b0111111; end // none
        5'b00001: begin out = 7'b0000110; end // one
        5'b00010: begin out = 7'b1011011; end // two
        5'b00011: begin out = 7'b1001111; end  // three
        5'b00100: begin out = 7'b1100110; end  // four
        5'b00101: begin out = 7'b1101101; end  // five
        5'b00110: begin out = 7'b1111101; end  // six
        5'b00111: begin out = 7'b0000111; end  // seven
        5'b01000: begin out = 7'b1111111; end  // eight
        5'b01001: begin out = 7'b1100111; end  // nine   
        default: out = 7'b0111111;
      endcase
    end
  end

endmodule

module ssdec2(
    input logic [4:0] in,
    input logic enable,
    output logic [6:0]out
  );

  // this displays the tens place for the counter thingy
  always_comb begin : display_tens
    out = 7'b0000000;
    if (enable == 1) begin 
      if (in < 10) begin out = 7'b0111111; end // none
      if ((in == 10) | ((in > 10) && (in < 20))) begin out = 7'b0000110; end // one
      if ((in == 10) | ((in > 10) && (in < 20))) begin out = 7'b0000110; end // one
      if ((in == 20) | ((in > 20) && (in < 30))) begin out = 7'b1011011; end // two
      if ((in == 30) | (in > 30)) begin out = 7'b1001111; end // two
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