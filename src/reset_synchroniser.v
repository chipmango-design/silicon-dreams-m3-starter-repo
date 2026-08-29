// =============================================================================
// reset_synchroniser.v
//
// Classic two-flop synchroniser with an optional hold counter. When the external
// rst_n goes low, rst_n_sync goes low asynchronously (fast path to the logic).
// When rst_n returns high, rst_n_sync stays low for HOLD_CYCLES further clock
// edges, then rises synchronously to the domain's clock.
// =============================================================================
`default_nettype none

module reset_synchroniser #(
  parameter integer HOLD_CYCLES = 4
) (
  input  wire clk,
  input  wire rst_n,
  output wire rst_n_sync
);

  reg [$clog2(HOLD_CYCLES+1)-1:0] hold_cnt;
  reg                             sync_ff1;
  reg                             sync_ff2;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sync_ff1 <= 1'b0;
      sync_ff2 <= 1'b0;
      hold_cnt <= HOLD_CYCLES[$clog2(HOLD_CYCLES+1)-1:0];
    end else begin
      sync_ff1 <= 1'b1;
      sync_ff2 <= sync_ff1;
      if (hold_cnt != 0) hold_cnt <= hold_cnt - 1'b1;
    end
  end

  assign rst_n_sync = sync_ff2 & (hold_cnt == 0);

endmodule

`default_nettype wire
