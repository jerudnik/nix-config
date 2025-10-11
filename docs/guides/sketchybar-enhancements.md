# SketchyBar Menu Bar Replacement - Implementation Summary

## Changes Made

### 1. macOS Menu Bar Auto-Hide

**File**: `hosts/parsley/configuration.nix`

```nix
appearance = {
  hideMenuBar = true;  # Hide macOS menu bar (using SketchyBar instead)
};
```

- Native macOS menu bar now auto-hides
- Press **Fn key** or move cursor to top edge to reveal temporarily
- SketchyBar takes its place at the top

### 2. SketchyBar Repositioning

**File**: `modules/home/desktop/sketchybar/default.nix`

Changes:
- **Corner radius**: 9 → 0 (square edges, flush with screen)
- **Y offset**: 5 → 0 (no gap from top)
- **Margin**: 5 → 0 (no side margins)
- **Position**: Already at top, now flush with screen edge

Result: SketchyBar sits exactly where the macOS menu bar was, looking like a native menu bar.

### 3. AeroSpace Gap Adjustment

**File**: `modules/home/window-manager/aerospace.nix`

```nix
[gaps]
outer.top = 32  # Space for SketchyBar at top (replaces macOS menu bar)
```

- Windows now have 32px top gap to avoid overlapping with SketchyBar
- Other gaps (left, right, bottom) remain at 8px for clean window spacing

### 4. New Widgets Added

**File**: `home/jrudnik/home.nix`

Enabled three new widgets:
- `showWifi = true;` - WiFi connection status and SSID
- `showVolume = true;` - System volume control (clickable)
- `showCpu = true;` - CPU usage monitoring

**File**: `modules/home/desktop/sketchybar/default.nix`

Created new widget items and plugins:

#### CPU Widget
- Shows total CPU usage as percentage
- Updates every 2 seconds
- Uses `ps` command to calculate system-wide CPU usage
- Icon: 󰻠 (processor symbol)

#### WiFi Widget
- Shows current WiFi network name (SSID)
- Displays "Disconnected" when offline
- Updates every 10 seconds
- Uses `networksetup` to get WiFi status
- Icons: 󰖩 (connected), 󰖪 (disconnected)

#### Volume Widget
- Shows current system volume percentage
- Icon changes based on volume level:
  - 󰝟 (muted)
  - 󰕿 (low)
  - 󰖀 (medium)
  - 󰕾 (high)
- **Interactive**: Click to increase volume by 10%
- Updates every second
- Uses AppleScript to get/set volume

## Widget Layout

```
┌─────────────────────────────────────────────────────────────────────┐
│ [1][2][3][4][5] │      [CPU][WiFi][Volume][Battery][Date/Time]    │
│  Workspaces     │                Status Widgets                     │
└─────────────────────────────────────────────────────────────────────┘
```

**Left Side**:
- Workspace indicators (1-5)
- Separator line

**Right Side** (in order):
1. CPU usage (e.g., "45%")
2. WiFi status (e.g., "MyNetwork")
3. Volume (e.g., "75%")
4. Battery (e.g., "100%")
5. Date/Time (e.g., "Mon Jan 01 12:00")

## Configuration Example

Your current configuration in `home/jrudnik/home.nix`:

```nix
sketchybar = {
  enable = true;
  position = "top";  # Replace macOS menu bar
  height = 32;  # Standard menu bar height
  font = "SF Pro";  # System font, clean and modern
  
  # AeroSpace workspace integration
  aerospace = {
    enable = true;
    workspaces = [ "1" "2" "3" "4" "5" ];
  };
  
  # Widget configuration
  showCalendar = true;   # Date/time widget
  showBattery = true;    # Battery indicator
  showWifi = true;       # WiFi status
  showVolume = true;     # Volume control
  showCpu = true;        # CPU usage
  
  # Color scheme
  colors = {
    bar = "0xff1e1e2e";  # Semi-transparent dark background
    icon = "0xffcad3f5";  # Light icon color
    label = "0xffcad3f5";  # Light label color
    workspaceActive = "0xffed8796";  # Highlight color for active workspace
    workspaceInactive = "0x44ffffff";  # Subtle inactive workspace background
  };
};
```

## Interactive Features (New!)

### Clickable Widgets

All widgets now support click interactions for quick access to system settings:

| Widget | Click Action | Opens |
|--------|-------------|-------|
| **Workspaces** | Switch workspace | `aerospace workspace <id>` |
| **Calendar** | Open Calendar app | Calendar.app |
| **Battery** | Battery settings | System Settings > Battery |
| **Volume** | Sound settings | System Settings > Sound |
| **WiFi** | Network settings | System Settings > Network |
| **CPU** | Activity Monitor | Activity Monitor.app |

Examples:
- Click **Calendar** widget → Calendar app opens showing current month
- Click **Battery** widget → System Settings opens to Battery pane
- Click **Volume** widget → System Settings opens to Sound pane
- Click **WiFi** widget → System Settings opens to Network pane
- Click **CPU** widget → Activity Monitor opens to view processes
- Click any **workspace number** → Instantly switch to that workspace

