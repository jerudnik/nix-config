# Dock Applications & Theme Switching Troubleshooting

Quick solutions for common issues with dock applications and automatic theme switching.

## Dock Applications Issues

### Applications Not Appearing in Dock

**Problem**: After configuration change, applications don't appear in dock.

**Solutions**:
1. **Check application paths**:
   ```bash
   # Verify app exists at specified path
   ls -la "/Applications/Zen.app"
   ls -la "/System/Applications/Messages.app"
   ```

2. **Find correct application paths**:
   ```bash
   # List all applications
   find /Applications -name "*.app" -maxdepth 1
   find /System/Applications -name "*.app" -maxdepth 1
   
   # Search for specific app
   find /Applications -name "*Zen*" -type d
   ```

3. **Force dock restart**:
   ```bash
   killall Dock
   # Dock will restart automatically
   ```

### Dock Configuration Not Applied

**Problem**: Dock settings like autohide or orientation aren't working.

**Solutions**:
1. **Rebuild and switch configuration**:
   ```bash
   cd ~/nix-config
   ./scripts/build.sh switch
   ```

2. **Check if system-defaults module is enabled**:
   ```nix
   # In hosts/parsley/configuration.nix
   darwin.system-defaults.enable = true;  # Must be true
   ```

3. **Verify dock configuration syntax**:
   ```bash
   nix flake check ~/nix-config
   ```

### Application Path Errors

**Problem**: Build fails with "path does not exist" errors.

**Solutions**:
1. **Remove non-existent applications**:
   ```nix
   # Comment out or remove apps you don't have installed
   persistentApps = [
     "/Applications/Warp.app"              # Keep if installed
     # "/Applications/VS Code.app"         # Comment out if not installed
   ];
   ```

2. **Install missing applications first**:
   ```bash
   # Via Homebrew (add to darwin.homebrew.casks)
   # Via Mac App Store
   # Via direct download
   ```

## Theme Switching Issues

### Themes Not Switching Automatically

**Problem**: Changing macOS appearance doesn't update application themes.

**Solutions**:
1. **Verify polarity setting**:
   ```nix
   # In hosts/parsley/configuration.nix
   darwin.theming = {
     enable = true;
     polarity = "either";  # Essential for auto-switching
   };
   ```

2. **Check current macOS appearance**:
   ```bash
   defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light Mode"
   ```

3. **Test theme switching status**:
   ```bash
   nix-theme-switch
   ```

4. **Restart affected applications**:
   ```bash
   # Applications need to be restarted to pick up theme changes
   # Try opening a new terminal window
   ```

### Theme Command Not Found

**Problem**: `nix-theme-switch` command not available.

**Solutions**:
1. **Ensure autoSwitch is enabled**:
   ```nix
   darwin.theming = {
     enable = true;
     autoSwitch.enable = true;  # Required for the command
   };
   ```

2. **Rebuild configuration**:
   ```bash
   ./scripts/build.sh switch
   ```

3. **Check if command is in PATH**:
   ```bash
   which nix-theme-switch
   echo $PATH | grep nix
   ```

### Applications Not Theming

**Problem**: Some applications don't change themes.

**Explanation**: Not all applications support automatic theming. Stylix works with:
- Terminal applications (Alacritty, etc.)
- Nix-managed editors (Emacs, Neovim)
- CLI tools (bat, eza, etc.)

**Solutions**:
1. **Check Stylix compatibility**:
   ```bash
   # Applications must be configured through Nix to be themed
   # GUI apps installed via Homebrew/App Store won't auto-theme
   ```

2. **Use supported applications**:
   - Install editors via Nix instead of Homebrew when possible
   - Terminal applications work best for theming

### Color Scheme Not Found

**Problem**: Build fails with "color scheme not found" error.

**Solutions**:
1. **Check available color schemes**:
   ```bash
   ls "$(nix-build '<nixpkgs>' -A base16-schemes --no-out-link)/share/themes/"
   ```

2. **Use correct scheme names**:
   ```nix
   # Popular working schemes:
   colorScheme = "gruvbox-material-dark-medium";
   colorScheme = "catppuccin-mocha";
   colorScheme = "tokyo-night-dark";
   colorScheme = "github-dark";
   ```

## General Troubleshooting

### Configuration Build Fails

**Problem**: Build errors when applying changes.

**Solutions**:
1. **Check syntax**:
   ```bash
   nix flake check ~/nix-config --show-trace
   ```

2. **Test specific components**:
   ```bash
   # Test system config only
   darwin-rebuild build --flake ~/nix-config#parsley --show-trace
   
   # Test home config only  
   home-manager build --flake ~/nix-config#jrudnik@parsley --show-trace
   ```

3. **Rollback if needed**:
   ```bash
   # System rollback
   sudo nix-env --rollback --profile /nix/var/nix/profiles/system
   
   # Home rollback
   home-manager switch --rollback
   ```

### Changes Not Taking Effect

**Problem**: Configuration changes don't seem to apply.

**Solutions**:
1. **Force complete rebuild**:
   ```bash
   ./scripts/build.sh clean
   ./scripts/build.sh switch
   ```

2. **Check system generation**:
   ```bash
   sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
   ```

3. **Restart affected services**:
   ```bash
   # Restart dock
   killall Dock
   
   # Restart finder (if finder settings changed)
   killall Finder
   ```

## Testing Your Setup

### Verify Dock Configuration

```bash
# Check dock defaults
defaults read com.apple.dock persistent-apps
defaults read com.apple.dock persistent-others
defaults read com.apple.dock autohide
defaults read com.apple.dock orientation
```

### Verify Theme Configuration

```bash
# Check current macOS appearance
defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light"

# Test theme utility (if autoSwitch enabled)
nix-theme-switch

# Check if Stylix is active (look for styled terminal)
echo "Terminal colors should match your theme"
```

### Test Complete System

```bash
# 1. Rebuild everything
./scripts/build.sh switch

# 2. Check dock
# - Applications should appear in dock
# - Dock behavior should match configuration

# 3. Test theme switching
# - Change System Preferences > General > Appearance
# - Open new terminal window
# - Colors should adapt to system appearance

# 4. Verify commands work
nix-theme-switch  # Should show current theme info
```

## Getting Help

If issues persist:

1. **Check logs**:
   ```bash
   # System logs
   log stream --predicate 'subsystem contains "com.apple.dock"'
   
   # Nix build logs
   darwin-rebuild switch --flake ~/nix-config#parsley --show-trace
   ```

2. **Create minimal reproduction**:
   - Comment out complex configuration
   - Test with simple dock/theme setup
   - Gradually add back features

3. **Verify system state**:
   ```bash
   # Check nix-darwin version
   darwin-rebuild --version
   
   # Check if changes committed
   git status ~/nix-config
   ```

This troubleshooting guide should help resolve most common issues with dock applications and theme switching.