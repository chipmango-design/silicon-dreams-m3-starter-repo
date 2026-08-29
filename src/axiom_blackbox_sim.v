// =============================================================================
// axiom_blackbox_sim.v
//
// Behavioural simulation stub for the AXIOM black-box. Reproduces the three
// published misbehaviours documented in TB-M3-05 §5.2 so that the shim tests
// can exercise the defensive rules without access to the encrypted binary.
//
// Only included when the `SIM_AXIOM` macro is defined (iverilog -DSIM_AXIOM).
// =============================================================================
`default_nettype none

`ifdef SIM_AXIOM
module axiom_blackbox (
  input  wire       clk,
  input  wire       rst,
  input  wire [3:0] cmd,
  input  wire [7:0] data,
  output reg  [7:0] resp,
  output reg        misbehaviour_strobe
);

  reg       ignore_reset;
  reg [7:0] sticky_cnt;

  /* verilator lint_off UNUSED */
  wire [7:0] _data_tap = data;
  /* verilator lint_on UNUSED */

  always @(posedge clk) begin
    // Published misbehaviour 3: ignore reset if last cmd was 0x2
    if (rst && !ignore_reset) begin
      resp                <= 8'h00;
      misbehaviour_strobe <= 1'b0;
      sticky_cnt          <= 8'h00;
      ignore_reset        <= (cmd == 4'h2);
    end else begin
      misbehaviour_strobe <= 1'b0;

      // Published misbehaviour 1: resp held at 0xFF for N cycles on cmd=0x4
      if (cmd == 4'h4 && sticky_cnt == 0) begin
        resp                <= 8'hFF;
        sticky_cnt          <= 8'd5;       // 5-cycle stickiness for sim
        misbehaviour_strobe <= 1'b1;
      end else if (sticky_cnt != 0) begin
        resp       <= 8'hFF;
        sticky_cnt <= sticky_cnt - 1'b1;
      end else begin
        // Easter egg: cmd sequence 0x4 → 0x7 → 0x2 prints 'AXIOM_DEBUG_1337'
        // (truncated to 8 bits = 0x37)
        case (cmd)
          4'h4: resp <= 8'h10;
          4'h7: resp <= 8'h07;
          4'h2: resp <= 8'h37;   // the easter egg value
          default: resp <= {4'h0, cmd};
        endcase
      end
    end
  end

  initial begin
    ignore_reset        = 1'b0;
    sticky_cnt          = 8'h00;
    resp                = 8'h00;
    misbehaviour_strobe = 1'b0;
  end

endmodule
`endif

`default_nettype wire
