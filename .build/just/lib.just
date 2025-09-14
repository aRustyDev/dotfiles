set shell := ["zsh", "-cu"]
root := `git rev-parse --show-toplevel`
host := `hostname`

# Repo Directories
dockerd := root + "/.build/docker"
jqd := root + "/.build/jq"
cued := root + "/.build/cue"
docsd := root + "/.docs/src"

# XDG Paths
xdg_bin := "${XDG_BIN_HOME:-$HOME/.config}"
xdg_data := "${XDG_DATA_HOME:-$HOME/.config}"
xdg_cache := "${XDG_CACHE_HOME:-$HOME/.config}"
xdg_state := "${XDG_STATE_HOME:-$HOME/.config}"
xdg_config := "${XDG_CONFIG_HOME:-$HOME/.config}"
xdg_runtime := "${XDG_RUNTIME_DIR:-$HOME/.local/share}"

# Data Files (json)
hosts := root + "/.data/hosts.json"
brews := root + "/.data/brews.json"
hooks := root + "/.data/git-hooks.json"

# Data Files (yaml)
fpaths := root + "/.data/fpaths.yaml"
paths := root + "/.data/paths.yaml"
mans := root + "/.data/man.yaml"
tools := root + "/.data/tools.yaml"
inits := root + "/.data/initializations.yaml"
comps := root + "/.data/completions.yaml"

# Computed Values
profile := shell("jq --arg h " + host + " '.[$h]' " + hosts)
metas := shell("fd -Hi -E .build/ -t file meta.json " + root)
todos := shell("fd -Hi -E .build/ -t file todo.md " + root)
# tmp := `mktemp -d -t "zed.settings"`

# get-config
# ? version

# ? x.Dependency
#   . | select(.dependencies.binaries == "foo")
# ? x.Env
#   . | select(.dependencies.binaries == "foo")
# ? x.completions
# ? Dependency -> x
# ? Env -> x
# ? Tag -> [x]
# ? LoC(x)
# ? x.xdg.* != true


test:
    @echo {{metas}}

meta:
    @jq '.' {{metas}}

_lib_install s d:
    @cp $s $d

_lib_docker s d:
    @cp $s $d
    docker run --rm -it -v /tmp/.X11-unix:/tmp/.X11-unix zshrc:latest

_update_lines_of_code:
