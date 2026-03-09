# Missing Collector Features

## Current State

The collector framework handles basic collection but lacks verification and coverage tracking.

## Required Features

### 1. GitHub Repo Link Detection (per component)

**Status**: Partial - only extracts if raw data has explicit github fields

**Required**:
- Detect GitHub URLs from any field (canonical_url, description, etc.)
- Normalize GitHub URLs to `https://github.com/owner/repo` format
- Extract owner/repo from various URL formats

```python
# base.py addition
def _extract_github_url(self, raw: RawComponent) -> str | None:
    """Extract and normalize GitHub URL from any field."""
    # Check all potential URL fields
    for field in ["github_url", "githubUrl", "html_url", "url", "canonical_url", "repository"]:
        url = raw.get(field, "")
        if "github.com" in str(url):
            return self._normalize_github_url(url)

    # Also scan description for GitHub links
    desc = raw.get("description", "") or ""
    match = re.search(r'https://github\.com/([^/\s]+/[^/\s]+)', desc)
    if match:
        return match.group(0)

    return None

def _normalize_github_url(self, url: str) -> str:
    """Normalize GitHub URL to https://github.com/owner/repo format."""
    match = re.match(r'https?://(?:www\.)?github\.com/([^/]+)/([^/\s?#]+)', url)
    if match:
        return f"https://github.com/{match.group(1)}/{match.group(2)}"
    return url
```

### 2. GitHub Repo Link Testing

**Status**: Missing

**Required**:
- Validate GitHub URLs exist (HEAD request, check 200/404)
- Cache results to avoid repeated checks
- Run as optional post-collection validation step

```python
# validation.py (new file)
async def validate_github_url(url: str, client: httpx.AsyncClient) -> bool:
    """Check if GitHub URL exists (HEAD request)."""
    try:
        response = await client.head(url, follow_redirects=True)
        return response.status_code == 200
    except httpx.HTTPError:
        return False

async def validate_components(components: list[dict], output_file: Path) -> ValidationReport:
    """Validate all components' GitHub URLs."""
    async with httpx.AsyncClient() as client:
        for comp in components:
            if comp.get("github_url"):
                comp["github_url_valid"] = await validate_github_url(comp["github_url"], client)
```

### 3. Registry Component Claims

**Status**: Missing

**Required**:
- Track what each registry claims to have (from their API/UI)
- Store in `registry_claims.json`
- Update claims during collection

```json
// registry_claims.json
{
  "smithery.ai": {
    "claimed_total": 3822,
    "claimed_by_kind": {
      "mcp_server": 3500,
      "skill": 322
    },
    "last_updated": "2026-03-09T18:00:00Z",
    "source": "homepage_stats"
  },
  "mcp.so": {
    "claimed_total": 14700,
    "claimed_by_kind": {
      "mcp_server": 14700
    },
    "pages": 294,
    "per_page": 50,
    "last_updated": "2026-03-09T18:00:00Z"
  }
}
```

### 4. Registry Component Count Verification

**Status**: Missing

**Required**:
- Compare collected count vs claimed count
- Alert on significant discrepancies
- Track historical coverage trends

```python
# coverage.py (new file)
@dataclass
class CoverageReport:
    registry: str
    claimed_total: int
    collected_total: int
    coverage_pct: float
    by_kind: dict[str, KindCoverage]
    discrepancy_alert: bool  # True if collected < 90% of claimed

def verify_coverage(registry: str, collected: int, claims: dict) -> CoverageReport:
    """Compare collected count against registry claims."""
    claimed = claims.get(registry, {}).get("claimed_total", 0)
    coverage = (collected / claimed * 100) if claimed > 0 else 0
    return CoverageReport(
        registry=registry,
        claimed_total=claimed,
        collected_total=collected,
        coverage_pct=coverage,
        discrepancy_alert=coverage < 90,
    )
```

### 5. Component Type Detection/Verification

**Status**: Partial - `infer_kind()` exists but not verified

**Required**:
- Compare inferred kind vs registry-declared kind
- Log mismatches for review
- Allow registry-specific kind overrides

