#Youtube: {
    // TODO: Flag length < 5
	title!: string
	topic!: string
	creator!: string
	// TODO: Flag 'v=example' ( & !~"v=example")
	// TODO: Determine proper length of '?=v'
	url!: =~"^https://www.youtube.com/watch\\?v=[a-zA-Z0-9_-]+$"
}

youtube!: [...#Youtube] | *[]
topics!: [...string] | *[]
