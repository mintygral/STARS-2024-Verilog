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
    // Write your code here!
    // use fsm to change mode when button is pressed
    fsm changemode (.clk(clk), .rst(!nRst_i), .keyout(button_i), .state(mode_o));

    logic clk_second;
    logic [99:0] clkmax = 100;
    logic pulse;
    clock_divider #(.N(100)) divideby100 (.clk(clk), .rst(!nRst_i), .max(clkmax), .pulse(pulse));

    logic [4:0] max = 31;
    logic [4:0] count;
    logic at_max;

    counter #(.N(5)) count_run (.clk(pulse), .nrst(nRst_i), .enable(mode_o == RUNNING), 
    .clear(mode_o == CLEAR), .wrap(1), .max(max), .count(count), .at_max(at_max));

endmodule