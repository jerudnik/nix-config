# SketchyBar Setup Guide

## Overview

SketchyBar is now successfully set up as a complete **replacement for the macOS menu bar**! It provides a customizable status bar at the top of your screen with:
- Full AeroSpace workspace integration
- System monitoring widgets (CPU, WiFi, Volume, Battery)
- Date/time display
- Auto-hidden native macOS menu bar

## What Was Configured

### System Level (nix-darwin)
- **sketchybar**: The status bar application
- **sketchybar-app-font**: Special font for displaying app icons

Location: `hosts/parsley/configuration.nix`

### User Level (home-manager)
- Configuration files in `~/.config/sketchybar/`
- LaunchAgent for auto-starting sketchybar at login
- AeroSpace workspace integration

Location: `modules/home/desktop/sketchybar/default.nix`

### AeroSpace Integration
- Sketchybar starts automatically with AeroSpace
- Workspace changes trigger sketchybar updates
- Active workspace is highlighted visually

Location: `modules/home/window-manager/aerospace.nix`

## Current Configuration

Your sketchybar is configured with:

- **Position**: Top of screen (replaces macOS menu bar)
- **Height**: 32 pixels (standard menu bar height)
- **Offset**: None - flush with screen edge
- **Font**: SF Pro (macOS system font)
- **Workspaces**: 1, 2, 3, 4, 5 (matching your AeroSpace setup)
- **Widgets** (left to right):
  - **Left side**: Workspace indicators (1-5)
  - **Right side**: CPU usage, WiFi status, Volume control, Battery, Date/time
- **macOS Menu Bar**: Auto-hidden (press Fn or move cursor to top to reveal)
- **AeroSpace Integration**: Top gap set to 32px to prevent window overlap

## Using SketchyBar

### Workspace Indicators

- **Numbered indicators** (1-5) on the left show your AeroSpace workspaces
- **Active workspace** has a highlighted background
- **Click** on a workspace number to switch to that workspace
- Automatically updates when you change workspaces with AeroSpace keybindings

### Status Widgets

**CPU Widget** (right side):
- Shows total CPU usage percentage
- Updates every 2 seconds
- Icon: 󰻠 (processor symbol)

**WiFi Widget** (right side):
- Shows WiFi connection status
- Displays connected network name (SSID)
- Shows "Disconnected" when offline
- Updates every 10 seconds

**Volume Widget** (right side):
- Shows current system volume percentage
- Icon changes based on volume level
- Shows mute icon when muted
- **Click** to increase volume by 10%
- Updates every second

**Battery Widget** (right side):
- Shows battery icon and percentage
- Icon changes based on charge level
- Shows charging indicator when plugged in
- Updates every 2 minutes

**Date/Time Widget** (right side):
- Shows current date and time
- Format: `Mon Jan 01 12:00`
- Updates every 30 seconds

## Customization

All customization is done through your nix configuration in `home/jrudnik/home.nix`:

```nix
sketchybar = {
  enable = true;
  position = "top";  # Options: "top", "bottom", "left", "right"
  height = 32;       # Adjust bar height
  font = "SF Pro";   # Change font family
  
  # AeroSpace workspace integration
  aerospace = {
    enable = true;
    workspaces = [ "1" "2" "3" "4" "5" ];  # Add/remove workspaces
  };
  
  # Widget configuration
  showCalendar = true;  # Date/time widget
  showBattery = true;   # Battery indicator
  showWifi = true;      # WiFi status
  showVolume = true;    # Volume control
  showCpu = true;       # CPU usage
  
  # Color scheme
  colors = {
    bar = "0xff1e1e2e";  # Bar background
    icon = "0xffcad3f5";  # Icon color
    label = "0xffcad3f5";  # Label color
    workspaceActive = "0xffed8796";  # Active workspace highlight
    workspaceInactive = "0x44ffffff";  # Inactive workspace background
  };
};
```

### Common Customizations

#### Change Bar Position

```nix
position = "bottom";  # Move to bottom of screen
```

#### Adjust Number of Workspaces

```nix
aerospace.workspaces = [ "1" "2" "3" "4" "5" "6" "7" "8" ];
```

Make sure this matches your AeroSpace keybindings!

#### Change Colors

Color format: `0xAARRGGBB` (AA=alpha, RR=red, GG=green, BB=blue)

