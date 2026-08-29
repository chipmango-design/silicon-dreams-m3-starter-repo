# Silicon Dreams · Module 3 · Tape-out Starter



[![Lvs](../../workflows/lvs/badge.svg)](../../actions/workflows/lvs.yml)
[![Drc](../../workflows/drc/badge.svg)](../../actions/workflows/drc.yml)
[![Timing](../../workflows/timing/badge.svg)](../../actions/workflows/timing.yml)
[![Docs](../../workflows/docs/badge.svg)](../../actions/workflows/docs.yml)
[![GDS](../../workflows/gds/badge.svg)](../../actions/workflows/gds.yml)
[![FPGA](../../workflows/fpga/badge.svg)](../../actions/workflows/fpga.yml)
[![Test](../../workflows/test/badge.svg)](../../actions/workflows/test.yml)


Week 3 of the ChipMango × ChipFoundry Silicon Dreams course (CM-HW-101). This
starter is where the work you've done in Modules 1 and 2 becomes a real chip.
By the end of the week you will push a tag called `v1.0.0-final`, upload a
tarball to the ChipFoundry shuttle portal, and wait approximately twelve
weeks for real silicon to arrive on your desk.

Unlike M2, this repo is **not** a patch on your M1 fork. Module 3 restructures
the project around multi-module integration, the LibreLane digital-design
flow, and the ChipFoundry shuttle submission pipeline. You install your
hardened M2 elevator into `src/elevator.v` and integrate it alongside three
new sub-modules you will write this week.

## What you build this week

| Sub-module         | What it does                                                    | Study guide |
|--------------------|------------------------------------------------------------------|-------------|
| `src/top.v`        | tt_um wrapper. Binds all four sub-modules to the shuttle pinout. | SG-M3-02    |
| `src/arbiter.v`    | Round-robin with priority override. Has one deliberate bug.      | SG-M3-03    |
| `src/clock_gate.v` | ICG wrapper around `sky130_fd_sc_hd__dlclkp_1`.                  | SG-M3-04    |
| `src/axiom_shim.v` | Defensive wrapper for the adversarial AXIOM black-box.           | SG-M3-05    |

## Flow and CI

Module 3 runs the **LibreLane 2025.04** digital-design flow end-to-end on
every push. Three CI workflows must stay green for you to tag a final
release:

- `.github/workflows/drc.yml` — DRC (Magic + KLayout) on the full GDS.
- `.github/workflows/lvs.yml` — LVS (Netgen) match on layout vs schematic.
- `.github/workflows/timing.yml` — OpenSTA setup + hold on the worst corner.

Each workflow POSTs a JSON payload to the ChipFoundry grader service, which
tracks your iteration count and final rubric score.

## Local quick-start

```bash
# 1. Fork and clone
gh repo fork chipfoundry/silicon-dreams-m3-starter --clone --remote
cd silicon-dreams-m3-starter
git checkout -b my-tapeout

# 2. Install your M2 elevator
cp ../silicon-dreams-m2/src/elevator.v src/elevator.v

# 3. Pull the LibreLane image and PDK
docker pull efabless/librelane:2025.04
./scripts/install-pdk.sh

# 4. First hardening pass (expect DRC/LVS fails — this is the calibration run)
./scripts/run-librelane.sh --tag first-run

# 5. Integration smoke (six tests, all must pass before you iterate the flow)
cd test/top && make smoke
```

## Deliverables

Pushed as a release on tag `v1.0.0-final`:

1. `src/*.v` — your four sub-modules plus the integrated top.
2. `librelane/config.json` + `librelane/constraints.sdc` — the flow config.
3. `runs/final/final/gds/top.gds` — the GDSII that goes to fab.
4. `runs/final/final/lef/top.lef` — the LEF for the shuttle integrator.
5. `info.yaml` — shuttle metadata. Author and Discord fields filled in.
6. `notes/escape-log.md` — your per-module post-mortem.
7. `notes/m3-reflection.md` — six reflection prompts, 500 words.

## Course context

- Course code: **CM-HW-101**
- Module: **M3 (Week 3 of 3)**
- Cohort: **2026-spring**
- Partners: **ChipMango × ChipFoundry**
- Shuttle: **ChipFoundry chipIgnite 2026-Q2**
- PDK: **SKY130A**, standard cell library **sky130_fd_sc_hd**
- LibreLane version: **2025.04** (pinned; CI rejects any other)

## Rubric (max 1700 XP)

| Section                                      | XP  |
|----------------------------------------------|-----|
| Clean DRC/LVS/timing on tag v1.0.0-final     | 500 |
| Arbiter fairness + 50 XP bonus               | 250 |
| Clock gating with measurable power drop      | 150 |
| AXIOM shim (all three misbehaviour tests)    | 250 |
| Reflection (500+ words)                      | 300 |
| Bring-up success at week 12                  | 150 |
| First-try shuttle accept                     | 100 |

Minimum pass: 1000 XP. Distinction: 1400 XP.

## AXIOM

AXIOM is the adversarial IP block you wrap in the shim (`src/axiom_shim.v`).
It is delivered as an encrypted binary bound by the grader at P&R time; a
behavioural stub at `src/axiom_blackbox_sim.v` is used for local simulation.
Three misbehaviours are published in TB-M3-05; your shim's job is to contain
them. There is also a documented easter egg on the command sequence
`0x4, 0x7, 0x2`. Treat it as a Chekhov's gun — rule #3 already handles it.
