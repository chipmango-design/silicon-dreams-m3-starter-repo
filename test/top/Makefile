TOPLEVEL_LANG = verilog
SIM           ?= icarus
TOPLEVEL      = tt_um_silicon_dreams
MODULE        = test_top_smoke
VERILOG_SOURCES = \
	$(PWD)/../../src/reset_synchroniser.v \
	$(PWD)/../../src/elevator.v \
	$(PWD)/../../src/elevator_req_port.v \
	$(PWD)/../../src/arbiter.v \
	$(PWD)/../../src/clock_gate.v \
	$(PWD)/../../src/axiom_blackbox.v \
	$(PWD)/../../src/axiom_blackbox_sim.v \
	$(PWD)/../../src/axiom_shim.v \
	$(PWD)/../../src/top.v

COMPILE_ARGS += -DSIM_AXIOM

include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: smoke
smoke:
	$(MAKE) sim MODULE=test_top_smoke
