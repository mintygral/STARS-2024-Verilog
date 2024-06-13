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
    localparam NUM_BITS = 8;

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
            $display("");
        else
            $error("Test number: %d, Test name %s -- Incorrect tb_count value. Actual: %0d, Expected: %0d.", tb_test_num, tb_test_name, tb_count, exp_count);
        
        if(exp_at_max == tb_at_max)
            $display("");
        else
            $error("Test number: %d, Test name %s -- Incorrect tb_at_max value. Actual: %0d, Expected: %0d.", tb_test_num, tb_test_name, tb_at_max, exp_at_max);

    end
    endtask 

    //////////
    // DUT //
    //////////

    // DUT Instance
    counter_8 DUT (
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
        tb_max = 8'hFF; // max value for counting (255 in decimal)

        tb_count_exp = 0;
        tb_at_max_exp = (tb_count == tb_max);
        for (integer i = 0; i < 255; i++) begin
            @(posedge tb_clk);
            tb_count_exp++;
            tb_at_max_exp = (tb_count_exp == 255);
            check_outputs(tb_count_exp, tb_at_max_exp);
        end

        if (tb_count == 255) begin 
            $display("Continuous counting successfully tested."); 
        end

        //////////////////////////////////////
        // Test 2: Discontinuous counting  //
        //////////////////////////////////////

        tb_test_num += 1; 
        tb_test_name = "Discontinous counting";
        $display("Test %d: %s", tb_test_num, tb_test_name);
        reset_dut();

        // Set inputs
        tb_wrap = 1'b1; 
        tb_enable = 1'b1;
        tb_max = 8'hFF; // max value for counting (15 in decimal)

        tb_count_exp = 0;
        tb_at_max_exp = 0;
        for (integer i = 0; i < 200; i++) begin
            @(posedge tb_clk);
            tb_count_exp++;
            tb_at_max_exp = (tb_count == tb_max);
            check_outputs(tb_count_exp, tb_at_max_exp);
        end

        tb_clear = 1'b1;
        @(posedge tb_clk);
        tb_count_exp = 0;
        tb_at_max_exp = (tb_count == tb_max);
        check_outputs(tb_count_exp, tb_at_max_exp);

        @(posedge tb_clk);
        tb_count_exp = 0;
        tb_at_max_exp = (tb_count == tb_max);
        check_outputs(tb_count_exp, tb_at_max_exp);

        tb_clear = 0; // should start counting again

        for (integer i = 0; i < 15; i++) begin
            @(posedge tb_clk);
            tb_count_exp++;
            tb_at_max_exp = (tb_count == tb_max);
            check_outputs(tb_count_exp, tb_at_max_exp);
        end

        if (tb_count == 15) begin $display("Discontinuous counting successfully tested."); end

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
        tb_max = 8'hFF; // max value for counting (15 in decimal)

        tb_count_exp = 0;
        tb_at_max_exp = 0;
        for (integer i = 0; i < 200; i++) begin
            @(posedge tb_clk);
            tb_count_exp++;
            tb_at_max_exp = (tb_count == tb_max);
            check_outputs(tb_count_exp, tb_at_max_exp);
        end

        tb_clear = 1'b1;
        @(posedge tb_clk);
        tb_count_exp = 0;
        tb_at_max_exp = (tb_count == tb_max);
        check_outputs(tb_count_exp, tb_at_max_exp);

        @(posedge tb_clk);
        tb_count_exp = 0;
        tb_at_max_exp = (tb_count == tb_max);
        check_outputs(tb_count_exp, tb_at_max_exp);

        // tb_clear = 1'b0; leave clear == 0

        for (integer i = 0; i < 15; i++) begin
            @(posedge tb_clk);
            tb_count_exp = 0;
            tb_at_max_exp = (tb_count == tb_max);
            check_outputs(tb_count_exp, tb_at_max_exp);
        end

        if (tb_count == 0) begin
            $display("Clear has priority. The final tb_count value is 0.");        
        end

        //////////////////////////////////////
        // Test 4: Wrap around != 1        //
        //////////////////////////////////////

        tb_test_num += 1; 
        tb_test_name = "Wrap test";
        $display("Test %d: %s", tb_test_num, tb_test_name);
        reset_dut();

        // // Set inputs
        // tb_wrap = 1'b0; 
        tb_enable = 1'b1;
        tb_wrap = 1'b0;
        tb_max = 8'hFF; // max value for counting (15 in decimal)

        tb_count_exp = 0;
        tb_at_max_exp = (tb_count == tb_max);
        tb_clear = 0;
        for (integer i = 0; i < 255; i++) begin
            @(posedge tb_clk);
            tb_count_exp++;
            tb_at_max_exp = (tb_count_exp == tb_max);
            check_outputs(tb_count_exp, tb_at_max_exp);
        end

        for (integer i = 0; i < 20; i++) begin
            @(posedge tb_clk);
            tb_count_exp = 255;
            tb_at_max_exp = (tb_count_exp == tb_max);
            check_outputs(tb_count_exp, tb_at_max_exp);
        end

        if (tb_count == 255) begin $display("Wrap not = to 0 successfully tested."); end

        $finish;
        end
    

endmodule