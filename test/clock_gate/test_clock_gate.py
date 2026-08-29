"""Clock gate behavioural model tests — see SG-M3-04."""
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


@cocotb.test()
async def test_gclk_high_only_when_enable_and_clk(dut):
    """Behavioural check: gclk should be clk AND enable_latched (latch-then-AND)."""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Enable high throughout: gclk should toggle with clk
    dut.enable.value = 1
    for _ in range(5):
        await RisingEdge(dut.clk)
    assert dut.gclk.value.is_resolvable, "gclk is X when enable stable high"

    # Enable goes low: gclk must stay low for the next two cycles
    dut.enable.value = 0
    for _ in range(2):
        await RisingEdge(dut.clk)
    # after enable drops and we pass through a clk-low window, gclk should be 0
    await Timer(3, units="ns")
    assert int(dut.gclk.value) == 0, "gclk did not settle to 0 with enable=0"


@cocotb.test()
async def test_no_glitch_on_enable_change_while_clk_high(dut):
    """Enable change while clk is HIGH must not glitch gclk before next clk-low."""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.enable.value = 1
    await RisingEdge(dut.clk)
    await Timer(2, units="ns")  # still in clk-high window

    saw_glitch = False
    dut.enable.value = 0
    for _ in range(5):
        await Timer(1, units="ns")
        if int(dut.gclk.value) != 1:
            # Only acceptable glitch is when clk goes low naturally
            if int(dut.clk.value) == 1:
                saw_glitch = True
                break

    assert not saw_glitch, "gclk glitched while clk was still high"
