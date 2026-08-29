// =============================================================================
// elevator_req_port.v
//
// Thin adapter that converts an edge-triggered request_strobe + 4-bit floor
// into a registered valid/ready handshake. Ensures valid does NOT depend
// combinationally on ready (see SG-M3-02 Step 5).
// =============================================================================
`default_nettype none

module elevator_req_port (
  input  wire       clk,
  input  wire       rst_n,
  input  wire       strobe,
  input  wire [3:0] floor,
  output reg  [3:0] req_payload,
  output reg        req_valid,
  input  wire       req_ready
);

  reg strobe_d;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      req_payload <= 4'h0;
      req_valid   <= 1'b0;
      strobe_d    <= 1'b0;
    end else begin
      strobe_d <= strobe;

      // Rising edge of strobe latches a new request
      if (strobe && !strobe_d) begin
        req_payload <= floor;
        req_valid   <= 1'b1;
      end else if (req_valid && req_ready) begin
        req_valid   <= 1'b0;
      end
    end
  end

endmodule

`default_nettype wire
