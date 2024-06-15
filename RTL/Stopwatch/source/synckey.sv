// encoder
module synckey (
    input clk, rst, // clock and reset ports
    input logic in,
    output logic out,
    output logic strobe,
    output logic strobe1
  );
    logic Q;
    //logic strobe1;

    //assign strobe = Q[1];
    // flip-flop 1
    // this takes the input of the OR'd value of the button inputs as data
    // outputs Q
    always_ff @( posedge clk, posedge rst ) begin 
      if(rst) begin
        Q <= 1'b0;
      end
      else begin
        Q <= | in;
      end
    end

    //flip-flop 2
    // input is Q (from first flipflop)
    // output is strobe
    always_ff @( posedge clk, posedge rst ) begin 
      if(rst) begin
        strobe <= 1'b0;
      end
      else begin
        strobe <= Q;
      end
    end
    
    // if (in) begin assign out = 1; end

    always @(in) begin
        out = 3'b0;
        if (in) begin out = 1; end


        // case (in)
        //     3'b100: out = 3'b100; // IDLE
        //     3'b010: out = 3'b010; // CLEAR
        //     3'b001: out = 3'b001; // RUNNING
        //     // all other cases:
        //     3'b000: out = out;
        //     3'b011: out = out;
        //     3'b110: out = out;
        //     3'b111: out = out;
        //     3'b101: out = out;
        //     default: out = out; // Default case
        // endcase
        if (out != 0) begin
            strobe1 = 1;
        end
        if (out == 0) begin
          strobe1 = 0;
        end
        if (out == 0 && (in)) begin
          strobe1 = 1;
        end
        else begin strobe1 = strobe1; end
    end
  endmodule