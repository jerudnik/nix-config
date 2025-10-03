#!/usr/bin/env bash

# Comprehensive Nix cleanup script for post-migration cleanup
# This script safely removes old generations and unused packages

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}=== Nix System Cleanup Script ===${NC}"
echo "This script will clean up old generations and unused packages"
echo "Configuration directory: $CONFIG_DIR"
echo

# Function to show current state
show_current_state() {
    echo -e "${YELLOW}=== Current System State ===${NC}"
    
    echo "System generations:"
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -5
    
    echo
    echo "Nix store size:"
    du -sh /nix/store
    echo
}

# Function to clean old system generations
cleanup_system_generations() {
    local days=${1:-30}
    
    echo -e "${YELLOW}=== Cleaning System Generations (older than ${days} days) ===${NC}"
    
    # Show what will be deleted
    echo "Generations that will be deleted:"
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | \
        awk -v cutoff="$(date -d "${days} days ago" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date -v-${days}d "+%Y-%m-%d %H:%M:%S")" \
        '$2" "$3 < cutoff {print "  Generation " $1 " from " $2 " " $3}'
    
    echo
    read -p "Continue with system generation cleanup? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo nix-collect-garbage --delete-older-than ${days}d
        echo -e "${GREEN}System generations cleanup completed${NC}"
    else
        echo "System generation cleanup skipped"
    fi
}

# Function to clean user profiles
cleanup_user_profiles() {
    echo -e "${YELLOW}=== Cleaning User Profiles ===${NC}"
    
    # Clean user profile (though we're using integrated home-manager now)
    if [ -d "$HOME/.nix-profile" ]; then
        echo "Cleaning user profile generations..."
        nix-collect-garbage -d
        echo -e "${GREEN}User profile cleanup completed${NC}"
    else
        echo "No user profile found to clean"
    fi
}

# Function to optimize nix store
optimize_store() {
    echo -e "${YELLOW}=== Optimizing Nix Store ===${NC}"
    echo "This will deduplicate files in the Nix store to save space"
    
    read -p "Run nix store optimization? This may take a while but saves space (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Running store optimization..."
        sudo nix store optimise
        echo -e "${GREEN}Store optimization completed${NC}"
    else
        echo "Store optimization skipped"
    fi
}

# Function to repair store
repair_store() {
    echo -e "${YELLOW}=== Checking Store Integrity ===${NC}"
    
    read -p "Run store integrity check and repair? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Checking and repairing store..."
        sudo nix-store --verify --check-contents --repair
        echo -e "${GREEN}Store check completed${NC}"
    else
        echo "Store check skipped"
    fi
}

# Function to show cleanup results
show_results() {
    echo -e "${YELLOW}=== Cleanup Results ===${NC}"
    
    echo "Remaining system generations:"
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -5
    
    echo
    echo "Final Nix store size:"
    du -sh /nix/store
    echo
    
    echo -e "${GREEN}=== Cleanup Complete ===${NC}"
    echo "Your system is now cleaned up!"
    echo
    echo "To prevent future buildup, consider:"
    echo "- Running './scripts/cleanup.sh conservative' monthly"
    echo "- Setting up automatic garbage collection in your config"
    echo "- Using './scripts/build.sh clean' for quick cleanup"
}

# Main cleanup function
main() {
    local mode="${1:-interactive}"
    
    show_current_state
    
    case "$mode" in
        "aggressive")
            echo -e "${RED}Running aggressive cleanup (removes generations older than 7 days)${NC}"
            cleanup_system_generations 7
            cleanup_user_profiles
            optimize_store
            ;;
        "conservative")
            echo -e "${GREEN}Running conservative cleanup (removes generations older than 60 days)${NC}"
            cleanup_system_generations 60
            cleanup_user_profiles
            ;;
        "interactive"|*)
            echo "Choose cleanup level:"
            echo "1) Conservative (60+ days old)"
            echo "2) Standard (30+ days old)" 
            echo "3) Aggressive (7+ days old)"
            echo "4) Custom (specify days)"
            echo "5) Exit"
            
            read -p "Enter choice (1-5): " choice
            
            case $choice in
                1) cleanup_system_generations 60 ;;
                2) cleanup_system_generations 30 ;;
                3) cleanup_system_generations 7 ;;
                4) 
                    read -p "Enter number of days: " days
                    cleanup_system_generations "$days"
                    ;;
                5) echo "Cleanup cancelled"; exit 0 ;;
                *) echo "Invalid choice"; exit 1 ;;
            esac
            
            cleanup_user_profiles
            
            echo
            read -p "Run additional optimizations? (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                optimize_store
                repair_store
            fi
            ;;
    esac
    
    show_results
}

# Show usage
show_usage() {
    echo "Usage: $0 [mode]"
    echo
    echo "Modes:"
    echo "  interactive  - Interactive cleanup with choices (default)"
    echo "  conservative - Remove generations older than 60 days"
    echo "  standard     - Remove generations older than 30 days"  
    echo "  aggressive   - Remove generations older than 7 days"
    echo
    echo "Examples:"
    echo "  $0                    # Interactive mode"
    echo "  $0 conservative       # Safe cleanup"
    echo "  $0 aggressive         # Aggressive cleanup"
}

# Handle arguments
if [[ $# -gt 1 ]]; then
    show_usage
    exit 1
fi

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    show_usage
    exit 0
fi

# Run main function
main "${1:-interactive}"