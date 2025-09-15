[
    .[]
    | match("(.+)/(.+)"; "i")
    | {
        "description": "todo",
        "domain": "https://github.com",
        "name": "todo:\(.captures[1].string)",
        "owner":"\(.captures[0].string)",
        "repo":"\(.captures[1].string)",
        "tags": ["todo"],
        "url": "https://github.com/\(.captures[0].string)/\(.captures[1].string)"
    }
]
