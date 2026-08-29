TOPLEVEL_LANG = verilog
SIM           ?= icarus
TOPLEVEL      = arbiter
MODULE        = test_fairness
VERILOG_SOURCES = $(PWD)/../../src/arbiter.v

include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: fairness
fairness:
	$(MAKE) sim MODULE=test_fairness
