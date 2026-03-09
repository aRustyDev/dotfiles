"""
Crawl state management with checkpoint/resume support.

Provides persistent state tracking for multi-session crawls,
enabling graceful resume after interruptions or rate limit pauses.
"""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from datetime import UTC, datetime
from pathlib import Path
from typing import Any


@dataclass
class RegistryState:
    """State for a single registry."""

    status: str = "pending"  # pending, in_progress, completed, failed
    last_page: int = 0
    total_fetched: int = 0
    estimated_total: int | None = None
    last_url: str | None = None
    topics_completed: list[str] = field(default_factory=list)
    repos_completed: list[str] = field(default_factory=list)
    metadata: dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> dict:
        return {
            "status": self.status,
            "last_page": self.last_page,
            "total_fetched": self.total_fetched,
            "estimated_total": self.estimated_total,
            "last_url": self.last_url,
            "topics_completed": self.topics_completed,
            "repos_completed": self.repos_completed,
            "metadata": self.metadata,
        }

    @classmethod
    def from_dict(cls, data: dict) -> RegistryState:
        return cls(
            status=data.get("status", "pending"),
            last_page=data.get("last_page", 0),
            total_fetched=data.get("total_fetched", 0),
            estimated_total=data.get("estimated_total"),
            last_url=data.get("last_url"),
            topics_completed=data.get("topics_completed", []),
            repos_completed=data.get("repos_completed", []),
            metadata=data.get("metadata", {}),
        )


@dataclass
class CrawlState:
    """Full crawl state with checkpoint/resume support."""

    version: str = "2.0"
    started_at: str | None = None
    last_updated: str | None = None
    registries: dict[str, RegistryState] = field(default_factory=dict)
    failures: list[dict] = field(default_factory=list)
    stats: dict[str, Any] = field(default_factory=dict)
    _state_file: Path | None = field(default=None, repr=False)

    @classmethod
    def load(cls, path: Path) -> CrawlState:
        """Load state from file or create new."""
        if path.exists():
            data = json.loads(path.read_text())
            state = cls()
            state.version = data.get("version", "2.0")
            state.started_at = data.get("started_at")
            state.last_updated = data.get("last_updated")
            state.failures = data.get("failures", [])
            state.stats = data.get("stats", {})
            state._state_file = path

            # Load registry states
            for name, reg_data in data.get("registries", {}).items():
                state.registries[name] = RegistryState.from_dict(reg_data)

            # Migrate from old tier-based format
            for tier_data in data.get("tiers", {}).values():
                for name, reg_data in tier_data.get("registries", {}).items():
                    if name not in state.registries:
                        state.registries[name] = RegistryState.from_dict(reg_data)

            return state

        return cls(
            started_at=datetime.now(UTC).isoformat(),
            _state_file=path,
        )

    def save(self, path: Path | None = None) -> None:
        """Save state to file."""
        save_path = path or self._state_file
        if not save_path:
            raise ValueError("No state file path specified")

        self.last_updated = datetime.now(UTC).isoformat()

        data = {
            "version": self.version,
            "started_at": self.started_at,
            "last_updated": self.last_updated,
            "registries": {
                name: reg.to_dict() for name, reg in self.registries.items()
            },
            "failures": self.failures,
            "stats": self.stats,
        }

        save_path.write_text(json.dumps(data, indent=2))

    def get_registry_state(self, registry: str) -> RegistryState:
        """Get or create registry state."""
        if registry not in self.registries:
            self.registries[registry] = RegistryState()
        return self.registries[registry]

    def log_failure(self, url: str, error: str, registry: str | None = None) -> None:
        """Log a crawl failure."""
        self.failures.append({
            "url": url,
            "error": error,
            "registry": registry,
            "timestamp": datetime.now(UTC).isoformat(),
            "will_retry": True,
        })
        self.save()

    def mark_completed(self, registry: str, total: int) -> None:
        """Mark a registry as completed."""
        reg_state = self.get_registry_state(registry)
        reg_state.status = "completed"
        reg_state.total_fetched = total
        self.save()

    def mark_failed(self, registry: str, error: str) -> None:
        """Mark a registry as failed."""
        reg_state = self.get_registry_state(registry)
        reg_state.status = "failed"
        reg_state.metadata["last_error"] = error
        self.save()

    def is_completed(self, registry: str) -> bool:
        """Check if a registry crawl is completed."""
        return self.registries.get(registry, RegistryState()).status == "completed"

    def get_resume_page(self, registry: str) -> int:
        """Get the page to resume from for a registry."""
        return self.registries.get(registry, RegistryState()).last_page + 1

    def update_progress(
        self,
        registry: str,
        page: int,
        fetched: int,
        url: str | None = None,
    ) -> None:
        """Update crawl progress for a registry."""
        reg_state = self.get_registry_state(registry)
        reg_state.status = "in_progress"
        reg_state.last_page = page
        reg_state.total_fetched = fetched
        if url:
            reg_state.last_url = url
        self.save()
