# Convert SSH config stanzas into JSON objects.
# Usage:
#   awk -f ssh_config_to_json.awk ~/.ssh/config | jq -s '.'
#
# Notes:
# - Does NOT resolve includes, precedence, or conditional Match directives.
# - Repeated directives become arrays.
# - Host line patterns are split into an array "hosts".
# - Keywords are lowercased in output.
#
BEGIN {
  IGNORECASE=1
  inblock=0
  n=0
}
# Skip comments and blank lines
/^[ \t]*#/ { next }
/^[ \t]*$/ { next }

# Start of a new Host stanza
/^[Hh]ost[ \t]/ {
  # Flush previous stanza if any
  if (inblock) flush()
  # Reset data structures
  delete data
  delete count
  delete order
  n=0
  inblock=1

  # Gather host patterns from this line (skip the 'Host' keyword)
  blockHosts=""
  for (i=2; i<=NF; i++) {
    if ($i != "") {
      blockHosts = blockHosts (blockHosts ? " " : "") $i
    }
  }
  next
}

# Within a stanza, gather directives
inblock {
  # Directive lines typically start with an alpha keyword
  if ($1 ~ /^[A-Za-z]/) {
    key=tolower($1)
    $1=""
    val=substr($0,2)
    gsub(/^[ \t]+|[ \t]+$/,"",val)

    # Escape JSON quotes
    gsub(/\\/,"\\\\",val)
    gsub(/"/,"\\\"",val)

    if (key in data) {
      # Append for repeated keys
      data[key] = data[key] ",\"" val "\""
      count[key]++
    } else {
      data[key] = "\"" val "\""
      count[key]=1
      order[++n] = key
    }
  }
  next
}

# Flush function emits one JSON object for current stanza
function flush() {
  print "{"
  # Emit hosts array
  split(blockHosts, h, /[ \t]+/)
  printf "  \"hosts\": ["
  for (i=1; i<=length(h); i++) {
    printf "\"%s\"%s", h[i], (i<length(h)?"," :"")
  }
  print "],"

  # Emit keys
  for (i=1; i<=n; i++) {
    k=order[i]
    if (count[k] > 1) {
      # Array for repeated directives
      printf "  \"%s\": [%s]%s\n", k, data[k], (i==n?"":",")
    } else {
      printf "  \"%s\": %s%s\n", k, data[k], (i==n?"":",")
    }
  }
  print "}"
  inblock=0
}

END {
  if (inblock) flush()
}
