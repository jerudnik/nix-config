# Spotlight Integration for Nix Applications

This guide explains how to make your Nix-installed applications discoverable in macOS Spotlight.

## How It Works

The `home.spotlight` module creates organized application links in `~/Applications/` that Spotlight can index and discover.

### What Gets Created

When you enable the spotlight module, it:

1. **Creates a clean folder**: `~/Applications/HomeManager/` (without spaces for better indexing)
2. **Links GUI applications**: Any .app bundles from your home-manager packages
3. **Triggers reindexing**: Attempts to refresh Spotlight's index automatically
4. **Provides feedback**: Shows status during home-manager activation

## Configuration

Add to your `home.nix`:

```nix
home.spotlight = {
  enable = true;
  appsFolder = "Applications/HomeManager";  # Customizable folder name
  forceReindex = true;  # Automatic reindexing
};
```

## Current Status

After running `darwin-rebuild switch`, check your setup:

```bash
# Verify application links exist
ls -la ~/Applications/HomeManager/

# Expected output: symlinks to .app bundles
# lrwxr-xr-x  Alacritty.app -> /nix/store/.../alacritty-.../Applications/Alacritty.app
```

## Troubleshooting Spotlight Discovery

### 1. Manual Spotlight Reindexing

If apps don't appear in Spotlight immediately:

```bash
# Force reindex (may show errors - this is normal)
mdutil -E ~/Applications

# Alternative: Use System Preferences
# System Preferences > Spotlight > Privacy
# Add ~/Applications, then remove it (forces reindex)
```

### 2. Check Indexing Status

```bash
# Check if directory is being indexed
mdutil -s ~/Applications

# Common responses:
# - "Indexing enabled" = Good
# - "Error: unknown indexing state" = Common with SIP, usually still works
```

### 3. Verify Application Discovery

```bash
# Search for your application
mdfind -name "Alacritty"

# Or use Spotlight search directly:
# Press Cmd+Space, type "Alacritty"
```

### 4. Alternative Discovery Methods

If Spotlight still doesn't find apps:

**Option A: Finder Integration**
- Open Finder
- Navigate to `~/Applications/HomeManager/`
- Drag applications to Dock for quick access
- Applications will be indexed over time

**Option B: Manual Spotlight Privacy Reset**
1. System Preferences → Spotlight → Privacy
2. Add `~/Applications` to the privacy list
3. Wait 10 seconds
4. Remove `~/Applications` from the privacy list
5. Spotlight will reindex the folder

**Option C: Launch Applications Directly**
```bash
# Launch from command line to "teach" Spotlight
open ~/Applications/HomeManager/Alacritty.app

# This helps Spotlight learn about the application
```

## Common Issues

### Issue: "Error: unknown indexing state"

**Symptom**: `mdutil` commands show indexing errors
**Cause**: macOS System Integrity Protection (SIP) restrictions
**Solution**: This is normal and usually doesn't prevent Spotlight from working

### Issue: Applications don't appear immediately

**Symptom**: Can't find newly installed applications in Spotlight
**Solution**: 
- Wait 2-5 minutes for background indexing
- Try manual reindexing with `mdutil -E ~/Applications`
- Launch the application once manually

### Issue: Old "Home Manager Apps" folder

**Symptom**: Both old and new application folders exist
**Solution**: The new `HomeManager` folder provides better indexing. The old folder can be ignored or you can disable the spotlight module temporarily to clean up.

## Expected Timeline

- **Immediate**: Application links appear in `~/Applications/HomeManager/`
- **1-2 minutes**: Applications may appear in Finder searches
- **2-5 minutes**: Applications appear in Spotlight search (Cmd+Space)
- **5+ minutes**: Full indexing including application metadata

## Integration with Other Launchers

This integration also works with:
- **Alfred**: Will discover applications in `~/Applications/HomeManager/`
- **Raycast**: Automatically finds symlinked applications
- **LaunchBar**: Includes ~/Applications in search scope

## Technical Details

The spotlight module:
- Uses `buildEnv` with `pathsToLink = "/Applications"` for proper symlinks
- Creates symlinks that preserve .app bundle structure
- Triggers Spotlight indexing via `mdutil` commands
- Provides user feedback during activation

The approach follows the established pattern from the Nix community for macOS application integration.

## Manual Testing

To test if your applications are properly linked:

```bash
# Check if Alacritty is linked correctly
ls -la ~/Applications/HomeManager/Alacritty.app

# Try launching it
open ~/Applications/HomeManager/Alacritty.app

# Search with mdfind
mdfind -name "Alacritty" 2>/dev/null
```

If manual launching works, Spotlight integration is functioning correctly.