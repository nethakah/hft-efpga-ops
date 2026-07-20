SIM ?= icarus
TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(shell pwd)/../rtl/divider.sv
TOPLEVEL = divider
MODULE = test_divider

# push params into the RTL (icarus) and the testbench (env)
COMPILE_ARGS += -g2012

include $(shell cocotb-config --makefiles)/Makefile.sim