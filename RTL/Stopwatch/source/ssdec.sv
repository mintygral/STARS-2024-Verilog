module ssdec(
    input logic [4:0] in,
    input logic enable,
    output logic [6:0]out
  );
  
  logic [4:0] in_temp;
  always_comb begin : decrease_in
    // in_temp = in;
    if (in < 10) begin in_temp = in; end
    else if (in < 20  && in > 10) begin in_temp = in - 10; end
    else if (in < 30  && in > 20) begin in_temp = in - 20; end
    else if (in > 30) begin in_temp = in - 30; end
    else begin in_temp = 5'b0; end
  end

  always_comb begin : displaynum
    out = 7'b0000000;
    if (enable == 1) begin 
      case(in_temp) 
        5'b00000: begin out = 7'b0111111; end // none
        5'b00001: begin out = 7'b0000110; end // one
        5'b00010: begin out = 7'b1011011; end // two
        5'b00011: begin out = 7'b1001111; end  // three
        5'b00100: begin out = 7'b1100110; end  // four
        5'b00101: begin out = 7'b1101101; end  // five
        5'b00110: begin out = 7'b1111101; end  // six
        5'b00111: begin out = 7'b0000111; end  // seven
        5'b01000: begin out = 7'b1111111; end  // eight
        5'b01001: begin out = 7'b1100111; end  // nine   
        default: out = 7'b0111111;
      endcase
    end
  end

endmodule