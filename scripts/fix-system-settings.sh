#!/usr/bin/env bash
#
# fix-system-settings.sh
# 
# Automated cleanup script for corrupted macOS System Settings preferences
# caused by conflicts between nix-darwin and home-manager preference writes.
#
# Usage:
#   ./scripts/fix-system-settings.sh [--dry-run] [--no-backup]
#
# Options:
#   --dry-run     Show what would be done without making changes
#   --no-backup   Skip backup creation (not recommended)
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
DRY_RUN=false
NO_BACKUP=false

for arg in "$@"; do
  case $arg in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --no-backup)
      NO_BACKUP=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [--dry-run] [--no-backup]"
      echo ""
      echo "Options:"
      echo "  --dry-run     Show what would be done without making changes"
      echo "  --no-backup   Skip backup creation (not recommended)"
      exit 0
      ;;
  esac
done

# Backup directory
BACKUP_DIR="$HOME/Library/Preferences/.backups/$(date +%Y%m%d_%H%M%S)"

echo -e "${BLUE}=== macOS System Settings Cleanup Script ===${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}DRY RUN MODE - No changes will be made${NC}"
  echo ""
fi

# Function to safely execute commands
safe_exec() {
  local description="$1"
  shift
  
  echo -e "${GREEN}→${NC} $description"
  
  if [ "$DRY_RUN" = true ]; then
    echo "  Would run: $*"
  else
    if "$@"; then
      echo -e "${GREEN}  ✓ Success${NC}"
    else
      echo -e "${RED}  ✗ Failed (continuing anyway)${NC}"
    fi
  fi
  echo ""
}

# Function to backup file
backup_file() {
  local file="$1"
  
  if [ ! -f "$file" ]; then
    return 0
  fi
  
  if [ "$NO_BACKUP" = true ]; then
    echo -e "${YELLOW}  Skipping backup (--no-backup flag set)${NC}"
    return 0
  fi
  
  if [ "$DRY_RUN" = false ]; then
    mkdir -p "$BACKUP_DIR"
    cp "$file" "$BACKUP_DIR/$(basename "$file")"
    echo -e "${GREEN}  ✓ Backed up to: $BACKUP_DIR/$(basename "$file")${NC}"
  else
    echo "  Would backup to: $BACKUP_DIR/$(basename "$file")"
  fi
}

# Step 1: Close System Settings if running
echo -e "${BLUE}Step 1: Closing System Settings${NC}"
safe_exec "Closing System Settings application" killall "System Settings" 2>/dev/null || echo -e "${YELLOW}  System Settings not running${NC}"

# Step 2: Kill preference daemon
echo -e "${BLUE}Step 2: Clearing preference cache${NC}"
safe_exec "Killing user preference daemon" killall cfprefsd 2>/dev/null || true
safe_exec "Killing system preference daemon (requires sudo)" sudo killall cfprefsd 2>/dev/null || true

# Step 3: Backup and remove GlobalPreferences
echo -e "${BLUE}Step 3: Cleaning GlobalPreferences files${NC}"

# User GlobalPreferences
if [ -f "$HOME/Library/Preferences/.GlobalPreferences.plist" ]; then
  echo -e "${GREEN}→${NC} Processing .GlobalPreferences.plist"
  backup_file "$HOME/Library/Preferences/.GlobalPreferences.plist"
  if [ "$DRY_RUN" = false ]; then
    rm -f "$HOME/Library/Preferences/.GlobalPreferences.plist"
    echo -e "${GREEN}  ✓ Removed${NC}"
  else
    echo "  Would remove: $HOME/Library/Preferences/.GlobalPreferences.plist"
  fi
  echo ""
fi

# ByHost GlobalPreferences
for file in "$HOME"/Library/Preferences/ByHost/.GlobalPreferences.*.plist; do
  if [ -f "$file" ]; then
    echo -e "${GREEN}→${NC} Processing $(basename "$file")"
    backup_file "$file"
    if [ "$DRY_RUN" = false ]; then
      rm -f "$file"
      echo -e "${GREEN}  ✓ Removed${NC}"
    else
      echo "  Would remove: $file"
    fi
    echo ""
  fi
done

