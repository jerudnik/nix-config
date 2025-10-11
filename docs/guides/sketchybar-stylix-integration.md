# SketchyBar + Stylix Integration

## Overview

SketchyBar is now fully integrated with Stylix for automatic theming! This means your status bar will automatically match your system theme and use your configured fonts.

## How It Works

### Automatic Font Integration

When Stylix is enabled, SketchyBar automatically uses:
- **Monospace font**: `iMWritingMono Nerd Font` (from Stylix configuration)

The font is pulled directly from your Stylix configuration in `modules/darwin/theming/default.nix`.

### Automatic Color Integration

SketchyBar maps Stylix's base16 color palette to its components:

| SketchyBar Element | Stylix Color | Purpose |
|-------------------|--------------|---------|
| Bar background | `base00` | Main background |
| Icons | `base05` | Foreground text |
| Labels | `base05` | Foreground text |
| Workspace active | `base08` | Red accent (active highlight) |
| Workspace inactive | `base03` | Subtle gray (inactive) |
| Popup background | `base01` | Elevated surface |
| Popup border | `base0D` | Blue accent |
| WHITE | `base07` | Bright foreground |
| RED | `base08` | Red accent |
| GREEN | `base0B` | Green accent |
| BLUE | `base0D` | Blue accent |
| YELLOW | `base0A` | Yellow accent |
| ORANGE | `base09` | Orange accent |
| MAGENTA | `base0E` | Magenta accent |
| GREY | `base03` | Dark gray |

### Current Theme: Gruvbox Material Dark Medium

With your current configuration, SketchyBar displays:
- **Bar color**: `0xff292828` (Gruvbox dark background)
- **Text color**: `0xffddc7a1` (Gruvbox light foreground)
- **Active workspace**: `0xffea6962` (Gruvbox red)
- **Inactive workspace**: `0x44665c54` (Semi-transparent Gruvbox gray)

## Verification

Check your current SketchyBar colors:

```bash
# View color configuration
cat ~/.config/sketchybar/colors.sh

# View font configuration
grep "^FONT=" ~/.config/sketchybar/sketchybarrc
```

Expected output:
```bash
FONT="iMWritingMono Nerd Font"
```

## Changing Themes

SketchyBar will automatically update when you change your system theme!

### Example: Switch to Catppuccin Mocha

Edit `hosts/parsley/configuration.nix`:

```nix
darwin.theming = {
  enable = true;
  colorScheme = "catppuccin-mocha";  # Change from gruvbox-material-dark-medium
  polarity = "either";
};
```

Then rebuild:
```bash
nrb
```

SketchyBar will automatically use the new Catppuccin colors!

### Example: Switch to Tokyo Night

```nix
darwin.theming = {
  enable = true;
  colorScheme = "tokyo-night-storm";
  polarity = "either";
};
```

### Example: Light Mode

```nix
darwin.theming = {
  enable = true;
  colorScheme = "gruvbox-material-light-medium";
  polarity = "light";
};
```

SketchyBar will update with light theme colors automatically.

## Manual Color Override (Optional)

If you want to override specific colors while keeping Stylix integration for others, you can set them in `home/jrudnik/home.nix`:

```nix
sketchybar = {
  enable = true;
  # ... other options ...
  
  # These colors will be used if Stylix is disabled
  # When Stylix is enabled, these are overridden automatically
  colors = {
    bar = "0xff000000";  # Pure black (only used if Stylix disabled)
    # ... other colors ...
  };
};
```

## Font Customization

The font is automatically pulled from Stylix's monospace font configuration:

**Current configuration** (in `modules/darwin/theming/default.nix`):
```nix
fonts = {
  monospace = {
    name = "iMWritingMono Nerd Font";
  };
};
```

To change the font globally (affects SketchyBar and all other Stylix targets):

```nix
darwin.theming = {
  enable = true;
  fonts = {
    monospace = {
      name = "JetBrainsMono Nerd Font";  # Change to different font
    };
  };
};
```

This will update:
- SketchyBar
- Alacritty
- Neovim
- All other Stylix-themed applications

## Disabling Stylix Integration

If you want SketchyBar to use manual colors instead of Stylix:

1. Keep Stylix enabled for other apps
2. Set specific colors in your SketchyBar config
3. The module will detect that Stylix colors should be overridden

Currently, SketchyBar will always prefer Stylix colors when available. To add a disable option, you would need to add an option like:

