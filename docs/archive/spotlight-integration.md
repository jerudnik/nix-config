# App Launcher Integration for Nix Applications

This guide explains how Nix-installed applications are organized and integrated with macOS app launchers (Raycast, Alfred, Spotlight).

## Current Architecture (Since 2025-01-04)

**Standard Two-Folder Model**: This configuration uses the official defaults from both nix-darwin and Home Manager for clean, predictable app organization.

### App Locations

1. **Home Manager Apps**: `~/Applications/Home Manager Apps/` (HM default)
   - Contains user-level applications from Home Manager packages
   - Examples: Alacritty, Emacs, AeroSpace, Raycast

2. **System Apps**: `/Applications/Nix Apps/` (nix-darwin default)
   - Contains system-level applications from nix-darwin packages
   - Examples: Warp (from nixpkgs `warp-terminal`)

3. **Standard Apps**: `/Applications/` (macOS default)
   - Regular macOS apps and Homebrew casks

## App Launcher Integration

**Primary Launcher**: Raycast (configured in `home.raycast`)

```nix
raycast = {
  enable = true;
  followSystemAppearance = true;
  globalHotkey = {
    keyCode = 49;        # Space key
    modifierFlags = 1048576;  # Command modifier (Cmd+Space)
  };
};
```

**How It Works**: Raycast automatically discovers applications in:
- `~/Applications/Home Manager Apps/`
- `/Applications/Nix Apps/`
- `/Applications/` (regular macOS apps)

No additional configuration required!

## Verification

After running `darwin-rebuild switch`, verify your setup:

```bash
# Check Home Manager apps
ls -la ~/Applications/"Home Manager Apps"/

# Check system apps  
ls -la "/Applications/Nix Apps/"

# Expected: symlinks to .app bundles in nix store
# lrwxr-xr-x  Alacritty.app -> /nix/store/.../Applications/Alacritty.app
```

## App Discovery Troubleshooting

### 1. Raycast Not Finding Apps

If apps don't appear in Raycast:

```bash
# Verify apps exist in standard locations
ls -la ~/Applications/"Home Manager Apps"/
ls -la "/Applications/Nix Apps/"

# Restart Raycast to refresh app index
killall Raycast && open "/Users/jrudnik/Applications/Home Manager Apps/Raycast.app"
```

### 2. Apps Not Launching

If apps launch but behave oddly:

```bash
# Remove quarantine flags (common with downloaded apps)
xattr -dr com.apple.quarantine ~/Applications/"Home Manager Apps"/*.app
xattr -dr com.apple.quarantine "/Applications/Nix Apps"/*.app
```

### 3. Alternative Launchers

Other launchers work with the standard folders:

- **Spotlight**: Press Cmd+Space (if not replaced by Raycast)
- **Alfred**: Automatically finds apps in `~/Applications` and `/Applications`
- **LaunchBar**: Includes standard application directories

```bash
# Test Spotlight discovery (if enabled)
mdfind -name "Alacritty"
```

### 4. Manual App Launch

Apps can always be launched directly:

```bash
# Launch Home Manager apps
open ~/Applications/"Home Manager Apps"/Alacritty.app
open ~/Applications/"Home Manager Apps"/Emacs.app

# Launch system apps
open "/Applications/Nix Apps"/Warp.app

# Or add to Dock by dragging from Finder
```

## Common Issues

### Issue: Apps installed but not visible in Raycast

**Symptom**: New packages installed but apps don't appear in Raycast
**Solution**:
1. Verify app was installed with GUI: `ls -la ~/Applications/"Home Manager Apps"/`
2. Restart Raycast: `killall Raycast && open "/Users/jrudnik/Applications/Home Manager Apps/Raycast.app"`
3. Wait 30 seconds for Raycast to reindex

### Issue: Wrong app location

**Symptom**: System app appears in Home Manager folder or vice versa
**Solution**: Check which package list the app is in:
- `environment.systemPackages` → `/Applications/Nix Apps/`
- `home.packages` → `~/Applications/Home Manager Apps/`

## Architecture Details

### How Apps Are Linked

- **Home Manager**: Uses `buildEnv` with `pathsToLink = "/Applications"` to create proper symlinks
- **nix-darwin**: Creates direct symlinks to system packages with GUI applications
- **Symlink Structure**: Preserves .app bundle structure for proper macOS integration

### Why This Approach Works

1. **Standard Locations**: Follows macOS conventions for app discovery
2. **Automatic Indexing**: Both folders are automatically indexed by launcher apps
3. **Clean Separation**: User vs system apps clearly separated
4. **Zero Maintenance**: No custom reindexing or complex configuration

### Launcher Compatibility

All major launchers work with these standard locations:
- **Raycast** ✅ (primary launcher)
- **Alfred** ✅ 
- **LaunchBar** ✅
- **Spotlight** ✅ (if enabled)
- **Finder** ✅

## Testing Your Setup

To verify everything is working:

```bash
# Check apps are properly linked
ls -la ~/Applications/"Home Manager Apps"/
ls -la "/Applications/Nix Apps"/

# Test launching apps
open ~/Applications/"Home Manager Apps"/Raycast.app
open "/Applications/Nix Apps"/Warp.app

# Test Raycast discovery
# Press Cmd+Space and type app name
```

If apps launch successfully, launcher integration is working correctly.

---

## Migration Notes

**Previous Setup**: Custom spotlight module with multiple folders  
**Current Setup**: Standard two-folder model with Raycast  
**Migration Date**: 2025-01-04  
**Decision Record**: See [ADR-001](adr-001-app-organization.md) for full rationale
