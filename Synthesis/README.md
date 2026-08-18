# Synthesis

This step synthesizes the RTL design and generates a **gate-level netlist**.

## Command

Run the following inside the LibreLane Nix shell:

```bash
librelane --flow Classic --to Yosys.Synthesis config.json
```

## Output

After synthesis, the generated files can be found under:

```text
runs/<run_name>/
```

The synthesized netlist is typically located in:

```text
results/synthesis/
```

The synthesis log can be used to check for errors, warnings, cell statistics, and inferred logic.

## Check

A successful synthesis should complete without fatal errors and generate the synthesized gate-level netlist.

Next step: **Floorplanning / Placement and Routing**.
