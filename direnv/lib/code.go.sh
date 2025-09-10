# Create new TEMPDIR to store tempfiles
if [[ -f go.sum ]]; then
    GOTMPDIR=`mktmp -d -t "go"`
fi