```python
# In each registry collector
def extract_components(self, raw: Any) -> list[RawComponent]:
    components = []
    for item in raw:
        comp = {
            "name": item.get("name"),
            # ... other fields
            "registry_declared_kind": item.get("type") or item.get("category"),  # NEW
        }
        components.append(comp)
    return components

def transform(self, raw: RawComponent, kind: str | None = None) -> dict:
    component = super().transform(raw, kind)

    # Verify kind matches registry declaration
    declared = raw.get("registry_declared_kind")
    inferred = component["type"]
    if declared and declared != inferred:
        logger.warning(f"Kind mismatch: registry={declared}, inferred={inferred}")
        component["kind_mismatch"] = True
        component["registry_declared_kind"] = declared

    return component
```

### 6. Per-Component Collection Strategy

**Status**: Implemented via `--kinds` filtering

**Works correctly**:
```bash
just collect mcp_server smithery.ai  # Only mcp_servers from smithery
just collect skill                    # Only skills from all registries
```

### 7. Per Registry+Component Coverage

**Status**: Missing

**Required**:
- Baseline file with expected counts per registry+kind
- Comparison report after each collection
- Track coverage trends over time

```json
// coverage_baseline.json
{
  "baselines": {
    "smithery.ai": {
      "mcp_server": {"expected": 3500, "tolerance": 0.05},
      "skill": {"expected": 322, "tolerance": 0.10}
    },
    "github": {
      "mcp_server": {"expected": 500, "tolerance": 0.20},
      "skill": {"expected": 100, "tolerance": 0.20}
    }
  },
  "last_full_collection": "2026-03-09T18:00:00Z"
}
```

```python
# coverage.py
def compare_to_baseline(
    results: dict[str, CollectResult],
    baseline_file: Path,
) -> CoverageComparison:
    """Compare collection results to baseline expectations."""
    baseline = json.loads(baseline_file.read_text())

    comparisons = []
    for registry, result in results.items():
        expected = baseline["baselines"].get(registry, {})
        for kind, counts in expected.items():
            actual = sum(1 for c in result.components if c["type"] == kind)
            tolerance = counts.get("tolerance", 0.10)
            expected_count = counts["expected"]

            comparison = {
                "registry": registry,
                "kind": kind,
                "expected": expected_count,
                "actual": actual,
                "coverage_pct": actual / expected_count * 100,
                "within_tolerance": abs(actual - expected_count) / expected_count <= tolerance,
            }
            comparisons.append(comparison)

    return comparisons
```

### 8. Detect New Strategy

**Status**: Partial - deduplication exists but no "new since X" tracking

**Required**:
- Track collection timestamps per component
- Compare against previous collection to identify new
- Generate "new components" report

```python
# detection.py (new file)
def detect_new_components(
    current_file: Path,
    previous_file: Path,
) -> list[dict]:
    """Detect components in current that weren't in previous."""
    previous_ids = set()
    if previous_file.exists():
        with open(previous_file) as f:
            for line in f:
                comp = json.loads(line)
                previous_ids.add(comp["id"])

    new_components = []
    with open(current_file) as f:
        for line in f:
            comp = json.loads(line)
            if comp["id"] not in previous_ids:
                comp["first_seen"] = datetime.now(UTC).isoformat()
                new_components.append(comp)

    return new_components

def generate_new_report(
    registry: str,
    new_components: list[dict],
    output_dir: Path,
) -> Path:
    """Generate report of newly discovered components."""
    report_file = output_dir / f"{registry}-new-{date.today().isoformat()}.ndjson"
    with open(report_file, "w") as f:
        for comp in new_components:
            f.write(json.dumps(comp) + "\n")
    return report_file
```

## Implementation Priority

1. **High**: GitHub link detection + normalization (affects data quality)
2. **High**: Registry claims tracking (needed for coverage)
3. **Medium**: Coverage comparison (needed for monitoring)
4. **Medium**: Detect new strategy (needed for incremental updates)
5. **Low**: GitHub link testing (expensive, can be batch job)
6. **Low**: Kind verification (edge case handling)

## CLI Additions Needed

```bash
# Validate GitHub URLs
just collect-validate --github-urls

# Show coverage report
just coverage-report

# Detect new components since last run
just detect-new

# Update registry claims from source
just update-claims
```

## Files to Create

- `collectors/validation.py` - URL validation
- `collectors/coverage.py` - Coverage tracking and comparison
- `collectors/detection.py` - New component detection
- `collectors/registry_claims.json` - Registry stated totals
- `collectors/coverage_baseline.json` - Expected counts per registry+kind
