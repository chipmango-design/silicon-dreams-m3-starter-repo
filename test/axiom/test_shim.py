"""AXIOM shim defensive-rules tests — see SG-M3-05."""
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


CLK_PERIOD_NS = 10


async def start_clock(dut):
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD_NS, units="ns").start())


async def nominal_reset(dut):
    dut.rst_n.value     = 0
    dut.axiom_rst.value = 1     # active-high; held
    dut.axiom_clk.value = 0     # gated clock input (driven by top in real design)
    dut.granted.value   = 0
    dut.cmd_in.value    = 0
    dut.data_in.value   = 0
    for _ in range(4):
        await RisingEdge(dut.clk)
    dut.rst_n.value     = 1
    dut.axiom_rst.value = 0
    for _ in range(4):
        await RisingEdge(dut.clk)


async def drive_axiom_clk(dut):
    """Very simple axiom_clk follower — toggles with dut.clk."""
    while True:
        await RisingEdge(dut.clk)
        dut.axiom_clk.value = 1
        await RisingEdge(dut.clk)
        dut.axiom_clk.value = 0


@cocotb.test()
async def test_resp_ff_clamped(dut):
    """Rule #3: AXIOM returns 0xFF on cmd=0x4; shim must clamp resp_out to 0."""
    await start_clock(dut)
    await nominal_reset(dut)
    cocotb.start_soon(drive_axiom_clk(dut))

    dut.granted.value = 1
    dut.cmd_in.value  = 0x4
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    assert int(dut.resp_out.value) == 0, (
        f"resp_out = {int(dut.resp_out.value):#04x}, expected 0x00"
    )
    assert int(dut.misbehaviour_led.value) == 1, "mstrobe LED must be high"


@cocotb.test()
async def test_clk_glitch_blocked(dut):
    """Rule #2: when granted=0 no cmd propagates; shim must remain quiet."""
    await start_clock(dut)
    await nominal_reset(dut)
    cocotb.start_soon(drive_axiom_clk(dut))

    dut.granted.value = 0
    dut.cmd_in.value  = 0x7
    for _ in range(20):
        await RisingEdge(dut.clk)

    assert int(dut.resp_out.value) == 0
    assert int(dut.misbehaviour_led.value) == 0


@cocotb.test()
async def test_stuck_reset_recoverable(dut):
    """Rule #2+#5: after cmd=0x2 AXIOM ignores reset; dropping granted
       (which in the top gates the clock) lets the shim recover."""
    await start_clock(dut)
    await nominal_reset(dut)
    cocotb.start_soon(drive_axiom_clk(dut))

    dut.granted.value = 1
    dut.cmd_in.value  = 0x2
    for _ in range(5):
        await RisingEdge(dut.clk)

    # Drop granted → in top this gates axiom_clk off; here we assert quiescence
    dut.granted.value = 0
    dut.cmd_in.value  = 0
    for _ in range(10):
        await RisingEdge(dut.clk)

    # Shim must not continue pulsing the LED forever; it should settle.
    assert int(dut.misbehaviour_led.value) == 0, "LED not cleared after grant dropped"
