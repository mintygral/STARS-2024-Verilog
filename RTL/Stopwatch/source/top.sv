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
  // allow synchronizer/encoder in order to be able to change states
  synckey encode (.clk(hz100), .rst(reset), .in(pb[2:0]), .out(out), .strobe(strobe), .strobe1(blue));

  state_t current_mode;
  fsm changemode (.clk(strobe), .rst(reset), .keyout(out), .state(current_mode));
  assign right[2:0] = current_mode; // check that states are switching properly --- checked!!!
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
      RUNNING: if (keyout == 3'b010) begin next_state = CLEAR; end else begin next_state = RUNNING; end
      CLEAR: if (keyout == 3'b100) begin next_state = IDLE; end else begin next_state = CLEAR; end
      default: next_state = IDLE;
      endcase
    end
  endmodule


