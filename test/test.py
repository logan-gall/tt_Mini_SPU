# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_main(dut):
    dut._log.info("Starting simulation...")

    # Create a 10 ns period clock (100 MHz)
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Initial signal values
    dut.rst_n.value = 1
    dut.ena.value   = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    # Reset sequence:
    # Wait 5 cycles, then drive rst_n low for 5 cycles, then release reset.
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1

    # Wait an additional 3 cycles then enable processing.
    await ClockCycles(dut.clk, 3)
    dut.ena.value = 1

    ############################################################################
    # SETUP MEMORY
    ############################################################################
    # Load A and B using Q = 4'b0110, A = 4, B = 5.
    Q = 0b0110
    A = 4
    B = 5
    # ui_in = {4'b0000, Q}
    dut.ui_in.value = (0 << 4) | Q
    # uio_in = {A, B}
    dut.uio_in.value = (A << 4) | B

    await ClockCycles(dut.clk, 4)  # Wait for data propagation

    # Load C and D using Q = 4'b0101, C = 6, D = 7.
    Q = 0b0101
    dut.ui_in.value = (0 << 4) | Q
    C = 6
    D = 7
    # uio_in = {C, D}
    dut.uio_in.value = (C << 4) | D

    await ClockCycles(dut.clk, 4)  # Wait for data propagation

    ############################################################################
    # EXECUTE OPERATIONS
    ############################################################################
    for i in range(16):
        # Cycle through operations: Op = i[3:0]
        Op = i & 0xF
        Q = 0  # No register update during operation
        # ui_in = {Op, Q}
        dut.ui_in.value = (Op << 4) | Q

        await ClockCycles(dut.clk, 4)  # Allow time for processing

        # Extract uo_out: [7:4] = M, [3:0] = N.
        uo_val = int(dut.uo_out.value)
        M = (uo_val >> 4) & 0xF
        N = uo_val & 0xF

        sim_time = cocotb.utils.get_sim_time("ns")
        dut._log.info(f"Time = {sim_time} ns")
        dut._log.info(f"Op  = {Op:04b} ({Op})")
        dut._log.info(f"A   = {A}, B = {B}, C = {C}, D = {D}")
        dut._log.info(f"M   = {M}, N = {N}")
        dut._log.info("-" * 30)
