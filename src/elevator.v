// =============================================================================
// src/elevator.v  —  PASTE YOUR MODULE 2 HARDENED RTL HERE
//
// This file is intentionally a placeholder. The course grader expects the
// elevator implementation you landed after the Module 2 fault-injection
// harness was green. Paste your M2 elevator.v over this file, preserving
// the port list below (which matches the M3 top-level instantiation).
//
// Port list required by top.v:
//   input  clk, rst_n, request_strobe, fault_inject_en
//   input  [3:0] requested_floor
//   output [3:0] current_floor
//   output [2:0] state
//   output       door_open
//   output       error_led
//
// Before tagging v1.0.0-final:
//   - Confirm your M2 fault-injection tests still pass on this file.
//   - Confirm the M1 deliberate bugs are absent.
//   - Confirm state is the 3-bit one-hot-plus-encoded vector you used
//     for the Floor 5 fix (not the original 2-bit dense binary).
// =============================================================================
`default_nettype none

module elevator (
  input  wire       clk,
  input  wire       rst_n,
  input  wire       request_strobe,
  input  wire [3:0] requested_floor,
  input  wire       fault_inject_en,
  output reg  [3:0] current_floor,
  output reg  [2:0] state,
  output reg        door_open,
  output reg        error_led
);

  // ----- Placeholder body ---------------------------------------------------
  // Replace this block with your M2 hardened RTL.
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_floor <= 4'h0;
      state         <= 3'h0;
      door_open     <= 1'b0;
      error_led     <= 1'b0;
    end else begin
      error_led <= 1'b0;
      if (request_strobe) begin
        // Trivial acknowledge — REPLACE WITH YOUR M2 IMPLEMENTATION
        current_floor <= requested_floor;
        state         <= 3'h2;
        door_open     <= 1'b1;
      end else begin
        state     <= 3'h0;
        door_open <= 1'b0;
      end
    end
  end

  /* verilator lint_off UNUSED */
  wire _unused = fault_inject_en;
  /* verilator lint_on UNUSED */

endmodule

`default_nettype wire
