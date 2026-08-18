# Quartus Prime Tcl script for MAC Unit Synthesis
load_package flow
project_new mac_top_64bit -overwrite

# Assign Family and Device (Common student board devices)
# Change this if you have a specific FPGA! (e.g., Cyclone V: 5CSEMA5F31C6)
set_global_assignment -name FAMILY "Cyclone V"

# Add RTL files
set_global_assignment -name SYSTEMVERILOG_FILE ../rtl/mac_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../rtl/full_adder.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../rtl/ripple_carry_adder.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../rtl/csla_block.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../rtl/csla_128bit.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../rtl/vedic_2x2.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../rtl/vedic_4x4.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../rtl/vedic_8x8.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../rtl/vedic_16x16.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../rtl/vedic_32x32.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../rtl/vedic_mult_64x64.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../rtl/bec.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../rtl/pipeline_ctrl.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../rtl/mac_top_64bit.sv

# Set top-level entity
set_global_assignment -name TOP_LEVEL_ENTITY mac_top_64bit

# Assign all pins as Virtual Pins to bypass the FPGA pin limit for 264 IOs
set_instance_assignment -name VIRTUAL_PIN ON -to *

# Run Analysis & Synthesis
execute_module -tool map

# Generate a timing netlist and run TimeQuest
execute_module -tool fit
execute_module -tool sta

project_close
