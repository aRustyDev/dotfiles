#Url: {
	// Name must start with a uppercase
	// letter, as defined by Unicode.
	[string]: =~"^\\p{Lu}" // https://
}

#FilePath: {
	// Name must start with a uppercase
	// letter, as defined by Unicode.
	[string]: =~"^\\p{Lu}" // https://
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
