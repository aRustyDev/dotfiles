#!/usr/bin/env bash
# =============================================================================
# Add Logging Configuration to MCP Server YAML Files
# =============================================================================
# This script adds logging configuration to MCP server docker-compose files
# that don't already have logging configured.
#
# Usage:
#   ./scripts/add-mcp-logging.sh [--dry-run]
#
# The script adds the following after the last label in each service:
#   logging:
#     driver: "${O11Y_LOGGING_DRIVER:-json-file}"
#     options:
#       max-size: "${O11Y_LOG_MAX_SIZE:-10m}"
#       max-file: "${O11Y_LOG_MAX_FILES:-3}"
#       tag: "{{.Name}}"
# =============================================================================

set -euo pipefail

DRY_RUN="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="${SCRIPT_DIR}/../modules/mcp"

# YAML snippet to add (indented for service context)
read -r -d '' LOGGING_BLOCK << 'EOF' || true
    logging:
      driver: "${O11Y_LOGGING_DRIVER:-json-file}"
      options:
        max-size: "${O11Y_LOG_MAX_SIZE:-10m}"
        max-file: "${O11Y_LOG_MAX_FILES:-3}"
        tag: "{{.Name}}"
EOF

# Find all YAML files in MCP modules
find_mcp_files() {
    find "${MODULES_DIR}" -name "*.yaml" -type f | grep -v TODO.yaml | sort
}

# Check if file already has logging configured
has_logging() {
    local file="$1"
    grep -q "^    logging:" "$file" 2>/dev/null
}

# Get service name from file
get_service_name() {
    local file="$1"
    local basename
    basename=$(basename "$file" .yaml)
    echo "mcp-${basename}"
}

# Add observability labels if not present
add_o11y_labels() {
    local file="$1"
    local service_name="$2"

    if ! grep -q "o11y.service:" "$file" 2>/dev/null; then
        # Find the line with traefik.docker.network and add labels after it
        if grep -q "traefik.docker.network:" "$file"; then
            sed -i.bak "/traefik.docker.network:.*$/a\\
      # Observability labels\\
      o11y.service: \"${service_name}\"\\
      o11y.component: \"mcp\"" "$file"
            rm -f "${file}.bak"
        fi
    fi
}

# Add logging block to file
add_logging() {
    local file="$1"

    # Find the position to insert (after labels section, before deploy or healthcheck)
    # This is tricky in shell, so we'll append at the end of the service
    if grep -q "^    deploy:" "$file"; then
        # Insert before deploy section
        sed -i.bak "/^    deploy:/i\\
${LOGGING_BLOCK}" "$file"
        rm -f "${file}.bak"
    elif grep -q "^    healthcheck:" "$file"; then
        # Insert before healthcheck section
        sed -i.bak "/^    healthcheck:/i\\
${LOGGING_BLOCK}" "$file"
        rm -f "${file}.bak"
    else
        # Append to end of service (before any blank lines at end)
        echo "${LOGGING_BLOCK}" >> "$file"
    fi
}

# Main
main() {
    local count=0
    local skipped=0

    echo "=== MCP Logging Configuration Script ==="
    echo "Scanning: ${MODULES_DIR}"
    echo ""

    while IFS= read -r file; do
        local service_name
        service_name=$(get_service_name "$file")

        if has_logging "$file"; then
            echo "[SKIP] ${file} - already has logging"
            ((skipped++))
            continue
        fi

        if [[ "${DRY_RUN}" == "--dry-run" ]]; then
            echo "[DRY-RUN] Would update: ${file}"
        else
            echo "[UPDATE] ${file}"
            add_o11y_labels "$file" "$service_name"
            add_logging "$file"
        fi
        ((count++))

    done < <(find_mcp_files)

    echo ""
    echo "=== Summary ==="
    echo "Files to update: ${count}"
    echo "Files skipped: ${skipped}"

    if [[ "${DRY_RUN}" == "--dry-run" ]]; then
        echo ""
        echo "Run without --dry-run to apply changes"
    fi
}

main "$@"
