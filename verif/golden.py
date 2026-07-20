def divide(dividend:int, divisor:int, 
           width:int = 32, frac_bits:int = 0) 
           -> tuple[int, int, int]:
    assert(0 <= frac_bits <= width) 

    # force inputs to be fixed-width unsigned bit values
    mask = (1 << width) - 1
    dividend &= mask
    divisor &= mask
        
    # return (quotient, remainder, divide-by-zero flag)
    
    if divisor == 0:
        return (0, 0, 1)
        # arbitrary - just must agree w hardware to flag dbz
    
    shifted_dividend = dividend << frac_bits
    quotient = shifted_dividend // divisor
    remainder = shifted_dividend % divisor
    return (quotient, remainder, 0)