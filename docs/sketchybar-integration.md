# SketchyBar Integration Guide

SketchyBar is a highly customizable macOS status bar replacement that integrates beautifully with your existing AeroSpace tiling window manager and Stylix theming system.

## Features

### 🎨 **Automatic Stylix Theming**
- **Seamless Integration**: SketchyBar automatically picks up colors from your current Stylix theme
- **Dynamic Colors**: All components use your Gruvbox Material theme colors
- **Consistent Design**: Matches your terminal, editor, and other themed applications

### 🚀 **AeroSpace Integration** 
- **Workspace Indicators**: Shows current AeroSpace workspace (1-10)
- **Visual Feedback**: Focused workspace highlighted with accent color
- **Click Navigation**: Click workspace numbers to switch instantly
- **Real-time Updates**: Automatically updates when switching workspaces

### 📊 **System Information**
- **Battery**: Smart battery indicator with charging status and icons
- **Clock**: Clean date and time display
- **WiFi**: Current network name and connection status
- **System Stats**: CPU usage and memory pressure
- **Volume**: Current volume level with mute detection

## Configuration

### Basic Setup

SketchyBar is configured through your Darwin system configuration:

```nix
# hosts/parsley/configuration.nix
darwin = {
  sketchybar = {
    enable = true;
    # All components enabled by default with beautiful Stylix theming
    # Integrates perfectly with AeroSpace workspace indicators
  };
};
```

### Customization Options

```nix
darwin.sketchybar = {
  enable = true;
  
  # Bar appearance
  position = "top";          # "top" or "bottom"
  height = 32;               # Height in pixels
  margin = 10;               # Margin around bar
  cornerRadius = 9;          # Corner radius
  shadow = true;             # Drop shadow
  blur = true;               # Background blur
  
  # Components (all enabled by default)
  components = {
    workspaces = true;       # AeroSpace workspace indicators
    clock = true;            # Date and time
    battery = true;          # Battery status
    wifi = true;             # WiFi information
    volume = true;           # Volume control
    systemStats = true;      # CPU/Memory usage
  };
  
  # Add custom configuration
  extraConfig = ''
    sketchybar --add item my_item right \
              --set my_item label="Custom"
  '';
};
```

## Theming System

SketchyBar uses an advanced theming system that automatically integrates with Stylix:

### Color Scheme Integration

The configuration automatically generates colors from your current Stylix theme:

- **Bar Background**: Uses your theme's base background color
- **Item Backgrounds**: Subtle contrast for readability  
- **Text Colors**: High contrast text from your theme
- **Icon Colors**: Accent colors for visual hierarchy
- **Focused Workspace**: Uses your theme's accent color for active workspace

### Theme Colors Available

```bash
# Automatically generated from your Gruvbox Material theme:
BAR_COLOR=#1d2021          # Dark background
ITEM_BG_COLOR=#282828      # Item backgrounds
ACCENT_COLOR=#83a598       # Blue accent (focused items)
TEXT_COLOR=#ebdbb2         # Light text
ICON_COLOR=#8ec07c         # Green accent (icons)
```

## AeroSpace Integration

SketchyBar provides seamless integration with your AeroSpace tiling window manager:

### Workspace Indicators

- **Visual Workspace Numbers**: Shows workspaces 1-10 on the left side of the bar
- **Current Workspace Highlight**: Active workspace uses accent color background
- **Click to Switch**: Click any workspace number to switch instantly
- **Real-time Updates**: Automatically detects workspace changes

### Integration Script

The AeroSpace integration uses a custom script that:
1. Monitors AeroSpace workspace changes
2. Updates SketchyBar indicators in real-time
3. Provides visual feedback with themed colors
4. Enables click navigation between workspaces

## System Information Components

### Battery Component
- **Smart Icons**: Different icons for various battery levels
- **Charging Indicator**: Special icon when plugged in
- **Percentage Display**: Shows current battery percentage
- **Power Awareness**: Updates when power source changes

### Clock Component
- **Full Date**: Shows day, month, date
- **12-hour Format**: AM/PM time display
- **Regular Updates**: Updates every 30 seconds

### WiFi Component
- **Network Name**: Shows current SSID when connected
- **Connection Status**: Indicates when WiFi is disconnected
- **Connection Icons**: Visual indicators for WiFi status

### System Stats Component
- **CPU Usage**: Real-time CPU utilization percentage
- **Memory Pressure**: System memory usage indicator
- **Performance Monitoring**: Updates every 5 seconds

## File Structure

SketchyBar creates the following configuration structure:

```
/etc/sketchybar/
├── sketchybarrc           # Main configuration script
├── colors.sh              # Stylix-generated theme colors
└── plugins/
    ├── aerospace.sh       # AeroSpace workspace integration
    ├── battery.sh         # Battery status script
    ├── volume.sh          # Volume control script
    ├── wifi.sh           # WiFi information script
    └── cpu.sh            # System statistics script
```

## Integration with macOS

### Menu Bar Hiding
When SketchyBar is enabled, the native macOS menu bar is automatically hidden to avoid conflicts.

### Hot Corners
Hot corners are disabled by default to prevent conflicts with SketchyBar and AeroSpace.

### Launch Management
SketchyBar is automatically launched via launchd and will restart if it crashes.

## Troubleshooting

### SketchyBar Not Visible
```bash
# Check if SketchyBar is running
pgrep -f sketchybar

# Restart SketchyBar service
launchctl kickstart -k gui/$(id -u)/org.nixos.sketchybar
```

### Theming Issues
```bash
# Check if colors are being generated
cat /etc/sketchybar/colors.sh

# Force reload configuration
/etc/sketchybar/sketchybarrc
```

### AeroSpace Integration
```bash
# Test workspace detection
aerospace list-workspaces --focused

# Check AeroSpace plugin
/etc/sketchybar/plugins/aerospace.sh 1
```

## Advanced Usage

### Custom Components

Add custom components using the `extraConfig` option:

```nix
darwin.sketchybar.extraConfig = ''
  # Add a custom weather component
  sketchybar --add item weather right \
            --set weather \
              icon="🌤" \
              script="curl -s 'wttr.in/YourCity?format=3'" \
              update_freq=1800
'';
```

### Component Positioning

Components are positioned as follows:
- **Left**: AeroSpace workspace indicators (1-10)
- **Right**: System information (CPU, WiFi, Volume, Battery, Clock)

### Styling Customization

All styling is automatically managed by Stylix, but you can override specific aspects:

```nix
darwin.sketchybar.extraConfig = ''
  # Override specific item styling
  sketchybar --set clock background.color=0xff83a598
'';
```

## Integration Benefits

✅ **Unified Design**: Matches your entire themed desktop environment  
✅ **AeroSpace Synergy**: Perfect companion to your tiling window manager  
✅ **Zero Configuration**: Works out of the box with sensible defaults  
✅ **Automatic Theming**: Always matches your current color scheme  
✅ **System Integration**: Native macOS integration and performance  
✅ **Modular Design**: Easy to customize and extend

SketchyBar complements your existing AeroSpace + Stylix setup perfectly, providing a beautiful, functional status bar that feels like a native part of your workflow.