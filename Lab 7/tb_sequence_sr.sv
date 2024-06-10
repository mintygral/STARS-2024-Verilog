`timescale 1ms/10ps
module tb;

 typedef enum logic [3:0] {
    LS0 = 0, LS1 = 1, LS2 = 2, LS3 = 3, LS4 = 4, LS5 = 5, LS6 = 6, LS7 = 7,
    OPEN = 8,
    ALARM = 9,
    INIT = 10
  } state_t;


// outputs
// logic [4:0] keyout;
state_t current_state;
logic strobe;
logic rst;
// logic [16:0] in;
initial strobe = 0;
always strobe = #10 ~strobe;
logic [4:0] keyout;
logic [31:0] password;
logic [31:0] pass_temp;
assign pass_temp = 32'd0;


sequence_sr entercode(.clk(strobe),
                    .rst(reset),
                    .en(current_state == INIT),
                    .in(keyout),
                    .out(password));

        
initial begin 
    $dumpfile("sim.vcd");
    $dumpvars(0, tb);
    // #10;
    // password = 32'd0;
    toggle_rst();
    current_state = INIT;

    @(posedge strobe);
    keyout = 8;
    @(negedge strobe);
    if (password != {pass_temp[27:0], keyout[3:0]}) begin 
        $display("Error shifting");
    end
  

    @(posedge strobe);
    keyout = 3;
    @(posedge strobe);
    if (password != {pass_temp[26:0], 1'h8, keyout[3:0]}) begin 
        $display("Error shifting");
    end
    


    @(posedge strobe);
    keyout = 5;
    @(posedge strobe);
    if (password != {pass_temp[25:0], 1'h8, 1'h3, keyout[3:0]}) begin 
        $display("Error shifting");
    end
    
    
    // #10 
    $finish;
    $display("Simulation finished.");
end

task toggle_rst; 
    rst = 0; #10;
    rst = 1; #10;
    rst = 0; #10;
endtask

task send_key;
    input logic [4:0] keytosend;
    begin 
        @ (negedge strobe);
        keyout = keytosend;
        @ (posedge strobe);
        #10;
    end

endtask

task sendstream;
    input logic [4:0] stream [];
    begin 
        for (integer keynum = 0; keynum < stream.size(); keynum++) begin
            send_key(stream[keynum]); end
    end
endtask


endmodule

