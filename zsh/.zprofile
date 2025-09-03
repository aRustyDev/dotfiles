if [ -x /usr/libexec/path_helper ]; then
    # PATH=""
	eval `/usr/libexec/path_helper -s`
fi

# XDG_CONFIG_HOME: Where user-specific configurations should be written (analogous to /etc).
# - Purpose: For user-specific configuration files and directories. This is where applications should store their settings.
# - $HOME/.config
#   - CARGO_CONFIG_DIR (.cargo/config)
# XDG_CACHE_HOME: Where user-specific non-essential (cached) data should be written (analogous to /var/cache).
# - Purpose: For temporary, non-essential files that can be regenerated or downloaded. Examples include web browser caches, package manager caches, or compiled code caches.
# - $HOME/.cache
#   - CARGO_CACHE_DIR (.cargo/git, .cargo/registry)
# XDG_DATA_HOME: Where user-specific data files should be written (analogous to /usr/share).
# - Purpose: For application data that is not configuration, cache, or runtime-specific. Think of it as where an application might store its internal data, like game saves or downloaded content.
# - $HOME/.local/share
# XDG_STATE_HOME: Where user-specific state files should be written (analogous to /var/lib).
# - Purpose: For state data that should persist between application restarts, but is not important enough to be considered configuration. This might include application history, logs, or temporary files that need to survive a reboot.
# - $HOME/.local/state
# XDG_BIN_HOME: Where user-specific executables should be written (similar to /usr/bin). (Non-standard, but popular)
# - $HOME/.local/bin
#   - CARGO_BIN_DIR (.cargo/bin)
# XDG_RUNTIME_DIR: Defines the base directory relative to which user-specific non-essential runtime files and other file objects (like sockets, named pipes, etc.) should be placed. This directory must be owned by the user, with read and write access limited to the user (Unix access mode 0700). It must be on a local filesystem and its lifetime is tied to the user's login session (i.e., it should be removed upon logout).
# - Purpose: For communication and synchronization purposes between applications. It's often used for temporary files that don't need to persist across reboots. Unlike other XDG variables, it does not have a default fallback value if unset; applications should issue a warning if it's not set and fall back to a replacement directory with similar capabilities.
# XDG_DATA_DIRS: Defines a preference-ordered set of base directories to search for data files in addition to the XDG_DATA_HOME base directory. Directories are separated by a colon (:). If this variable is unset or empty, its default value is /usr/local/share:/usr/share.
# - Purpose: For system-wide or globally installed data files that applications might need to access.
# XDG_CONFIG_DIRS: Defines a preference-ordered set of base directories to search for configuration files in addition to the XDG_CONFIG_HOME base directory. Directories are separated by a colon (:). If this variable is unset or empty, its default value is /etc/xdg.
# - Purpose: For system-wide or globally installed configuration files.
