"""
Credential resolution from various sources.

Supports:
- 1Password CLI (op)
- Environment variables
- macOS Keychain
- Direct config values
"""

from __future__ import annotations

import logging
import os
import subprocess
from dataclasses import dataclass
from enum import Enum

logger = logging.getLogger(__name__)


class AuthType(str, Enum):
    """Authentication type for APIs."""

    NONE = "none"
    BEARER = "bearer"
    TOKEN = "token"
    BASIC = "basic"
    OAUTH = "oauth"


class AuthSource(str, Enum):
    """Source for credentials."""

    ENV = "env"
    ONEPASSWORD = "1password"
    CONFIG = "config"
    KEYCHAIN = "keychain"


@dataclass
class AuthConfig:
    """Authentication configuration."""

    type: AuthType = AuthType.NONE
    source: AuthSource | None = None
    path: str | None = None  # 1Password path
    var: str | None = None  # Env var name
    value: str | None = None  # Direct value (config only)


class CredentialResolver:
    """Resolve credentials from various sources."""

    @staticmethod
    def resolve(auth: AuthConfig) -> str | None:
        """Resolve credential based on auth config.

        Args:
            auth: Authentication configuration

        Returns:
            Resolved credential string, or None if unavailable
        """
        if auth.type == AuthType.NONE:
            return None

        match auth.source:
            case AuthSource.ONEPASSWORD:
                return CredentialResolver._from_1password(auth.path)
            case AuthSource.ENV:
                return CredentialResolver._from_env(auth.var)
            case AuthSource.CONFIG:
                return auth.value
            case AuthSource.KEYCHAIN:
                return CredentialResolver._from_keychain(auth.path)
            case _:
                logger.warning(f"Unknown auth source: {auth.source}")
                return None

    @staticmethod
    def _from_1password(path: str | None) -> str | None:
        """Resolve credential from 1Password.

        Args:
            path: 1Password item path (e.g., "op://Developer/skillsmp/credential")

        Returns:
            Credential value or None
        """
        if not path:
            logger.warning("1Password path not specified")
            return None

        try:
            result = subprocess.run(
                ["op", "read", path],
                capture_output=True,
                text=True,
                check=True,
            )
            return result.stdout.strip()
        except subprocess.CalledProcessError as e:
            logger.error(f"1Password read failed: {e.stderr}")
            return None
        except FileNotFoundError:
            logger.error("1Password CLI (op) not found. Install with: brew install 1password-cli")
            return None

    @staticmethod
    def _from_env(var: str | None) -> str | None:
        """Resolve credential from environment variable.

        Args:
            var: Environment variable name

        Returns:
            Credential value or None
        """
        if not var:
            logger.warning("Environment variable name not specified")
            return None

        value = os.environ.get(var)
        if not value:
            logger.warning(f"Environment variable {var} not set")
        return value

    @staticmethod
    def _from_keychain(service: str | None) -> str | None:
        """Resolve credential from macOS Keychain.

        Args:
            service: Keychain service name

        Returns:
            Credential value or None
        """
        if not service:
            logger.warning("Keychain service name not specified")
            return None

        try:
            result = subprocess.run(
                ["security", "find-generic-password", "-s", service, "-w"],
                capture_output=True,
                text=True,
                check=True,
            )
            return result.stdout.strip()
        except subprocess.CalledProcessError:
            logger.error(f"Keychain item not found: {service}")
            return None
        except FileNotFoundError:
            logger.error("security command not found (not on macOS?)")
            return None


def build_auth_headers(auth: AuthConfig, credential: str | None) -> dict[str, str]:
    """Build HTTP headers for authentication.

    Args:
        auth: Authentication configuration
        credential: Resolved credential value

    Returns:
        Dictionary of HTTP headers
    """
    headers = {}

    if not credential or auth.type == AuthType.NONE:
        return headers

    match auth.type:
        case AuthType.BEARER:
            headers["Authorization"] = f"Bearer {credential}"
        case AuthType.TOKEN:
            headers["X-API-Key"] = credential
        case AuthType.BASIC:
            import base64
            encoded = base64.b64encode(credential.encode()).decode()
            headers["Authorization"] = f"Basic {encoded}"
        case AuthType.OAUTH:
            headers["Authorization"] = f"Bearer {credential}"

    return headers
