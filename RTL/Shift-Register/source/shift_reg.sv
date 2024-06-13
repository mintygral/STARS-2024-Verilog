/*
    Module Name: shift_reg
    Description: Shift Register with multiple mode options
*/

module shift_reg
(
    // Inputs
    input  logic clk, // system clock (max operating freq: 400 Mhz)
    input logic nrst, // asynchronous active low reset
    input logic D, //serial input to the shift register
    input  logic [1:0] mode_i, // 00: HOLD (don't change value in shift register)
                               // 01: LOAD (store value of par_i in register)
                               // 10: LEFT (shift register contents to the left)
                               // 11: RIGHT (shift register contents to the right)
    input  logic [7:0] par_i, // parallel input to the shift register

    // Outputs
    output logic [7:0] P // parallel output of the shift register
);
    logic [7:0] next_P;
    always_comb begin : assignP
        case (mode_i)
            00: next_P = P;
            01: next_P = {D, P[7:1]};
            10: next_P = {P[6:0], D};
            11: next_P = par_i;
            default: 
        endcase
    end
    
endmodule