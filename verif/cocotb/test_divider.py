import cocotb, random, os
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from golden import expected_divide

WIDTH = 32
FRAC_BITS = 0
MASK = (1 << WIDTH) - 1 # largest value for 32-bit input
N = WIDTH + FRAC_BITS

async def reset(dut):
    dut.rst.value = 1
    dut.start.value = 0
    dut.dividend.value = 0
    dut.divisor.value = 0
    
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)

async def execute_divide(dut, dividend, divisor):
    dut.dividend.value = dividend
    dut.divisor.value = divisor
    dut.start.value = 1

    await RisingEdge(dut.clk)
    dut.start.value = 0

    for _ in range(N + 16):
        await RisingEdge(dut.clk)
        if dut.done.value == 1:
            return (int(dut.quotient.value),
                    int(dut.remainder.value),
                    int(dut.dbz.value))

    assert False, f"Timeout: {dividend}/{divisor} did not assert done."

async def check(dut, dividend, divisor):
    output = await execute_divide(dut, dividend, divisor)
    expected = expected_divide(dividend, divisor, WIDTH, FRAC_BITS) # golden.py divide
    assert output == expected, f"{dividend}/{divisor} outputted (q,r,dbz)={output}; expected {expected}."

@cocotb.test()
async def test_divider(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    await reset(dut)

    specific_cases = [
        (0, 0), (5, 0),           # divide-by-zero: expect dbz=1, q=0, r=0
        (10, 1), (255, 1),        # divide by 1: expect quotient == dividend
        (7, 10), (0, 7),          # dividend < divisor, and zero dividend: expect q=0
        (42, 42), (MASK, MASK),   # dividend == divisor: expect q=1, r=0
        (MASK, 1),                # biggest quotient
        (13, 3), (100, 7),        # arbitrary (13/3 should give q=4, r=1)
    ]

    for dividend, divisor in specific_cases:
        await check(dut, dividend, divisor)
    cocotb.log.info("Specific cases passed!")

    for _ in range(1000):
        await check(dut, random.randint(0, MASK), random.randint(0, MASK))
    cocotb.log.info("1,000 random cases passed!")

