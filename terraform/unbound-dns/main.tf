resource "unbound_local_zone" "mcp-localhost" {
  for_each = local.subdomains["traefik"]["mcp"]
  name     = "${each.value}.localhost."
  type     = "transparent"
}

resource "unbound_local_zone" "mcp-local" {
  for_each = local.subdomains["traefik"]["mcp"]
  name     = "${each.value}.local."
  type     = "transparent"
}

resource "unbound_local_zone" "mcp-host" {
  for_each = local.subdomains["traefik"]["mcp"]
  name     = "${each.value}.host."
  type     = "transparent"
}

resource "unbound_local_zone" "mcp-docker" {
  for_each = local.subdomains["traefik"]["mcp"]
  name     = "${each.value}.docker."
  type     = "transparent"
}

resource "unbound_local_zone" "mcp-test" {
  for_each = local.subdomains["traefik"]["mcp"]
  name     = "${each.value}.test."
  type     = "transparent"
}
