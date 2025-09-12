# Stow Improved

## Ideas

```toml
[default]
# type : inferred by default
sudo = false
dest = "${XDG_CONFIG_HOME:-$HOME}"

[[pkg]]
name = "foo"
type = "dir|file"
dot = true
sudo = false
dest = "path/to/.foo"
src = "path/to/pkg/foo/"
```

- `.stow.local.ignore`: ignore file, not checked into version control
- `.stow.ignore`: ignore file, checked into version control
- `stow.toml`: configuration file
