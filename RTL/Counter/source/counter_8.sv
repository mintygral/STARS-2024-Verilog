/*
module name: counter_8
description: Wraps around counter module, resulting in an 8-bit counter
*/

module counter_8 (
    input logic clk,            // Clock
    input logic nrst,           // Asyncronous active low reset
    input logic enable,         // Enable
    input logic clear,          // Synchronous active high clear 
    input logic wrap,           // 0: no wrap at max, 1: wrap to 0 at max
    input logic [7:0] max,      // Max number of count (inclusive)
    output logic [7:0] count,   // Current count
    output logic at_max         // 1 when counter is at max, otherwise 0
);
    // edit
    // Add an instance of your counter module
    // HINT: What should the value of parameter N be?
    counter #(.N(8)) counter8 (.clk(clk), .nrst(nrst), .enable(enable), .clear(clear), .wrap(wrap), .max(max), .count(count), .at_max(at_max));

endmodule
