[
    .items[] | {
        "description": "\(.repository.description)",
        "domain": "\( .repository.html_url | match("(https://[^/]+)"; "i") | .captures[0].string)",
        "forks": [
            "ids",
            "\(.repository.forks_url)"
        ],
        "id": "\(.repository.id)",
        "is_fork": "\(.repository.fork)",
        "name": "todo:\(.repository.name)",
        "node_id": "\(.repository.node_id)",
        "owner": "\(.repository.owner.login)",
        "repo": "\(.repository.name)",
        "tags": ["todo"],
        "url": "\( .repository.html_url | match("(https://[^/]+)"; "i") | .captures[0].string)/\(.repository.owner.login)/\(.repository.name)"
    }
]
