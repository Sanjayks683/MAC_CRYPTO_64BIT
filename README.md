# 64-bit MAC Unit for Crypto

This is my B.Tech project. It's a 64-bit Multiply-Accumulate (MAC) unit designed in SystemVerilog. It is meant to be used for cryptographic calculations which need large numbers.

## Features
- 64x64 multiplier using Vedic mathematics (Urdhva-Tiryagbhyam)
- 128-bit Carry Select Adder (CSLA) with BEC to save area
- 5-stage pipeline to increase clock speed
- Supports different modes: multiply only, MAC, and MAC with modular reduction

## Folder Structure
- `rtl/` : Contains all the design files (multiplier, adders, pipeline logic).
- `tb/` : Contains the SystemVerilog testbench. I used a layered testbench approach with a driver, monitor, and scoreboard.
- `scripts/` : Quartus TCL and batch files for running synthesis.
- `docs/` : Extra documentation for the project.

## Simulation
To run the simulation, just compile `tb/mac_tb_top.sv` along with the files in the `rtl` folder using your simulator (ModelSim, Vivado, VCS, etc.). The testbench will automatically generate random inputs and check the answers against a golden model in the scoreboard.

## Synthesis Results
I synthesized the code using Intel Quartus Prime for a Cyclone V FPGA (5CGXFC7C7F23C8). Since it's a 64-bit design, I had to set the IOs as virtual pins so it would fit on the board.

Here are the final hardware results:

* **LUTs / Logic Cells used:** 11,322
* **Registers (Flip-Flops) used:** 722
* **DSP Blocks used:** 0 (Everything is built using basic gates/LUTs)
* **Max Clock Frequency (Fmax):** 42.4 MHz

Since the pipeline is 5 stages, it takes 5 cycles to get the first result, but after that it gives 1 result every clock cycle. So it runs at about 42 million operations per second.
