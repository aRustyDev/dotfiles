#!/usr/bin/env bash
# MCP Server Management Script

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

MCP_HOME="${HOME}/.mcp"
SERVERS_DIR="${MCP_HOME}/servers"

# Function to list installed servers
list_servers() {
    echo -e "${BLUE}Installed MCP Servers:${NC}"
    echo -e "${BLUE}=====================${NC}"

    if [[ ! -d "$SERVERS_DIR" ]] || [[ -z "$(ls -A "$SERVERS_DIR" 2>/dev/null)" ]]; then
        echo "No servers installed. Run 'darwin-rebuild switch' to install configured servers."
        return
    fi

    for server_dir in "$SERVERS_DIR"/*; do
        if [[ -d "$server_dir" ]]; then
            server_name=$(basename "$server_dir")
            info_file="$server_dir/info.json"

            if [[ -f "$info_file" ]]; then
                # Parse server info
                server_type=$(jq -r '.type // "unknown"' "$info_file" 2>/dev/null || echo "unknown")
                runtime=$(jq -r '.runtime // "unknown"' "$info_file" 2>/dev/null || echo "unknown")

                echo -e "\n${GREEN}${server_name}${NC}"
                echo "  Type: $server_type"
                echo "  Runtime: $runtime"

                if [[ "$server_type" == "docker" ]]; then
                    image=$(jq -r '.image // "unknown"' "$info_file" 2>/dev/null || echo "unknown")
                    echo "  Image: $image"

                    # Check if image tar exists
                    if [[ -f "$server_dir/image.tar" ]]; then
                        size=$(du -h "$server_dir/image.tar" | cut -f1)
                        echo "  Exported: Yes (${size})"
                    else
                        echo "  Exported: No (run 'export-docker $server_name' to export)"
                    fi
                else
                    # Check binary
                    if [[ -x "$server_dir/bin/$server_name" ]]; then
                        echo "  Binary: ✓ Installed"
                    else
                        echo "  Binary: ✗ Not found"
                    fi
                fi

                # Show command
                echo "  Command: mcp-${server_name}"
            else
                echo -e "\n${YELLOW}${server_name}${NC} (no metadata)"
            fi
        fi
    done
}

# Function to show server details
show_server() {
    local server_name=$1
    local server_dir="$SERVERS_DIR/$server_name"

    if [[ ! -d "$server_dir" ]]; then
        echo -e "${RED}Server '$server_name' not found${NC}"
        return 1
    fi

    echo -e "${BLUE}Server: ${server_name}${NC}"
    echo -e "${BLUE}==================${NC}"

    # Show metadata
    if [[ -f "$server_dir/info.json" ]]; then
        echo -e "\n${GREEN}Metadata:${NC}"
        jq . "$server_dir/info.json"
    fi

    # Show directory structure
    echo -e "\n${GREEN}Installation:${NC}"
    find "$server_dir" -type f -o -type l | sort | while read -r file; do
        echo "  ${file#$server_dir/}"
    done

    # Show disk usage
    echo -e "\n${GREEN}Disk Usage:${NC}"
    du -sh "$server_dir" | cut -f1
}

# Function to export Docker images
export_docker() {
    local server_name=$1
    local export_script="$SERVERS_DIR/$server_name/export-image.sh"

    if [[ ! -f "$export_script" ]]; then
        echo -e "${RED}Server '$server_name' is not a Docker-based server${NC}"
        return 1
    fi

    echo -e "${BLUE}Exporting Docker image for ${server_name}...${NC}"
    bash "$export_script"
}

# Function to export all Docker images
export_all_docker() {
    echo -e "${BLUE}Exporting all Docker-based MCP servers...${NC}"

    for server_dir in "$SERVERS_DIR"/*; do
        if [[ -d "$server_dir" ]]; then
            server_name=$(basename "$server_dir")
            export_script="$server_dir/export-image.sh"

            if [[ -f "$export_script" ]]; then
                echo -e "\n${GREEN}Exporting ${server_name}...${NC}"
                bash "$export_script"
            fi
        fi
    done
}

# Function to clean up old exports
cleanup() {
    echo -e "${YELLOW}Cleaning up old Docker exports...${NC}"

    local total_size=0
    for tar_file in "$SERVERS_DIR"/*/image.tar; do
        if [[ -f "$tar_file" ]]; then
            size=$(stat -f%z "$tar_file" 2>/dev/null || stat -c%s "$tar_file" 2>/dev/null || echo 0)
            total_size=$((total_size + size))
            rm -v "$tar_file"
        fi
    done

    if [[ $total_size -gt 0 ]]; then
        echo -e "${GREEN}Freed $(numfmt --to=iec-i --suffix=B $total_size)${NC}"
    else
        echo "No Docker exports to clean up"
    fi
}

# Function to test a server
test_server() {
    local server_name=$1
    local test_script="${0%/*}/test-server.sh"

    if [[ -x "$test_script" ]]; then
        "$test_script" test "$server_name"
    else
        echo -e "${RED}Test script not found at $test_script${NC}"
    fi
}

# Main script
main() {
    case "${1:-}" in
        list|ls)
            list_servers
            ;;
        show|info)
            if [[ -z "${2:-}" ]]; then
                echo "Usage: $0 show <server-name>"
                exit 1
            fi
            show_server "$2"
            ;;
        export-docker)
            if [[ -z "${2:-}" ]]; then
                echo "Usage: $0 export-docker <server-name>"
                exit 1
            fi
            export_docker "$2"
            ;;
        export-all)
            export_all_docker
            ;;
        cleanup|clean)
            cleanup
            ;;
        test)
            if [[ -z "${2:-}" ]]; then
                echo "Usage: $0 test <server-name>"
                exit 1
            fi
            test_server "$2"
            ;;
        *)
            echo "MCP Server Manager"
            echo
            echo "Usage:"
            echo "  $0 list                    List installed servers"
            echo "  $0 show <server>           Show server details"
            echo "  $0 export-docker <server>  Export Docker image for server"
            echo "  $0 export-all              Export all Docker images"
            echo "  $0 cleanup                 Remove exported Docker images"
            echo "  $0 test <server>           Test a server"
            echo
            echo "Server Location: ~/.mcp/servers/"
            echo
            echo "Examples:"
            echo "  $0 list"
            echo "  $0 show github"
            echo "  $0 export-docker github"
            ;;
    esac
}

# Check for required tools
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}Warning: jq not found. Some features may not work properly.${NC}"
fi

main "$@"
