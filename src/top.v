// =============================================================================
// Silicon Dreams · Module 3 · top.v
//
// tt_um wrapper. Binds the four sub-modules of the M3 design to the
// ChipFoundry chipIgnite shuttle pinout contract.
//
// See docs/pinout-contract.md and SG-M3-02 for the full explanation of
// why reset domains are partitioned, why every AXIOM pin is registered,
// and why the priority-override handshake must not depend combinationally
// on elev_req_ready.
// =============================================================================
`default_nettype none

module tt_um_silicon_dreams (
  input  wire [7:0] ui_in,
  output wire [7:0] uo_out,
  input  wire [7:0] uio_in,
  output wire [7:0] uio_out,
  output wire [7:0] uio_oe,
  input  wire       ena,
  input  wire       clk,
  input  wire       rst_n
);

  // ---------------------------------------------------------------------------
  // Reset-domain partitioning
  // ---------------------------------------------------------------------------
  // The three sub-modules require DIFFERENT hold times and DIFFERENT polarities.
  // See SG-M3-02 Step 4.
  wire elevator_rst_n;
  wire arbiter_rst_n;
  wire axiom_rst_n_sync;
  wire axiom_rst;   // active-HIGH — AXIOM is inverted

  reset_synchroniser #(.HOLD_CYCLES(4)) u_rst_elev (
    .clk        (clk),
    .rst_n      (rst_n),
    .rst_n_sync (elevator_rst_n)
  );
  reset_synchroniser #(.HOLD_CYCLES(6)) u_rst_arb (
    .clk        (clk),
    .rst_n      (rst_n),
    .rst_n_sync (arbiter_rst_n)
  );
  reset_synchroniser #(.HOLD_CYCLES(4)) u_rst_axm (
    .clk        (clk),
    .rst_n      (rst_n),
    .rst_n_sync (axiom_rst_n_sync)
  );
  assign axiom_rst = ~axiom_rst_n_sync;   // polarity flip at the boundary

  // ---------------------------------------------------------------------------
  // Input decoding
  // ---------------------------------------------------------------------------
  wire       request_strobe       = ui_in[0];
  wire [3:0] requested_floor      = ui_in[4:1];
  wire       priority_override    = ui_in[5];
  wire       axiom_enable         = ui_in[6];
  /* verilator lint_off UNUSED */
  wire       debug_probe_select   = ui_in[7];
  /* verilator lint_on UNUSED */

  // ---------------------------------------------------------------------------
  // Elevator
  // ---------------------------------------------------------------------------
  wire [3:0] current_floor;
  wire [2:0] elevator_state;
  wire       door_open;
  wire       elevator_error_led;

  wire [3:0] req_payload;
  wire       req_valid;
  wire       req_ready;

  elevator_req_port u_req_port (
    .clk         (clk),
    .rst_n       (elevator_rst_n),
    .strobe      (request_strobe),
    .floor       (requested_floor),
    .req_payload (req_payload),
    .req_valid   (req_valid),
    .req_ready   (req_ready)
  );

  elevator u_elevator (
    .clk             (clk),
    .rst_n           (elevator_rst_n),
    .request_strobe  (request_strobe),
    .requested_floor (requested_floor),
    .fault_inject_en (uio_in[0]),
    .current_floor   (current_floor),
    .state           (elevator_state),
    .door_open       (door_open),
    .error_led       (elevator_error_led)
  );

  // ---------------------------------------------------------------------------
  // Arbiter
  // ---------------------------------------------------------------------------
  wire grant_elev;
  wire grant_axiom;

  arbiter u_arbiter (
    .clk              (clk),
    .rst_n            (arbiter_rst_n),
    .priority_req     (priority_override),
    .elev_req_valid   (req_valid),
    .elev_req_ready   (req_ready),
    .elev_req_payload (req_payload),
    .grant_elev       (grant_elev),
    .grant_axiom      (grant_axiom)
  );

  // ---------------------------------------------------------------------------
  // Clock gate — drives AXIOM's clock when ena && axiom_enable are both high
  // ---------------------------------------------------------------------------
  wire axiom_clk;
  wire clock_gate_active;

  clock_gate u_axiom_gate (
    .clk    (clk),
    .enable (ena & axiom_enable),
    .gclk   (axiom_clk)
  );
  assign clock_gate_active = ena & axiom_enable;

  // ---------------------------------------------------------------------------
  // AXIOM shim (wraps the encrypted black-box)
  // ---------------------------------------------------------------------------
  wire [7:0] axiom_resp_out;
  wire       axiom_mstrobe_led;

  axiom_shim u_axiom_shim (
    .clk              (clk),
    .rst_n            (axiom_rst_n_sync),
    .axiom_rst        (axiom_rst),
    .axiom_clk        (axiom_clk),
    .granted          (grant_axiom),
    .cmd_in           (req_payload[3:0]),
    .data_in          (8'h00),
    .resp_out         (axiom_resp_out),
    .misbehaviour_led (axiom_mstrobe_led)
  );

  // ---------------------------------------------------------------------------
  // Output pad assignments
  // ---------------------------------------------------------------------------
  assign uo_out = { door_open,
                    elevator_state,
                    current_floor };

  assign uio_out = { elevator_error_led,      // [7]
                     clock_gate_active,       // [6]
                     2'b00,                   // [5:4] reserved
                     grant_axiom,             // [3]
                     grant_elev,              // [2]
                     axiom_mstrobe_led,       // [1]
                     1'b0 };                  // [0] fault_inject_enable is INPUT

  assign uio_oe = 8'b1111_1110;               // [0] is input; rest are outputs

  /* verilator lint_off UNUSED */
  wire _unused = &{1'b0, uio_in[7:1], ena, axiom_resp_out, debug_probe_select};
  /* verilator lint_on UNUSED */

endmodule

`default_nettype wire
