// =============================================================================
// axiom_blackbox.v  —  DO NOT MODIFY
//
// This is the interface-only declaration for the AXIOM encrypted IP.
// At hardening time, the ChipFoundry grader binds the encrypted
// implementation against this module name. Changing any port name,
// width, or direction will cause LVS to fail immediately.
//
// For LOCAL simulation, use `-DSIM_AXIOM` on the iverilog command line
// and the stub in axiom_blackbox_sim.v will take precedence.
// =============================================================================
`default_nettype none

`ifdef SIM_AXIOM
// In simulation, axiom_blackbox_sim.v provides the body.
`else
(* blackbox *)
module axiom_blackbox (
  input  wire       clk,
  input  wire       rst,                 // ACTIVE-HIGH (see datasheet)
  input  wire [3:0] cmd,
  input  wire [7:0] data,
  output wire [7:0] resp,
  output wire       misbehaviour_strobe
);
  // No body — bound by grader.
endmodule
`endif

`default_nettype wire
