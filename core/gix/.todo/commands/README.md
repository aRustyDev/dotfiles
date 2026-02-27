---
id: 7b8d4053-41a2-4d42-9cc2-a360595cafa5
title: GitOxide
created: 2025-12-13T00:00:00
updated: 2025-12-13T00:00:00
project: dotfiles
scope: git
type: reference
status: 🚧 in-progress
publish: false
tags:
  - git
  - gix
aliases:
  - GitOxide
  - GitOxide Reference
related: []
---

# GitOxide

```
helpers
  help
  tutorials
  guides
  man
  completions (bash, zsh, fish, powershell, nushell, elvish, xonsh, tcsh)

project management
  clone      Clone a repository into a new directory
  init       Create an empty Git repository or reinitialize an existing one
  setup
  config
    - credentials
  remote
  submod    (git submodule)

basic snapshotting
  add        Add file contents to the index
  mv         Move or rename a file, a directory, or a symlink
  restore    Restore working tree files
  rm         Remove files from the working tree and from the index
  stash
  status     Show the working tree status
  diff       Show changes between commits, commit and working tree, etc
  commit     Record changes to the repository
  notes
  reset      Reset current HEAD to the specified state

examine the history and state (see also: git help revisions)
  bisect     Use binary search to find the commit that introduced a bug
  grep       Print lines matching a pattern
    - search files/commits/hashes/filenames/metadata across branches
  log        Show commit logs
  shortlog
  show       Show various types of objects
  blame
  describe

branch management
  branch     List, create, or delete branches
  checkout   **TODO**
  switch     Switch branches
  merge      Join two or more development histories together
  merge-base
  mergetool
  log
  stash
  tag        Create, list, delete or verify a tag object signed with GPG
    - verify  (git verify-tag)
    - mktag   (git mktag)
  tree
    - ls      (gix ls-tree)
    - write   (gix write-tree)
    - diff    (gix diff-tree)
    - read    (gix read-tree)
    - commit  (gix commit-tree)


grow, mark and tweak your common history
  backfill   Download missing objects in a partial clone
  rebase     Reapply commits on top of another base tip

utilities
  clean
  gc
  prune
  fsck
  reflog
  filter-branch
  instaweb
  bundle
  daemon
  update-server-info
  archive (gix archive)
    - upload (gix-upload-archive)
  index
    - update (gix update-index)
    - merge (gix merge-index)
    - checkout (gix checkout-index)
  ref
    - --symbolic (gix symbolic-ref)
    - show (gix show-ref)
  files
    - ls (gix ls-files)
    - cat (gix cat-file)
  object
    - count (gix count-objects)
    - hash (gix hash-object)
  pack
    - repack (gix-repack)
    - receive (git-receive-pack)
    - upload-pack (gix-upload-pack)

collaborate (see also: git help workflows)
  fetch      Download objects and refs from another repository
  pull       Fetch from and integrate with another repository or a local branch
  push       Update remote refs along with associated objects
  pr         (eq. git request-pull)
  format-patch

email
  am
  apply
  imap-send
  format-patch
  send-email
  request-pull

patching
  apply
  cherry-pick
  diff
  rebase
  revert

Inspection and Comparison
  show
  log
  diff
  difftool
  range-diff
  shortlog
  describe

debugging
  bisect
  blame
  grep


plumbing
  cat-file
  check-ignore
  checkout-index
  commit-tree
  count-objects
  diff-index
  for-each-ref
  hash-object
  ls-files
  ls-tree
  merge-base
  read-tree
  rev-list
  rev-parse
  show-ref
  symbolic-ref
  update-index
  update-ref
  verify-pack
  write-tree

```

```
gix cvsserver
gix shell
gix interpret-trailers
gix credential-cache
```
