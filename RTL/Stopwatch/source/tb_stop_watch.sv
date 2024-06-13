/*
    Module Name: tb_stop_watch
    Description: Test bench for stop_watch module
*/

`timescale 1ms / 100us

module tb_stop_watch ();

    // Enum for mode types
    typedef enum logic [2:0] {
        IDLE = 3'b100,
        CLEAR = 3'b010, 
        RUNNING = 3'b001
    } MODE_TYPES; 

    // Testbench parameters
    localparam CLK_PERIOD = 10; // 100 Hz clk
    logic tb_checking_outputs; 
    integer tb_test_num;
    string tb_test_case;

    // DUT ports
    logic tb_clk, tb_nRst_i;
    logic tb_button_i;
    logic [4:0] tb_time_o;
    logic [2:0] tb_mode_o;

    // Reset DUT Task
    task reset_dut;
        @(negedge tb_clk);
        tb_nRst_i = 1'b0; 
        @(negedge tb_clk);
        @(negedge tb_clk);
        tb_nRst_i = 1'b1;
        @(posedge tb_clk);
    endtask
    
    // Task that presses the button once
    task single_button_press;
    begin
        @(negedge tb_clk);
        tb_button_i = 1'b1; 
        @(negedge tb_clk);
        tb_button_i = 1'b0; 
        @(posedge tb_clk);  // Task ends in rising edge of clock: remember this!
    end
    endtask

    // Task to check mode output
    task check_mode_o;
    input logic [2:0] expected_mode; 
    input string string_mode; 
    begin
        @(negedge tb_clk); 
        tb_checking_outputs = 1'b1; 
        if(tb_mode_o == expected_mode)
            $info("Correct Mode: %s.", string_mode);
        else
            $error("Incorrect mode. Expected: %s. Actual: %s.", string_mode, tb_mode_o); 
        
        #(1);
        tb_checking_outputs = 1'b0;  
    end
    endtask

    // Task to check time output
    task check_time_o;
    input logic[4:0] exp_time_o; 
    begin
        @(negedge tb_clk);
        tb_checking_outputs = 1'b1;
        if(tb_time_o == exp_time_o)
            $info("Correct time_o: %0d.", exp_time_o);
        else
            $error("Incorrect mode. Expected: %0d. Actual: %0d.", exp_time_o, tb_time_o); 
        
        #(1);
        tb_checking_outputs = 1'b0;  
    end
    endtask

    // Clock generation block
    always begin
        tb_clk = 1'b0; 
        #(CLK_PERIOD / 2.0);
        tb_clk = 1'b1; 
        #(CLK_PERIOD / 2.0); 
    end

    // DUT Portmap
    stop_watch DUT(.clk(tb_clk),
                .nRst_i(tb_nRst_i),
                .button_i(tb_button_i),
                .mode_o(tb_mode_o),
                .time_o(tb_time_o)); 

    // Main Test Bench Process
    initial begin
        // Signal dump
        $dumpfile("dump.vcd");
        $dumpvars; 

        // Initialize test bench signals
        tb_button_i = 1'b0; 
        tb_nRst_i = 1'b1;
        tb_checking_outputs = 1'b0;
        tb_test_num = -1;
        tb_test_case = "Initializing";

        // Wait some time before starting first test case
        #(0.1);

        // ************************************************************************
        // Test Case 0: Power-on-Reset of the DUT
        // ************************************************************************
        tb_test_num += 1;
        tb_test_case = "Test Case 0: Power-on-Reset of the DUT";
        $display("\n\n%s", tb_test_case);

        tb_button_i = 1'b1;  // press button
        tb_nRst_i = 1'b0;  // activate reset

        // Wait for a bit before checking for correct functionality
        #(2);
        check_mode_o(IDLE, "IDLE");
        check_time_o('0);

        // Check that the reset value is maintained during a clock cycle
        @(negedge tb_clk);
        check_mode_o(IDLE, "IDLE");
        check_time_o('0);

        // Release the reset away from a clock edge
        @(negedge tb_clk);
        tb_nRst_i  = 1'b1;   // Deactivate the chip reset
        // Check that internal state was correctly keep after reset release
        check_mode_o(IDLE, "IDLE");
        check_time_o('0);

        tb_button_i = 1'b0;  // release button

        // ************************************************************************
        // Test Case 1: Iterating through the different modes
        // ************************************************************************
        tb_test_num += 1;
        reset_dut;
        tb_test_case = "Test Case 1: Iterating through the different modes";
        $display("\n\n%s", tb_test_case);

        // Initially, mode_o is IDLE
        check_mode_o(IDLE, "IDLE"); 

        // Press button (IDLE->CLEAR)
        single_button_press(); 
        #(CLK_PERIOD * 5); // allow for sync + edge det + FSM delay 
        check_mode_o(CLEAR, "CLEAR"); 

        // Press button (CLEAR->RUNNING)
        single_button_press(); 
        #(CLK_PERIOD * 5);
        check_mode_o(RUNNING, "RUNNING"); 

        // Press button (back to IDLE)
        single_button_press(); 
        #(CLK_PERIOD * 5);
        check_mode_o(IDLE, "IDLE"); 

        // ************************************************************************
        // Test Case 2: Only Changes Modes during Rising edges
        // ************************************************************************
        tb_test_num += 1; 
        reset_dut;
        tb_test_case = "Test Case 2: Stop watch changes mode once for each button press";
        $display("\n\n%s", tb_test_case);

        @(negedge tb_clk); 
        tb_button_i = 1'b1;  // press button

        #(CLK_PERIOD * 20);  // keep button pressed a long time
        check_mode_o(CLEAR, "CLEAR"); 
        @(negedge tb_clk); 
        tb_button_i = 1'b0;  // release button

        // Keep adding to this test case!!

        ////////////////////////////////
        // ADD MORE TEST CASES HERE!! //
        ////////////////////////////////

        $finish; 
    end

endmodule 