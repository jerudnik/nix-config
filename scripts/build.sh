#!/usr/bin/env bash

# Build script for nix-config
# Usage: ./scripts/build.sh [switch|build|check]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"

# Default action
ACTION="${1:-build}"

echo -e "${GREEN}=== nix-config build script ===${NC}"
echo "Configuration directory: $CONFIG_DIR"
echo "Action: $ACTION"
echo

case "$ACTION" in
    "switch")
        echo -e "${YELLOW}Building and switching to new configuration...${NC}"
        sudo darwin-rebuild switch --flake "$CONFIG_DIR#parsley"
        ;;
    "build")
        echo -e "${YELLOW}Building configuration (no switch)...${NC}"
        darwin-rebuild build --flake "$CONFIG_DIR#parsley"
        ;;
    "check")
        echo -e "${YELLOW}Checking flake...${NC}"
        cd "$CONFIG_DIR"
        nix flake check
        ;;
    "update")
        echo -e "${YELLOW}Updating flake inputs...${NC}"
        cd "$CONFIG_DIR"
        nix flake update
        ;;
    "clean")
        echo -e "${YELLOW}Cleaning up old generations...${NC}"
        nix-collect-garbage -d
        sudo nix-collect-garbage -d
        ;;
    *)
        echo -e "${RED}Unknown action: $ACTION${NC}"
        echo "Usage: $0 [switch|build|check|update|clean]"
        exit 1
        ;;
esac

echo -e "${GREEN}Done!${NC}"