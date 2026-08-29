// =============================================================================
// arbiter.v  (STARTER — CONTAINS ONE DELIBERATE BUG)
//
// Round-robin between the elevator and AXIOM, with a priority override input
// that lets AXIOM preempt. The learner's job in SG-M3-03 is to find the bug,
// fix it, and prove it with test/arbiter/test_fairness.py.
//
// Contract:
//   - When priority_req is 1, grant_axiom is 1 and grant_elev is 0.
//   - When priority_req is 0 and elev_req_valid is 1, grant_elev is 1 unless
//     the last granted master was the elevator, in which case the arbiter
//     yields to axiom (implicit idle).
//   - Fairness: in the presence of a held priority_req adversary, the
//     elevator must still receive at least 2% of grants over 1000 cycles.
//
// The BUG: priority_req path does NOT update last_granted_axiom. Consequence
// is that a held priority_req adversary can starve the elevator forever.
// =============================================================================
`default_nettype none

module arbiter (
  input  wire       clk,
  input  wire       rst_n,
  input  wire       priority_req,
  input  wire       elev_req_valid,
  output wire       elev_req_ready,
  input  wire [3:0] elev_req_payload,
  output reg        grant_elev,
  output reg        grant_axiom
);

  reg last_granted_axiom;

  /* verilator lint_off UNUSED */
  wire [3:0] _payload_tap = elev_req_payload;
  /* verilator lint_on UNUSED */

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      grant_elev         <= 1'b0;
      grant_axiom        <= 1'b0;
      last_granted_axiom <= 1'b0;
    end else if (priority_req) begin
      grant_elev         <= 1'b0;
      grant_axiom        <= 1'b1;
      // BUG: last_granted_axiom is not updated here.
      // See SG-M3-03 Step 4 for the fix.
    end else if (elev_req_valid && !last_granted_axiom) begin
      grant_elev         <= 1'b1;
      grant_axiom        <= 1'b0;
      last_granted_axiom <= 1'b0;
    end else if (elev_req_valid && last_granted_axiom) begin
      // Rotate back to elevator after axiom
      grant_elev         <= 1'b1;
      grant_axiom        <= 1'b0;
      last_granted_axiom <= 1'b0;
    end else begin
      grant_elev         <= 1'b0;
      grant_axiom        <= 1'b0;
    end
  end

  assign elev_req_ready = grant_elev;

endmodule

`default_nettype wire
