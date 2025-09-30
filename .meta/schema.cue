import "encoding/json"

// Name must start with a uppercase
// letter, as defined by Unicode.
#Url: =~"^https?://[a-zA-Z0-9\\.-]+(:\\d+)?/[a-zA-Z0-9\\.-_]*(/[\\?a-zA-Z0-9\\.-_=%&])?" | null

#Semver: string & =~"^((\\d{1,3})\\.){2}(\\d{1,3})(-(alpha)|(beta)|(rc)|(dev)|(pre))?$" | "0.1.0"

#Category: string | "TODO" // "TODO" | "TODO" | "TODO" | "TODO" | "TODO"

#Tag: string | "TODO" // "binary" | "env" | "file" | "arch" | "platform"

#FilePath: =~"^((.?/)|(../)+)?[a-zA-Z0-9\\.-_\\s/]+"

#Override: {
    just?: [...#FilePath] | *[]
    templates?: [...#FilePath] | *[]
}

#Dependency: {
    kind: "binary" | "env" | "file" | "arch" | "platform"
    var: string | "TODO"
}

version: #Semver
category: #Category
tags: [...#Tag] | *[]
description: string | "TODO"
completions: bool | null
keybindings: bool | null
aliases: bool | null
dotdir: bool | null
ignore: bool | null
just: bool | null
env: bool | null
loc: int & >=0 | 0
xdg: {
    // Required booleans, defaults to false if not specified
    Bin: bool | null
    Data: bool | null
    Cache: bool | null
    State: bool | null
    Config: bool | null
}
paths: bool | null
functions: bool | null
dependencies?: [...#Dependency] | []
// These keys are expected and required by default
url: {
   	contribute?: #Url
   	bugz?: #Url
   	docs?: #Url
}
templates: [...#FilePath] | []
health_checks: [...string] | []
generates: [...#FilePath] | []
platform_overrides: {
    windows?: #Override
    darwin?: #Override
    linux?: #Override
    bsd?: #Override
} | *{}
