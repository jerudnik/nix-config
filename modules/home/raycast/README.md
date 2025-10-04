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

### Settings not applying
- Settings are applied via `targets.darwin.defaults` during Home Manager activation
- Raycast must be restarted to pick up new preference changes
- Check `defaults read com.raycast.macos` to verify settings were written