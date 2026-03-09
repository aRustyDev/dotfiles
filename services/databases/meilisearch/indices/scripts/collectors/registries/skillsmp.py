"""
SkillsMP.com collector for Claude Code skills.

Uses API-based collection with bearer token authentication.
"""

from __future__ import annotations

from typing import Any

from collectors.auth import AuthConfig, AuthSource, AuthType
from collectors.base import RawComponent
from collectors.methods.api import APICollector
from collectors.rate_limit import RateLimitConfig


class SkillsmpCollector(APICollector):
    """API-based collector for skillsmp.com.

    skillsmp.com provides a REST API for searching skills.
    Requires bearer token authentication via 1Password.
    """

    registry_name = "skillsmp.com"
    supported_kinds = {"skill"}

    base_url = "https://skillsmp.com/api/v1"

    auth_config = AuthConfig(
        type=AuthType.BEARER,
        source=AuthSource.ONEPASSWORD,
        path="op://Developer/skillsmp/credential",
    )

    rate_limit = RateLimitConfig(delay=2.0, daily_limit=500)

    # API pagination
    results_per_page = 100

    def build_url(self, page: int) -> str:
        """Build API URL for skill search."""
        return f"{self.base_url}/skills/search?q=*&limit={self.results_per_page}&page={page}"

    def extract_components(self, data: dict) -> list[RawComponent]:
        """Extract skills from API response.

        Response format:
        {
            "data": {
                "skills": [
                    {
                        "name": "...",
                        "description": "...",
                        "skillUrl": "...",
                        "author": "...",
                        "keywords": [...],
                        ...
                    }
                ]
            }
        }
        """
        skills = data.get("data", {}).get("skills", [])

        components = []
        for skill in skills:
            components.append({
                "name": skill.get("name"),
                "description": skill.get("description"),
                "url": skill.get("skillUrl"),
                "author": skill.get("author"),
                "keywords": skill.get("keywords", []),
                "stars": skill.get("stars", 0),
                "githubUrl": skill.get("githubUrl"),
            })

        return components

    def infer_kind(self, raw: RawComponent) -> str:
        """SkillsMP only has skills."""
        return "skill"

    def transform(self, raw: RawComponent, kind: str | None = None) -> dict:
        """Transform with skillsmp-specific handling."""
        component = super().transform(raw, kind)

        # Use keywords as tags
        if "keywords" in raw:
            component["tags"] = raw["keywords"]

        return component
