# jq

Lightweight command-line JSON processor.

## Current Configuration

- **Status**: Stub module
- `jq.rules` - Rule definitions (empty)
- `wip/` - Work in progress

## TODOs

### Setup (Critical)

- [ ] **Create jq library**: jq supports module imports
  - Library location: `~/.jq` or `$JQ_LIBRARY_PATH`
  - Can define reusable functions

### Configuration (Medium Priority)

- [ ] **Common jq functions**: Create reusable filters
  ```jq
  # ~/.jq
  def map_values(f): .[] |= f;
  def compact: map(select(. != null and . != ""));
  def keys_sorted: keys | sort;
  ```

- [ ] **Kubernetes helpers**:
  ```jq
  def k8s_name: .metadata.name;
  def k8s_namespace: .metadata.namespace // "default";
  def k8s_labels: .metadata.labels // {};
  ```

- [ ] **JSON manipulation**:
  ```jq
  def flatten_object: [paths(scalars) as $p | {($p | join(".")): getpath($p)}] | add;
  def unflatten_object: reduce to_entries[] as $e ({}; setpath($e.key | split("."); $e.value));
  ```

### Integration (Low Priority)

- [ ] **Shell aliases**: Common jq operations
  ```bash
  alias jqc='jq -c'        # Compact output
  alias jqr='jq -r'        # Raw output
  alias jqs='jq -S'        # Sort keys
  alias jqp='jq .'         # Pretty print
  ```

- [ ] **fzf integration**: Preview JSON with jq
  ```bash
  alias jqf='fzf --preview "jq . {}"'
  ```

## Notes

jq doesn't have a traditional config file, but supports:
- `~/.jq` - Library file for user-defined functions
- `$JQ_LIBRARY_PATH` - Search path for modules
- Modules can be imported with `import "foo" as bar;`

## References

- [jq Manual](https://stedolan.github.io/jq/manual/)
- [jq Cookbook](https://github.com/stedolan/jq/wiki/Cookbook)
- [jq Play](https://jqplay.org/) - Online playground