# Step 4: Clean symbolic hotkeys
echo -e "${BLUE}Step 4: Cleaning symbolic hotkeys preferences${NC}"

if [ -f "$HOME/Library/Preferences/com.apple.symbolichotkeys.plist" ]; then
  echo -e "${GREEN}→${NC} Processing com.apple.symbolichotkeys.plist"
  backup_file "$HOME/Library/Preferences/com.apple.symbolichotkeys.plist"
  if [ "$DRY_RUN" = false ]; then
    rm -f "$HOME/Library/Preferences/com.apple.symbolichotkeys.plist"
    echo -e "${GREEN}  ✓ Removed${NC}"
  else
    echo "  Would remove: $HOME/Library/Preferences/com.apple.symbolichotkeys.plist"
  fi
  echo ""
fi

# Step 5: Clean System Settings container (optional, aggressive)
echo -e "${BLUE}Step 5: System Settings container cleanup (optional)${NC}"
echo -e "${YELLOW}This step is more aggressive and usually not needed.${NC}"
read -p "Remove System Settings container? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  if [ -f "$HOME/Library/Preferences/com.apple.systempreferences.plist" ]; then
    echo -e "${GREEN}→${NC} Processing com.apple.systempreferences.plist"
    backup_file "$HOME/Library/Preferences/com.apple.systempreferences.plist"
    if [ "$DRY_RUN" = false ]; then
      rm -f "$HOME/Library/Preferences/com.apple.systempreferences.plist"
      echo -e "${GREEN}  ✓ Removed${NC}"
    else
      echo "  Would remove: $HOME/Library/Preferences/com.apple.systempreferences.plist"
    fi
    echo ""
  fi
  
  if [ -d "$HOME/Library/Containers/com.apple.systempreferences" ]; then
    echo -e "${GREEN}→${NC} Processing System Settings container directory"
    if [ "$DRY_RUN" = false ]; then
      rm -rf "$HOME/Library/Containers/com.apple.systempreferences"
      echo -e "${GREEN}  ✓ Removed${NC}"
    else
      echo "  Would remove: $HOME/Library/Containers/com.apple.systempreferences"
    fi
    echo ""
  fi
  
  # System-level preference (requires sudo)
  if [ -f "/Library/Preferences/com.apple.systempreferences.plist" ]; then
    echo -e "${GREEN}→${NC} Processing system-level com.apple.systempreferences.plist (requires sudo)"
    if [ "$DRY_RUN" = false ]; then
      sudo cp "/Library/Preferences/com.apple.systempreferences.plist" "$BACKUP_DIR/com.apple.systempreferences.plist.system" 2>/dev/null || true
      sudo rm -f "/Library/Preferences/com.apple.systempreferences.plist"
      echo -e "${GREEN}  ✓ Removed${NC}"
    else
      echo "  Would backup and remove: /Library/Preferences/com.apple.systempreferences.plist"
    fi
    echo ""
  fi
else
  echo -e "${YELLOW}Skipping System Settings container cleanup${NC}"
  echo ""
fi

# Step 6: Final preference daemon restart
echo -e "${BLUE}Step 6: Final preference daemon restart${NC}"
safe_exec "Restarting preference daemon" killall cfprefsd 2>/dev/null || true
safe_exec "Restarting system preference daemon (requires sudo)" sudo killall cfprefsd 2>/dev/null || true

# Summary
echo -e "${BLUE}=== Cleanup Complete ===${NC}"
echo ""

if [ "$NO_BACKUP" = false ] && [ "$DRY_RUN" = false ]; then
  echo -e "${GREEN}Backups saved to:${NC} $BACKUP_DIR"
  echo ""
fi

echo -e "${YELLOW}Next steps:${NC}"
echo "1. Apply your nix-darwin configuration:"
echo "   ${BLUE}darwin-rebuild switch --flake ~/nix-config#parsley${NC}"
echo ""
echo "2. Open System Settings and verify all panes display correctly:"
echo "   ${BLUE}open '/System/Applications/System Settings.app'${NC}"
echo ""
echo "3. If issues persist, you may need to restart your Mac"
echo ""
echo -e "${GREEN}Done!${NC}"
