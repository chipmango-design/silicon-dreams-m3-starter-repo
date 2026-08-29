TOPLEVEL_LANG = verilog
SIM           ?= icarus
TOPLEVEL      = clock_gate
MODULE        = test_clock_gate
VERILOG_SOURCES = $(PWD)/../../src/clock_gate.v

# Use behavioural model by default (not -DSYNTHESIS)
include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: gate
gate:
	$(MAKE) sim MODULE=test_clock_gate
