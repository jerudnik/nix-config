# Raycast Home Manager Module

A WARP.md compliant Home Manager module for installing and configuring Raycast declaratively on macOS.

## Features

- ✅ **Pure declarative configuration** - No activation scripts or manual commands
- ✅ **Type-safe options** - Strict typing with sensible defaults  
- ✅ **nixpkgs installation** - Installs via nixpkgs, not Homebrew
- ✅ **Spotlight replacement** - Automatically disables macOS Spotlight shortcuts
- ✅ **Hermetic configuration** - No external state dependencies

## Options

### `home.raycast.enable`
- **Type**: `bool`
- **Default**: `false`
- **Description**: Enable Raycast launcher installed and configured declaratively

### `home.raycast.package`
- **Type**: `package`
- **Default**: `pkgs.raycast`
- **Description**: Raycast application package from nixpkgs (unfree)
- **Notes**: Requires unfree packages to be allowed via `allowUnfreePredicate`

### `home.raycast.followSystemAppearance`
- **Type**: `bool`
- **Default**: `true`
- **Description**: Follow system appearance for light/dark mode
- **Maps to**: `com.raycast.macos.raycastShouldFollowSystemAppearance`

### `home.raycast.globalHotkey`
- **Type**: `nullOr (submodule { keyCode, modifierFlags })`
- **Default**: `{ keyCode = 49; modifierFlags = 1048576; }` (Cmd+Space)
- **Description**: Global hotkey configuration for Raycast activation
- **Maps to**: `com.raycast.macos.raycastGlobalHotkey`

#### Hotkey Submodule Options:
- `keyCode` (int): Key code for the global hotkey (49 = space, 36 = return)
- `modifierFlags` (int): Modifier flags (1048576 = Cmd, 524288 = Option, 262144 = Ctrl, 131072 = Shift)

### `home.raycast.extraDefaults`
- **Type**: `attrsOf (oneOf [ bool int float str ])`
- **Default**: `{}`
- **Description**: Additional com.raycast.macos defaults for documented Raycast keys
- **Usage**: Escape hatch for settings not covered by typed options

### `home.raycast.autoStart`
- **Type**: `submodule`
- **Default**: `{ enable = true; delaySeconds = 3; startInBackground = true; keepAlive = false; logToFile = true; label = "org.home-manager.raycast.autostart"; }`
- **Description**: Creates a user LaunchAgent to start Raycast at login. Uses `/usr/bin/open -a Raycast`.
- **Best practice**: Keep `startInBackground = true` to avoid stealing focus at login.
- **Edge cases**: If Accessibility permission is not granted yet, macOS will prompt on first launch. This cannot be configured declaratively due to TCC restrictions.

#### autoStart Submodule Options:
- `enable` (bool): Enable automatic startup via launchd agent
- `label` (string): LaunchAgent label (default: "org.home-manager.raycast.autostart")
- `delaySeconds` (int): Optional startup delay to avoid login race conditions (default: 3)
- `startInBackground` (bool): Launch Raycast in background without activating window (default: true)
- `keepAlive` (bool): Relaunch Raycast if it exits (default: false - respects manual quits)
- `logToFile` (bool): Log LaunchAgent output to ~/Library/Logs/raycast-autostart.log (default: true)

## Configuration Example

```nix
{
  home.raycast = {
    enable = true;
    followSystemAppearance = true;
    globalHotkey = {
      keyCode = 49;           # Space key
      modifierFlags = 1048576; # Command modifier (Cmd+Space)
    };
    autoStart = {
      enable = true;
      delaySeconds = 3;
      startInBackground = true;
      keepAlive = false;      # Respect manual quits
    };
    # Add additional settings if needed
    extraDefaults = {
      "onboarding_setupHotkey" = true;
    };
  };
}
```

## Implementation Details

### Preference Keys Mapping

| Option | Defaults Key | Type | Purpose |
|--------|-------------|------|---------|
| `followSystemAppearance` | `raycastShouldFollowSystemAppearance` | bool | System theme following |
| `globalHotkey` | `raycastGlobalHotkey` | dict | Global activation hotkey |
| N/A | `mainWindow_isMonitoringGlobalHotkeys` | bool | Enable hotkey monitoring |
| N/A | `onboardingCompleted` | bool | Skip onboarding dialogs |
| N/A | `onboarding_setupHotkey` | bool | Mark hotkey setup complete |

### Automatic Spotlight Disable

When enabled, this module automatically disables macOS Spotlight shortcuts to prevent conflicts:

- **Cmd+Space**: Disabled via `com.apple.symbolichotkeys.AppleSymbolicHotKeys.64.enabled = false`
- **Cmd+Option+Space**: Disabled via `com.apple.symbolichotkeys.AppleSymbolicHotKeys.65.enabled = false`

### Platform Requirements

- **macOS only**: Module includes assertion for `pkgs.stdenv.isDarwin`
- **Home Manager**: Designed for user-level installation (not system-level)
- **Unfree package**: Raycast requires unfree packages to be allowed

## Limitations

1. **Hotkey complexity**: Only simple hotkey combinations supported via typed interface
2. **Extension management**: Does not manage Raycast extensions or store configurations  
3. **Advanced preferences**: Complex nested preferences require `extraDefaults`
4. **Real-time updates**: Settings take effect on next Raycast launch, not immediately

## WARP.md Compliance

This module is fully compliant with all Configuration Purity Laws:

- ✅ **LAW 1**: No imperative actions - uses only `targets.darwin.defaults`
- ✅ **LAW 2**: Single responsibility - focused solely on Raycast configuration  
- ✅ **LAW 3**: Type safety - all options strictly typed with descriptions
- ✅ **LAW 4**: Build discipline - no complex logic in configuration
- ✅ **LAW 5**: File boundaries - all files within nix-config directory
- ✅ **LAW 6**: Workflow adherence - follows documented patterns
- ✅ **LAW 7**: Pure functional - hermetic, reproducible configuration

## Troubleshooting

### Raycast not found
- Verify `home.packages` includes the Raycast package
- Check `~/Applications/home-manager/` for Raycast.app symlink
- Ensure unfree packages are allowed in nixpkgs config

### Hotkey not working
- Verify Spotlight shortcuts are disabled in System Preferences
- Check that `raycastGlobalHotkey` is set in com.raycast.macos defaults
- Restart Raycast to pick up new hotkey settings
- If hotkey fails: verify Spotlight keys are disabled and Raycast has Accessibility permission

### Auto-startup not working
- Check if LaunchAgent is loaded: `launchctl print gui/$(id -u) | grep org.home-manager.raycast.autostart`
- View startup logs: `tail -f ~/Library/Logs/raycast-autostart.log`
- Manually trigger startup: `launchctl kickstart -k gui/$(id -u)/org.home-manager.raycast.autostart`
- If intermittent failures: increase `delaySeconds` to 5-8 seconds

### Settings not applying
- Settings are applied via `targets.darwin.defaults` during Home Manager activation
- Raycast must be restarted to pick up new preference changes
- Check `defaults read com.raycast.macos` to verify settings were written

### Accessibility Permission
- macOS will prompt for Accessibility permission on first Raycast launch
- This cannot be granted declaratively due to TCC (Transparency, Consent, and Control) restrictions
- Once granted, hotkeys will work reliably across reboots
