[.[] | select(.groups | contains(["aws"])) | { "\(.key | sub("aws_conf_"; "") | sub("aws_acct_"; "") | sub("aws_"; ""))": "\(.value)"}] | reduce .[] as $o ({}; . * $o) | . += { "cx" : $cx}
