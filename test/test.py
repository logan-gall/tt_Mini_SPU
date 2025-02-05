# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
    dut._log.info("Starting test_project")

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
    # Test 1: Raster Focal Mean (OpSel = 00)
    #   Inputs:
    #     ui_in  = {B, A} = {8, 4}
    #     uio_in = {OpSel, D, C} = {00, 2, 6}
    #   Expected output:
    #     uo_out = 5
    #-------------------------------------------------------------------------
    dut._log.info("Test 1: Raster Focal Mean")
    dut.ui_in.value  = (8 << 4) | 4         # 4-bit A in lower nibble, 4-bit B in upper nibble
    dut.uio_in.value = (0 << 6) | (2 << 3) | 6  # 2-bit OpSel=00, 3-bit D, 3-bit C
    await ClockCycles(dut.clk, 4)
    expected = 5
    actual = int(dut.uo_out.value)
    dut._log.info(f"Test 1: Expected uo_out = {expected}, got {actual}")
    assert actual == expected, f"Test 1 failed: expected {expected}, got {actual}"

    #-------------------------------------------------------------------------
    # Test 2: Vector Manhattan Distance (OpSel = 01)
    #   Inputs:
    #     ui_in  = {B, A} = {3, 5}
    #     uio_in = {OpSel, D, C} = {01, 7, 1}
    #   Expected output:
    #     uo_out = 8
    #-------------------------------------------------------------------------
    dut._log.info("Test 2: Vector Manhattan Distance")
    dut.ui_in.value  = (3 << 4) | 5         # B=3, A=5
    dut.uio_in.value = (1 << 6) | (7 << 3) | 1  # OpSel=01, D=7, C=1
    await ClockCycles(dut.clk, 4)
    expected = 8
    actual = int(dut.uo_out.value)
    dut._log.info(f"Test 2: Expected uo_out = {expected}, got {actual}")
    assert actual == expected, f"Test 2 failed: expected {expected}, got {actual}"

    #-------------------------------------------------------------------------
    # Test 3: Vector Box Area (OpSel = 10)
    #   Inputs:
    #     ui_in  = {B, A} = {3, 2}
    #     uio_in = {OpSel, D, C} = {10, 1, 5}
    #   Expected output:
    #     uo_out = 6
    #-------------------------------------------------------------------------
    dut._log.info("Test 3: Vector Box Area")
    dut.ui_in.value  = (3 << 4) | 2         # B=3, A=2
    dut.uio_in.value = (2 << 6) | (1 << 3) | 5  # OpSel=10, D=1, C=5
    await ClockCycles(dut.clk, 4)
    expected = 6
    actual = int(dut.uo_out.value)
    dut._log.info(f"Test 3: Expected uo_out = {expected}, got {actual}")
    assert actual == expected, f"Test 3 failed: expected {expected}, got {actual}"

    #-------------------------------------------------------------------------
    # Test 4: Tensor Multiply (OpSel = 11)
    #   Inputs:
    #     ui_in  = {B, A} = {3, 2}
    #     uio_in = {OpSel, D, C} = {11, 5, 4}
    #   Expected output:
    #     uo_out = 6
    #   (Explanation: The two least-significant bits of A and B produce product1 = 2*3 = 6,
    #    while the two LSBs of C and D yield product2 = 0*1 = 0; the result is {product2, product1} = 0x06.)
    #-------------------------------------------------------------------------
    dut._log.info("Test 4: Tensor Multiply")
    dut.ui_in.value  = (3 << 4) | 2         # B=3, A=2
    dut.uio_in.value = (3 << 6) | (5 << 3) | 4  # OpSel=11, D=5, C=4
    await ClockCycles(dut.clk, 4)
    expected = 6
    actual = int(dut.uo_out.value)
    dut._log.info(f"Test 4: Expected uo_out = {expected}, got {actual}")
    assert actual == expected, f"Test 4 failed: expected {expected}, got {actual}"

    dut._log.info("All tests passed!")
