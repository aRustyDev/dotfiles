.[] | select(.[$field] == "todo" or ( .[$field] | contains(["todo"]) ) ) | .name
