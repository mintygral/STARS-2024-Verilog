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
logic [31:0] password;
logic [4:0] testdata [];
logic [63:0] ss;
logic red, green, blue;


display displayresults(.state(current_state), .seq(password), .ss(ss),
                        .red(red), .green(green), .blue(blue));

        
initial begin 
    $dumpfile("sim.vcd");
    $dumpvars(0, tb);
    #10;
    password = 0;
    current_state = INIT;
    #10;
    current_state = OPEN;
    #10; 
    if (ss[63:56] != 8'b00111111 &&
        ss[55:48] != 8'b01110011  &&
        ss[47:40] != 8'b01111001 &&
        ss[39:32] != 8'b00110111) begin
            $display("ss not working.");
        end

    #10;
    current_state = ALARM;
    #10; 
    if (ss[63:56] != 8'b00111001 &&
        ss[55:48] != 8'b01110111 &&
        ss[47:40] != 8'b00111000 &&
        ss[39:32] != 8'b00111000 &&
        ss[31:24] != 8'b01100111 &&
        ss[23:16] != 8'b00000110 &&
        ss[15:8] != 8'b00000110 )  begin
            $display("ss not working.");
        end
    
    #10; 
    current_state = LS0;
    #10; 
    if (ss[63] != 1'b1) begin $display("ss not working."); end 

    #10; 
    current_state = LS1;
    #10; 
    if (ss[55] != 1'b1) begin $display("ss not working."); end 

    #10; 
    current_state = LS2;
    #10; 
    if (ss[47] != 1'b1) begin $display("ss not working."); end 
    
    #10; 
    current_state = LS3;
    #10; 
    if (ss[39] != 1'b1) begin $display("ss not working."); end 
    
    #10; 
    current_state = LS4;
    #10; 
    if (ss[31] != 1'b1) begin $display("ss not working."); end 
    
    #10; 
    current_state = LS5;
    #10; 
    if (ss[23] != 1'b1) begin $display("ss not working."); end 
    
    #10; 
    current_state = LS6;
    #10; 
    if (ss[15] != 1'b1) begin $display("ss not working."); end 
    
    #10; 
    current_state = LS7;
    #10; 
    if (ss[8] != 1'b1) begin $display("ss not working."); end 
    #10 $finish;
    $display("Simulation finished.");
end

// task send_key;
//     input logic [4:0] keytosend;
//     begin 
//         @ (negedge strobe);
//         keyout = keytosend;
//         @ (posedge strobe);
//         #10;
//     end

// endtask

// task sendstream;
//     input logic [4:0] stream [];
//     begin 
//         for (integer keynum = 0; keynum < stream.size(); keynum++) begin
//             send_key(stream[keynum]); end
//     end
// endtask


endmodule

