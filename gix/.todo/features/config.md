# Config

- backward compatible with `gitconfig`
  - `system`
  - `user`
  - `project`

## Git/Gix Config

- [GitHub Repo][gh-repo]
- Gix Config
  - Figment based configs
  - TOML output by default
  - Read from Stdin `cat giconfig | gix config` should output validated TOML to STDOUT
  - Convert to GitConfig, `gix config --git-config` should output valid gitconfig to STDOUT
  - Should read `GIX_` ENV vars; build time flag enables `GIT_` vars too

### Git Config

```git-config
#
# This is the config file, and
# a '#' or ';' character indicates
# a comment
#

; core variables
[core]
	; Don't trust file modes
	filemode = false

; Our diff algorithm
[diff]
	external = /usr/local/bin/diff-wrapper
	renames = true

; Proxy settings
[core]
	gitproxy=proxy-command for kernel.org
	gitproxy=default-proxy ; for all the rest

; HTTP
[http]
	sslVerify
[http "https://weak.example.com"]
	sslVerify = false
	cookieFile = /tmp/cookie.txt
```

### Gix Config

```toml
# comment
[core]
filemode = false
gitproxy=proxy-command for kernel.org
gitproxy=default-proxy ; for all the rest

[diff]
external = /usr/local/bin/diff-wrapper
renames = true

[http]
sslVerify

[http."https://weak.example.com"]
sslVerify = false
cookieFile = /tmp/cookie.txt
```

- [git-filter-dimst23]: https://medium.com/@dimst23/a-hidden-gem-of-git-clean-smudge-filter-6c27bee20081 "Clean/Smudge"
- [git-filter-geeks]: https://www.geeksforgeeks.org/git/using-git-filters-customizing-content-on-the-fly/
- [gh-repo]: https://github.com/GitoxideLabs/gitoxide.git "gix github"
