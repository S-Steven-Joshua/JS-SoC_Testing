# Floorplanning

## Overview

Floorplanning is the first major physical-design stage after RTL verification, synthesis, formal equivalence checking, and gate-level simulation.

In this stage, the synthesized standard cells are given a physical region on the chip. The die and core dimensions are defined, and the design is prepared for placement, clock-tree synthesis, routing, and final physical verification.

## Design Information

| Parameter             |           Value |
| --------------------- | --------------: |
| Technology            |          SKY130 |
| Design                |           `top` |
| Synthesized instances |           6,767 |
| Synthesized cell area | 88,167.0592 µm² |
| Target utilization    |             50% |
| I/O pins              |              38 |
| Die area              |    500 × 500 µm |
| Core area             |    420 × 420 µm |
| Clock period          |           50 ns |
| Target frequency      |          20 MHz |

## Core Area Calculation

The synthesized standard-cell area is:

```text
88,167.0592 µm²
```

For a target utilization of 50%:

```text
Core Area = Cell Area / Utilization
          = 88,167.0592 / 0.50
          = 176,334.12 µm²
```

For an approximately square core:

```text
√176,334.12 ≈ 420 µm
```

Therefore, the theoretical core size is approximately:

```text
420 µm × 420 µm
```

## Floorplan Configuration

The current floorplan uses:

```json
"DIE_AREA": "0 0 500 500",
"CORE_AREA": "40 40 460 460",
"PL_TARGET_DENSITY_PCT": 50
```

This provides:

```text
Die  = 500 × 500 µm
Core = 420 × 420 µm
```

The theoretical cell utilization is approximately:

```text
88,167.0592 / (420 × 420) × 100 ≈ 50%
```

## Timing Constraints

The design targets a 50 ns clock period:

```text
Clock frequency = 1 / 50 ns = 20 MHz
```

The PnR and signoff SDC files define the clock constraint.

### PnR SDC

```tcl
create_clock -name clk -period 50.0 [get_ports clk]

set_clock_uncertainty 0.1 [get_clocks clk]

set_max_transition 1.5 [current_design]

set_max_fanout 6 [current_design]
```

### Signoff SDC

```tcl
create_clock -name clk -period 50.0 [get_ports clk]

set_clock_uncertainty 0.1 [get_clocks clk]

set_max_transition 1.5 [current_design]

set_max_fanout 6 [current_design]
```

The configuration references them using:

```json
"PNR_SDC_FILE": "dir::pnr.sdc",
"SIGNOFF_SDC_FILE": "dir::signoff.sdc"
```

## LibreLane Configuration

Relevant floorplanning parameters:

```json
"FP_PDN_CORE_RING": true,

"FP_SIZING": "absolute",
"DIE_AREA": "0 0 500 500",
"CORE_AREA": "40 40 460 460",

"PL_TARGET_DENSITY_PCT": 50,

"GPL_CELL_PADDING": 2,
"DPL_CELL_PADDING": 1
```

Synthesis optimization:

```json
"SYNTH_STRATEGY": "DELAY 4",
"MAX_FANOUT_CONSTRAINT": 6
```

## Floorplanning Command

To run the floorplanning stage:

```bash
librelane --flow Classic --to OpenROAD.Floorplan config.json
```

To run the complete physical-design flow:

```bash
librelane --flow Classic config.json
```

## Initial Floorplanning Results

The floorplanning stage produced a core-grid snapping warning similar to:

```text
[IFP-0028] Core area lower left (60.000, 60.000)
snapped to (60.260, 62.560)
```

This is not a fatal error. OpenROAD adjusts the requested core boundary to the legal placement/site grid.

## Placement and Timing Results

After placement optimization, the reported timing results were:

```text
Hold violations  = 0
Setup violations = 0
```

The worst setup slack was approximately:

```text
30.22 ns
```

for the current 50 ns clock constraint.

Electrical violations were still present:

```text
Max capacitance violations = 6
Max slew violations       = 629
```

The fanout constraint was reduced from 10 to 6, which significantly improved the violations.

### Before fanout optimization

```text
Max capacitance violations = 32
Max slew violations        = 2336
```

### After setting MAX_FANOUT_CONSTRAINT to 6

```text
Max capacitance violations = 6
Max slew violations        = 629
```

This demonstrates that the fanout constraint significantly improved the electrical characteristics of the design.

## Next Step

The design can proceed to the remaining physical implementation stages:

```text
Floorplanning
      ↓
Placement
      ↓
Clock Tree Synthesis (CTS)
      ↓
Routing
      ↓
Post-route STA
      ↓
DRC
      ↓
LVS
      ↓
Final GDS
```

The max-capacitance and max-slew violations must ultimately be resolved or otherwise accepted according to the technology/signoff criteria before tapeout.

## Summary

The floorplan was selected based on the synthesized cell area rather than arbitrarily choosing a die size.

The current physical-design target is:

```text
Technology       : SKY130
Die              : 500 × 500 µm
Core             : 420 × 420 µm
Target utilization: 50%
I/O pins         : 38
Clock period     : 50 ns
Clock frequency  : 20 MHz
```

The design has passed setup and hold timing checks at this stage, while max-capacitance and max-slew optimization continues during physical implementation.
