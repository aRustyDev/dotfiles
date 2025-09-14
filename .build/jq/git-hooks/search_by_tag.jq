[
    .repos[]
    | select( .tags | contain($tag) )
]
