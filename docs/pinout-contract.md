# Silicon Dreams · Module 3 · Pinout contract

The tt_um pinout contract is the immovable boundary between your design
and the ChipFoundry chipIgnite shuttle pad ring. 32 signals total, fixed
names, fixed directions. Renaming any pin breaks LVS.

## Dedicated inputs — `ui_in[7:0]`

| Bit | Name                    | Consumer     | Notes                                       |
|-----|-------------------------|--------------|---------------------------------------------|
| 0   | request_strobe          | elevator     | Rising edge latches a request.              |
| 1   | requested_floor[0]      | elevator     | LSB of the 4-bit floor request.             |
| 2   | requested_floor[1]      | elevator     |                                             |
| 3   | requested_floor[2]      | elevator     |                                             |
| 4   | requested_floor[3]      | elevator     | MSB.                                        |
| 5   | priority_override_req   | arbiter      | When 1, arbiter grants AXIOM on next cycle. |
| 6   | axiom_enable            | axiom_shim   | When 0, AXIOM's clock is gated off.         |
| 7   | debug_probe_select      | —            | Reserved for debug bring-up; unused in RTL. |

## Dedicated outputs — `uo_out[7:0]`

| Bit | Name               | Producer  |
|-----|--------------------|-----------|
| 0   | current_floor[0]   | elevator  |
| 1   | current_floor[1]   | elevator  |
| 2   | current_floor[2]   | elevator  |
| 3   | current_floor[3]   | elevator  |
| 4   | state[0]           | elevator  |
| 5   | state[1]           | elevator  |
| 6   | state[2]           | elevator  |
| 7   | door_open          | elevator  |

## Bidirectionals — `uio[7:0]`

| Bit | Name                       | Direction | Producer / Consumer |
|-----|----------------------------|-----------|---------------------|
| 0   | fault_inject_enable        | INPUT     | elevator consumes   |
| 1   | axiom_misbehaviour_led     | OUTPUT    | axiom_shim          |
| 2   | arbiter_grant_elevator     | OUTPUT    | arbiter (debug)     |
| 3   | arbiter_grant_axiom        | OUTPUT    | arbiter (debug)     |
| 4   | reserved                   | OUTPUT=0  | —                   |
| 5   | reserved                   | OUTPUT=0  | —                   |
| 6   | clock_gate_active          | OUTPUT    | top (ena && axiom_enable) |
| 7   | elevator_error_led         | OUTPUT    | elevator            |

`uio_oe` must be `8'b1111_1110` (bit 0 is input; rest are outputs).

## Global signals

| Name  | Width | Direction | Notes                                      |
|-------|-------|-----------|--------------------------------------------|
| ena   | 1     | input     | Always 1 when the tile is selected.        |
| clk   | 1     | input     | Primary clock. 10 ns period (100 MHz).     |
| rst_n | 1     | input     | Active-LOW reset, asynchronously asserted. |

## Why some pins are what they are

- `priority_override_req` sits on `ui_in[5]` because bit-5 is the closest
  unassigned dedicated input to the arbiter's region of the floorplan
  (north pad ring). Routing distance from pad to flop is smaller than it
  would be on a bidirectional pin.
- `axiom_misbehaviour_led` is on `uio[1]` not a dedicated output because
  we want it visible from the bring-up board but do not need it to be
  latency-critical. `uio` pins sit on the south edge, closer to the AXIOM
  shim's placement.
- `fault_inject_enable` stays on `uio[0]` across all three modules to
  keep testbenches identical.
