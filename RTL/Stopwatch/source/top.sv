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
  state_t current_mode;
  lgoic [4:0] count;
  stop_watch start_stopwatch(.clk(hz100), .nRst_i(!reset), .button_i(pb[0]), .mode_o(current_mode), .time_o(count));
endmodule