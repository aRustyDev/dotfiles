#!/usr/bin/env bash
# Test script for MCP servers

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to test a server
test_server() {
    local server_name=$1
    local server_cmd="mcp-${server_name}"

    echo -e "${YELLOW}Testing MCP server: ${server_name}${NC}"

    # Check if command exists
    if ! command -v "$server_cmd" &> /dev/null; then
        echo -e "${RED}✗ Server command not found: ${server_cmd}${NC}"
        return 1
    fi

    # Test 1: Initialize request
    echo -e "  Testing initialize..."
    local init_response=$(echo '{
        "jsonrpc": "2.0",
        "method": "initialize",
        "params": {
            "clientInfo": {
                "name": "mcp-test",
                "version": "1.0.0"
            }
        },
        "id": 1
    }' | $server_cmd stdio 2>/dev/null | head -1)

    if echo "$init_response" | grep -q '"result"'; then
        echo -e "  ${GREEN}✓ Initialize successful${NC}"
    else
        echo -e "  ${RED}✗ Initialize failed${NC}"
        echo "    Response: $init_response"
        return 1
    fi

    # Test 2: List tools (if applicable)
    echo -e "  Testing tool listing..."
    local tools_response=$(echo '{
        "jsonrpc": "2.0",
        "method": "tools/list",
        "params": {},
        "id": 2
    }' | $server_cmd stdio 2>/dev/null | grep -A1 '"id":2' | tail -1)

    if echo "$tools_response" | grep -q '"tools"'; then
        echo -e "  ${GREEN}✓ Tools listing successful${NC}"
        # Count tools
        local tool_count=$(echo "$tools_response" | grep -o '"name"' | wc -l)
        echo -e "    Found ${tool_count} tools"
    else
        echo -e "  ${YELLOW}⚠ No tools found or method not supported${NC}"
    fi

    echo -e "${GREEN}✓ Server ${server_name} is functional${NC}\n"
}

# Function to list available servers
list_servers() {
    echo -e "${YELLOW}Available MCP servers:${NC}"
    for cmd in $(compgen -c | grep '^mcp-' | sort); do
        local server_name=${cmd#mcp-}
        echo "  - $server_name"
    done
}

# Main script
main() {
    case "${1:-}" in
        list)
            list_servers
            ;;
        test)
            if [ -z "${2:-}" ]; then
                echo "Usage: $0 test <server-name>"
                exit 1
            fi
            test_server "$2"
            ;;
        test-all)
            for cmd in $(compgen -c | grep '^mcp-' | sort); do
                server_name=${cmd#mcp-}
                test_server "$server_name" || true
                echo
            done
            ;;
        *)
            echo "MCP Server Test Utility"
            echo
            echo "Usage:"
            echo "  $0 list              List available MCP servers"
            echo "  $0 test <server>     Test a specific server"
            echo "  $0 test-all          Test all available servers"
            echo
            echo "Examples:"
            echo "  $0 test github"
            echo "  $0 test-all"
            ;;
    esac
}

# Ensure we're in the right environment
if ! command -v op &> /dev/null; then
    echo -e "${YELLOW}Warning: 1Password CLI (op) not found. Servers using secrets may fail.${NC}"
    echo "Please sign in with: op signin"
    echo
fi

main "$@"
