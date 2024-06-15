module fsm (
    input logic clk, rst,
    input logic keyout,
    output state_t state
  );

    state_t next_state;
    always_ff @ (posedge clk, posedge rst) begin
      if (rst == 1) begin state <= IDLE; end
      else begin state <= next_state; end 
    end

    always_comb begin 
      next_state = state;
      case(state)
      IDLE: if (keyout) begin next_state = RUNNING; end else begin next_state = IDLE; end
      RUNNING: if (keyout) begin next_state = CLEAR; end else begin next_state = RUNNING; end
      CLEAR: if (keyout) begin next_state = IDLE; end else begin next_state = CLEAR; end
      default: next_state = IDLE;
      endcase
    end
  endmodule
