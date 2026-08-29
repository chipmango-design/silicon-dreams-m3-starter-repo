"""Arbiter fairness tests — see SG-M3-03."""
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


CLK_PERIOD_NS = 10
FAIRNESS_WINDOW = 1000
FAIRNESS_THRESHOLD = 0.02


async def start_clock(dut):
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD_NS, units="ns").start())


async def nominal_reset(dut):
    dut.rst_n.value            = 0
    dut.priority_req.value     = 0
    dut.elev_req_valid.value   = 0
    dut.elev_req_payload.value = 0
    for _ in range(4):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    for _ in range(4):
        await RisingEdge(dut.clk)


@cocotb.test()
async def test_priority_does_not_starve_elevator(dut):
    """Priority-req adversary: hold priority_req=1 for FAIRNESS_WINDOW cycles.
       Elevator must still receive >= FAIRNESS_THRESHOLD share of grants.
       This test FAILS on the starter RTL (deliberate). See SG-M3-03 Step 4."""
    await start_clock(dut)
    await nominal_reset(dut)

    dut.priority_req.value     = 1
    dut.elev_req_valid.value   = 1
    dut.elev_req_payload.value = 0x3

    grants_elev  = 0
    grants_axiom = 0
    for _ in range(FAIRNESS_WINDOW):
        await RisingEdge(dut.clk)
        grants_elev  += int(dut.grant_elev.value)
        grants_axiom += int(dut.grant_axiom.value)

    total = grants_elev + grants_axiom
    elev_share = grants_elev / total if total else 0.0
    assert elev_share >= FAIRNESS_THRESHOLD, (
        f"elevator starved: elev={grants_elev} axiom={grants_axiom} "
        f"share={elev_share:.3f} threshold={FAIRNESS_THRESHOLD}"
    )


@cocotb.test()
async def test_nominal_round_robin(dut):
    """Priority=0, both asking → elev and axiom alternate."""
    await start_clock(dut)
    await nominal_reset(dut)

    dut.priority_req.value     = 0
    dut.elev_req_valid.value   = 1
    dut.elev_req_payload.value = 0x1

    grants_elev  = 0
    grants_axiom = 0
    for _ in range(200):
        await RisingEdge(dut.clk)
        grants_elev  += int(dut.grant_elev.value)
        grants_axiom += int(dut.grant_axiom.value)

    # In nominal RR, elevator should get most grants (axiom isn't requesting)
    assert grants_elev >= 50, f"elevator got only {grants_elev} grants in 200 cycles"
