# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_vector_manhattan_distance(dut):
    dut._log.info("Starting test_project (Vector Manhattan Distance Test)")

    # Start a 10 us period clock (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset sequence
    dut._log.info("Applying reset")
    dut.ena.value   = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    #-------------------------------------------------------------------------
    # Test 1: 
    #   Set A = 4, B = 8, C = 6, D = 2.
    #   Manhattan distance = |4-6| + |8-2| = 2 + 6 = 8.
    #-------------------------------------------------------------------------
    dut._log.info("Test 1: Manhattan Distance (A=4, B=8, C=6, D=2)")
    dut.ui_in.value  = (8 << 4) | 4        # B=8, A=4
    dut.uio_in.value = (0 << 6) | (2 << 3) | 6  # D=2, C=6 (upper bits ignored)
    await ClockCycles(dut.clk, 4)
    expected = 8
    actual = int(dut.uo_out.value)
    dut._log.info(f"Test 1: Expected uo_out = {expected}, got {actual}")
    assert actual == expected, f"Test 1 failed: expected {expected}, got {actual}"

    #-------------------------------------------------------------------------
    # Test 2: 
    #   Set A = 5, B = 3, C = 1, D = 7.
    #   Manhattan distance = |5-1| + |3-7| = 4 + 4 = 8.
    #-------------------------------------------------------------------------
    dut._log.info("Test 2: Manhattan Distance (A=5, B=3, C=1, D=7)")
    dut.ui_in.value  = (3 << 4) | 5        # B=3, A=5
    dut.uio_in.value = (0 << 6) | (7 << 3) | 1  # D=7, C=1
    await ClockCycles(dut.clk, 4)
    expected = 8
    actual = int(dut.uo_out.value)
    dut._log.info(f"Test 2: Expected uo_out = {expected}, got {actual}")
    assert actual == expected, f"Test 2 failed: expected {expected}, got {actual}"

    #-------------------------------------------------------------------------
    # Test 3:
    #   Set A = 7, B = 2, C = 2, D = 6.
    #   Manhattan distance = |7-2| + |2-6| = 5 + 4 = 9.
    #-------------------------------------------------------------------------
    dut._log.info("Test 3: Manhattan Distance (A=7, B=2, C=2, D=6)")
    dut.ui_in.value  = (2 << 4) | 7        # B=2, A=7
    dut.uio_in.value = (0 << 6) | (6 << 3) | 2  # D=6, C=2
    await ClockCycles(dut.clk, 4)
    expected = 9
    actual = int(dut.uo_out.value)
    dut._log.info(f"Test 3: Expected uo_out = {expected}, got {actual}")
    assert actual == expected, f"Test 3 failed: expected {expected}, got {actual}"

    #-------------------------------------------------------------------------
    # Test 4:
    #   Set A = 2, B = 3, C = 7, D = 1.
    #   Manhattan distance = |2-7| + |3-1| = 5 + 2 = 7.
    #-------------------------------------------------------------------------
    dut._log.info("Test 4: Manhattan Distance (A=2, B=3, C=7, D=1)")
    dut.ui_in.value  = (3 << 4) | 2        # B=3, A=2
    dut.uio_in.value = (0 << 6) | (1 << 3) | 7  # D=1, C=7
    await ClockCycles(dut.clk, 4)
    expected = 7
    actual = int(dut.uo_out.value)
    dut._log.info(f"Test 4: Expected uo_out = {expected}, got {actual}")
    assert actual == expected, f"Test 4 failed: expected {expected}, got {actual}"

    dut._log.info("All tests passed!")
