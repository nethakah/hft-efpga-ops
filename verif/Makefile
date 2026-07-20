sim: ../rtl/divider.sv tb_divider.sv
	iverilog -g2012 -o sim ../rtl/divider.sv tb_divider.sv
	vvp sim
clean:
	rm -f sim dv.vcd