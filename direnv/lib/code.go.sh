# Create new TEMPDIR to store tempfiles
if [[ -f go.sum ]]; then
    GOTMPDIR=`mktemp -d -t "go"`
fi
