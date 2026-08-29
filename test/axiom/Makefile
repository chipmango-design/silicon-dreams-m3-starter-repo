TOPLEVEL_LANG = verilog
SIM           ?= icarus
TOPLEVEL      = axiom_shim
MODULE        = test_shim
VERILOG_SOURCES = \
	$(PWD)/../../src/axiom_blackbox.v \
	$(PWD)/../../src/axiom_blackbox_sim.v \
	$(PWD)/../../src/axiom_shim.v

COMPILE_ARGS += -DSIM_AXIOM

include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: shim
shim:
	$(MAKE) sim MODULE=test_shim
