#!/usr/bin/env bash

# Git Setup Script with SQLite Backend
# Configures git repositories with SSH keys and user information from local SQLite database

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DB_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/git-setup/git-profiles.db"
DB_DIR="$(dirname "$DB_PATH")"

# Ensure database directory exists
mkdir -p "$DB_DIR"

# Function to print colored output
print_color() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

# Function to detect OS and set SSH signing program
set_os_specific_stuff() {
    local kernel_name
    kernel_name=$(uname -s)

    case "$kernel_name" in
        Linux*)
            print_color "$BLUE" "Linux detected"
            GIT_SSH_SIGNING_PROGRAM="/usr/bin/ssh-keygen"
            ;;
        Darwin*)
            print_color "$BLUE" "macOS detected"
            GIT_SSH_SIGNING_PROGRAM="/usr/bin/ssh-keygen"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            print_color "$BLUE" "Windows detected"
            GIT_SSH_SIGNING_PROGRAM="C:/Windows/System32/OpenSSH/ssh-keygen.exe"
            ;;
        *)
            print_color "$RED" "Unknown OS: $kernel_name"
            exit 1
            ;;
    esac

    if [ ! -f "$GIT_SSH_SIGNING_PROGRAM" ]; then
        print_color "$RED" "SSH signing program not found: $GIT_SSH_SIGNING_PROGRAM"
        exit 1
    fi
}

# Initialize SQLite database
init_database() {
    if [ ! -f "$DB_PATH" ]; then
        print_color "$YELLOW" "Creating new git profiles database..."
        sqlite3 "$DB_PATH" <<EOF
CREATE TABLE profiles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    email TEXT NOT NULL,
    ssh_key_path TEXT,
    ssh_public_key TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

-- Insert default settings
INSERT INTO settings (key, value) VALUES ('version', '1.0');

-- Create index for faster lookups
CREATE INDEX idx_profiles_name ON profiles(name);

-- Trigger to update timestamp on modification
CREATE TRIGGER update_profiles_timestamp
AFTER UPDATE ON profiles
BEGIN
    UPDATE profiles SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;
EOF
        print_color "$GREEN" "Database created successfully"
    fi
}

# Add or update a profile
add_profile() {
    local name=$1
    local display_name=$2
    local email=$3
    local ssh_key_path=$4
    local ssh_public_key=""

    # Read public key from file if path is provided
    if [ -n "$ssh_key_path" ] && [ -f "$ssh_key_path.pub" ]; then
        ssh_public_key=$(cat "$ssh_key_path.pub")
    elif [ -n "$ssh_key_path" ] && [ -f "$ssh_key_path" ]; then
        # Try to extract public key from private key
        ssh_public_key=$(ssh-keygen -y -f "$ssh_key_path" 2>/dev/null || echo "")
    fi

    if [ -z "$ssh_public_key" ]; then
        print_color "$RED" "Error: Could not read SSH public key"
        return 1
    fi

    sqlite3 "$DB_PATH" <<EOF
INSERT OR REPLACE INTO profiles (name, display_name, email, ssh_key_path, ssh_public_key)
VALUES ('$name', '$display_name', '$email', '$ssh_key_path', '$ssh_public_key');
EOF

    print_color "$GREEN" "Profile '$name' saved successfully"
}

# List all profiles
list_profiles() {
    print_color "$BLUE" "Available Git Profiles:"
    sqlite3 -column -header "$DB_PATH" <<EOF
SELECT name, display_name, email,
       CASE WHEN ssh_key_path IS NOT NULL THEN 'File' ELSE 'Embedded' END as key_type,
       datetime(updated_at, 'localtime') as last_updated
FROM profiles
ORDER BY name;
EOF
}

# Get profile details
get_profile() {
    local profile_name=$1
    sqlite3 -separator "|" "$DB_PATH" <<EOF
SELECT display_name, email, ssh_key_path, ssh_public_key
FROM profiles
WHERE name = '$profile_name';
EOF
}

# Delete a profile
delete_profile() {
    local profile_name=$1
    sqlite3 "$DB_PATH" "DELETE FROM profiles WHERE name = '$profile_name';"
    print_color "$GREEN" "Profile '$profile_name' deleted"
}

# Configure git repository with profile
configure_git() {
    local profile_name=$1

    # Get profile data
    local profile_data
    profile_data=$(get_profile "$profile_name")

    if [ -z "$profile_data" ]; then
        print_color "$RED" "Error: Profile '$profile_name' not found"
        print_color "$YELLOW" "Available profiles:"
        list_profiles
        return 1
    fi

    # Parse profile data
    IFS='|' read -r display_name email ssh_key_path ssh_public_key <<< "$profile_data"

    print_color "$BLUE" "Configuring git for profile: $profile_name"
    print_color "$BLUE" "  Name: $display_name"
    print_color "$BLUE" "  Email: $email"

    # Set git configuration
    git config --local user.name "$display_name"
    git config --local user.email "$email"
    git config --local user.signingkey "$ssh_public_key"
    git config --local commit.gpgsign true
    git config --local tag.gpgsign true
    git config --local gpg.format ssh
    git config --local gpg.ssh.program "$GIT_SSH_SIGNING_PROGRAM"

    # Update allowed signers file
    local allowed_signers="${XDG_CONFIG_HOME:-$HOME/.config}/git/allowed_signers"
    mkdir -p "$(dirname "$allowed_signers")"

    # Remove existing entry for this email if present
    if [ -f "$allowed_signers" ]; then
        grep -v "^$email " "$allowed_signers" > "$allowed_signers.tmp" || true
        mv "$allowed_signers.tmp" "$allowed_signers"
    fi

    # Add new entry
    echo "$email $ssh_public_key" >> "$allowed_signers"
    git config --local gpg.ssh.allowedSignersFile "$allowed_signers"

    print_color "$GREEN" "Git configuration updated successfully"
}

