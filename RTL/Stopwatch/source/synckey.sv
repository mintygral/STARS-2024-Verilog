module synckey (
    input clk, rst, // clock and reset ports
    input logic in,
    output logic [2:0] out,
    output logic strobe,
    output logic strobe1
  );
    logic Q;

    always_ff @( posedge clk, posedge rst ) begin 
      if(rst) begin
        Q <= 1'b0;
      end
      else begin
        Q <= in;
      end
    end

    always_ff @( posedge clk, posedge rst ) begin 
      if(rst) begin
        strobe <= 1'b0;
      end
      else begin
        strobe <= Q;
      end
    end

    always @(in) begin
        case (in)
            1'b0: out = out;
            1'b1: out = (out == 3'b100) ? 3'b001 : 
                        (out == 3'b001) ? 3'b010 : 
                        (out == 3'b010) ? 3'b100 : 3'b100;
            default: out = out;
        endcase
        strobe1 = (out == 3'b001);
    end
  endmodule