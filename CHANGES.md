# Silicon Dreams Module 3 starter — change log

All notable changes from the Module 2 starter repo.

## 3.0.0 — 2026-04-19

Initial Module 3 starter release. Scope: full tape-out integration, LibreLane 2025.04 flow, ChipFoundry shuttle submission.

### Added

- `src/top.v` — tt_um wrapper integrating elevator + arbiter + clock_gate + axiom_shim.
- `src/arbiter.v` — round-robin with priority override (contains deliberate teaching bug).
- `src/clock_gate.v` — ICG wrapper around `sky130_fd_sc_hd__dlclkp_1`.
- `src/axiom_shim.v` — defensive wrap for the adversarial AXIOM black-box.
- `src/axiom_blackbox.v` — DO NOT MODIFY. Bound by grader at P&R.
- `src/axiom_blackbox_sim.v` — behavioural stub for local simulation.
- `src/reset_synchroniser.v` — parameterised sync for independent reset domains.
- `librelane/config.json` — pinned to LibreLane 2025.04, SKY130A, sky130_fd_sc_hd.
- `librelane/constraints.sdc` — includes the critical `set_clock_groups -physically_exclusive` for gated clocks.
- `librelane/pin_order.cfg` — pad ring mapping matching the tt_um contract.
- `test/top/` — six-test integration smoke harness.
- `test/arbiter/` — cocotb fairness test (elev_share ≥ 0.02 under priority adversary).
- `test/axiom/` — three misbehaviour tests (resp clamp, clk glitch, stuck reset).
- `test/clock_gate/` — behavioural ICG model vs synthesis alignment test.
- `.github/workflows/drc.yml`, `lvs.yml`, `timing.yml` — three sign-off pipelines.
- `scripts/run-librelane.sh` — wraps the flow with version check + tag convention.
- `scripts/build-submission.sh` — builds a submission tarball with COURSE_HASH.
- `scripts/install-pdk.sh` — first-run PDK install.
- `docs/flow-architecture.md` — flow diagram + stage-by-stage responsibilities.
- `docs/pinout-contract.md` — the tt_um pin allocation for M3.
- `notes/known-solutions.md` — INSTRUCTOR-ONLY reference fixes for every deliberate bug.
- `notes/escape-log.md`, `notes/m3-reflection.md` — learner templates.
- `info.yaml` — chipIgnite shuttle metadata with full M3 pinout.

### Restructured from Module 2

- `src/elevator.v` — learners paste their M2-hardened RTL here. It is no longer the whole design.
- `test/` — reorganised under per-sub-module directories. The old `test/fault_injection/` is retained as a reference but is not exercised by M3 CI.
- `harness/` — kept from M2 for anyone who wants to run fault injection on the integrated top. M3 CI does not require it.
