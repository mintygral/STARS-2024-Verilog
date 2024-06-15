module ssdec2(
    input logic [4:0] in,
    input logic enable,
    output logic [6:0]out
  );

  // this displays the tens place for the counter thingy
  always_comb begin : display_tens
    out = 7'b0000000;
    if (enable == 1) begin 
      if (in < 10) begin out = 7'b0111111; end // none
      if ((in == 10) | ((in > 10) && (in < 20))) begin out = 7'b0000110; end // one
      if ((in == 10) | ((in > 10) && (in < 20))) begin out = 7'b0000110; end // one
      if ((in == 20) | ((in > 20) && (in < 30))) begin out = 7'b1011011; end // two
      if ((in == 30) | (in > 30)) begin out = 7'b1001111; end // two
    end
  end

endmodule