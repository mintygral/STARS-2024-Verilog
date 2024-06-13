/*
    Module name: tb_counter
    Description: A testbench for the counter module
    (using default bit size of 4)
*/

`timescale 1ns/1ps

module tb_counter();

    /////////////////////
    // Testbench Setup //
    /////////////////////
    
    // Define local parameters
    localparam CLK_PERIOD = 10; // 100 MHz 
    localparam RESET_ACTIVE = 0;
    localparam RESET_INACTIVE = 1;
    localparam NUM_BITS = 4;

    // Testbench Signals
    integer tb_test_num;
    string tb_test_name; 

    // DUT Inputs
    logic tb_clk;
    logic tb_nrst;
    logic tb_enable;
    logic tb_clear;
    logic tb_wrap;
    logic [NUM_BITS-1:0] tb_max;

    // DUT Outputs
    logic [NUM_BITS-1:0] tb_count;
    logic tb_at_max;

    // Expected values for checks
    logic [NUM_BITS-1:0] tb_count_exp; 
    logic tb_at_max_exp; 

    // Signal Dump
    initial begin
        $dumpfile ("dump.vcd");
        $dumpvars;
    end

    ////////////////////////
    // Testbenching tasks //
    ////////////////////////

    // Quick reset for 2 clock cycles
    task reset_dut;
    begin
        @(negedge tb_clk); // synchronize to negedge edge so there are not hold or setup time violations
        
        // Activate reset
        tb_nrst = RESET_ACTIVE;

        // Wait 2 clock cycles
        @(negedge tb_clk);
        @(negedge tb_clk);

        // Deactivate reset
        tb_nrst = RESET_INACTIVE; 
    end
    endtask

    // Check output values against expected values
    task check_outputs;
        input logic [NUM_BITS-1:0] exp_count; 
        input logic exp_at_max; 
    begin
        @(negedge tb_clk);  // Check away from the clock edge!
        if(exp_count == tb_count)
            $info("Correct tb_count value.");  
        else
            $error("Incorrect tb_count value. Actual: %0d, Expected: %0d.", tb_count, exp_count);
        
        if(exp_at_max == tb_at_max)
            $info("Correct tb_at_max value.");
        else
            $error("Incorrect tb_at_max value. Actual: %0d, Expected: %0d.", tb_at_max, exp_at_max);

    end
    endtask 

    //////////
    // DUT //
    //////////

    // DUT Instance
    counter DUT (
        .clk(tb_clk),
        .nrst(tb_nrst),
        .enable(tb_enable),
        .clear(tb_clear),
        .wrap(tb_wrap),
        .max(tb_max),
        .count(tb_count),
        .at_max(tb_at_max)
    );

    // Clock generation block
    always begin
        tb_clk = 0; // set clock initially to be 0 so that they are no time violations at the rising edge 
        #(CLK_PERIOD / 2);
        tb_clk = 1;
        #(CLK_PERIOD / 2);
    end

    initial begin

        // Initialize all test inputs
        tb_test_num = -1;  // We haven't started testing yet
        tb_test_name = "Test Bench Initialization";
        tb_nrst = RESET_INACTIVE;
        tb_enable = 0;
        tb_clear = 0;
        tb_wrap = 0;
        tb_max = 0;
        // Wait some time before starting first test case
        #(0.5);

        ////////////////////////////
        // Test 0: Power on reset //
        ////////////////////////////

        // NOTE: Do not use reset task during reset test case 
        tb_test_num+=1;
        tb_test_name = "Power on Reset";
        $display("Test %d: %s", tb_test_num, tb_test_name);
        // Set inputs to non-reset values
        tb_enable = 1;
        tb_clear = 0;
        tb_wrap = 1;
        tb_max = '1;

        // Activate Reset
        tb_nrst = RESET_ACTIVE;

        #(CLK_PERIOD * 2); // Wait 2 clock periods before proceeding
        
        // Check outputs are reset
        tb_count_exp = 0; 
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // Deactivate Reset
        tb_nrst = RESET_INACTIVE;

        // Check outputs again
        tb_count_exp = 1;  // because enable is high
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        //////////////////////////////////////
        // Test 1: Test Continuous Counting //
        //////////////////////////////////////

        tb_test_num += 1; 
        tb_test_name = "Continuous Counting";
        $display("Test %d: %s", tb_test_num, tb_test_name);
        reset_dut();

        // Set inputs
        tb_wrap = 1'b1; 
        tb_enable = 1'b1;
        tb_max = 4'hF; // max value for counting (15 in decimal)

        // Keep adding to this test case!
        // Check outputs after a few clock periods!
        // 1
        @(posedge tb_clk);
        tb_count_exp = 1;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // 2
        @(posedge tb_clk);
        tb_count_exp = 2;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // 3
        @(posedge tb_clk);
        tb_count_exp = 3;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);
        
        // 4
        // #(CLK_PERIOD);
        @(posedge tb_clk);
        tb_count_exp = 4;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);
        
        // 5
        // #(CLK_PERIOD);
        @(posedge tb_clk);
        tb_count_exp = 5;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);
        
        // // 6
        #(CLK_PERIOD);
        @(negedge tb_clk);
        tb_count_exp = 7;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);
        
        // // 7
        #(CLK_PERIOD);
        @(negedge tb_clk);
        tb_count_exp = 9;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // // Max
        #(CLK_PERIOD);
        @(negedge tb_clk);
        tb_count_exp = 11;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // #(CLK_PERIOD);
        @(negedge tb_clk);
        tb_count_exp = 13;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // #(CLK_PERIOD);
        @(negedge tb_clk);
        tb_count_exp = 15;
        tb_at_max_exp = 1;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // // 8 -- RESET
        // #(CLK_PERIOD / 2);
        @(posedge tb_clk);
        tb_count_exp = 0;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // // 10
        // #(CLK_PERIOD);
        @(posedge tb_clk);
        tb_count_exp = 1;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        
        // // 11
        // #(CLK_PERIOD);
        @(posedge tb_clk);
        tb_count_exp = 2;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // // 12
        // #(CLK_PERIOD);
        @(posedge tb_clk);
        tb_count_exp = 3;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        //////////////////////////////////////
        // Test 3: Discontinuous counting  //
        //////////////////////////////////////

        tb_test_num += 1; 
        tb_test_name = "Discontinous counting";
        $display("Test %d: %s", tb_test_num, tb_test_name);
        reset_dut();

        // Set inputs
        tb_wrap = 1'b1; 
        tb_enable = 1'b1;
        tb_max = 4'hF; // max value for counting (15 in decimal)

        @(posedge tb_clk);
        tb_count_exp = 1;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // 2
        @(posedge tb_clk);
        tb_count_exp = 2;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // 3
        @(posedge tb_clk);
        tb_count_exp = 3;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);
        
        // 4
        // #(CLK_PERIOD);
        @(posedge tb_clk);
        tb_count_exp = 4;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);
        
        // 5
        // #(CLK_PERIOD);
        @(posedge tb_clk);
        tb_count_exp = 5;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);
        
        // // 6
        #(CLK_PERIOD);
        @(negedge tb_clk);
        tb_count_exp = 7;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);
        
        // // 7
        #(CLK_PERIOD);
        @(negedge tb_clk);
        tb_count_exp = 9;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // // Max
        #(CLK_PERIOD);
        @(negedge tb_clk);
        tb_count_exp = 11;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // #(CLK_PERIOD);
        @(negedge tb_clk);
        tb_count_exp = 13;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // clear
        tb_clear = 1'b1;
        @(negedge tb_clk);
        tb_count_exp = 0;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // // reset
        tb_clear = 1'b1;
        @(posedge tb_clk);
        tb_count_exp = 0;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // // 10
        tb_clear = 0;
        @(posedge tb_clk);
        tb_count_exp = 1;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // // 11
        // #(CLK_PERIOD);
        @(posedge tb_clk);
        tb_count_exp = 2;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // // 12
        // #(CLK_PERIOD);
        @(posedge tb_clk);
        tb_count_exp = 3;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        //////////////////////////////////////
        // Test 3: Checking clear priority //
        //////////////////////////////////////

        tb_test_num += 1; 
        tb_test_name = "Checking clear priority";
        $display("Test %d: %s", tb_test_num, tb_test_name);
        reset_dut();

        // Set inputs
        tb_wrap = 1'b1; 
        tb_enable = 1'b1;
        tb_max = 4'hF; // max value for counting (15 in decimal)

        // 1
        @(negedge tb_clk);
        tb_count_exp = 2;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // 2
        #(CLK_PERIOD);
        @(negedge tb_clk);
        tb_count_exp = 4;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // 3
        #(CLK_PERIOD);
        @(negedge tb_clk);
        tb_count_exp = 6;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);
        
        // 4
        #(CLK_PERIOD);
        @(negedge tb_clk);
        tb_count_exp = 8;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);
        
        // 5
        #(CLK_PERIOD);
        @(negedge tb_clk);
        tb_count_exp = 10;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);
        
        // 6 -- CLEAR 
        #(CLK_PERIOD);
        tb_clear = 1'b1;
        @(negedge tb_clk);
        tb_count_exp = 0;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // 7
        @(negedge tb_clk);
        tb_count_exp = 0;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // 8
        @(negedge tb_clk);
        tb_count_exp = 0;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);
        
        // 9
        @(negedge tb_clk);
        tb_count_exp = 0;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // 10
        @(negedge tb_clk);
        tb_count_exp = 0;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        //////////////////////////////////////
        // Test 3: Wrap around != 1        //
        //////////////////////////////////////

        tb_test_num += 1; 
        tb_test_name = "No wrap around this time";
        $display("Test %d: %s", tb_test_num, tb_test_name);
        reset_dut();

        // Set inputs
        tb_wrap = 0; 
        tb_enable = 1'b1;
        tb_max = 4'hF; // max value for counting (15 in decimal)
        tb_clear = 0;

        // Keep adding to this test case!
        // Check outputs after a few clock periods!
        // 1
        @(posedge tb_clk);
        tb_count_exp = 1;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // 2
        @(posedge tb_clk);
        tb_count_exp = 2;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // 3
        @(posedge tb_clk);
        tb_count_exp = 3;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);
        
        // 4
        // #(CLK_PERIOD);
        @(posedge tb_clk);
        tb_count_exp = 4;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);
        
        // 5
        // #(CLK_PERIOD);
        @(posedge tb_clk);
        tb_count_exp = 5;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);
        
        // // 6
        #(CLK_PERIOD);
        @(negedge tb_clk);
        tb_count_exp = 7;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);
        
        // // 7
        #(CLK_PERIOD);
        @(negedge tb_clk);
        tb_count_exp = 9;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // // Max
        #(CLK_PERIOD);
        @(negedge tb_clk);
        tb_count_exp = 11;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // #(CLK_PERIOD);
        @(negedge tb_clk);
        tb_count_exp = 13;
        tb_at_max_exp = 0;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // #(CLK_PERIOD);
        @(negedge tb_clk);
        tb_count_exp = 15;
        tb_at_max_exp = 1;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // // 8 -- RESET
        // #(CLK_PERIOD / 2);
        @(posedge tb_clk);
        tb_count_exp = 15;
        tb_at_max_exp = 1;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // // 10
        // #(CLK_PERIOD);
        @(posedge tb_clk);
        tb_count_exp = 15;
        tb_at_max_exp = 1;
        check_outputs(tb_count_exp, tb_at_max_exp);

        
        // // 11
        // #(CLK_PERIOD);
        @(posedge tb_clk);
        tb_count_exp = 15;
        tb_at_max_exp = 1;
        check_outputs(tb_count_exp, tb_at_max_exp);

        // // 12
        // #(CLK_PERIOD);
        @(posedge tb_clk);
        tb_count_exp = 15;
        tb_at_max_exp = 1;
        check_outputs(tb_count_exp, tb_at_max_exp);
        $finish;
    end


endmodule
