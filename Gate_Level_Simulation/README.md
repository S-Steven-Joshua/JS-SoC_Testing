# Gate-Level Simulation

## Overview

This stage verifies the synthesized generic gate-level netlist using the same testbench used for the RTL design.

The RTL design was synthesized using Yosys to generate a flattened generic gate-level netlist. The resulting netlist was then simulated independently to confirm that the synthesized logic produces the expected functional behavior.

## Flow

```text
RTL
 │
 │ Yosys synthesis
 ▼
generic_clean.nl.v
 │
 │ Gate-Level Simulation
 ▼
Testbench
 │
 ▼
Expected Output
