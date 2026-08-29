"""Integration smoke tests for tt_um_silicon_dreams.

Six tests. All six must pass before you touch LibreLane. See SG-M3-02 Step 6.
"""
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

CLK_PERIOD_NS = 10
RESET_CYCLES  = 8


async def start_clock(dut):
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD_NS, units="ns").start())


async def nominal_reset(dut):
    dut.rst_n.value  = 0
    dut.ena.value    = 1
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    for _ in range(RESET_CYCLES):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    for _ in range(RESET_CYCLES):
        await RisingEdge(dut.clk)


@cocotb.test()
async def reset_release(dut):
    """After reset deasserts, elevator state must reach IDLE within 8 cycles."""
    await start_clock(dut)
    await nominal_reset(dut)
    state = int(dut.uo_out.value) >> 4 & 0x7
    assert state == 0, f"elevator state = {state}, expected IDLE=0"


@cocotb.test()
async def elevator_wakes_in_IDLE(dut):
    """Elevator must not assert door_open immediately after reset."""
    await start_clock(dut)
    await nominal_reset(dut)
    door = (int(dut.uo_out.value) >> 7) & 0x1
    assert door == 0, "door_open asserted at reset release"


@cocotb.test()
async def arbiter_grants_elevator_by_default(dut):
    """With priority=0 and elev_req_valid=1, grant_elev must pulse."""
    await start_clock(dut)
    await nominal_reset(dut)
    dut.ui_in.value = 0b0000_0001  # request_strobe asserted
    for _ in range(20):
        await RisingEdge(dut.clk)
    grant_elev = (int(dut.uio_out.value) >> 2) & 0x1
    assert grant_elev == 1, "elevator never received a grant under nominal conditions"


@cocotb.test()
async def priority_override_grants_axiom(dut):
    """With priority=1, grant_axiom must be high on the next cycle."""
    await start_clock(dut)
    await nominal_reset(dut)
    dut.ui_in.value = 0b0110_0001  # axiom_enable + priority_override + strobe
    for _ in range(10):
        await RisingEdge(dut.clk)
    grant_axiom = (int(dut.uio_out.value) >> 3) & 0x1
    assert grant_axiom == 1, "priority_override did not grant AXIOM"


@cocotb.test()
async def axiom_shim_clamps_misbehaviour(dut):
    """Driving cmd_in=0x4 through axiom_shim must pulse uio_out[1] (mstrobe LED)."""
    await start_clock(dut)
    await nominal_reset(dut)
    # Drive cmd 0x4 via request_payload
    dut.ui_in.value = 0b0110_1001  # axiom_enable + priority + floor[3:0]=0x4 + strobe
    mstrobe_seen = False
    for _ in range(30):
        await RisingEdge(dut.clk)
        if (int(dut.uio_out.value) >> 1) & 0x1:
            mstrobe_seen = True
            break
    assert mstrobe_seen, "axiom misbehaviour LED never pulsed"


@cocotb.test()
async def clock_gate_disables_on_idle(dut):
    """With axiom_enable=0, clock_gate_active must be 0."""
    await start_clock(dut)
    await nominal_reset(dut)
    dut.ui_in.value = 0  # axiom_enable clear
    for _ in range(8):
        await RisingEdge(dut.clk)
    cga = (int(dut.uio_out.value) >> 6) & 0x1
    assert cga == 0, "clock_gate_active still high with axiom_enable=0"
