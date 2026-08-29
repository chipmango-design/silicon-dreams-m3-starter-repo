# Silicon Dreams · Module 3 · Flow architecture

## LibreLane 2025.04 stage map

```
  RTL (src/*.v)
       │
       ▼
  ┌─────────────┐
  │  Yosys      │  synth -flatten → gate-level netlist
  │  synthesis  │  emits: reports/synthesis/1-synth.stat
  └──────┬──────┘
         ▼
  ┌─────────────┐
  │  OpenROAD   │  die outline, pad ring, power grid
  │  floorplan  │  emits: reports/floorplan/
  └──────┬──────┘
         ▼
  ┌─────────────┐
  │  OpenROAD   │  global + detailed placement
  │  placement  │  target density PL_TARGET_DENSITY_PCT (config.json)
  └──────┬──────┘
         ▼
  ┌─────────────┐
  │  OpenROAD   │  clock-tree synthesis, buffer insertion
  │  CTS        │  emits: reports/cts/
  └──────┬──────┘
         ▼
  ┌─────────────┐
  │  OpenROAD   │  global + detailed routing
  │  routing    │  warns on congestion; errors on open/short
  └──────┬──────┘
         ▼
  ┌─────────────────────────┐
  │  Magic + KLayout DRC     │  design-rule checks (SKY130)
  │  reports/signoff/drc.rpt │  MUST be 0 errors
  └──────┬───────────────────┘
         ▼
  ┌─────────────────────────┐
  │  Netgen LVS              │  layout-vs-schematic
  │  reports/signoff/lvs.rpt │  MUST match
  └──────┬───────────────────┘
         ▼
  ┌─────────────────────────┐
  │  OpenSTA                 │  setup + hold on all corners
  │  reports/signoff/sta-*   │  WNS >= 0, WHS >= 0
  └──────┬───────────────────┘
         ▼
  ┌─────────────┐
  │  Magic       │  antenna ratio checks
  │  antenna     │  MUST be 0 errors
  └──────┬───────┘
         ▼
  ┌─────────────┐
  │  GDS writer │  final/gds/top.gds + final/lef/top.lef
  └─────────────┘
```

## What each report file tells you

| File                                          | What it tells you                                                 |
|-----------------------------------------------|-------------------------------------------------------------------|
| `reports/synthesis/1-synth.stat`              | Gate count, estimated area, longest combinational path.           |
| `reports/placement/*.rpt`                     | Placement density, wirelength, overflow cells.                    |
| `reports/cts/*.rpt`                           | Clock-tree skew (max to min latency spread), buffer count.        |
| `reports/routing/*.rpt`                       | Congestion heatmap, open/short count, DRV count.                  |
| `reports/signoff/drc.rpt`                     | The 5-bucket DRC errors. Must be empty.                           |
| `reports/signoff/drc.klayout.xml`             | KLayout's second DRC pass. Also must be clean.                    |
| `reports/signoff/lvs.rpt`                     | Port/net/cell-count match vs schematic.                           |
| `reports/signoff/sta-best.rpt`                | Best-corner timing (typically hold-bound).                        |
| `reports/signoff/sta-worst.rpt`               | Worst-corner timing (typically setup-bound). The headline report. |
| `reports/signoff/antenna.rpt`                 | Antenna ratio violations.                                         |
| `metrics.csv`                                 | One-line summary consumed by CI and by the ChipFoundry grader.    |

## The iteration curve

Most cohort designs follow this DRC-error count curve:

```
  run 1  ........ 147  (calibration)
  run 2  ........  72  (density lowered to 0.55)
  run 3  ........  28  (DIODE_INSERTION_STRATEGY = 3)
  run 4  ........   9  (FP_TAP_DISTANCE = 14)
  run 5  ........   0  (pin_order.cfg snapped, PDN strap widened)
```

If you are still above 50 errors on run 6, the problem is structural, not
a config knob — escalate in Discord #m3-drc with the failing drc.rpt.

## The three workflow wires

```
  Learner push  ──►  .github/workflows/drc.yml    ──►  ChipFoundry grader
                ──►  .github/workflows/lvs.yml    ──►  (POST /v1/silicon-dreams/m3)
                ──►  .github/workflows/timing.yml ──►
```

Each workflow re-runs the relevant stage of the flow (not the full pipeline)
and POSTs a JSON payload including pass/fail, iteration count, and the run's
metrics.csv. The grader tracks your per-module iteration history for the
rubric.
