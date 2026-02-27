---
id: 34cf6809-dfdb-4704-a2a4-96b24320695d
title: Traefik ToDos
created: 2025-12-13T00:00:00
updated: 2025-12-13T16:38
project: dotfiles
scope: docker
type: plan
status: 🚧 in-progress
publish: false
tags:
  - docker
  - todo
aliases:
  - Traefik ToDos
  - Todo
related: []
---

# Traefik ToDos

## Middlewares

- OPA
  - https://plugins.traefik.io/plugins/67709f24f5aa5a721d14c9de/open-policy-agent-opa
  - https://plugins.traefik.io/plugins/6294734fffc0cd18356a97cc/opa
- WebFinger
  - https://plugins.traefik.io/plugins/67d871499fc1afd96d90203f/webfinger-plugin
- JWT
  - https://plugins.traefik.io/plugins/6735e658573cd7803d65cb1a/dynamic-jwt-validation-middleware
  - https://plugins.traefik.io/plugins/62947304108ecc83915d7782/jwt-access-policy
  - https://plugins.traefik.io/plugins/659e6aaf0f0494247310c69a/jwt-and-opa-access-management
  - https://plugins.traefik.io/plugins/628c9f11108ecc83915d7772/traefik-token-middleware
- TLS Auth / Mutual TLS
  - https://plugins.traefik.io/plugins/643d2dc75faef603aa1b66f7/client-certificate-authorization-plugin
  - https://plugins.traefik.io/plugins/63a4cc653038a467c0ee9cb1/tls-auth
  - https://plugins.traefik.io/plugins/6637c92c3f17a1aeb061e27e/mtls-or-whitelist
  - https://plugins.traefik.io/plugins/650d2d6f2b2274baa7fa2231/m-tls-header-plugin
- Cloudflare
  - https://plugins.traefik.io/plugins/6330891aa4caa9ddeffda114/cloudflare
- Vault
  - https://plugins.traefik.io/plugins/62947358ffc0cd18356a97cf/basic-auth-powered-by-vault
- Chaos:
  - https://plugins.traefik.io/plugins/628c9f22ffc0cd18356a97bc/fault-injection
- Prometheus/Thanos/Loki/etc Auth:
  - https://plugins.traefik.io/plugins/6835d38eb2caaa3ee768b0fe/prometheus-thanos-loki-authorization
- Traefik WARP
  - https://plugins.traefik.io/plugins/68d8eb8a0476823aaedfd35f/traefik-warp-real-client-ip
- Trace ID
  - https://plugins.traefik.io/plugins/62947364108ecc83915d7794/add-trace-id
- CORS
- API Key
  - https://plugins.traefik.io/plugins/66f6ac697dd5a6c3095befd3/api-key-and-token-middleware
  - https://plugins.traefik.io/plugins/644ae964a57ce22514790380/api-key-middleware
  - https://plugins.traefik.io/plugins/650d88d82b2274baa7fa2232/api-key-auth
- WAF
  - https://plugins.traefik.io/plugins/6690f7a906c725ce1201a99f/chaitin-safeline-waf
  - https://plugins.traefik.io/plugins/6299fed1114527177109b58f/snapt-nova-waf
  - https://plugins.traefik.io/plugins/65f2aea146079255c9ffd1ec/coraza-waf
- Analytics
  - Umami: https://plugins.traefik.io/plugins/65d4cc8e769af9e5f2251e09/umami-analytics
  - Umami: https://plugins.traefik.io/plugins/6710d226573cd7803d65cb15/traefik-umami-feeder
  - Matomo: https://plugins.traefik.io/plugins/677d094a86fc372d4dc11fa3/matomo-tracking
  - Tianji: https://plugins.traefik.io/plugins/685ece2c86449432ce615359/tianji-plugin
  - Rybbit: https://plugins.traefik.io/plugins/688d0ecc1181ba8b1e36eb25/traefik-rybbit-feeder
- Container Mgr:
  - https://plugins.traefik.io/plugins/628c9ee8ffc0cd18356a97af/container-manager-for-traefik
  - https://plugins.traefik.io/plugins/633b4658a4caa9ddeffda119/sablier
  - https://plugins.traefik.io/plugins/6715d1d37dd5a6c3095befd4/sablier
- ModSecurity:
  - https://plugins.traefik.io/plugins/644d9a72ebafd55c9c740848/mx-m-owasp-crs-modsecurity-plugin
  - https://plugins.traefik.io/plugins/628c9eadffc0cd18356a9799/modsecurity-plugin
- Pangolin: https://plugins.traefik.io/plugins/676da7c6eaa878daeef9c7e9/pangolin-badger
- Cache:
  - https://plugins.traefik.io/plugins/6294728cffc0cd18356a97c2/souin
- OIDC:
  - https://plugins.traefik.io/plugins/66b63d12d29fd1c421b503f5/oidc-authentication
- Rate Limit:
  - https://plugins.traefik.io/plugins/66d867f4573cd7803d65cb08/traefik-cluster-rate-limiter
  - https://plugins.traefik.io/plugins/64fa08a728398e0b89746792/jwt-field-as-header
- GraphQL:
  - https://plugins.traefik.io/plugins/64daff544a44b52408b09eab/disable-graph-ql-introspection-plugin
- Redirect:
  - https://plugins.traefik.io/plugins/65be38dc52addb37b8074614/redirect-errors
  - https://plugins.traefik.io/plugins/6569fc07ce37949adf28307f/error-pages
- Referer:
  - https://plugins.traefik.io/plugins/63eb4d9e9454451553c1c912/referer-plugin
- Proxmox:
  - https://plugins.traefik.io/plugins/67dd8d209fc1afd96d902040/traefik-proxmox-provider
