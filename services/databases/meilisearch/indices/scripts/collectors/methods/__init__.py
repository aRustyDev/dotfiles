"""Collection method implementations."""

from collectors.methods.api import APICollector
from collectors.methods.scrape import ScrapeCollector
from collectors.methods.browser import BrowserCollector
from collectors.methods.readme import ReadmeCollector
from collectors.methods.search import SearchCollector

__all__ = [
    "APICollector",
    "ScrapeCollector",
    "BrowserCollector",
    "ReadmeCollector",
    "SearchCollector",
]
