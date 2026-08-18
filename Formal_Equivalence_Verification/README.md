Formal Equivalence Verification

1. Objective

The purpose of this step is to formally verify that the synthesized generic gate-level netlist preserves the functionality of the original RTL design.

The verification was performed using Yosys formal equivalence checking.

2. Design Flow

                RTL Design
                    │
                    ▼
              Yosys Synthesis
                    │
                    ▼
          Generic Gate-Level Netlist
              generic_clean.nl.v
                    │
                    ▼
             Formal Equivalence
                    │
          ┌─────────┴─────────┐
          │                   │
          ▼                   ▼
       RTL IL          Generic Netlist IL
      rtl.il              generic.il
          │                   │
          ▼                   ▼
     memory_map           memory_map
          │                   │
          ▼                   ▼
   rtl_mapped.il       generic_mapped.il
          │                   │
          └─────────┬─────────┘
                    ▼
             Yosys Equivalence
                    │
                    ▼
              2719 / 2719 PASS

3. Initial EQY Verification Attempt

The first formal verification approach used EQY to automatically partition and compare the RTL and gate-level designs.

The configuration was generated using:

eqy --init-config-file test.eqy top top.sv generic.nl.v

The EQY flow successfully read both designs, but the automatic partitioning stage failed.

3.1 First Partitioning Error

EQY reported:

ERROR: conflicting matches for gold bit
bridge1.fifo_master1.master1.master_apb.fifo_data [0]:

bridge1.fifo_master1.data_out [0]
vs
bridge1.fifo_master1.master1.master_apb.fifo_data [0]

The issue was caused by EQY finding multiple possible internal signal matches/aliases for the same gold signal.

The relevant signals were:

bridge1.fifo_master1.data_out
bridge1.fifo_master1.master1.master_apb.fifo_data

Both were present as 64-bit signals in the RTL representation.

3.2 Second Partitioning Error

After addressing the first conflicting match, EQY encountered another conflict:

ERROR: conflicting matches for gold bit
core1.data.e1.instr [20]:

core1.data.e1.instr [20]
vs
core1.data.e1.instr [15]

This showed that EQY's automatic internal signal matching was producing conflicting candidates during partitioning.

The problem was therefore with the EQY partition/matching process, not evidence of an RTL functional bug.

4. Direct Yosys Equivalence Verification

Because the EQY partitioning approach was not suitable for this design, a direct Yosys equivalence flow was used.

The design was converted into RTLIL and the generic netlist was also converted into RTLIL.

The initial equivalence process left a number of unproven equivalence cells.

At one stage:

Found 221 unproven $equiv cells

A later attempt reduced the number to:

107 unproven $equiv cells

5. Investigation of the Unproven Points

The equivalence log showed that several memory structures were represented as Yosys $mem_v2 cells.

Examples included:

bridge1.fifo_master1.fifo1.array ($mem_v2)

core1.data.r1.register ($mem_v2)

dmem1.ram ($mem_v2)

These correspond to memories such as:

FIFO storage

Register file

Data memory

Other memory structures in the design

The formal engine did not have a suitable SAT model for these $mem_v2 cells in the original representation.

This prevented all equivalence points from being proven.

6. Memory Mapping

To make the memory structures suitable for formal reasoning, memory_map was applied to both the RTL and generic gate-level representations.

RTL

yosys -p '
read_ilang rtl.il;
memory_map;
opt;
write_ilang rtl_mapped.il;
'

Generic Gate-Level Netlist

yosys -p '
read_ilang generic.il;
memory_map;
opt;
write_ilang generic_mapped.il;
'

This converted the $mem_v2 abstractions into explicit logic/register structures.

Importantly, this operation was applied equally to both designs.

6.1 No Verification Bypass

The memory_map step did not bypass formal verification.

No equivalence points were manually removed or forced to pass.

The following were not used to hide failures:

Signal exclusions

Forced equivalence results

Manual $equiv proofs

Ignored unproven points

Verification waivers

Instead, the same transformation was applied to both sides:

RTL
 │
 └── memory_map ──► RTL mapped representation

Generic Netlist
 │
 └── memory_map ──► Generic mapped representation

The resulting mapped designs were then formally compared.

7. Final Formal Equivalence

The final equivalence flow used:

equiv_make
equiv_simple
equiv_induct
equiv_status -assert

The induction stage successfully proved all remaining equivalence points.

The final Yosys result was:

Found 2719 $equiv cells in equiv:
  Of those cells 2719 are proven and 0 are unproven.

Equivalence successfully proven!

8. Final Result

Metric

Result

Total equivalence points

2719

Proven

2719

Unproven

0

Result

PASS

Verification Status

╔══════════════════════════════════════╗
║       FORMAL EQUIVALENCE PASS        ║
╠══════════════════════════════════════╣
║ Total equivalence points : 2719      ║
║ Proven                   : 2719      ║
║ Unproven                 : 0         ║
║ Result                   : PASS      ║
╚══════════════════════════════════════╝

9. Conclusion

The initial EQY verification attempt failed during automatic partitioning because of conflicting internal signal matches.

A direct Yosys equivalence flow was then used. The first direct attempts left equivalence points unproven because the design contained $mem_v2 memory structures that could not be directly modeled by the formal engine.

The memories were therefore mapped into explicit logic using memory_map on both the RTL and generic gate-level representations.

After this transformation, Yosys successfully proved:

2719 / 2719 equivalence points

with:

0 unproven equivalence points

Therefore, the generic synthesized gate-level implementation was formally proven equivalent to the RTL representation used in this verification flow.
