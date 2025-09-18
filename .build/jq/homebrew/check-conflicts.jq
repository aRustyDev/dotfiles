# Checks for conflicts between packages
# For Testing, use: [( .[] | .name )] as $manifest|
.[]
| select(
    .name
    | IN($manifest[])
)
| select(
    .conflicts[]
    | IN($manifest[])
)
