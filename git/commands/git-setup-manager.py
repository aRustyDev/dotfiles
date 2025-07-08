#!/usr/bin/env python3
"""
Git Profile Manager - Flexible git configuration management

Supports multiple backends:
- SQLite database
- JSON file storage
- YAML configuration
- Direct 1Password integration (with fallback)
"""

import os
import sys
import json
import sqlite3
import subprocess
import argparse
from pathlib import Path
from typing import Dict, Optional, List, Tuple
from dataclasses import dataclass, asdict
from datetime import datetime
import platform
import shutil
import hashlib

try:
    import yaml
    HAS_YAML = True
except ImportError:
    HAS_YAML = False

try:
    import keyring
    HAS_KEYRING = True
except ImportError:
    HAS_KEYRING = False


@dataclass
class GitProfile:
    """Git profile configuration"""
    name: str
    display_name: str
    email: str
    ssh_key_path: Optional[str] = None
    ssh_public_key: str = ''
    metadata: Optional[Dict] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    def to_dict(self):
        """Convert to dictionary for serialization"""
        data = asdict(self)
        if self.created_at:
            data['created_at'] = self.created_at.isoformat()
        if self.updated_at:
            data['updated_at'] = self.updated_at.isoformat()
        return data

    @classmethod
    def from_dict(cls, data: Dict):
        """Create from dictionary"""
        if 'created_at' in data and isinstance(data['created_at'], str):
            data['created_at'] = datetime.fromisoformat(data['created_at'])
        if 'updated_at' in data and isinstance(data['updated_at'], str):
            data['updated_at'] = datetime.fromisoformat(data['updated_at'])
        return cls(**data)


class ProfileBackend:
    """Base class for profile storage backends"""

    def list_profiles(self) -> List[GitProfile]:
        raise NotImplementedError

    def get_profile(self, name: str) -> Optional[GitProfile]:
        raise NotImplementedError

    def save_profile(self, profile: GitProfile) -> None:
        raise NotImplementedError

    def delete_profile(self, name: str) -> None:
        raise NotImplementedError


