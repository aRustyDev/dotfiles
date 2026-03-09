"""
Rate limiting utilities for registry crawling.

Provides per-registry rate limiting with daily limits and adaptive delays.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass, field
from datetime import date
from typing import Any

logger = logging.getLogger(__name__)


@dataclass
class RateLimitConfig:
    """Configuration for rate limiting a registry."""

    delay: float = 1.0  # Seconds between requests
    daily_limit: int | None = None  # Max requests per day, None = unlimited
    batch_delay: float | None = None  # Extra delay between batches


@dataclass
class RateLimiter:
    """Track request counts and enforce rate limits."""

    registry: str
    config: RateLimitConfig
    requests_today: int = 0
    reset_date: date = field(default_factory=date.today)

    def can_request(self) -> bool:
        """Check if we can make another request today."""
        if self.config.daily_limit is None:
            return True

        # Reset counter on new day
        if date.today() > self.reset_date:
            self.requests_today = 0
            self.reset_date = date.today()

        return self.requests_today < self.config.daily_limit

    def record_request(self) -> None:
        """Record that a request was made."""
        self.requests_today += 1

        if self.config.daily_limit and self.requests_today >= self.config.daily_limit:
            logger.warning(
                f"{self.registry}: Daily limit reached ({self.config.daily_limit})"
            )
            logger.info("Resume tomorrow with: --registry %s --resume", self.registry)

    @property
    def delay(self) -> float:
        """Get the delay to use between requests."""
        return self.config.delay

    @property
    def batch_delay(self) -> float:
        """Get the delay to use between batches."""
        return self.config.batch_delay or self.config.delay * 2

    def remaining_today(self) -> int | None:
        """Get remaining requests for today, or None if unlimited."""
        if self.config.daily_limit is None:
            return None
        return max(0, self.config.daily_limit - self.requests_today)


class DailyRateLimiter(RateLimiter):
    """Backwards-compatible alias for RateLimiter with daily limits."""

    def __init__(self, registry: str, daily_limit: int | None = None, delay: float = 1.0):
        config = RateLimitConfig(delay=delay, daily_limit=daily_limit)
        super().__init__(registry=registry, config=config)


@dataclass
class BackoffConfig:
    """Configuration for exponential backoff on failures."""

    initial_delay: float = 2.0
    multiplier: float = 2.0
    max_delay: float = 300.0  # 5 minute ceiling
    max_retries: int = 5


# Default rate limit configurations per registry
DEFAULT_RATE_LIMITS: dict[str, RateLimitConfig] = {
    "skillsmp.com": RateLimitConfig(delay=2.0, daily_limit=500),
    "github": RateLimitConfig(delay=2.0, daily_limit=5000),
    "claudemarketplaces.com": RateLimitConfig(delay=0.5),
    "buildwithclaude.com": RateLimitConfig(delay=1.0),
    "mcp.so": RateLimitConfig(delay=3.0),
    "mcpservers.org": RateLimitConfig(delay=1.0),
    "smithery.ai": RateLimitConfig(delay=1.0, batch_delay=2.0),
}

# Default backoff configuration
DEFAULT_BACKOFF = BackoffConfig()


def get_rate_limit(registry: str) -> RateLimitConfig:
    """Get rate limit config for a registry, with sensible defaults."""
    return DEFAULT_RATE_LIMITS.get(registry, RateLimitConfig())