# Setup pre-commit hooks
setup_precommit() {
    if ! command -v pre-commit &> /dev/null; then
        print_color "$YELLOW" "pre-commit not found. Installing..."
        pip install --user pre-commit
    fi

    if [ -f ".pre-commit-config.yaml" ]; then
        print_color "$BLUE" "Installing pre-commit hooks..."
        pre-commit install
        pre-commit install --hook-type commit-msg
        print_color "$GREEN" "Pre-commit hooks installed"
    else
        print_color "$YELLOW" "No .pre-commit-config.yaml found, skipping pre-commit setup"
    fi
}

# Import profiles from 1Password agent.toml
import_from_1password() {
    local agent_toml="${HOME}/.config/1Password/ssh/agent.toml"

    if [ ! -f "$agent_toml" ]; then
        print_color "$RED" "1Password agent.toml not found at: $agent_toml"
        return 1
    fi

    print_color "$YELLOW" "This will attempt to import SSH key configurations from 1Password."
    print_color "$YELLOW" "You'll need to manually add the display name and email for each key."

    # Parse agent.toml and extract SSH keys
    # This is a simplified parser - in production you'd want something more robust
    while IFS= read -r line; do
        if [[ $line =~ \[\[ssh-keys\]\] ]]; then
            local vault=""
            local item=""

            while IFS= read -r key_line && [[ ! $key_line =~ \[\[.*\]\] ]]; do
                if [[ $key_line =~ vault[[:space:]]*=[[:space:]]*\"(.*)\" ]]; then
                    vault="${BASH_REMATCH[1]}"
                elif [[ $key_line =~ item[[:space:]]*=[[:space:]]*\"(.*)\" ]]; then
                    item="${BASH_REMATCH[1]}"
                fi
            done

            if [ -n "$vault" ] && [ -n "$item" ]; then
                print_color "$BLUE" "Found key: $item in vault: $vault"
                print_color "$YELLOW" "This import feature requires manual configuration."
                print_color "$YELLOW" "Use: git-setup add <profile-name> <display-name> <email> <ssh-key-path>"
            fi
        fi
    done < "$agent_toml"
}

# Export profile to SSH config format
export_ssh_config() {
    local profile_name=$1
    local profile_data
    profile_data=$(get_profile "$profile_name")

    if [ -z "$profile_data" ]; then
        print_color "$RED" "Error: Profile '$profile_name' not found"
        return 1
    fi

    IFS='|' read -r display_name email ssh_key_path ssh_public_key <<< "$profile_data"

    if [ -n "$ssh_key_path" ]; then
        print_color "$GREEN" "SSH config for $profile_name:"
        echo "# Git profile: $profile_name"
        echo "# User: $display_name <$email>"
        echo "IdentityFile $ssh_key_path"
    else
        print_color "$YELLOW" "No SSH key file path stored for this profile"
    fi
}

# Show help
show_help() {
    cat << EOF
Git Setup with SQLite - Configure git repositories with stored profiles

Usage: git-setup <command> [arguments]

Commands:
    init                                    Initialize the SQLite database
    add <name> <display-name> <email> <ssh-key-path>
                                           Add or update a profile
    list                                   List all stored profiles
    delete <profile-name>                  Delete a profile
    use <profile-name>                     Configure current repo with profile
    show <profile-name>                    Show profile details
    export-ssh <profile-name>              Export SSH config for profile
    import-1password                       Import from 1Password agent.toml
    setup-precommit                        Setup pre-commit hooks
    help                                   Show this help message

Examples:
    # Initialize database
    git-setup init

    # Add a new profile
    git-setup add github "John Doe" "john@example.com" ~/.ssh/id_github

    # Configure current repository
    git-setup use github

    # List all profiles
    git-setup list

Environment Variables:
    XDG_DATA_HOME    Base directory for database (default: ~/.local/share)

Database Location:
    $DB_PATH
EOF
}

# Main execution
main() {
    local command=${1:-help}

    # Initialize database if it doesn't exist
    init_database

    # Set OS-specific variables
    set_os_specific_stuff

    case "$command" in
        init)
            print_color "$GREEN" "Database initialized"
            ;;
        add)
            if [ $# -lt 5 ]; then
                print_color "$RED" "Error: Missing arguments"
                echo "Usage: git-setup add <name> <display-name> <email> <ssh-key-path>"
                exit 1
            fi
            add_profile "$2" "$3" "$4" "$5"
            ;;
        list)
            list_profiles
            ;;
        delete)
            if [ $# -lt 2 ]; then
                print_color "$RED" "Error: Missing profile name"
                exit 1
            fi
            delete_profile "$2"
            ;;
        use)
            if [ $# -lt 2 ]; then
                print_color "$RED" "Error: Missing profile name"
                exit 1
            fi
            configure_git "$2"
            ;;
        show)
            if [ $# -lt 2 ]; then
                print_color "$RED" "Error: Missing profile name"
                exit 1
            fi
            get_profile "$2" | column -t -s '|'
            ;;
        export-ssh)
            if [ $# -lt 2 ]; then
                print_color "$RED" "Error: Missing profile name"
                exit 1
            fi
            export_ssh_config "$2"
            ;;
        import-1password)
            import_from_1password
            ;;
        setup-precommit)
            setup_precommit
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            # For backward compatibility, treat single argument as profile name
            if [ $# -eq 1 ] && [ "$1" != "help" ]; then
                configure_git "$1"
            else
                print_color "$RED" "Unknown command: $command"
                show_help
                exit 1
            fi
            ;;
    esac
}

# Run main function with all arguments
main "$@"