```nix
colors = {
  bar = "0xff000000";  # Pure black background
  workspaceActive = "0xff00ff00";  # Green highlight
};
```

#### Toggle Widgets

```nix
# Enable/disable any combination of widgets
showCalendar = true;   # Date/time widget
showBattery = true;    # Battery indicator  
showWifi = true;       # WiFi status
showVolume = true;     # Volume control
showCpu = true;        # CPU usage
```

## Manual Control

### Reload Configuration

After making changes to your nix configuration:

```bash
nrb  # Rebuild and switch configuration
```

SketchyBar will restart automatically with the new settings.

### Check Status

```bash
# Check if sketchybar is running
pgrep -fl sketchybar

# View sketchybar logs
log show --predicate 'process == "sketchybar"' --last 1m

# Manually restart sketchybar
launchctl kickstart -k gui/$(id -u)/org.nix-community.home.sketchybar
```

### Test Workspace Changes

1. Open some windows
2. Use AeroSpace keybindings to switch workspaces (Alt+1, Alt+2, etc.)
3. Watch the workspace indicators update in sketchybar

## Troubleshooting

### SketchyBar Not Visible

1. **Check if running**:
   ```bash
   pgrep sketchybar
   ```

2. **Restart manually**:
   ```bash
   launchctl kickstart -k gui/$(id -u)/org.nix-community.home.sketchybar
   ```

3. **Check logs**:
   ```bash
   log stream --predicate 'process == "sketchybar"'
   ```

### Workspace Indicators Not Updating

1. **Verify AeroSpace integration**:
   ```bash
   cat ~/.aerospace.toml | grep sketchybar
   ```
   
   Should show:
   ```toml
   after-startup-command = ['exec-and-forget sketchybar']
   exec-on-workspace-change = ['/bin/bash', '-c', 'sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE']
   ```

2. **Restart both services**:
   ```bash
   launchctl kickstart -k gui/$(id -u)/org.nix-community.home.sketchybar
   aerospace reload-config
   ```

### Wrong Workspace Numbers Displayed

Make sure your sketchybar workspaces match your AeroSpace configuration:

In `home/jrudnik/home.nix`:
```nix
sketchybar.aerospace.workspaces = [ "1" "2" "3" "4" "5" ];
```

Should match the keybindings in your AeroSpace config (generated from `modules/home/window-manager/aerospace.nix`).

## Advanced Customization

For advanced customization beyond the module options, you can:

1. **Add custom plugins**: Create shell scripts in `~/.config/sketchybar/plugins/`
2. **Add custom items**: Create item configs in `~/.config/sketchybar/items/`
3. **Extend the module**: Add options to `modules/home/desktop/sketchybar/default.nix`

See the [SketchyBar documentation](https://felixkratz.github.io/SketchyBar/) for more advanced features.

## Integration with Your Workflow

SketchyBar works seamlessly with your existing setup:

- **AeroSpace**: Workspace changes are instantly reflected
- **Stylix**: Colors will adapt when you change your theme
- **Fonts**: Uses your system font (SF Pro by default, or change to match iM-Writing)
- **Auto-start**: Launches automatically at login via LaunchAgent

## Next Steps

1. **Test the workspace indicators** by switching workspaces with Alt+1, Alt+2, etc.
2. **Customize the colors** to match your Gruvbox theme if desired
3. **Add more widgets** if needed (see module source for available options)
4. **Adjust the bar position** if you prefer it elsewhere

## Files Created

Configuration files (managed by nix-darwin/home-manager):
- `~/.config/sketchybar/sketchybarrc` - Main configuration
- `~/.config/sketchybar/colors.sh` - Color definitions
- `~/.config/sketchybar/icons.sh` - Icon definitions
- `~/.config/sketchybar/items/` - Widget definitions
- `~/.config/sketchybar/plugins/` - Plugin scripts
- `~/Library/LaunchAgents/org.nix-community.home.sketchybar.plist` - Auto-start service

Module source:
- `modules/home/desktop/sketchybar/default.nix` - SketchyBar module

## Resources

- [SketchyBar GitHub](https://github.com/FelixKratz/SketchyBar)
- [SketchyBar Documentation](https://felixkratz.github.io/SketchyBar/)
- [Example Configurations](https://github.com/FelixKratz/SketchyBar/discussions/47)
- [AeroSpace Integration](https://nikitabobko.github.io/AeroSpace/guide#exec-on-workspace-change)