```nix
sketchybar = {
  useStylix = false;  # Future option to disable Stylix integration
};
```

## Color Format Reference

SketchyBar uses hex colors in the format: `0xAARRGGBB`
- `AA`: Alpha (transparency) - `ff` = opaque, `44` = semi-transparent
- `RR`: Red component
- `GG`: Green component
- `BB`: Blue component

Stylix base16 colors are automatically converted to this format.

## Benefits of Integration

1. **Consistency**: Status bar matches your terminal, editor, and other apps
2. **Easy theme switching**: Change theme once, updates everywhere
3. **Font consistency**: Same monospace font across all applications
4. **Automatic updates**: No need to manually update SketchyBar colors
5. **Light/dark mode**: Automatically follows your system appearance

## Implementation Details

**Location**: `modules/home/desktop/sketchybar/default.nix`

The integration works by:
1. Detecting if Stylix is enabled: `config.stylix.enable`
2. Reading Stylix colors: `config.lib.stylix.colors`
3. Reading Stylix fonts: `config.stylix.fonts`
4. Converting base16 colors to SketchyBar format
5. Injecting into configuration files during build

Key code:
```nix
# Detect Stylix
stylixEnabled = config.stylix.enable or false;

# Use Stylix colors if available
barColor = if stylixEnabled && stylixColors ? base00
  then toSketchyColor stylixColors.base00 "ff"
  else cfg.colors.bar;

# Use Stylix font if available
barFont = if stylixEnabled && stylixFonts ? monospace
  then stylixFonts.monospace.name or cfg.font
  else cfg.font;
```

## Available Color Schemes

Your system supports these themes (all work with SketchyBar):

**Gruvbox variants:**
- gruvbox-material-dark-medium ← Current
- gruvbox-material-light-medium
- gruvbox-dark-hard / soft / medium
- gruvbox-light-hard / soft / medium

**Catppuccin variants:**
- catppuccin-mocha (dark)
- catppuccin-macchiato (dark)
- catppuccin-frappe (dark)
- catppuccin-latte (light)

**Tokyo Night variants:**
- tokyo-night / tokyo-night-dark
- tokyo-night-storm
- tokyo-night-light

**Other popular themes:**
- nord (cool blue-gray)
- dracula (purple-pink)
- rose-pine / rose-pine-moon / rose-pine-dawn
- kanagawa (warm traditional Japanese)
- everforest (green forest)
- solarized-dark / solarized-light

All themes listed in `modules/darwin/theming/default.nix`.

## Testing Theme Changes

1. **Edit theme**:
   ```bash
   # Edit hosts/parsley/configuration.nix
   # Change darwin.theming.colorScheme
   ```

2. **Rebuild**:
   ```bash
   nrb  # Build and switch
   ```

3. **View new colors**:
   ```bash
   cat ~/.config/sketchybar/colors.sh
   ```

4. **Restart SketchyBar** (if needed):
   ```bash
   launchctl kickstart -k gui/$(id -u)/org.nix-community.home.sketchybar
   ```

## Troubleshooting

### Colors not updating

```bash
# 1. Check if Stylix is enabled
nix eval ~/.config/nixpkgs\#darwinConfigurations.parsley.config.darwin.theming.enable

# 2. Rebuild
nrb

# 3. Restart SketchyBar
launchctl kickstart -k gui/$(id -u)/org.nix-community.home.sketchybar
```

### Font not changing

```bash
# Check current font
grep "^FONT=" ~/.config/sketchybar/sketchybarrc

# Rebuild and restart
nrb
launchctl kickstart -k gui/$(id -u)/org.nix-community.home.sketchybar
```

### Want manual colors

Currently, Stylix colors always override manual colors when Stylix is enabled. This ensures consistency across all applications.

## Related Documentation

- Main SketchyBar guide: `docs/guides/sketchybar-setup.md`
- Enhancement details: `docs/guides/sketchybar-enhancements.md`
- Stylix documentation: https://stylix.danth.me/
- Base16 color scheme reference: https://github.com/chriskempson/base16

## Architecture Compliance

✅ **LAW 9**: Intelligent home-manager configuration
- Proper detection of Stylix state
- Graceful fallback to manual colors
- No breaking changes to existing configuration

✅ **LAW 2**: Proper separation of concerns
- Theming defined at system level (nix-darwin)
- Applied at user level (home-manager)
- SketchyBar reads from Stylix, doesn't duplicate config
