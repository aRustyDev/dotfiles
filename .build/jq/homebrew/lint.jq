def channeled(n;c):
    [
        n,
        (
            c?
            | select(. != null)
        )
    ]
    | join("@");
.
| sort_by(channeled(.name; .channel))
| unique_by(channeled(.name; .channel))
