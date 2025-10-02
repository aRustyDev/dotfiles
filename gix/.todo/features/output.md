# Gix output format

- all output should be formatt-able as
  - (\*) json (`jq` support)
  - markdown
  - html
  - txt
  - yaml
  - csv
  - tsv
  - toml

## Use cases

### Cleaning up local branches

- instead of `git branch --v | grep "\[gone\]" | awk '{print $1}' | xargs git branch -D`
  - `gix branch --v -o json | jq '.'`

clean-git:
git stash save "just: stashing while cleaning up"
git checkout main
git branch --v | grep "\[gone\]" | awk '{print $1}' | xargs git branch -D
git fetch origin --prune
git checkout main
git pop
