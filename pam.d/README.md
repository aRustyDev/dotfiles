# PAM configuration for sudo

The PAM modules themselves are shared object (.so) files

A PAM interface is essentially the type of authentication action which that specific module can perform. Four types of PAM module interface are available, each corresponding to a different aspect of the authentication and authorization process:

An individual module can provide any or all module interfaces. For instance, pam_unix.so provides all four module interfaces.

## Explaining the files

Each file in this directory corresponds to a specific service. For instance, the
`sshd` file configures PAM for SSH, and the `sudo` file configures PAM for the
sudo command.

### `sudo`

- SUDO command line / terminal access.

### `sshd`

- Secure Shell (SSH) logins. Ensure Remote Logins are enabled in macOS System Preferences.

### `authorization`

- OS Logon screen.

### `screensaver`

- OS unlock screen.

### `sudo_local`

### `sudo_local.template`

## [Explaining the file contents][redhat-pam]

### `sufficient` vs `required`

- `required`:
  The module result must be successful for authentication to continue. If the
  test fails at this point, the user is not notified until the results of all
  module tests that reference that interface are complete.
- `requisite`:
  The module result must be successful for authentication to continue. However,
  if a test fails at this point, the user is notified immediately with a message
  reflecting the first failed required or requisite module test.
- `sufficient`:
  The module result is ignored if it fails. However, if the result of a module
  flagged sufficient is successful and no previous modules flagged required have
  failed, then no other results are required and the user is authenticated to
  the service.
- `optional`:
  The module result is ignored. A module flagged as optional only becomes
  necessary for successful authentication when no other modules reference the
  interface.
- `include`:
  Unlike the other controls, this does not relate to how the module result is
  handled. This flag pulls in all lines in the configuration file which match
  the given parameter and appends them as an argument to the module.

### PAM module interface: `auth`

This module interface authenticates users. For example, it requests and verifies the validity of a password. Modules with this interface can also set credentials, such as group memberships

### PAM module interface: `account`

This module interface verifies that access is allowed. For example, it checks if a user account has expired or if a user is allowed to log in at a particular time of day.

### PAM module interface: `password`

This module interface is used for changing user passwords

### PAM module interface: `session`

This module interface configures and manages user sessions. Modules with this interface can also perform additional tasks that are needed to allow access, like mounting a user's home directory and making the user's mailbox available

## About the **Shared Object** (`*.so`) files

### `pam_tid.so`

### `pam_smartcard.so`

### `pam_opendirectory.so`

### `pam_permit.so`

### `pam_deny.so`

### `pam_unix.so`

- controls when users must enter their password for sudo

### Finding Additional Modules (`~.so`)

```bash
ls /usr/lib/pam/pam_*
ls /opt/homebrew/lib/pkcs11/
ls /opt/homebrew/lib/pam/
fd pkcs /opt/homebrew/lib/
fd pam /opt/homebrew/lib/
fd -t d -E $HOME -E /System/Volumes/Data/Users/$(whoami) -E /nix pam /
fd -t f -E '**/*pam*/*' -E $HOME -E '*.h' -E '*.plist' -E '**/man/**' -E /System/Volumes/Data/Users/$(whoami) -E /nix pam /
```

- `brew install pam-u2f`
- `brew install pam-reattach`
- `brew install google-authenticator-libpam`

- [redhat-pam]: https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/system-level_authentication_guide/pam_configuration_files "RedHat Docs"
