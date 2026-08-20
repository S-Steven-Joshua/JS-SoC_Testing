
# Floorplanning

## Overview

Floorplanning is the first major physical-design stage after RTL verification, synthesis, formal equivalence checking, and gate-level simulation.

In this stage, the synthesized standard cells are assigned a physical region on the chip. The die and core dimensions are defined, and the design is prepared for placement, clock-tree synthesis, routing, and final physical verification.

---

## Design Information

| Parameter             | Value |
| --------------------- | -----: |
| Technology            | SKY130 |
| Design                | `top` |
| Synthesized instances | 8,873 |
| Synthesized cell area | 96,308.6176 µm² |
| Target utilization    | 50% |
| I/O pins              | 38 |
| Die area              | 500 × 500 µm |
| Core area             | 440 × 440 µm |
| Clock period          | 50 ns |
| Target frequency      | 20 MHz |
| Synthesis strategy    | `DELAY 4` |
| Maximum fanout        | 6 |

---

## Post-Synthesis Area

The latest synthesis result is:

```text
Instance count = 8,873
Cell area      = 96,308.6176 µm²
```

The synthesized standard-cell area is used to determine the required core area.

---

## Core Area Calculation

The target utilization is 50%.

The required core area is:

```text
Core Area = Cell Area / Target Utilization

          = 96,308.6176 / 0.50

          = 192,617.2352 µm²
```

For an approximately square core:

```text
√192,617.2352 ≈ 438.88 µm
```

Therefore, a practical core size of:

```text
440 µm × 440 µm
```

was selected.

The resulting core area is:

```text
440 × 440 = 193,600 µm²
```

The estimated utilization is:

```text
96,308.6176 / 193,600 × 100
≈ 49.75%
```

Therefore, the selected 440 × 440 µm core provides approximately the targeted 50% utilization.

---

## Die Area

A die size of:

```text
500 µm × 500 µm
```

was selected.

The floorplan configuration is:

```json
"DIE_AREA": "0 0 500 500",
"CORE_AREA": "30 30 470 470",
"PL_TARGET_DENSITY_PCT": 50
```

This provides:

```text
Die  = 500 × 500 µm
Core = 440 × 440 µm
```

The `CORE_AREA` format is:

```text
x1 y1 x2 y2
```

Therefore:

```text
Core width  = 470 - 30 = 440 µm
Core height = 470 - 30 = 440 µm
```

The 30 µm offset between the die boundary and the core boundary provides space for I/O placement and other physical-design requirements.

---

## I/O Pin Reduction

The initial design contained 102 top-level I/O pins.

Two unnecessary 32-bit buses were removed from the top-level interface:

```text
write_data[31:0] → 32 pins
data_add[31:0]   → 32 pins
```

Therefore:

```text
102 - 32 - 32 = 38 pins
```

The current top-level interface contains:

| Signal | Width | Pins |
| ------ | ----: | ---: |
| `clk` | 1 | 1 |
| `rst` | 1 | 1 |
| `mem_write` | 1 | 1 |
| `pr_data` | 32 | 32 |
| `wave` | 1 | 1 |
| `wave1` | 1 | 1 |
| `wave2` | 1 | 1 |
| **Total** | | **38** |

The 32-bit `pr_data` output is intentionally retained to observe the complete UART-reconstructed data in parallel.

---

## Clock Constraint

The design targets a 50 ns clock period:

```text
Clock period   = 50 ns
Clock frequency = 1 / 50 ns
                = 20 MHz
```

LibreLane configuration:

```json
"CLOCK_PORT": "clk",
"CLOCK_PERIOD": 50
```

---

## PnR SDC

The PnR SDC file contains the clock and basic timing constraints:

```tcl
# PnR timing constraints

create_clock -name clk -period 50.0 [get_ports clk]

# Clock uncertainty
set_clock_uncertainty 0.1 [get_clocks clk]

# Maximum transition
set_max_transition 1.5 [current_design]
```

The maximum fanout is controlled through the LibreLane configuration:

```json
"MAX_FANOUT_CONSTRAINT": 6
```

The fanout constraint is not duplicated in the PnR SDC.

---

## Signoff SDC

The signoff SDC file currently uses stricter electrical constraints:

```tcl
# Signoff timing constraints

create_clock -name clk -period 50.0 [get_ports clk]

# Clock uncertainty
set_clock_uncertainty 0.5 [get_clocks clk]

# Maximum transition
set_max_transition 0.4 [current_design]

# Maximum fanout
set_max_fanout 4

# Maximum capacitance
set_max_capacitance 0.8 [current_design]
```

The configuration references both SDC files:

```json
"PNR_SDC_FILE": "dir::pnr.sdc",
"SIGNOFF_SDC_FILE": "dir::signoff.sdc"
```

---

## LibreLane Configuration

The relevant floorplanning parameters are:

```json
"FP_PDN_CORE_RING": true,

"FP_SIZING": "absolute",
"DIE_AREA": "0 0 500 500",
"CORE_AREA": "30 30 470 470",

"PL_TARGET_DENSITY_PCT": 50,

"GPL_CELL_PADDING": 2,
"DPL_CELL_PADDING": 1
```

