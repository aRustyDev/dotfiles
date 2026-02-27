root := `git rev-parse --show-toplevel`
cue := root + "/.build/cue"
metas := "zsh"

meta_json:
    @cue vet -c {{cue}}/meta.cue {{root}}/zsh/data.yaml

vet-meta:
    @for cfg in {{metas}}; do \
        cue vet -c {{cue}}/meta.cue {{root}}/$cfg/.meta.json; \
    done

init target:
    @cue export file.cue --out json
    @cue vet -c {{cue}}/meta.cue {{root}}/zsh/data.yaml

test:
    @echo "{{cue}}"
