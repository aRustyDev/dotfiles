"""
SkillsMP.com collector for Claude Code skills.

Uses browser-based collection to bypass Cloudflare WAF.
Crawls category pages since skills are organized by category.
"""

from __future__ import annotations

import re
from typing import Any

from collectors.base import RawComponent
from collectors.methods.browser import BrowserCollector
from collectors.rate_limit import RateLimitConfig


# List of category slugs to crawl
CATEGORIES = [
    "tools",
    "development",
    "business",
    "data-ai",
    "testing-security",
    "devops",
    "documentation",
    "content-media",
    "research",
    "databases",
    "lifestyle",
    "blockchain",
]


class SkillsmpCollector(BrowserCollector):
    """Browser-based collector for skillsmp.com.

    skillsmp.com uses Cloudflare WAF which blocks API requests.
    Uses crawl4ai to render category pages and extract skill data.

    Page numbering maps to categories:
    - Pages 1-N: category 0, pages 1-N
    - When category exhausted, next category starts at page 1

    To simplify, we just crawl page 1 of each category (most skills visible).
    """

    registry_name = "skillsmp.com"
    supported_kinds = {"skill"}

    base_url = "https://skillsmp.com"

    rate_limit = RateLimitConfig(delay=2.0)

    def build_url(self, page: int) -> str:
        """Build URL for a category page.

        Maps page numbers to categories:
        page 1 = tools page 1
        page 2 = development page 1
        page 3 = business page 1
        ... etc.
        """
        if page > len(CATEGORIES):
            return ""  # Signal end of pagination

        category = CATEGORIES[page - 1]
        return f"{self.base_url}/categories/{category}"

    def extract_components(self, markdown: str) -> list[RawComponent]:
        """Extract skill data from rendered markdown."""
        components = []
        seen = set()

        # Pattern for skill links on skillsmp.com
        # The text may contain nested markdown (images), so use DOTALL
        # Format: [ skill-name.md 280.0k ![author](...) from "owner/repo" Description date ](url)
        skill_pattern = re.compile(
            r'\[\s*(.*?)\s*\]\((https://skillsmp\.com/skills/([a-z0-9_-]+))\)',
            re.IGNORECASE | re.DOTALL,
        )

        for match in skill_pattern.finditer(markdown):
            text = match.group(1).strip()
            url = match.group(2)
            slug = match.group(3)

            # Skip if seen
            if slug in seen:
                continue
            seen.add(slug)

            # Skip navigation/UI links that got captured due to greedy matching
            if any(skip in text.lower() for skip in [
                "skip to main", "ready ~/", "main-content", "categories",
                "run any skill", "manus.im", "$cd", "$sign", "categories"
            ]):
                continue

            # Clean up text - remove nested markdown images
            clean_text = re.sub(r'!\[[^\]]*\]\([^)]+\)', '', text)
            clean_text = clean_text.strip()

            # Extract author from "from" pattern
            from_match = re.search(r'from "([^/]+)/([^"]+)"', text)
            if from_match:
                author = from_match.group(1)
            else:
                # Try to extract from slug (first segment)
                parts = slug.split("-")
                author = parts[0] if parts else None

            # Extract skill name (usually the .md filename at start)
            name_match = re.match(r'([a-z0-9_-]+\.md)', clean_text, re.IGNORECASE)
            if name_match:
                name = name_match.group(1).replace(".md", "").replace("-", " ").replace("_", " ").title()
            else:
                # Fall back to slug parsing - get second-to-last segment
                parts = slug.split("-")
                # Look for skill name segment (before skill-md)
                if len(parts) >= 2:
                    name = parts[-2] if parts[-1] == "md" else parts[-1]
                else:
                    name = slug
                name = name.replace("-", " ").replace("_", " ").title()

            # Extract description (text after "from owner/repo")
            desc_match = re.search(r'from "[^"]+"\s+(.+?)(?:\s+\d{4}-\d{2}-\d{2})?$', clean_text)
            if desc_match:
                description = desc_match.group(1).strip()
            else:
                # Try description after first pattern
                desc_match2 = re.search(r'\.md\s+[\d.]+k?\s+from\s+"[^"]+"\s+(.+?)(?:\s+\d{4}-\d{2})?$', clean_text, re.IGNORECASE)
                description = desc_match2.group(1).strip() if desc_match2 else None

            components.append({
                "name": name,
                "description": description,
                "url": url,
                "author": author,
                "slug": slug,
            })

        return components

    def infer_kind(self, raw: RawComponent) -> str:
        """SkillsMP only has skills."""
        return "skill"
