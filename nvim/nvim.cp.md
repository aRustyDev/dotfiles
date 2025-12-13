---
id: 3c4d5e6f-7a8b-9c0d-1e2f-3a4b5c6d7e8f
title: NeoVim Search Options
created: 2025-12-13T00:00:00
updated: 2025-12-13T17:04
project: dotfiles
scope:
  - editor
  - neovim
type: reference
status: 📝 draft
publish: false
tags:
  - neovim
  - search
  - mkdocs
aliases:
  - nvim-search
related: []
---

# NeoVim Todos

## Option 1: Use the existing static Lunr index directly (no extra infra)

What exists after mkdocs build:

- search/search_index.json (the Lunr index data)
- search/config.json (field metadata)

You can fetch that JSON and run Lunr queries in your own process.

Pros:

- Zero extra infrastructure.
- Always in sync with the deployed site (assuming you fetch the current file).

Cons:

- The index format is optimized for client usage; rehydrating and querying server-side still requires a Lunr-compatible library.
- No ranking customization beyond what Lunr index encodes.
- Large sites produce a large JSON payload (clients already download it—duplicating server queries may not be better).

Minimal Python example (server-side “API” wrapper):

```python
import json
import requests
from lunr import lunr  # pip install lunr

SEARCH_INDEX_URL = "https://your-docs.example.com/search/search_index.json"

# Cache the index once (refresh periodically as needed)
def load_index():
    r = requests.get(SEARCH_INDEX_URL, timeout=10)
    r.raise_for_status()
    payload = r.json()
    # payload usually has {"config": {...}, "docs": [...], "index": {...}} OR (older) "docs" only.
    # mkdocs search plugin structures changed slightly across versions/material theme.
    docs = payload.get("docs") or []
    # Build a new Lunr index from docs (fields: "location","title","text")
    # If you want to use the prebuilt index object, you'd have to port the serialized structure;
    # simpler: rebuild.
    return lunr(ref="location", fields=("title", "text"), documents=docs)

INDEX = load_index()

def query(q: str, limit=10):
    results = INDEX.search(q)
    # results entries: {'score': ..., 'ref': 'path#fragment'}
    # Map back to docs
    return [
        {
            "score": r["score"],
            "location": r["ref"],
        } for r in results[:limit]
    ]

if __name__ == "__main__":
    for res in query("certificate signer secret", limit=5):
        print(res)
```

Wrap that in a tiny FastAPI/Flask service if you want a formal HTTP API:

- GET /search?q=...
- Return JSON list.

Caveat: Rebuilding the Lunr index (as above) may produce different scoring than the shipped prebuilt index (material theme builds with pipeline stemming, stop words). If you want identical results, you would need to deserialize the prebuilt index (more code).

## Option 2: Add a dedicated search backend (Meilisearch / Typesense)

Workflow:

1. Build docs (mkdocs build).
2. Extract structured records (one per page or heading).
3. Push records into the search engine index.
4. Provide an API (the engine already exposes one).
5. Frontend: either replace built-in search or build a custom search UI.

Pros:

- Relevance tuning, filters, facets, synonyms.
- Incremental updates (only push changed docs).
- Real server-side query API.

Cons:

- Extra infrastructure + ops.
- Need ingestion script + CI automation.

Example ingestion script for Meilisearch (run in CI after mkdocs build):

```python
import os, json, pathlib, hashlib, requests, re

MEILI_HOST = os.environ["MEILI_HOST"]          # e.g. https://search.internal
MEILI_KEY  = os.environ["MEILI_API_KEY"]
INDEX_NAME = "docs_internal"

SITE_DIR   = "site"  # mkdocs output directory

def collect_pages():
    pages = []
    for html_path in pathlib.Path(SITE_DIR).rglob("*.html"):
        rel = html_path.relative_to(SITE_DIR).as_posix()
        text = html_path.read_text(encoding="utf-8", errors="ignore")
        # naive extraction of title + stripped text (better: use BeautifulSoup)
        title_match = re.search(r"<title>(.*?)</title>", text, re.I|re.S)
        title = title_match.group(1).strip() if title_match else rel
        # crude text extraction; replace with bs4 for quality
        stripped = re.sub(r"<script.*?</script>|<style.*?</style>", "", text, flags=re.S|re.I)
        stripped = re.sub(r"<[^>]+>", " ", stripped)
        stripped = re.sub(r"\s+", " ", stripped).strip()
        doc_id = hashlib.sha1(rel.encode()).hexdigest()
        pages.append({
            "id": doc_id,
            "path": "/" + rel,
            "title": title,
            "content": stripped[:50000]  # cap if huge
        })
    return pages

def push_to_meili(docs):
    # Create index if missing
    r = requests.get(f"{MEILI_HOST}/indexes/{INDEX_NAME}", headers={"Authorization": f"Bearer {MEILI_KEY}"})
    if r.status_code == 404:
        requests.post(f"{MEILI_HOST}/indexes",
                      json={"uid": INDEX_NAME, "primaryKey": "id"},
                      headers={"Authorization": f"Bearer {MEILI_KEY}"})
    # Batch add
    r = requests.post(f"{MEILI_HOST}/indexes/{INDEX_NAME}/documents",
                      json=docs,
                      headers={"Authorization": f"Bearer {MEILI_KEY}", "Content-Type": "application/json"})
    r.raise_for_status()
    print("Update enqueued:", r.json())

if __name__ == "__main__":
    docs = collect_pages()
    push_to_meili(docs)

```

CI job example steps:

- pip install -r requirements (include beautifulsoup4, requests, meilisearch client)
- mkdocs build
- python meili_ingest.py

Then query:
GET https://search.internal/indexes/docs_internal/search
Body:
{"q": "signer password", "limit": 10}

## Option 4: Typesense (similar to Meilisearch)

Nearly identical ingestion approach to Meilisearch. Differences:

- Schema required up front (define fields types).
- Good for fuzzy search and natural language queries.

---

## Option 5: Custom minimal API proxy around existing index

If you only need “search over what the static site already indexes” but with an HTTP endpoint, simplest architecture:

1. Cron / build step fetches search/search_index.json (and optional docs) and stores locally.
2. A small service loads that JSON → Lunr → answers queries.
3. Clients call /search?q=…; service returns matches (location + snippet).

Pros:

- No large engine.
  Cons:
- Limited relevancy tuning & no incremental indexing improvements.
