// =============================================================================
// axiom_shim.v
//
// Defensive wrap around the adversarial AXIOM black-box. Implements the five
// defensive rules from TB-M3-05:
//
//   1. Invert reset polarity at the boundary  (axiom_rst is active-HIGH)
//   2. Gate the AXIOM clock                    (axiom_clk comes in pre-gated)
//   3. Clamp outputs outside valid range       (resp_out = 0 if resp_raw > 0x3F)
//   4. Wrap every pin through a register       (cmd / data / resp all flopped)
//   5. Log misbehaviour on uio_out[1]          (4-cycle hold on mstrobe)
//
// The AXIOM black-box has three published misbehaviours. See TB-M3-05 §5.2.
// =============================================================================
`default_nettype none

module axiom_shim (
  input  wire       clk,
  input  wire       rst_n,            // active-LOW; synchronous with top
  input  wire       axiom_rst,        // active-HIGH; already inverted by top
  input  wire       axiom_clk,        // already gated by top
  input  wire       granted,          // arbiter grant — lets cmd propagate
  input  wire [3:0] cmd_in,
  input  wire [7:0] data_in,
  output wire [7:0] resp_out,
  output wire       misbehaviour_led
);

  // ---------------------------------------------------------------------------
  // Rule #4 — register every AXIOM input pin on the clk domain
  // ---------------------------------------------------------------------------
  reg [3:0] cmd_reg;
  reg [7:0] data_reg;
  reg       granted_reg;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cmd_reg     <= 4'h0;
      data_reg    <= 8'h00;
      granted_reg <= 1'b0;
    end else begin
      cmd_reg     <= cmd_in;
      data_reg    <= data_in;
      granted_reg <= granted;
    end
  end

  // ---------------------------------------------------------------------------
  // AXIOM black-box instantiation
  //
  // In SYNTHESIS, axiom_blackbox is bound by the grader at P&R time.
  // In simulation, axiom_blackbox_sim.v provides a published-behaviour stub.
  // ---------------------------------------------------------------------------
  wire [7:0] resp_raw;
  wire       axiom_mstrobe;

  axiom_blackbox u_axiom (
    .clk                 (axiom_clk),
    .rst                 (axiom_rst),
    .cmd                 (granted_reg ? cmd_reg : 4'h0),
    .data                (data_reg),
    .resp                (resp_raw),
    .misbehaviour_strobe (axiom_mstrobe)
  );

  // ---------------------------------------------------------------------------
  // Rule #3 — clamp outputs. Only accept resp values <= 0x3F.
  // Rule #4 (output side) — register resp before letting it leave the shim.
  // ---------------------------------------------------------------------------
  wire       resp_valid = (resp_raw <= 8'h3F);
  reg  [7:0] resp_ff;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)             resp_ff <= 8'h00;
    else if (resp_valid)    resp_ff <= resp_raw;
    else                    resp_ff <= 8'h00;
  end

  assign resp_out = resp_ff;

  // ---------------------------------------------------------------------------
  // Rule #5 — 4-cycle hold on the misbehaviour LED when either AXIOM's own
  // mstrobe fires or the clamp had to suppress a bad resp.
  // ---------------------------------------------------------------------------
  reg [2:0] mstrobe_hold;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)                                 mstrobe_hold <= 3'b000;
    else if (axiom_mstrobe || !resp_valid)      mstrobe_hold <= 3'b111;
    else if (mstrobe_hold != 0)                 mstrobe_hold <= mstrobe_hold - 1'b1;
  end

  assign misbehaviour_led = (mstrobe_hold != 0);

endmodule

`default_nettype wire
