
      "name": "shellcheck",
      "tags": ["python"],
      "repo": "https://github.com/shellcheck-py/shellcheck-py",
      "description": ""

#Url: =~"^https://.*" // Must be unique in array, dont contain "([Oo]thers?)"
#Tags: "python"|"sync"|"fix"|"format"|"lint"|"png"|"images"|"json"|"yaml"|"github"|"gha"|"cicd"|"spelling"|"markdown"|"toc"|"prose"|"ruby"|"swift"|"terraform"|"protobuf"|"sql"|"cloudformation"|"jsonnet"|"lua"|"make"|"just"|"jupyter"|"commits-msg"|"git"|"secrets"|"rust"|"go"|"roc"|"powershell"|"zsh"|"shell"|"bash"|"sh"|"fish"|"nushell"|"elvish"|"c"|"cpp"|"objc"|"java"|"kotlin"|"tide"|"mermaid"|"mdbook"|"awk"|"jq"|"yq"|"toml"|"ini"|"env"|"direnv"|"gitlab"|"cue"|"sed"|"cli" // Valid tags

#Repo: {
    name: string // Must be unique in array != "todo"
    tags: [...#Tags] // Valid tags only
    repo: string & #Url // Must be unique in array, dont contain "([Oo]thers?)"
	description: string // Must be unique in array & Capital Case
}

#Hook: {
    language: string
    name: string
	repo: string
}

Config: {
    // These keys are expected and required by default
    url: {
        #Url
    }
    // Optional arrays of #FilePath, defaults to empty array if not specified
    just?: [...#FilePath] | *[]
    templates?: [...#FilePath] | *[]

    dotdir: bool | *false

    env?: {
        // This key is optional
    	Shell?: string
        // This key is optional
    	Dir?:  string
    }

    xdg: {
        // Required booleans, defaults to false if not specified
        Bin: bool | *false
        Data: bool | *false
        Cache: bool | *false
        State: bool | *false
        Config: bool | *false
        // This key is also required
        logLevel?: "info" | "debug" | "error" // Enums for allowed values
        timeoutSeconds?: int & >0 // Integer greater than 0
    }
}
