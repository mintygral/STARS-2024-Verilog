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
    input logic wrap,           // 0: at_max = 1, next_count == 0
                                // 1: at_max = 1, count holds at max 
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
