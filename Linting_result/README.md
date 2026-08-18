# Linting

Linting checks the RTL for syntax errors, coding issues, and potential design problems before synthesis.

## Command

Run inside the LibreLane Nix shell:

```bash
librelane --flow Classic --to OpenROAD.Checker.LintWarnings config.json
```

## Output

The lint results are stored in the run directory:

```text
runs/<run_name>/reports/
```

The lint log can be checked for warnings and errors.

## Check

A successful linting step should complete without **fatal errors**. Review the generated warnings and fix any important RTL issues before moving to synthesis.
