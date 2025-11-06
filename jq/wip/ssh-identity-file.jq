# Used in conjunction with AWK script to convert ssh_config to json
.[]
| select(
        .hostname == $bastion
        and
        .identityfile != null
    )
| .identityfile
