# Silicon Dreams Elevator Controller

**Author:** ChipMango  
**Discord:** @chipmango  
**Module:** CM-HW-101 - Module 3  
**Cohort:** 2026-spring  

## Description

Multi-block elevator system with round-robin arbiter, clock gating, and AXIOM shim for ChipFoundry chipIgnite 2026-Q2 shuttle. This is the final integration for CM-HW-101 Silicon Dreams - Module 3.

## How it works

The design implements a complete elevator control system with the following features:

- **Elevator Controller**: Manages floor requests, door operations, and elevator movement with one-hot state encoding
- **Round-Robin Arbiter**: Fair arbitration between elevator and AXIOM requests with priority override capability
- **Clock Gating**: Integrated clock gating for the AXIOM subsystem to save power
- **AXIOM Shim**: Defensive wrapper around the adversarial AXIOM black-box IP
- **Reset Synchronization**: Multiple reset domains with configurable hold cycles

## Inputs

| Pin | Signal | Description |
|-----|--------|-------------|
| ui[0] | request_strobe | Strobe signal for floor requests |
| ui[1:4] | requested_floor[3:0] | 4-bit floor selection |
| ui[5] | priority_override_req | Priority override for arbiter |
| ui[6] | axiom_enable | Enable signal for AXIOM clock gate |
| ui[7] | debug_probe_select | Debug probe selection |
| uio[0] | fault_inject_enable | Fault injection enable |

## Outputs

| Pin | Signal | Description |
|-----|--------|-------------|
| uo[0:3] | current_floor[3:0] | Current floor position |
| uo[4:6] | state[2:0] | Elevator state (IDLE/MOVING/DOOR_OPEN) |
| uo[7] | door_open | Door open indicator |
| uio[1] | arbiter_grant_elevator | Arbiter grant to elevator |
| uio[2] | arbiter_grant_axiom | Arbiter grant to AXIOM |
| uio[3] | clock_gate_active | Clock gate active indicator |
| uio[4] | axiom_misbehaviour_led | AXIOM misbehaviour indicator |
| uio[7] | error_led | Error LED |

## Architecture

The design consists of several key modules:

1. **Elevator Module**: Core elevator logic with state machine
2. **Elevator Request Port**: Handles incoming floor requests
3. **Round-Robin Arbiter**: Fair arbitration between request sources
4. **Clock Gate**: Integrated clock gating for power savings
5. **AXIOM Shim**: Defensive wrapper around AXIOM IP
6. **Reset Synchronizers**: Multiple reset domain handling

## Source Files

- `top.v` - Top-level module
- `elevator.v` - Elevator controller
- `elevator_req_port.v` - Request port handler
- `arbiter.v` - Round-robin arbiter
- `clock_gate.v` - Clock gating module
- `axiom_shim.v` - AXIOM wrapper
- `reset_synchroniser.v` - Reset synchronizer

## FPGA Resources

- **Target Device:** ice40up5k
- **Tiles:** 1x2 (161 µm × 226 µm)
- **LC Utilization:** 133/5280 (2%)
- **Clock Frequency:** 12 MHz (for FPGA demo)

## Testing

The design includes fault injection capability for testing robustness. Enable fault injection via `uio[0]` to test error handling.

## Course Information

- **Course:** CM-HW-101
- **Module:** M3 - The Summit
- **Partners:** ChipMango, ChipFoundry
