# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_operations(dut):
    dut._log.info("Starting test_project (Operations Test)")

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

    ############################################################################
    # Tests for Vector Manhattan Distance (OpSel = 0)
    ############################################################################
    dut._log.info("Testing Vector Manhattan Distance (OpSel = 0)")

    # Test M1:
    #   Inputs:
    #     ui_in = {B, A} = {8, 4} => A=4, B=8
    #     uio_in = {OpSel, D, C} = {00, 2, 6} => C=6, D=2
    #   Calculation:
    #     Extend C: 6, Extend D: 2
    #     deltaX = |4 - 6| = 2, deltaY = |8 - 2| = 6, total = 8.
    dut.ui_in.value  = (8 << 4) | 4         # B=8, A=4
    dut.uio_in.value = (0 << 6) | (2 << 3) | 6  # OpSel=0, D=2, C=6
    await ClockCycles(dut.clk, 4)
    expected = 8
    actual = int(dut.uo_out.value)
    dut._log.info(f"Manhattan Test 1: Expected uo_out = {expected}, got {actual}")
    assert actual == expected, f"Manhattan Test 1 failed: expected {expected}, got {actual}"

    # Test M2:
    #   Inputs:
    #     ui_in = {B, A} = {3, 5} => A=5, B=3
    #     uio_in = {OpSel, D, C} = {00, 7, 1} => C=1, D=7
    #   Calculation:
    #     deltaX = |5 - 1| = 4, deltaY = |3 - 7| = 4, total = 8.
    dut.ui_in.value  = (3 << 4) | 5         # B=3, A=5
    dut.uio_in.value = (0 << 6) | (7 << 3) | 1  # OpSel=0, D=7, C=1
    await ClockCycles(dut.clk, 4)
    expected = 8
    actual = int(dut.uo_out.value)
    dut._log.info(f"Manhattan Test 2: Expected uo_out = {expected}, got {actual}")
    assert actual == expected, f"Manhattan Test 2 failed: expected {expected}, got {actual}"

    ############################################################################
    # Tests for Vector Box Area (OpSel = 1)
    ############################################################################
    dut._log.info("Testing Vector Box Area (OpSel = 1)")

    # Test BA1:
    #   Inputs:
    #     ui_in = {B, A} = {8, 4} => A=4, B=8
    #     uio_in = {OpSel, D, C} = {01, 2, 6} => C=6, D=2
    #   Calculation (Box Area):
    #     Extend C: 6, Extend D: 2
    #     deltaX = |6 - 4| = 2, deltaY = |8 - 2| = 6, area = 2 * 6 = 12.
    dut.ui_in.value  = (8 << 4) | 4         # B=8, A=4
    dut.uio_in.value = (1 << 6) | (2 << 3) | 6  # OpSel=1, D=2, C=6
    await ClockCycles(dut.clk, 4)
    expected = 12
    actual = int(dut.uo_out.value)
    dut._log.info(f"Box Area Test 1: Expected uo_out = {expected}, got {actual}")
    assert actual == expected, f"Box Area Test 1 failed: expected {expected}, got {actual}"

    # Test BA2:
    #   Inputs:
    #     ui_in = {B, A} = {3, 5} => A=5, B=3
    #     uio_in = {OpSel, D, C} = {01, 7, 1} => C=1, D=7
    #   Calculation:
    #     Extend C: 1, Extend D: 7
    #     deltaX = |5 - 1| = 4, deltaY = |7 - 3| = 4, area = 4 * 4 = 16.
    dut.ui_in.value  = (3 << 4) | 5         # B=3, A=5
    dut.uio_in.value = (1 << 6) | (7 << 3) | 1  # OpSel=1, D=7, C=1
    await ClockCycles(dut.clk, 4)
    expected = 16
    actual = int(dut.uo_out.value)
    dut._log.info(f"Box Area Test 2: Expected uo_out = {expected}, got {actual}")
    assert actual == expected, f"Box Area Test 2 failed: expected {expected}, got {actual}"

    # Test BA3:
    #   Inputs:
    #     ui_in = {B, A} = {2, 7} => A=7, B=2
    #     uio_in = {OpSel, D, C} = {01, 6, 2} => C=2, D=6
    #   Calculation:
    #     Extend C: 2, Extend D: 6
    #     deltaX = |7 - 2| = 5, deltaY = |6 - 2| = 4, area = 5 * 4 = 20.
    dut.ui_in.value  = (2 << 4) | 7         # B=2, A=7
    dut.uio_in.value = (1 << 6) | (6 << 3) | 2  # OpSel=1, D=6, C=2
    await ClockCycles(dut.clk, 4)
    expected = 20
    actual = int(dut.uo_out.value)
    dut._log.info(f"Box Area Test 3: Expected uo_out = {expected}, got {actual}")
    assert actual == expected, f"Box Area Test 3 failed: expected {expected}, got {actual}"

    # Test BA4:
    #   Inputs:
    #     ui_in = {B, A} = {3, 2} => A=2, B=3
    #     uio_in = {OpSel, D, C} = {01, 1, 7} => C=7, D=1
    #   Calculation:
    #     Extend C: 7, Extend D: 1
    #     deltaX = |7 - 2| = 5, deltaY = |3 - 1| = 2, area = 5 * 2 = 10.
    dut.ui_in.value  = (3 << 4) | 2         # B=3, A=2
    dut.uio_in.value = (1 << 6) | (1 << 3) | 7  # OpSel=1, D=1, C=7
    await ClockCycles(dut.clk, 4)
    expected = 10
    actual = int(dut.uo_out.value)
    dut._log.info(f"Box Area Test 4: Expected uo_out = {expected}, got {actual}")
    assert actual == expected, f"Box Area Test 4 failed: expected {expected}, got {actual}"

    dut._log.info("All tests passed!")
