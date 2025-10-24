# Planning `meta.json` for dotfiles

## Functions

- `semver` converter
  - majore
  - minor
  - patch
  - pre-release
  - build metadata
- schema comparator
  - check if remote schema is newer than local schema
- cue tester
- uuid validator
- new meta.json generator
- dependency generator (extract used tools from the json to add to dependencies)
- Need some way to load the functions into a global pool to deconflict across all per shell dotfile contexts
- Need some way to determine generated files / artifacts

## Architectural decisions

- How to define a metafile for `shells` (bash, zsh, fish, powershell, xonsh, elvish, nushell, etc)
- Do keybind managers differ in their definitions/schemas? (skhd, sxhkd, kwin, etc)
- cross platform Keybind managment
- context considerations for aliases and keybinds
- How to / is it possible to, make this editorconfig compliant?

```json
[
  {
    "version": "0.1.0",
    "category": "TODO",
    "tags": ["TODO"],
    "description": "This does blah blah foo bar",
    "just": null,
    "completions": {
      // Describe command for completions & supported shells
      // The shells will use this to generate the appropriate completion files
      "command": "{{self}} completion {{shell}}",
      "source": "path/to/completions",
      "shells": [
        "fish",
        "zsh",
        "bash",
        "powershell",
        "xonsh",
        "elvish",
        "nushell"
      ]
    },
    "keybindings": [
      {
        "key": "TODO",
        "command": "TODO",
        "context": "TODO"
      }
    ],
    "aliases": [
      {
        "key": "TODO",
        "value": "TODO"
      }
    ],
    // Does this tool have anything to ignore?
    "ignore": [
      {
        "kind": "git",
        "regex": "TODO", //  regex XOR blob
        "blob": "TODO"
      },
      {
        "kind": "ripgrep",
        "regex": "TODO", //  regex XOR blob
        "blob": "TODO"
      }
    ],
    // How to clean up
    "tasks": [
      {
        "kind": "install"
        "stage":"runtime|build|all|pre-*|post-*|uninstall|install",
        "method": "homebrew|nix|cargo|go|npm|pip|gem|source|binary|manual",
        "package": "TODO",
        "version": "TODO",
        "platform": {
          "os": ["linux","darwin|macos","windows","unix","bsd","*"],
          "arch": ["amd64","arm64","386"]
        },
        "url": "TODO",
        "sha256": "TODO"
      },
      {
        "kind": "health"
        "stage":"runtime|build|all|pre-*|post-*|uninstall|install",
        "method": "homebrew|nix|cargo|go|npm|pip|gem|source|binary|manual",
        "package": "TODO",
        "version": "TODO",
        "platform": {
          "os": ["linux","darwin|macos","windows","unix","bsd","*"],
          "arch": ["amd64","arm64","386"]
        },
        "url": "TODO",
        "sha256": "TODO"
      },
      {
        "kind": "build"
        "stage":"runtime|build|all|pre-*|post-*|uninstall|install",
        "method": "cargo|go|npm|pip|gem|source|binary|manual",
        "package": "TODO",
        "version": "TODO",
        "platform": {
          "os": ["linux","darwin|macos","windows","unix","bsd","*"],
          "arch": ["amd64","arm64","386"]
        },
        "url": "TODO",
        "sha256": "TODO"
      },
      {
        "kind": "test"
        "stage":"runtime|build|all|pre-*|post-*|uninstall|install",
        "method": "homebrew|nix|cargo|go|npm|pip|gem|source|binary|manual",
        "package": "TODO",
        "version": "TODO",
        "platform": {
          "os": ["linux","darwin|macos","windows","unix","bsd","*"],
          "arch": ["amd64","arm64","386"]
        },
        "url": "TODO",
        "sha256": "TODO"
      },
      {
        "kind": "clean"
        "stage":"runtime|build|all|pre-*|post-*|uninstall|install",
        "method": "cargo|go|npm|pip|gem|source|binary|manual",
        "package": "TODO",
        "version": "TODO",
        "platform": {
          "os": ["linux","darwin|macos","windows","unix","bsd","*"],
          "arch": ["amd64","arm64","386"]
        },
        "url": "TODO",
        "sha256": "TODO"
      }
    ]
    // Repeated tasks to run on a schedule (Cross-platform considerations)
    "cron":[
      {
        "cron": "TODO",
        "command": "TODO",
        "user": "TODO"
      }
    ]
    "env": [
      {
        "key": "foo",
        "value": "TODO",
        "required": false,
        "description": "string"
      }
    ],
    "dot": {
      "xdg": true,
      // /etc/*
      "system":{
        "bin": null,
        "data": "just",
        "cache": "just",
        "state": "just",
        "config": "just"
      },
      // usr/local/*
      "share":{
        "bin": null,
        "data": "just",
        "cache": "just",
        "state": "just",
        "config": "just"
      },
      // $HOME/.local/*
      "user":{
        "bin": null,
        "data": "just",
        "cache": "just",
        "state": "just",
        "config": "just"
      }
    },
    "paths": [
      {
        "priority": 0,
        "": "file|dir",
      }
    ],
    "functions": [
      {
        "shell": "TODO",
        "source": "TODO"
      }
    ],
    // Dependencies needed for this tool to work
    "dependencies": [
      {
        "kind": "binary|env|file|arch|platform",
        "stages": ["runtime","install","uninstall","build","all"],
        "var": "TODO"
      },
      {
        "kind": "binary",
        "stages": ["install","uninstall"],
        "var": "just"
      }
    ],
    "url": {
      "contribute": "TODO",
      "bugz": "TODO",
      "docs": "TODO"
    },
    "templates": ["TODO"],
    "artifacts": ["TODO"],
    "self":{
      // path relative to dotfiles root; default = "{{self.name}}"
      "path": "foo",
      // name of the tool; default = basename(path)
      "name": "foo",
      // lines of code; default = $(cloc)
      "loc": 0,
      // uuid of the tool; default = uuidv5(name)
      "id": "6A07C24E-1308-4406-B094-3F83491D5E29"
    }
  }
]
```
