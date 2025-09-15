set shell := ["zsh", "-cu"]
root := `git rev-parse --show-toplevel`
host := `hostname`

# Repo Directories
datad := root + "/.data"
build := root + "/.build"
docsd := root + "/.docs/src"
jqd := build + "/jq"
cued := build + "/cue"
dockerd := build + "/docker"

# XDG Paths
xdg_bin := `echo ${XDG_BIN_HOME:=$HOME/.local/bin}`
xdg_data := `echo ${XDG_DATA_HOME:=$HOME/.local/share}`
xdg_cache := `echo ${XDG_CACHE_HOME:=$HOME/.local/cache}`
xdg_state := `echo ${XDG_STATE_HOME:=$HOME/.local/state}`
xdg_config := `echo ${XDG_CONFIG_HOME:=$HOME/.config}`
xdg_runtime := `echo ${XDG_RUNTIME_DIR:=$HOME/.local/share}`

# Data Files (json)
# - fp: file path
# - db: database / datafile
hostsdb := "hosts.json"
brewsdb := "brews.json"
hooksdb := "git-hooks.json"
hostsfp := datad + "/" + hostsdb
brewsfp := datad + "/" + brewsdb
hooksfp := datad + "/" + hooksdb

# Data Files (yaml)
fpaths := datad + "/fpaths.yaml"
paths := datad + "/paths.yaml"
mans := datad + "/man.yaml"
tools := datad + "/tools.yaml"
inits := datad + "/initializations.yaml"
comps := datad + "/completions.yaml"

# Computed Values
profile := shell("jq --arg h " + host + " '.[$h]' " + hostsfp)
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


_test:
    @echo {{metas}}

meta:
    @jq '.' {{metas}}

_lib_install s d:
    @cp $s $d

_lib_docker s d:
    @cp $s $d
    docker run --rm -it -v /tmp/.X11-unix:/tmp/.X11-unix zshrc:latest

_update_lines_of_code:
