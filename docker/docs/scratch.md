## Issues

#### 1: TLS Certificate Verification (Node.js)

- **Error**: UNABLE_TO_VERIFY_LEAF_SIGNATURE / subjectAltName does not match
- **Cause**: macOS LibreSSL/curl and Node.js don't properly match \*.localhost wildcard SANs
- **Status**: The mkcert CA IS installed in System keychain, but wildcard matching is broken
- **Workaround**: Use NODE_EXTRA_CA_CERTS or --use-system-ca flag

##### Root Causes Identified

| Issue             | Cause                                        | Fix                                           |
| ----------------- | -------------------------------------------- | --------------------------------------------- |
| TLS cert mismatch | Node.js doesn't match \*.localhost wildcards | Regenerated cert with explicit subdomain SANs |

#### 2: Traefik Routing 404 (The Main Problem)

- **Error**: field not found, node: parentRefs in Traefik logs → returns 404
- **Cause**: parentRefs (multi-layer routing) is NOT supported by the Docker label provider

##### Root Causes Identified

| Issue            | Cause                                               | Fix                         |
| ---------------- | --------------------------------------------------- | --------------------------- |
| 404 from Traefik | parentRefs requires Traefik v3.6+ (you have v3.2.5) | Used compound rules instead |

> Per Traefik documentation:
> Supported providers for parentRefs: File, KV stores, Kubernetes CRD
> NOT supported: Docker, Kubernetes Ingress, Gateway API

```yaml
labels:
  traefik.http.routers.context7.rule: >-
    (Host(`docs.localhost`) || Host(`doc.localhost`)) &&
    PathPrefix(`/mcp`) &&
    Header(`X-Service`, `context7`)
```

```bash
NODE_EXTRA_CA_CERTS=/Users/arustydev/.local/share/mkcert/rootCA.pem \
timeout 8 \
npx -y mcp-remote https://docs.localhost/mcp \
--header "X-Service: context7"
```
