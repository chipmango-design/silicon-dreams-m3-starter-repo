// =============================================================================
// clock_gate.v
//
// Wrapper around sky130_fd_sc_hd__dlclkp_1 (integrated clock gate).
// Simulation (non-SKY130) environments use the behavioural model below.
//
// See SG-M3-04 for the SDC constraints required to make STA analyse this
// correctly — in particular the `set_clock_groups -physically_exclusive`
// line that MUST pair gclk with the source clock.
// =============================================================================
`default_nettype none

module clock_gate (
  input  wire clk,
  input  wire enable,
  output wire gclk
);

`ifdef SYNTHESIS
  // Silicon path — use the SKY130 ICG primitive
  sky130_fd_sc_hd__dlclkp_1 u_icg (
    .CLK (clk),
    .GCLK(gclk),
    .GATE(enable)
  );
`else
  // Simulation path — latch-then-AND behavioural equivalent.
  // MUST match the ICG cell exactly (no glitch on enable changes while clk=high).
  reg enable_latched;
  always @(*) if (!clk) enable_latched = enable;
  assign gclk = clk & enable_latched;
`endif

endmodule

`default_nettype wire
