Formal Equivalence Check

Overview

Formal equivalence was used to verify that the synthesized generic gate-level netlist preserves the functionality of the RTL design.

The initial EQY-based approach did not complete successfully because of conflicting signal matches during partitioning.

Initial Equivalence Attempt

The first approach used Yosys EQY to compare the RTL and gate-level netlist.

The first issue was a conflicting match involving:

bridge1.fifo_master1.master1.master_apb.fifo_data

EQY reported:

ERROR: conflicting matches for gold bit
bridge1.fifo_master1.master1.master_apb.fifo_data [0]

bridge1.fifo_master1.data_out [0]
vs
bridge1.fifo_master1.master1.master_apb.fifo_data [0]

This was caused by EQY finding multiple possible aliases for the same internal signal.

After addressing that issue, another conflicting match appeared:

ERROR: conflicting matches for gold bit
core1.data.e1.instr [20]

core1.data.e1.instr [20]
vs
core1.data.e1.instr [15]

At this point, the EQY partitioning approach was abandoned because the automatically generated signal matching was not providing a reliable equivalence partition for this design.

Direct Yosys Equivalence Check

A direct Yosys equivalence flow was then used instead.

The initial proof produced:

Found 221 unproven $equiv cells

After equiv_induct, the result was:

107 unproven $equiv cells

This was investigated further.

Cause of the Unproven Points

The equivalence log reported:

Warning: No SAT model available for cell
bridge1.fifo_master1.fifo1.array ($mem_v2).

Warning: No SAT model available for cell
core1.data.r1.register ($mem_v2).

Warning: No SAT model available for cell
dmem1.ram ($mem_v2).

The design contained several $mem_v2 memory representations, including:

FIFO memory

Register file

Instruction memory

Data memory

Because the formal engine could not directly reason about these memory cells in the original representation, several equivalence points remained unproven.

Solution

The RTL and generic gate-level representations were both passed through Yosys memory_map.

yosys -p '
read_ilang rtl.il;
memory_map;
opt;
write_ilang rtl_mapped.il;
'

and:

yosys -p '
read_ilang generic.il;
memory_map;
opt;
write_ilang generic_mapped.il;
'

The resulting files contained:

0 $mem_v2 cells

for both designs.

This did not bypass the equivalence check. The memories were converted into explicit logic/register structures in both designs so that the formal SAT/induction engine could reason about them.

Final Equivalence Check

The mapped RTL and mapped generic gate-level netlist were then compared using:

equiv_make
equiv_simple
equiv_induct
equiv_status -assert

The final result was:

Found 2719 $equiv cells in equiv:
  Of those cells 2719 are proven and 0 are unproven.

Equivalence successfully proven!

Final Result

+--------------------------+
| Formal Equivalence       |
+--------------------------+
| Equivalence points       | 2719 |
| Proven                   | 2719 |
| Unproven                 | 0    |
| Status                   | PASS |
+--------------------------+

Verification Flow

             RTL
              │
              ▼
          Yosys IL
              │
              ▼
         memory_map
              │
              ▼
       rtl_mapped.il
              │
              │
              │ Formal
              │ Equivalence
              │
              ▼
      generic_mapped.il
              ▲
              │
         memory_map
              ▲
              │
     generic gate-level
        netlist (.nl.v)
              ▲
              │
          Yosys
        synthesis

Conclusion

The initial EQY partition-based equivalence check failed because of conflicting internal signal matches.

The subsequent direct Yosys equivalence check initially left 107 points unproven because the formal engine could not directly model the $mem_v2 memories.

After mapping the memories into explicit logic on both sides, the formal check successfully proved:

2719 / 2719 equivalence points — PASS.

This establishes formal equivalence between the RTL and the synthesized generic gate-level implementation used in this check.
