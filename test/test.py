# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
    dut._log.info("Starting test_project (Addition Test)")

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
    # Test 1: Addition
    #   Inputs:
    #     ui_in  = {B, A} = {8, 4}  -> A=4, B=8
    #     uio_in = {ignored, D, C} = {xx, 2, 6}  -> C=6, D=2
    #   Expected output: 4 + 8 + 6 + 2 = 20
    #-------------------------------------------------------------------------
    dut._log.info("Test 1: Addition")
    dut.ui_in.value  = (8 << 4) | 4         # A=4, B=8
    dut.uio_in.value = (0 << 6) | (2 << 3) | 6  # D=2, C=6 (upper bits ignored)
    await ClockCycles(dut.clk, 4)
    expected = 20
    actual = int(dut.uo_out.value)
    dut._log.info(f"Test 1: Expected uo_out = {expected}, got {actual}")
    assert actual == expected, f"Test 1 failed: expected {expected}, got {actual}"

    #-------------------------------------------------------------------------
    # Test 2: Addition
    #   Inputs:
    #     ui_in  = {B, A} = {3, 5}  -> A=5, B=3
    #     uio_in = {ignored, D, C} = {xx, 7, 1}  -> C=1, D=7
    #   Expected output: 5 + 3 + 1 + 7 = 16
    #-------------------------------------------------------------------------
    dut._log.info("Test 2: Addition")
    dut.ui_in.value  = (3 << 4) | 5         # A=5, B=3
    dut.uio_in.value = (0 << 6) | (7 << 3) | 1  # D=7, C=1
    await ClockCycles(dut.clk, 4)
    expected = 16
    actual = int(dut.uo_out.value)
    dut._log.info(f"Test 2: Expected uo_out = {expected}, got {actual}")
    assert actual == expected, f"Test 2 failed: expected {expected}, got {actual}"

    #-------------------------------------------------------------------------
    # Test 3: Addition
    #   Inputs:
    #     ui_in  = {B, A} = {3, 2}  -> A=2, B=3
    #     uio_in = {ignored, D, C} = {xx, 1, 5}  -> C=5, D=1
    #   Expected output: 2 + 3 + 5 + 1 = 11
    #-------------------------------------------------------------------------
    dut._log.info("Test 3: Addition")
    dut.ui_in.value  = (3 << 4) | 2         # A=2, B=3
    dut.uio_in.value = (0 << 6) | (1 << 3) | 5  # D=1, C=5
    await ClockCycles(dut.clk, 4)
    expected = 11
    actual = int(dut.uo_out.value)
    dut._log.info(f"Test 3: Expected uo_out = {expected}, got {actual}")
    assert actual == expected, f"Test 3 failed: expected {expected}, got {actual}"

    #-------------------------------------------------------------------------
    # Test 4: Addition
    #   Inputs:
    #     ui_in  = {B, A} = {3, 2}  -> A=2, B=3
    #     uio_in = {ignored, D, C} = {xx, 5, 4}  -> C=4, D=5
    #   Expected output: 2 + 3 + 4 + 5 = 14
    #-------------------------------------------------------------------------
    dut._log.info("Test 4: Addition")
    dut.ui_in.value  = (3 << 4) | 2         # A=2, B=3
    dut.uio_in.value = (0 << 6) | (5 << 3) | 4  # D=5, C=4
    await ClockCycles(dut.clk, 4)
    expected = 14
    actual = int(dut.uo_out.value)
    dut._log.info(f"Test 4: Expected uo_out = {expected}, got {actual}")
    assert actual == expected, f"Test 4 failed: expected {expected}, got {actual}"

    dut._log.info("All tests passed!")