### Visual Enhancement: Widget Brackets

Each widget now has:
- **Subtle background** (matches Stylix theme)
- **Rounded corners** (6px radius)
- **Padding** on both sides (5px each)
- **Consistent height** (26px)

This creates visual separation between widgets, similar to modern status bar designs.

**Before:**
```
│ [Calendar: Mon Jan 01 12:00][Battery: 100%][WiFi: MyNetwork] │
                    ↓
```

**After:**
```
│ [  Calendar: Mon Jan 01 12:00  ] [  Battery: 100%  ] [  WiFi: MyNetwork  ] │
    └─ Background + padding ─┘       └─ Each widget separated ─┘
```

### Fixed: WiFi Status Detection

**Problem:** WiFi widget sometimes showed "Disconnected" even when connected.

**Solution:** Now checks for an actual IP address instead of just SSID:

```bash
# Old method (unreliable):
SSID=$(networksetup -getairportnetwork en0)
# Could return empty even when connected

# New method (reliable):
IP=$(ipconfig getifaddr en0 2>/dev/null)
if [ -n "$IP" ]; then
  # Has IP = truly connected
  SSID=$(networksetup -getairportnetwork en0)
else
  # No IP = truly disconnected
fi
```

The widget now:
1. Checks for IP address first (reliable indicator)
2. Only shows "Disconnected" when truly offline
3. Displays SSID when connected
4. Subscribes to `wifi_change` and `system_woke` events
5. Updates automatically after sleep/wake

## Benefits

1. **Clean Workspace**: No duplicate menu bars cluttering the screen
2. **More Screen Real Estate**: Auto-hidden native menu bar when not needed
3. **Better Integration**: SketchyBar matches your aesthetic and shows relevant info
4. **Workspace Awareness**: Always visible workspace indicators
5. **System Monitoring**: At-a-glance CPU, WiFi, volume, battery status
6. **🆕 Fully Interactive**: All widgets respond to clicks for quick actions
7. **🆕 Visual Polish**: Bracketed widgets with padding and backgrounds
8. **🆕 Reliable WiFi**: Fixed detection shows accurate connection status
9. **Seamless**: Windows respect the status bar location (32px top gap)

## Customization

All widgets can be toggled individually:

```nix
# Minimal setup (workspaces + time only)
showCalendar = true;
showBattery = false;
showWifi = false;
showVolume = false;
showCpu = false;

# Power user setup (all widgets)
showCalendar = true;
showBattery = true;
showWifi = true;
showVolume = true;
showCpu = true;
```

## Access Native Menu Bar

When you need the native macOS menu bar:
- Press **Fn** key
- Move cursor to top edge of screen
- Menu bar will slide down temporarily
- Slides back up when cursor moves away

## Testing

Verify everything is working:

```bash
# Check SketchyBar is running
pgrep sketchybar

# View all widgets
sketchybar --query bar | jq '.items'

# Check menu bar auto-hide setting
defaults read NSGlobalDomain _HIHideMenuBar  # Should output: 1

# Check AeroSpace top gap
grep "outer.top" ~/.aerospace.toml  # Should show: 32

# Restart SketchyBar to see changes
launchctl kickstart -k gui/$(id -u)/org.nix-community.home.sketchybar
```

## Files Modified

1. `hosts/parsley/configuration.nix` - Menu bar auto-hide
2. `home/jrudnik/home.nix` - Widget enablement
3. `modules/home/desktop/sketchybar/default.nix` - Widget implementation
4. `modules/home/window-manager/aerospace.nix` - Top gap adjustment
5. `docs/guides/sketchybar-setup.md` - Updated documentation

## Architecture Compliance

All changes follow WARP laws:

- **LAW 2**: Proper separation (system vs user config) ✅
- **LAW 5.4**: Menu bar setting in `system-settings/appearance.nix` (correct NSGlobalDomain location) ✅
- **LAW 9**: Intelligent home-manager config with proper module structure ✅

## Next Steps

1. Use your system normally - SketchyBar should be visible at top
2. Switch workspaces (Alt+1, Alt+2, etc.) - indicators should update
3. Press Fn key - native menu bar should slide down temporarily
4. Customize colors/widgets to your preference
5. Consider adding more custom widgets if needed (see SketchyBar docs)

## Troubleshooting

### Menu bar still visible
```bash
# Force apply menu bar hide setting
defaults write NSGlobalDomain _HIHideMenuBar -bool true
killall SystemUIServer
```

### Windows overlap SketchyBar
```bash
# Check AeroSpace gap
grep "outer.top" ~/.aerospace.toml
# Should be: outer.top = 32

# Reload AeroSpace config
aerospace reload-config
```

### Widget not showing
```bash
# Check which widgets are loaded
sketchybar --query bar | jq '.items'

# Restart SketchyBar
launchctl kickstart -k gui/$(id -u)/org.nix-community.home.sketchybar
```

## References

- Main guide: `docs/guides/sketchybar-setup.md`
- SketchyBar docs: https://felixkratz.github.io/SketchyBar/
- AeroSpace docs: https://nikitabobko.github.io/AeroSpace/guide