class SQLiteBackend(ProfileBackend):
    """SQLite database backend"""

    def __init__(self, db_path: Path):
        self.db_path = db_path
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self._init_db()

    def _init_db(self):
        """Initialize database schema"""
        conn = sqlite3.connect(self.db_path)
        conn.execute('''
            CREATE TABLE IF NOT EXISTS profiles (
                name TEXT PRIMARY KEY,
                display_name TEXT NOT NULL,
                email TEXT NOT NULL,
                ssh_key_path TEXT,
                ssh_public_key TEXT NOT NULL,
                metadata TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        conn.commit()
        conn.close()

    def list_profiles(self) -> List[GitProfile]:
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.execute('SELECT * FROM profiles ORDER BY name')
        profiles = []
        for row in cursor:
            profiles.append(self._row_to_profile(row))
        conn.close()
        return profiles

    def get_profile(self, name: str) -> Optional[GitProfile]:
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.execute('SELECT * FROM profiles WHERE name = ?', (name,))
        row = cursor.fetchone()
        conn.close()
        return self._row_to_profile(row) if row else None

    def save_profile(self, profile: GitProfile) -> None:
        conn = sqlite3.connect(self.db_path)
        metadata_json = json.dumps(profile.metadata) if profile.metadata else None

        conn.execute('''
            INSERT OR REPLACE INTO profiles
            (name, display_name, email, ssh_key_path, ssh_public_key, metadata, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
        ''', (profile.name, profile.display_name, profile.email,
              profile.ssh_key_path, profile.ssh_public_key, metadata_json))
        conn.commit()
        conn.close()

    def delete_profile(self, name: str) -> None:
        conn = sqlite3.connect(self.db_path)
        conn.execute('DELETE FROM profiles WHERE name = ?', (name,))
        conn.commit()
        conn.close()

    def _row_to_profile(self, row) -> GitProfile:
        metadata = json.loads(row['metadata']) if row['metadata'] else None
        return GitProfile(
            name=row['name'],
            display_name=row['display_name'],
            email=row['email'],
            ssh_key_path=row['ssh_key_path'],
            ssh_public_key=row['ssh_public_key'],
            metadata=metadata,
            created_at=datetime.fromisoformat(row['created_at']) if row['created_at'] else None,
            updated_at=datetime.fromisoformat(row['updated_at']) if row['updated_at'] else None
        )


class JSONBackend(ProfileBackend):
    """JSON file backend"""

    def __init__(self, json_path: Path):
        self.json_path = json_path
        self.json_path.parent.mkdir(parents=True, exist_ok=True)
        if not self.json_path.exists():
            self._save_data({})

    def _load_data(self) -> Dict:
        with open(self.json_path, 'r') as f:
            return json.load(f)

    def _save_data(self, data: Dict):
        # Create backup before saving
        if self.json_path.exists():
            backup = self.json_path.with_suffix('.json.bak')
            shutil.copy2(self.json_path, backup)

        with open(self.json_path, 'w') as f:
            json.dump(data, f, indent=2)

    def list_profiles(self) -> List[GitProfile]:
        data = self._load_data()
        return [GitProfile.from_dict(p) for p in data.values()]

    def get_profile(self, name: str) -> Optional[GitProfile]:
        data = self._load_data()
        profile_data = data.get(name)
        return GitProfile.from_dict(profile_data) if profile_data else None

    def save_profile(self, profile: GitProfile) -> None:
        data = self._load_data()
        profile.updated_at = datetime.now()
        if profile.name not in data:
            profile.created_at = datetime.now()
        data[profile.name] = profile.to_dict()
        self._save_data(data)

    def delete_profile(self, name: str) -> None:
        data = self._load_data()
        if name in data:
            del data[name]
            self._save_data(data)


class YAMLBackend(ProfileBackend):
    """YAML file backend"""

    def __init__(self, yaml_path: Path):
        if not HAS_YAML:
            raise ImportError('PyYAML is required for YAML backend. Install with: pip install pyyaml')

        self.yaml_path = yaml_path
        self.yaml_path.parent.mkdir(parents=True, exist_ok=True)
        if not self.yaml_path.exists():
            self._save_data({})

    def _load_data(self) -> Dict:
        with open(self.yaml_path, 'r') as f:
            return yaml.safe_load(f) or {}

    def _save_data(self, data: Dict):
        # Create backup before saving
        if self.yaml_path.exists():
            backup = self.yaml_path.with_suffix('.yaml.bak')
            shutil.copy2(self.yaml_path, backup)

        with open(self.yaml_path, 'w') as f:
            yaml.dump(data, f, default_flow_style=False)

    def list_profiles(self) -> List[GitProfile]:
        data = self._load_data()
        profiles_data = data.get('profiles', {})
        return [GitProfile.from_dict(p) for p in profiles_data.values()]

    def get_profile(self, name: str) -> Optional[GitProfile]:
        data = self._load_data()
        profile_data = data.get('profiles', {}).get(name)
        return GitProfile.from_dict(profile_data) if profile_data else None

    def save_profile(self, profile: GitProfile) -> None:
        data = self._load_data()
        if 'profiles' not in data:
            data['profiles'] = {}

        profile.updated_at = datetime.now()
        if profile.name not in data['profiles']:
            profile.created_at = datetime.now()

        data['profiles'][profile.name] = profile.to_dict()
        self._save_data(data)

    def delete_profile(self, name: str) -> None:
        data = self._load_data()
        if 'profiles' in data and name in data['profiles']:
            del data['profiles'][name]
            self._save_data(data)


class OnePasswordIntegration:
    """1Password integration for importing profiles"""

    @staticmethod
    def is_available() -> bool:
        """Check if 1Password CLI is available"""
        return shutil.which('op') is not None

    @staticmethod
    def parse_agent_toml(path: Path) -> List[Dict]:
        """Parse 1Password agent.toml file"""
        configs = []

        if not path.exists():
            return configs

        # Simple TOML parser for agent.toml structure
        with open(path, 'r') as f:
            lines = f.readlines()

        current_key = {}
        in_ssh_keys = False

        for line in lines:
            line = line.strip()

            if line == '[[ssh-keys]]':
                if current_key:
                    configs.append(current_key)
                current_key = {}
                in_ssh_keys = True
            elif in_ssh_keys and '=' in line:
                key, value = line.split('=', 1)
                key = key.strip()
                value = value.strip().strip('"')

                # Skip commented out name fields
                if not line.startswith('#'):
                    current_key[key] = value

        if current_key:
            configs.append(current_key)

        return configs

    @staticmethod
    def get_ssh_key_from_op(vault: str, item: str) -> Optional[Tuple[str, str, str]]:
        """Get SSH key details from 1Password"""
        try:
            # Get item details
            result = subprocess.run(
                ['op', 'item', 'get', item, '--vault', vault, '--format=json'],
                capture_output=True, text=True, check=True
            )

            item_data = json.loads(result.stdout)

            # Extract fields
            public_key = None
            username = None
            email = None

            for field in item_data.get('fields', []):
                if field.get('label') == 'public key':
                    public_key = field.get('value')
                elif field.get('label') == 'username':
                    username = field.get('value')

            # Try to get email from item details
            if 'urls' in item_data:
                for url in item_data['urls']:
                    if '@' in url.get('href', ''):
                        email = url['href']

            return (username, email, public_key) if public_key else None

        except (subprocess.CalledProcessError, json.JSONDecodeError):
            return None


class GitSetupManager:
    """Main git setup manager"""

    def __init__(self, backend: ProfileBackend):
        self.backend = backend
        self.ssh_signing_program = self._detect_ssh_signing_program()

    def _detect_ssh_signing_program(self) -> str:
        """Detect SSH signing program based on OS"""
        system = platform.system()

        if system in ['Linux', 'Darwin']:
            return '/usr/bin/ssh-keygen'
        elif system == 'Windows':
            return 'C:/Windows/System32/OpenSSH/ssh-keygen.exe'
        else:
            return 'ssh-keygen'  # Fallback

    def _read_ssh_public_key(self, key_path: str) -> Optional[str]:
        """Read SSH public key from file"""
        pub_path = Path(key_path + '.pub')

        if pub_path.exists():
            return pub_path.read_text().strip()

        # Try to extract public key from private key
        try:
            result = subprocess.run(
                ['ssh-keygen', '-y', '-f', key_path],
                capture_output=True, text=True, check=True
            )
            return result.stdout.strip()
        except subprocess.CalledProcessError:
            return None

    def add_profile(self, name: str, display_name: str, email: str,
                   ssh_key_path: Optional[str] = None,
                   ssh_public_key: Optional[str] = None) -> None:
        """Add or update a profile"""

        # Read public key if not provided
        if not ssh_public_key and ssh_key_path:
            ssh_public_key = self._read_ssh_public_key(ssh_key_path)
            if not ssh_public_key:
                raise ValueError(f"Could not read SSH public key from {ssh_key_path}")

        profile = GitProfile(
            name=name,
            display_name=display_name,
            email=email,
            ssh_key_path=ssh_key_path,
            ssh_public_key=ssh_public_key or ''
        )

        self.backend.save_profile(profile)
        print(f"✅ Profile '{name}' saved successfully")

    def configure_git_repo(self, profile_name: str, setup_precommit: bool = True) -> None:
        """Configure git repository with profile"""
        profile = self.backend.get_profile(profile_name)

        if not profile:
            print(f"❌ Error: Profile '{profile_name}' not found")
            self.list_profiles()
            return

        print(f"🔧 Configuring git for profile: {profile_name}")
        print(f"  Name: {profile.display_name}")
        print(f"  Email: {profile.email}")

        # Set git configuration
        git_configs = [
            ('user.name', profile.display_name),
            ('user.email', profile.email),
            ('user.signingkey', profile.ssh_public_key),
            ('commit.gpgsign', 'true'),
            ('tag.gpgsign', 'true'),
            ('gpg.format', 'ssh'),
            ('gpg.ssh.program', self.ssh_signing_program),
        ]

        for key, value in git_configs:
            subprocess.run(['git', 'config', '--local', key, value], check=True)

        # Update allowed signers
        self._update_allowed_signers(profile)

        if setup_precommit:
            self._setup_precommit()

        print('✅ Git configuration updated successfully')

    def _update_allowed_signers(self, profile: GitProfile) -> None:
        """Update git allowed signers file"""
        config_home = Path(os.environ.get('XDG_CONFIG_HOME', Path.home() / '.config'))
        allowed_signers = config_home / 'git' / 'allowed_signers'
        allowed_signers.parent.mkdir(parents=True, exist_ok=True)

        # Read existing entries
        entries = {}
        if allowed_signers.exists():
            with open(allowed_signers, 'r') as f:
                for line in f:
                    if line.strip():
                        parts = line.strip().split(' ', 1)
                        if len(parts) == 2:
                            entries[parts[0]] = parts[1]

        # Update with new entry
        entries[profile.email] = profile.ssh_public_key

        # Write back
        with open(allowed_signers, 'w') as f:
            for email, key in entries.items():
                f.write(f"{email} {key}\n")

        # Set git config
        subprocess.run([
            'git', 'config', '--local',
            'gpg.ssh.allowedSignersFile', str(allowed_signers)
        ], check=True)

    def _setup_precommit(self) -> None:
        """Setup pre-commit hooks"""
        if not Path('.pre-commit-config.yaml').exists():
            print('⚠️  No .pre-commit-config.yaml found, skipping pre-commit setup')
            return

        if not shutil.which('pre-commit'):
            print('⚠️  pre-commit not found. Install with: pip install pre-commit')
            return

        print('🔧 Installing pre-commit hooks...')
        subprocess.run(['pre-commit', 'install'], check=True)
        subprocess.run(['pre-commit', 'install', '--hook-type', 'commit-msg'], check=True)
        print('✅ Pre-commit hooks installed')

    def list_profiles(self) -> None:
        """List all profiles"""
        profiles = self.backend.list_profiles()

        if not profiles:
            print('No profiles found. Add one with: git-setup add <name> <display-name> <email>')
            return

        print('\n📋 Available Git Profiles:')
        print('-' * 80)

        for profile in profiles:
            key_info = 'SSH Key' if profile.ssh_key_path else 'Embedded Key'
            print(f"  {profile.name:<15} {profile.display_name:<25} {profile.email:<30} [{key_info}]")

        print('-' * 80)

    def import_from_1password(self) -> None:
        """Import profiles from 1Password"""
        if not OnePasswordIntegration.is_available():
            print('❌ 1Password CLI (op) not found. Please install it first.')
            return

        agent_toml = Path.home() / '.config' / '1Password' / 'ssh' / 'agent.toml'
        configs = OnePasswordIntegration.parse_agent_toml(agent_toml)

        if not configs:
            print('⚠️  No SSH key configurations found in agent.toml')
            return

        print(f"📥 Found {len(configs)} SSH key configuration(s) in 1Password")

        for config in configs:
            vault = config.get('vault')
            item = config.get('item')

            if not vault or not item:
                continue

            print(f"\n🔑 Processing: {item} (vault: {vault})")

            # Try to get details from 1Password
            details = OnePasswordIntegration.get_ssh_key_from_op(vault, item)

            if details:
                username, email, public_key = details

                # Generate profile name from item name
                profile_name = item.lower().replace(' ', '-').replace('_', '-')

                print(f"  Username: {username or 'Not found'}")
                print(f"  Email: {email or 'Not found'}")

                if not username:
                    username = input('  Enter display name: ').strip()
                if not email:
                    email = input('  Enter email: ').strip()

                if username and email and public_key:
                    self.add_profile(profile_name, username, email,
                                   ssh_public_key=public_key)
                    print(f"✅ Imported as profile: {profile_name}")
            else:
                print('  ⚠️  Could not retrieve details from 1Password')
                print('  You can manually add this profile with:')
                print(f"  git-setup add {item.lower()} <display-name> <email> <ssh-key-path>")


def main():
    """Main CLI entry point"""
    parser = argparse.ArgumentParser(
        description='Git Profile Manager - Flexible git configuration management',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Add a new profile
  git-setup add github "John Doe" "john@example.com" ~/.ssh/id_github

  # Configure current repository
  git-setup use github

  # Import from 1Password
  git-setup import-1password

  # List all profiles
  git-setup list

Storage Backends:
  --backend sqlite    Use SQLite database (default)
  --backend json      Use JSON file storage
  --backend yaml      Use YAML file storage
        """
    )

    parser.add_argument('--backend', choices=['sqlite', 'json', 'yaml'],
                       default='json', help='Storage backend to use')
    parser.add_argument('--data-dir', type=Path,
                       help='Data directory (default: ~/.local/share/git-setup)')

    subparsers = parser.add_subparsers(dest='command', help='Commands')

    # Add command
    add_parser = subparsers.add_parser('add', help='Add or update a profile')
    add_parser.add_argument('name', help='Profile name (e.g., github, work)')
    add_parser.add_argument('display_name', help='Display name for commits')
    add_parser.add_argument('email', help='Email address')
    add_parser.add_argument('ssh_key_path', nargs='?', help='Path to SSH private key')

    # Use command
    use_parser = subparsers.add_parser('use', help='Configure repo with profile')
    use_parser.add_argument('profile', help='Profile name to use')
    use_parser.add_argument('--no-precommit', action='store_true',
                           help='Skip pre-commit setup')

    # List command
    subparsers.add_parser('list', help='List all profiles')

    # Delete command
    delete_parser = subparsers.add_parser('delete', help='Delete a profile')
    delete_parser.add_argument('profile', help='Profile name to delete')

    # Import command
    subparsers.add_parser('import-1password', help='Import from 1Password')

    # Show command
    show_parser = subparsers.add_parser('show', help='Show profile details')
    show_parser.add_argument('profile', help='Profile name to show')

    args = parser.parse_args()

    # Determine data directory
    if args.data_dir:
        data_dir = args.data_dir
    else:
        xdg_data = os.environ.get('XDG_DATA_HOME')
        if xdg_data:
            data_dir = Path(xdg_data) / 'git-setup'
        else:
            data_dir = Path.home() / '.local' / 'share' / 'git-setup'

    # Create backend
    if args.backend == 'sqlite':
        backend = SQLiteBackend(data_dir / 'profiles.db')
    elif args.backend == 'json':
        backend = JSONBackend(data_dir / 'profiles.json')
    elif args.backend == 'yaml':
        backend = YAMLBackend(data_dir / 'profiles.yaml')

    # Create manager
    manager = GitSetupManager(backend)

    # Execute command
    if args.command == 'add':
        manager.add_profile(args.name, args.display_name, args.email, args.ssh_key_path)
    elif args.command == 'use':
        manager.configure_git_repo(args.profile, not args.no_precommit)
    elif args.command == 'list':
        manager.list_profiles()
    elif args.command == 'delete':
        backend.delete_profile(args.profile)
        print(f"✅ Profile '{args.profile}' deleted")
    elif args.command == 'import-1password':
        manager.import_from_1password()
    elif args.command == 'show':
        profile = backend.get_profile(args.profile)
        if profile:
            print(f"\n📋 Profile: {profile.name}")
            print(f"  Display Name: {profile.display_name}")
            print(f"  Email: {profile.email}")
            print(f"  SSH Key Path: {profile.ssh_key_path or 'Not stored'}")
            print(f"  Public Key: {profile.ssh_public_key[:50]}...")
            if profile.created_at:
                print(f"  Created: {profile.created_at.strftime('%Y-%m-%d %H:%M')}")
            if profile.updated_at:
                print(f"  Updated: {profile.updated_at.strftime('%Y-%m-%d %H:%M')}")
        else:
            print(f"❌ Profile '{args.profile}' not found")
    else:
        # For backward compatibility - treat as profile name
        if len(sys.argv) == 2 and not args.command:
            manager.configure_git_repo(sys.argv[1])
        else:
            parser.print_help()


if __name__ == '__main__':
    main()
