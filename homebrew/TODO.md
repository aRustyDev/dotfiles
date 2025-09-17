# TODO

- `aerospace`: update tap w/ License, dependencies, conflicts
- `tenv`: update tap w/ conflicts (cosign)
- `virtualbox`: update tap w/ License, dependencies, conflicts
- `packer`: update tap w/ License, dependencies, url
- `vagrant`: update tap w/ License, dependencies, url, conflicts
- `sevenzip`: update tap w/ dependencies, conflicts
- `resvg`: update tap w/ conflicts
- `imagemagick`: update tap w/ License (check it? 'ImageMagick'), conflicts
- `atuin`: update tap w/ conflicts
- `starship`: update tap w/ conflicts
- `yazi`: update tap w/ conflicts
- `lsd`: update tap w/ conflicts
- `fzf`: update tap w/ conflicts
- `1password-cli`: update tap w/ license, dependencies, conflicts (add @beta too)
- `font-symbols-only-nerd-font`: update tap w/ License, dependencies, conflicts
- `texinfo`: update tap w/ dependencies, conflicts
- `mise`: update tap w/ conflicts
- `eza`: update tap w/ conflicts
- `archiver`: update tap w/ conflicts
- `grv`: update tap w/ proper tap documenation (brew tap \*)

## Healthchecks

- conflicts != []
- .\* contains("todo")
- schema type mismatches
- entries are unique
- count todos by field

## Services

- atuin (/opt/homebrew/opt/atuin/bin/atuin daemon)

## Fix: dependency "foo, bar" like entries -> "foo", "bar"

## Distinguish between dependencies

Build vs Runtime; vs Requirements (Arch vs OS, etc)

## Distinguish between conflicts

Hard vs Soft (same binary vs duplicate coverage)

## Distinguish between AND / OR for licenses

## List 'channels' and set "default"/"selected" channel

## Capture Files installed, file sizes, cloc info, and sha256

## Detect and alert on "Deprecation" and "Disabled" casks/kegs/taps etc

## Add support for Attestation Verification

## Clearly show the "tap" for each formula

## Capture "caveats"?

## Enable out-of-band (OOB) dependency presence checking

- (e.g., allow pluggable tools to provide custom checks for dependencies)

## add clarification of "aliases" (ie kubernetes-cli vs kubectl)

### Fzf

```
To set up shell integration, see:
  https://github.com/junegunn/fzf#setting-up-shell-integration
To use fzf in Vim, add the following line to your .vimrc:
  set rtp+=/opt/homebrew/opt/fzf
```

### mise

```
If you are using fish shell, mise will be activated for you automatically.
```

### Bash

```
DEFAULT_LOADABLE_BUILTINS_PATH: /opt/homebrew/lib/bash:/usr/local/lib/bash:/usr/lib/bash:/opt/local/lib/bash:/usr/pkg/lib/bash:/opt/pkg/lib/bash:.
```

### Gawk

```
GNU "awk" has been installed as "gawk".
If you need to use it as "awk", you can add a "gnubin" directory
to your PATH from your ~/.bashrc and/or ~/.zshrc like:

    PATH="/opt/homebrew/opt/gawk/libexec/gnubin:$PATH"
```

### grep

````
All commands have been installed with the prefix "g".
If you need to use these commands with their normal names, you
can add a "gnubin" directory to your PATH from your bashrc like:
  PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"```
````

### Gnu-sed

```
GNU "sed" has been installed as "gsed".
If you need to use it as "sed", you can add a "gnubin" directory
to your PATH from your bashrc like:

    PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
```

### Coreutils

```
Commands also provided by macOS and the commands dir, dircolors, vdir have been installed with the prefix "g".
If you need to use these commands with their normal names, you can add a "gnubin" directory to your PATH with:
  PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
```

### Rustup

```
To initialize `rustup`, set a default toolchain:
  rustup default stable

If you have `rust` installed, ensure you have "$(brew --prefix rustup)/bin"
before "$(brew --prefix)/bin" in your $PATH:
  https://rust-lang.github.io/rustup/installation/already-installed-rust.html

rustup is keg-only, which means it was not symlinked into /opt/homebrew,
because it conflicts with rust.
```

### Browsh

```
You need Firefox 57 or newer to run Browsh
```

### Wireshark-chmodbpf

```
This cask will install only the ChmodBPF package from the current Wireshark
stable install package.
An access_bpf group will be created and its members allowed access to BPF
devices at boot to allow unprivileged packet captures.
This cask is not required if installing the Wireshark cask. It is meant to
support Wireshark installed from Homebrew or other cases where unprivileged
access to macOS packet capture devices is desired without installing the binary
distribution of Wireshark.
The user account used to install this cask will be added to the access_bpf
group automatically.

You must reboot for the installation of wireshark-chmodbpf to take effect.
```

### Rustnet

```
RustNet requires elevated privileges to capture network packets.

On macOS, you have several options:

1. Run with sudo (simplest):
   sudo rustnet

2. Add yourself to the access_bpf group (recommended):
   - Install Wireshark's ChmodBPF helper:
     brew install --cask wireshark-chmodbpf
   - This will create the access_bpf group and configure BPF permissions
   - Log out and back in for changes to take effect
   - Then run rustnet without sudo

3. Manual BPF configuration:
   sudo dseditgroup -o edit -a $USER -t user access_bpf

For more information, see: https://github.com/domcyrus/rustnet#permissions
```

### readline

```
readline is keg-only, which means it was not symlinked into /opt/homebrew,
because macOS provides BSD libedit.

For compilers to find readline you may need to set:
  export LDFLAGS="-L/opt/homebrew/opt/readline/lib"
  export CPPFLAGS="-I/opt/homebrew/opt/readline/include"

For pkg-config to find readline you may need to set:
  export PKG_CONFIG_PATH="/opt/homebrew/opt/readline/lib/pkgconfig"
```

### cmake

```
To install the CMake documentation, run:
  brew install cmake-docs
```

### Surrealdb

```
For local development only, this formula ships a launchd config
to start a single-node cluster that stores its data under:
  /opt/homebrew/var/
The database is available on the default port of 8000:
  http://localhost:8000
```
