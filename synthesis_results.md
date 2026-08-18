# Quartus Synthesis Results

Here are the hardware synthesis results for the 64-bit MAC unit. I used Intel Quartus Prime to compile the design.

**FPGA Board:** Cyclone V (Part: 5CGXFC7C7F23C8)

## Area Report (How much space it takes)
I didn't use any pre-built DSP blocks because the goal of the project was to build the Vedic multiplier and CSLA adders from scratch using basic logic gates.

* **Logic Cells (LUTs):** 11,322
* **Registers (Flip-Flops):** 722
* **DSP Blocks:** 0 

The 722 registers are mainly used for the 5-stage pipeline which holds the 64-bit and 128-bit numbers between stages. 11,322 LUTs is normal for a full 64x64 multiplier built without DSPs.

## Timing Report (How fast it runs)
I checked the timing using the TimeQuest analyzer in Quartus.

* **Delay:** 23.56 ns
* **Max Frequency (Fmax):** 42.4 MHz

For a 128-bit adder and modular reduction logic on an older FPGA like Cyclone V, 42 MHz is a good result. The 5-stage pipeline helped break down the long delay of the multiplier.

## Overall Performance
Because it is pipelined, the MAC unit gives an output every single clock cycle.
At 42.4 MHz, this means the design can do **42.4 million MAC operations per second**.
