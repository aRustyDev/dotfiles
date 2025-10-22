# Read newline-delimited JSON objects from stdin
# Group by name, collect unique/sorted IPv4 addresses
# Wrap under "local" plus pass USER env var
[
    .responses[].answers[]
]
| group_by(.name)
# For each group do
| map(
    {
        # since grouped by name, all have the same name
        name: .[0].name,
        # Get unique sorted IPs
        ips: (
            # Grab [.address]
            map( .address )
            # Get unique and sort
            | unique
            | sort_by(
                split(".")
                | map(tonumber)
            )
        )
    }
)
| { user: ($u // "unknown"), localhost: $dns, zones: . }