Synthesis and fanout optimization:

```json
"SYNTH_STRATEGY": "DELAY 4",
"MAX_FANOUT_CONSTRAINT": 6
```

---

## Floorplanning Command

To run only the floorplanning stage:

```bash
librelane --flow Classic --to OpenROAD.Floorplan config.json
```

To run the complete physical-design flow:

```bash
librelane --flow Classic config.json
```

---

## Floorplanning Results

During floorplanning, OpenROAD may produce a core-grid snapping warning similar to:

```text
[IFP-0028] Core area lower left (...) snapped to (...)
```

This is not a fatal error.

OpenROAD adjusts the requested core boundary to the legal placement/site grid of the SKY130 technology.

---

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

The worst hold slack was approximately:

```text
0.1499 ns
```

Therefore, setup and hold timing were clean at this stage.

---

## Electrical Constraint Results

The initial placement results with a maximum fanout constraint of 10 were:

```text
Max capacitance violations = 32
Max slew violations        = 2336
```

The maximum fanout constraint was then reduced to 6:

```json
"MAX_FANOUT_CONSTRAINT": 6
```

The resulting violations improved to:

```text
Max capacitance violations = 6
Max slew violations        = 629
```

### Before Fanout Optimization

```text
Max capacitance violations = 32
Max slew violations        = 2336
```

### After Setting MAX_FANOUT_CONSTRAINT to 6

```text
Max capacitance violations = 6
Max slew violations        = 629
```

This demonstrates that reducing the fanout constraint significantly improved the electrical characteristics of the design.

The remaining max-capacitance and max-slew violations require further optimization during physical implementation.

---

## SDC Error and Correction

An initial PnR SDC contained:

```tcl
set_max_fanout 6 [current_design]
```

OpenSTA reported:

```text
wrong # args: should be "set_max_fanout fanout objects"
```

The PnR SDC was corrected by removing the incompatible `set_max_fanout` command.

The fanout constraint is instead controlled through the LibreLane configuration:

```json
"MAX_FANOUT_CONSTRAINT": 6
```

This prevents the SDC parsing error during the pre-PnR STA stage.

---

## Floorplanning Database

The OpenROAD database generated during the physical-design process is:

```text
top.odb
```

The `.odb` file contains the OpenROAD physical-design database, including floorplan and placement information.

A DEF representation can be generated using:

```tcl
write_def /path/to/floorplan.def
```

The DEF contains the physical floorplan and placement information.

KLayout cannot directly open the OpenROAD `.odb` format. The DEF requires the corresponding SKY130 LEF and technology information to correctly display the standard cells.

---

## Floorplanning Files

The recommended GitHub directory structure is:

```text
05_floorplanning/
├── README.md
├── config.json
├── pnr.sdc
├── signoff.sdc
├── floorplan.log
├── top.odb
└── floorplan.def
```

### File Description

| File | Description |
| ---- | ----------- |
| `README.md` | Floorplanning documentation |
| `config.json` | LibreLane configuration |
| `pnr.sdc` | P&R timing constraints |
| `signoff.sdc` | Signoff timing constraints |
| `floorplan.log` | Floorplanning execution log |
| `top.odb` | OpenROAD physical-design database |
| `floorplan.def` | Physical floorplan/placement representation |

---

## Physical Design Flow

The overall physical-design flow is:

```text
RTL
 │
 ├── Lint
 │
 ├── Synthesis
 │
 ├── Formal Equivalence Check
 │
 ├── Gate-Level Simulation
 │
 ▼
Floorplanning
 │
 ▼
Placement
 │
 ▼
Clock Tree Synthesis (CTS)
 │
 ▼
Routing
 │
 ▼
Post-Route STA
 │
 ▼
DRC
 │
 ▼
LVS
 │
 ▼
Final GDS
```

---

## Next Step

After successful floorplanning and placement, the design proceeds to:

```text
Placement
    ↓
Clock Tree Synthesis (CTS)
    ↓
Routing
    ↓
Post-Route STA
    ↓
DRC
    ↓
LVS
    ↓
Final GDS
```

The max-capacitance and max-slew violations must ultimately be resolved or otherwise accepted according to the SKY130 technology and final signoff requirements before tapeout.

---

## Summary

The floorplan was calculated from the latest post-synthesis standard-cell area.

Current design parameters:

```text
Technology            : SKY130
Design                : top
Synthesized instances : 8,873
Cell area             : 96,308.6176 µm²

I/O pins              : 38

Die                   : 500 × 500 µm
Core                  : 440 × 440 µm

Target utilization    : 50%
Estimated utilization : ≈49.75%

Clock period          : 50 ns
Clock frequency       : 20 MHz

Synthesis strategy    : DELAY 4
Maximum fanout        : 6
```

The selected 500 × 500 µm die and 440 × 440 µm core provide a practical starting point for physical implementation.

At the current stage:

```text
Setup violations      : 0
Hold violations       : 0
Max capacitance       : 6 violations
Max slew              : 629 violations
```

Setup and hold timing are currently clean, while the remaining electrical violations will be addressed during the subsequent physical-design stages.
````
