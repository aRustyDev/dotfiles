# awk

Pattern-directed text processing language.

## Current Configuration

- **Status**: Stub module
- `wip/` - Work in progress scripts

## TODOs

### Setup (Low Priority)

- [ ] **Create awk library**: Common awk functions
  - No standard config location for awk
  - Consider creating scripts directory

### Scripts (Low Priority)

- [ ] **Common awk patterns**:
  ```awk
  # Print specific columns
  awk '{print $1, $3}'

  # Sum a column
  awk '{sum += $1} END {print sum}'

  # Filter by pattern
  awk '/pattern/ {print}'

  # Field separator
  awk -F: '{print $1}'
  ```

- [ ] **CSV processing**:
  ```awk
  # Using FPAT for proper CSV handling (GNU awk)
  awk 'BEGIN { FPAT = "([^,]+)|(\"[^\"]+\")" }'
  ```

### Consideration

- [ ] **Modern alternatives**: Consider when to use awk vs:
  - `jq` - For JSON
  - `yq` - For YAML
  - `miller` (mlr) - For CSV/JSON/etc
  - `xsv` - For CSV
  - Rust tools (ripgrep, sd, etc.)

## Notes

awk has no config file - it's a command-line tool. This module would contain:
- Reusable awk scripts
- Function libraries (sourced with -f flag)
- Reference examples

## References

- [GNU Awk Manual](https://www.gnu.org/software/gawk/manual/)
- [The AWK Programming Language](https://ia903404.us.archive.org/0/items/pdfy-MgN0H1joIoDVoIC7/The_AWK_Programming_Language.pdf)
- [Awk One-Liners](https://catonmat.net/awk-one-liners-explained-part-one)
