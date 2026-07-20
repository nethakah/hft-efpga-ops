.PHONY: test clean

test:
	iverilog -g2012 -o sim ../rtl/divider.sv test_divider.sv
	vvp sim

clean:
	rm -f sim dv.vcd