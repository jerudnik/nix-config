# SketchyBar Configuration Module
# Provides a customizable macOS status bar with AeroSpace workspace integration
# 
# SketchyBar is installed system-wide via nix-darwin (per WARP LAW 2 and RULE 4.3)
# This module manages user-specific configuration files and styling

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.sketchybar;
  
  # Stylix integration for automatic theming
  stylixEnabled = config.stylix.enable or false;
  stylixColors = config.lib.stylix.colors or {};
  stylixFonts = config.stylix.fonts or {};
  
  # Helper to convert Stylix colors to SketchyBar format (0xAARRGGBB)
  toSketchyColor = color: alpha: "0x${alpha}${color}";
  
  # Default to Stylix colors if available, otherwise use configured colors
  barColor = if stylixEnabled && stylixColors ? base00
    then toSketchyColor stylixColors.base00 "ff"
    else cfg.colors.bar;
  
  iconColor = if stylixEnabled && stylixColors ? base05
    then toSketchyColor stylixColors.base05 "ff"
    else cfg.colors.icon;
  
  labelColor = if stylixEnabled && stylixColors ? base05
    then toSketchyColor stylixColors.base05 "ff"
    else cfg.colors.label;
  
  workspaceActiveColor = if stylixEnabled && stylixColors ? base08
    then toSketchyColor stylixColors.base08 "ff"
    else cfg.colors.workspaceActive;
  
  workspaceInactiveColor = if stylixEnabled && stylixColors ? base03
    then toSketchyColor stylixColors.base03 "44"
    else cfg.colors.workspaceInactive;
  
  # Use Stylix monospace font if available, otherwise use configured font
  barFont = if stylixEnabled && stylixFonts ? monospace
    then stylixFonts.monospace.name or cfg.font
    else cfg.font;
  
  # Helper to write shell scripts with proper permissions
  mkScript = name: text: pkgs.writeShellScript name text;
in
{
  options.home.sketchybar = {
    enable = mkEnableOption "SketchyBar status bar configuration";
    
    font = mkOption {
      type = types.str;
      default = "SF Pro";
      description = ''
        Font family for SketchyBar (requires Regular, Bold, Semibold, Heavy, and Black variants).
        
        Note: If Stylix is enabled, this will be automatically overridden with the 
        Stylix monospace font (currently: iMWritingMono Nerd Font).
      '';
    };
    
    position = mkOption {
      type = types.enum [ "top" "bottom" "left" "right" ];
      default = "top";
      description = "Position of the status bar on screen";
    };
    
    height = mkOption {
      type = types.int;
      default = 32;
      description = "Height of the status bar in pixels";
    };
    
    cornerRadius = mkOption {
      type = types.int;
      default = 9;
      description = "Corner radius for rounded bar appearance";
    };
    
    aerospace = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable AeroSpace workspace integration";
      };
      
      workspaces = mkOption {
        type = types.listOf types.str;
        default = [ "1" "2" "3" "4" "5" ];
        description = "List of workspace identifiers to display";
      };
    };
    
    colors = {
      bar = mkOption {
        type = types.str;
        default = "0xff1e1e2e";
        description = ''
          Background color of the bar (hex format: 0xAARRGGBB).
          
          Note: If Stylix is enabled, this will be automatically overridden 
          with the Stylix base00 color (background).
        '';
      };
      
      icon = mkOption {
        type = types.str;
        default = "0xffcad3f5";
        description = "Default icon color";
      };
      
      label = mkOption {
        type = types.str;
        default = "0xffcad3f5";
        description = "Default label color";
      };
      
      workspaceActive = mkOption {
        type = types.str;
        default = "0xffed8796";
        description = "Color for active workspace indicator";
      };
      
      workspaceInactive = mkOption {
        type = types.str;
        default = "0x44ffffff";
        description = "Color for inactive workspace background";
      };
    };
    
    showCalendar = mkOption {
      type = types.bool;
      default = true;
      description = "Show date/time widget";
    };
    
    showBattery = mkOption {
      type = types.bool;
      default = true;
      description = "Show battery indicator";
    };
    
    showWifi = mkOption {
      type = types.bool;
      default = false;
      description = "Show WiFi status indicator";
    };
    
    showVolume = mkOption {
      type = types.bool;
      default = false;
      description = "Show volume control widget";
    };
    
    showCpu = mkOption {
      type = types.bool;
      default = false;
      description = "Show CPU usage widget";
    };
  };
  
  config = mkIf cfg.enable {
    # SketchyBar configuration directory structure
    home.file = {
      # Main configuration file
      ".config/sketchybar/sketchybarrc" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          
          # Load colors and icons
          source "$HOME/.config/sketchybar/colors.sh"
          source "$HOME/.config/sketchybar/icons.sh"
          
          ITEM_DIR="$HOME/.config/sketchybar/items"
          PLUGIN_DIR="$HOME/.config/sketchybar/plugins"
          FONT="${barFont}"
          
          PADDINGS=4
          POPUP_BORDER_WIDTH=2
          POPUP_CORNER_RADIUS=11
          SHADOW=on
          
          # Bar appearance
          sketchybar --bar position=${cfg.position}          \
                           height=${toString cfg.height}     \
                           color=$BAR_COLOR                  \
                           shadow=$SHADOW                    \
                           sticky=on                         \
                           padding_right=10                  \
                           padding_left=10                   \
                           corner_radius=0                   \
                           y_offset=0                        \
                           margin=0                          \
                           blur_radius=20                    \
                                                             \
                     --default updates=when_shown            \
                           icon.font="$FONT:Bold:14.0"       \
                           icon.color=$ICON_COLOR            \
                           icon.padding_left=$PADDINGS       \
                           icon.padding_right=$PADDINGS      \
                           label.font="$FONT:Semibold:13.0"  \
                           label.color=$LABEL_COLOR          \
                           label.padding_left=$PADDINGS      \
                           label.padding_right=$PADDINGS     \
                           background.padding_right=$PADDINGS \
                           background.padding_left=$PADDINGS  \
                           popup.background.border_width=$POPUP_BORDER_WIDTH \
                           popup.background.corner_radius=$POPUP_CORNER_RADIUS \
                           popup.background.border_color=$POPUP_BORDER_COLOR \
                           popup.background.color=$POPUP_BACKGROUND_COLOR \
                           popup.background.shadow.drawing=$SHADOW
          
          # Load item configurations
          ${optionalString cfg.aerospace.enable ''
          source "$ITEM_DIR/aerospace.sh"
          ''}
          ${optionalString cfg.showCpu ''
          source "$ITEM_DIR/cpu.sh"
          ''}
          ${optionalString cfg.showWifi ''
          source "$ITEM_DIR/wifi.sh"
          ''}
          ${optionalString cfg.showVolume ''
          source "$ITEM_DIR/volume.sh"
          ''}
          ${optionalString cfg.showBattery ''
          source "$ITEM_DIR/battery.sh"
          ''}
          ${optionalString cfg.showCalendar ''
          source "$ITEM_DIR/calendar.sh"
          ''}
          
          # Finalize setup
          sketchybar --update
          
          echo "SketchyBar configuration loaded"
        '';
      };
      
      # Colors configuration (Stylix-aware)
      ".config/sketchybar/colors.sh" = {
        text = ''
          #!/usr/bin/env bash
          
          # Bar colors (from Stylix or manual config)
          export BAR_COLOR="${barColor}"
          export ICON_COLOR="${iconColor}"
          export LABEL_COLOR="${labelColor}"
          export POPUP_BACKGROUND_COLOR="${if stylixEnabled && stylixColors ? base01 then toSketchyColor stylixColors.base01 "ff" else "0xff24273a"}"
          export POPUP_BORDER_COLOR="${if stylixEnabled && stylixColors ? base0D then toSketchyColor stylixColors.base0D "ff" else "0xff7dc4e4"}"
          
          # Workspace colors (from Stylix or manual config)
          export WORKSPACE_ACTIVE="${workspaceActiveColor}"
          export WORKSPACE_INACTIVE="${workspaceInactiveColor}"
          
          # Additional colors (from Stylix base16 palette or defaults)
          export WHITE="${if stylixEnabled && stylixColors ? base07 then toSketchyColor stylixColors.base07 "ff" else "0xffcad3f5"}"
          export RED="${if stylixEnabled && stylixColors ? base08 then toSketchyColor stylixColors.base08 "ff" else "0xffed8796"}"
          export GREEN="${if stylixEnabled && stylixColors ? base0B then toSketchyColor stylixColors.base0B "ff" else "0xffa6da95"}"
          export BLUE="${if stylixEnabled && stylixColors ? base0D then toSketchyColor stylixColors.base0D "ff" else "0xff8aadf4"}"
          export YELLOW="${if stylixEnabled && stylixColors ? base0A then toSketchyColor stylixColors.base0A "ff" else "0xffeed49f"}"
          export ORANGE="${if stylixEnabled && stylixColors ? base09 then toSketchyColor stylixColors.base09 "ff" else "0xfff5a97f"}"
          export MAGENTA="${if stylixEnabled && stylixColors ? base0E then toSketchyColor stylixColors.base0E "ff" else "0xffc6a0f6"}"
          export GREY="${if stylixEnabled && stylixColors ? base03 then toSketchyColor stylixColors.base03 "ff" else "0xff939ab7"}"
          export TRANSPARENT="0x00000000"
        '';
      };
      
      # Icons configuration
      ".config/sketchybar/icons.sh" = {
        text = ''
          #!/usr/bin/env bash
          
          # Nerd Font icons
          export ICON_APPLE=""
          export ICON_CALENDAR="󰃭"
          export ICON_CLOCK="󰥔"
          export ICON_BATTERY_100="󰁹"
          export ICON_BATTERY_75="󰂁"
          export ICON_BATTERY_50="󰁾"
          export ICON_BATTERY_25="󰁻"
          export ICON_BATTERY_0="󰂎"
          export ICON_BATTERY_CHARGING="󰂄"
          export ICON_WIFI="󰖩"
          export ICON_WIFI_OFF="󰖪"
        '';
      };
      
      # AeroSpace workspace integration
      ".config/sketchybar/items/aerospace.sh" = mkIf cfg.aerospace.enable {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          
          # Create aerospace workspace change event
          sketchybar --add event aerospace_workspace_change
          
          # Add workspace indicators for each configured workspace
          ${concatMapStringsSep "\n" (sid: ''
          sketchybar --add item space.${sid} left \
              --subscribe space.${sid} aerospace_workspace_change \
              --set space.${sid} \
              icon="${sid}" \
              icon.padding_left=10 \
              icon.padding_right=10 \
              icon.highlight_color=$WORKSPACE_ACTIVE \
              background.color=$WORKSPACE_INACTIVE \
              background.corner_radius=5 \
              background.height=24 \
              background.drawing=off \
              label.drawing=off \
              click_script="aerospace workspace ${sid}" \
              script="$PLUGIN_DIR/aerospace_workspace.sh ${sid}"
          '') cfg.aerospace.workspaces}
          
          # Add separator
          sketchybar --add item separator left \
              --set separator \
              icon= \
              icon.font="Hack Nerd Font:Regular:16.0" \
              background.padding_left=10 \
              background.padding_right=10 \
              label.drawing=off \
              icon.color=$WHITE
        '';
      };
      
      # Aerospace workspace plugin
      ".config/sketchybar/plugins/aerospace_workspace.sh" = mkIf cfg.aerospace.enable {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          
          # Highlight active workspace, dim inactive ones
          if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
              sketchybar --set $NAME background.drawing=on
          else
              sketchybar --set $NAME background.drawing=off
          fi
        '';
      };
      
      # Calendar widget with popup menu
      ".config/sketchybar/items/calendar.sh" = mkIf cfg.showCalendar {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          
          # Add padding item before calendar
          sketchybar --add item calendar.padding1 right \
              --set calendar.padding1 width=5 \
              label.drawing=off \
              icon.drawing=off
          
          # Add calendar item with popup
          sketchybar --add item calendar right \
              --subscribe calendar mouse.clicked \
              --set calendar \
              icon=$ICON_CALENDAR \
              icon.padding_left=8 \
              icon.padding_right=0 \
              label.padding_right=8 \
              update_freq=30 \
              script="$PLUGIN_DIR/calendar.sh"
          
          # Add padding item after calendar
          sketchybar --add item calendar.padding2 right \
              --set calendar.padding2 width=5 \
              label.drawing=off \
              icon.drawing=off
          
          # Add bracket around calendar with popup capability
          sketchybar --add bracket calendar_bracket \
              calendar.padding1 \
              calendar \
              calendar.padding2 \
              --set calendar_bracket \
              background.color=$POPUP_BACKGROUND_COLOR \
              background.corner_radius=6 \
              background.height=26 \
              popup.align=center \
              popup.height=140
          
          # Add popup items showing month calendar with full grid (minimal spacing)
          sketchybar --add item calendar.title popup.calendar_bracket \
              --set calendar.title \
              icon.drawing=off \
              icon.padding_left=0 \
              icon.padding_right=0 \
              label.font="$FONT:Bold:14.0" \
              label.padding_left=4 \
              label.padding_right=4 \
              padding_left=0 \
              padding_right=0 \
              y_offset=0 \
              width=250 \
              background.height=22 \
              background.color=$TRANSPARENT \
              background.padding_left=0 \
              background.padding_right=0 \
              label="$(date '+%B %Y')"
          
          # Calendar grid header (Mo Tu We Th Fr Sa Su)
          sketchybar --add item calendar.header popup.calendar_bracket \
              --set calendar.header \
              icon.drawing=off \
              icon.padding_left=0 \
              icon.padding_right=0 \
              label.font="$FONT:Regular:10.0" \
              label.padding_left=4 \
              label.padding_right=4 \
              padding_left=0 \
              padding_right=0 \
              y_offset=0 \
              width=250 \
              background.height=14 \
              background.color=$TRANSPARENT \
              background.padding_left=0 \
              background.padding_right=0 \
              label="Mo Tu We Th Fr Sa Su"
          
          # Calendar grid rows (will be populated by script)
          for i in {1..6}; do
            sketchybar --add item calendar.row$i popup.calendar_bracket \
                --set calendar.row$i \
                icon.drawing=off \
                icon.padding_left=0 \
                icon.padding_right=0 \
                label.font="$FONT:Regular:10.0" \
                label.padding_left=4 \
                label.padding_right=4 \
                padding_left=0 \
                padding_right=0 \
                y_offset=0 \
                width=250 \
                background.height=14 \
                background.color=$TRANSPARENT \
                background.padding_left=0 \
                background.padding_right=0 \
                label=""
          done
          
          # Calendar details popup item
          sketchybar --add item calendar.details popup.calendar_bracket \
              --set calendar.details \
              icon.drawing=off \
              icon.padding_left=0 \
              icon.padding_right=0 \
              label.font="$FONT:Regular:9.0" \
              label.padding_left=4 \
              label.padding_right=4 \
              padding_left=0 \
              padding_right=0 \
              y_offset=0 \
              width=250 \
              background.height=14 \
              background.color=$TRANSPARENT \
              background.padding_left=0 \
              background.padding_right=0 \
              click_script="open -a 'Calendar'" \
              label="Click to open Calendar.app"
        '';
      };
      
      # Calendar plugin with popup toggle and month grid generation
      ".config/sketchybar/plugins/calendar.sh" = mkIf cfg.showCalendar {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          
          # Update the calendar label
          sketchybar --set $NAME label="$(date '+%a %b %d %H:%M')"
          
          # Handle click to toggle popup
          if [ "$SENDER" = "mouse.clicked" ]; then
            sketchybar --set calendar_bracket popup.drawing=toggle
            
            # Update popup content when opened
            sketchybar --set calendar.title label="$(date '+%B %Y')"
            
            # Generate calendar grid
            MONTH=$(date +%m)
            YEAR=$(date +%Y)
            TODAY=$(date +%d | sed 's/^0//')
            
            # Get first day of month (0=Sunday, 1=Monday, etc)
            FIRST_DAY=$(date -j -f "%Y-%m-%d" "$YEAR-$MONTH-01" "+%u")
            # Get number of days in month
            DAYS_IN_MONTH=$(date -j -f "%Y-%m-%d" "$YEAR-$MONTH-01" -v+1m -v-1d "+%d" | sed 's/^0//')
            
            # Build calendar grid
            DAY=1
            for ROW in {1..6}; do
              LINE=""
              for COL in {1..7}; do
                CELL_NUM=$(( ($ROW - 1) * 7 + $COL ))
                
                if [ $CELL_NUM -lt $FIRST_DAY ] || [ $DAY -gt $DAYS_IN_MONTH ]; then
                  LINE="$LINE   "
                else
                  if [ $DAY -eq $TODAY ]; then
                    LINE="$LINE$(printf "%02d*" $DAY)"
                  else
                    LINE="$LINE$(printf "%02d " $DAY)"
                  fi
                  DAY=$((DAY + 1))
                fi
              done
              sketchybar --set calendar.row$ROW label="$LINE"
            done
          fi
        '';
      };
      
      # Battery widget with popup for power management
      ".config/sketchybar/items/battery.sh" = mkIf cfg.showBattery {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          
          # Add padding item before battery
          sketchybar --add item battery.padding1 right \
              --set battery.padding1 width=5 \
              label.drawing=off \
              icon.drawing=off
          
          # Add battery item with popup
          sketchybar --add item battery right \
              --subscribe battery system_woke power_source_change mouse.clicked \
              --set battery \
              update_freq=120 \
              icon.padding_left=8 \
              icon.padding_right=0 \
              label.padding_right=8 \
              script="$PLUGIN_DIR/battery.sh"
          
          # Add padding item after battery
          sketchybar --add item battery.padding2 right \
              --set battery.padding2 width=5 \
              label.drawing=off \
              icon.drawing=off
          
          # Add bracket with popup
          sketchybar --add bracket battery_bracket \
              battery.padding1 \
              battery \
              battery.padding2 \
              --set battery_bracket \
              background.color=$POPUP_BACKGROUND_COLOR \
              background.corner_radius=6 \
              background.height=26 \
              popup.align=center \
              popup.height=85
          
          # Battery status popup items (minimal spacing)
          sketchybar --add item battery.details popup.battery_bracket \
              --set battery.details \
              icon.drawing=off \
              icon.padding_left=0 \
              icon.padding_right=0 \
              label.font="$FONT:Semibold:12.0" \
              label.padding_left=4 \
              label.padding_right=4 \
              padding_left=0 \
              padding_right=0 \
              y_offset=0 \
              width=200 \
              background.height=20 \
              background.color=$TRANSPARENT \
              background.padding_left=0 \
              background.padding_right=0
          
          sketchybar --add item battery.remaining popup.battery_bracket \
              --set battery.remaining \
              icon.drawing=off \
              icon.padding_left=0 \
              icon.padding_right=0 \
              label.font="$FONT:Regular:11.0" \
              label.padding_left=4 \
              label.padding_right=4 \
              padding_left=0 \
              padding_right=0 \
              y_offset=0 \
              width=200 \
              background.height=18 \
              background.color=$TRANSPARENT \
              background.padding_left=0 \
              background.padding_right=0
          
          sketchybar --add item battery.charging popup.battery_bracket \
              --set battery.charging \
              icon.drawing=off \
              icon.padding_left=0 \
              icon.padding_right=0 \
              label.font="$FONT:Regular:11.0" \
              label.padding_left=4 \
              label.padding_right=4 \
              padding_left=0 \
              padding_right=0 \
              y_offset=0 \
              width=200 \
              background.height=18 \
              background.color=$TRANSPARENT \
              background.padding_left=0 \
              background.padding_right=0
          
          sketchybar --add item battery.settings popup.battery_bracket \
              --set battery.settings \
              icon.drawing=off \
              icon.padding_left=0 \
              icon.padding_right=0 \
              label.font="$FONT:Regular:9.0" \
              label="Click to open Battery settings" \
              label.padding_left=4 \
              label.padding_right=4 \
              padding_left=0 \
              padding_right=0 \
              y_offset=0 \
              width=200 \
              background.height=16 \
              background.color=$TRANSPARENT \
              background.padding_left=0 \
              background.padding_right=0 \
              click_script="open /System/Library/PreferencePanes/Battery.prefPane"
        '';
      };
      
      # Battery plugin with popup data
      ".config/sketchybar/plugins/battery.sh" = mkIf cfg.showBattery {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          
          PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
          CHARGING=$(pmset -g batt | grep 'AC Power')
          
          if [ -n "$CHARGING" ]; then
            ICON=$ICON_BATTERY_CHARGING
          elif [ "$PERCENTAGE" -gt 75 ]; then
            ICON=$ICON_BATTERY_100
          elif [ "$PERCENTAGE" -gt 50 ]; then
            ICON=$ICON_BATTERY_75
          elif [ "$PERCENTAGE" -gt 25 ]; then
            ICON=$ICON_BATTERY_50
          elif [ "$PERCENTAGE" -gt 10 ]; then
            ICON=$ICON_BATTERY_25
          else
            ICON=$ICON_BATTERY_0
          fi
          
          sketchybar --set $NAME icon="$ICON" label="''${PERCENTAGE}%"
          
          # Handle click to toggle popup and update details
          if [ "$SENDER" = "mouse.clicked" ]; then
            sketchybar --set battery_bracket popup.drawing=toggle
            
            # Get battery details
            REMAINING=$(pmset -g batt | grep -Eo "\d+:\d+ remaining" || echo "Calculating...")
            CONDITION=$(pmset -g batt | grep -Eo "[0-9]+%" | head -1)
            
            if [ -n "$CHARGING" ]; then
              STATUS="Charging"
            else
              STATUS="On Battery"
            fi
            
            sketchybar --set battery.details label="Battery: ''${PERCENTAGE}%"
            sketchybar --set battery.remaining label="Time: $REMAINING"
            sketchybar --set battery.charging label="Status: $STATUS"
          fi
        '';
      };
      
      # Volume widget with popup slider
      ".config/sketchybar/items/volume.sh" = mkIf cfg.showVolume {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          
          # Add padding item before volume
          sketchybar --add item volume.padding1 right \
              --set volume.padding1 width=5 \
              label.drawing=off \
              icon.drawing=off
          
          # Add volume item with click for popup
          sketchybar --add item volume right \
              --subscribe volume volume_change mouse.clicked \
              --set volume \
              icon.padding_left=8 \
              icon.padding_right=0 \
              label.padding_right=8 \
              script="$PLUGIN_DIR/volume.sh"
          
          # Add padding item after volume
          sketchybar --add item volume.padding2 right \
              --set volume.padding2 width=5 \
              label.drawing=off \
              icon.drawing=off
          
          # Add bracket with popup
          sketchybar --add bracket volume_bracket \
              volume.padding1 \
              volume \
              volume.padding2 \
              --set volume_bracket \
              background.color=$POPUP_BACKGROUND_COLOR \
              background.corner_radius=6 \
              background.height=26 \
              popup.align=center \
              popup.height=75
          
          # Add volume slider in popup
          sketchybar --add slider volume.slider popup.volume_bracket 250 \
              --set volume.slider \
              slider.highlight_color=$BLUE \
              slider.background.height=6 \
              slider.background.corner_radius=3 \
              slider.background.color=$GREY \
              slider.knob.drawing=on \
              slider.knob="󰀁" \
              slider.percentage=50 \
              click_script='osascript -e "set volume output volume $PERCENTAGE"'
        '';
      };
      
      # Volume plugin with popup toggle and slider update
      ".config/sketchybar/plugins/volume.sh" = mkIf cfg.showVolume {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          
          VOLUME=$(osascript -e 'output volume of (get volume settings)')
          MUTED=$(osascript -e 'output muted of (get volume settings)')
          
          if [ "$MUTED" = "true" ]; then
            ICON="󰝟"
          elif [ "$VOLUME" -gt 50 ]; then
            ICON="󰕾"
          elif [ "$VOLUME" -gt 0 ]; then
            ICON="󰖀"
          else
            ICON="󰕿"
          fi
          
          sketchybar --set $NAME icon="$ICON" label="''${VOLUME}%"
          
          # Update slider position
          sketchybar --set volume.slider slider.percentage=$VOLUME
          
          # Handle click to toggle popup
          if [ "$SENDER" = "mouse.clicked" ]; then
            sketchybar --set volume_bracket popup.drawing=toggle
          fi
        '';
      };
      
      # WiFi widget with bracket for padding and click interaction
      ".config/sketchybar/items/wifi.sh" = mkIf cfg.showWifi {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          
          # Create wifi_change event
          sketchybar --add event wifi_change
          
          # Add padding item before wifi
          sketchybar --add item wifi.padding1 right \
              --set wifi.padding1 width=5 \
              label.drawing=off \
              icon.drawing=off
          
          # Add wifi item with event subscription
          sketchybar --add item wifi right \
              --subscribe wifi wifi_change system_woke \
              --set wifi \
              update_freq=10 \
              icon.padding_left=8 \
              icon.padding_right=0 \
              label.padding_right=8 \
              click_script="open /System/Library/PreferencePanes/Network.prefpane" \
              script="$PLUGIN_DIR/wifi.sh"
          
          # Add padding item after wifi
          sketchybar --add item wifi.padding2 right \
              --set wifi.padding2 width=5 \
              label.drawing=off \
              icon.drawing=off
          
          # Add bracket around wifi for visual grouping
          sketchybar --add bracket wifi_bracket \
              wifi.padding1 \
              wifi \
              wifi.padding2 \
              --set wifi_bracket \
              background.color=$POPUP_BACKGROUND_COLOR \
              background.corner_radius=6 \
              background.height=26
        '';
      };
      
      # WiFi plugin (fixed to properly detect connection status)
      ".config/sketchybar/plugins/wifi.sh" = mkIf cfg.showWifi {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          
          # Check if we have an IP address (more reliable than SSID check)
          IP=$(ipconfig getifaddr en0 2>/dev/null)
          
          if [ -n "$IP" ]; then
            # Connected - get SSID
            SSID=$(networksetup -getairportnetwork en0 | awk -F': ' '{print $2}')
            if [ "$SSID" != "" ] && [ "$SSID" != "You are not associated with an AirPort network." ]; then
              ICON=$ICON_WIFI
              LABEL="$SSID"
            else
              # Has IP but can't get SSID (unusual, but possible)
              ICON=$ICON_WIFI
              LABEL="Connected"
            fi
          else
            # No IP address - disconnected
            ICON=$ICON_WIFI_OFF
            LABEL="Disconnected"
          fi
          
          sketchybar --set $NAME icon="$ICON" label="$LABEL"
        '';
      };
      
      # CPU widget with bracket for padding
      ".config/sketchybar/items/cpu.sh" = mkIf cfg.showCpu {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          
          # Add padding item before cpu
          sketchybar --add item cpu.padding1 right \
              --set cpu.padding1 width=5 \
              label.drawing=off \
              icon.drawing=off
          
          # Add cpu item
          sketchybar --add item cpu right \
              --set cpu \
              update_freq=2 \
              icon="󰻠" \
              icon.padding_left=8 \
              icon.padding_right=0 \
              label.padding_right=8 \
              click_script="open -a 'Activity Monitor'" \
              script="$PLUGIN_DIR/cpu.sh"
          
          # Add padding item after cpu
          sketchybar --add item cpu.padding2 right \
              --set cpu.padding2 width=5 \
              label.drawing=off \
              icon.drawing=off
          
          # Add bracket around cpu for visual grouping
          sketchybar --add bracket cpu_bracket \
              cpu.padding1 \
              cpu \
              cpu.padding2 \
              --set cpu_bracket \
              background.color=$POPUP_BACKGROUND_COLOR \
              background.corner_radius=6 \
              background.height=26
        '';
      };
      
      # CPU plugin
      ".config/sketchybar/plugins/cpu.sh" = mkIf cfg.showCpu {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          
          CPU_USAGE=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s}')
          
          sketchybar --set $NAME label="''${CPU_USAGE}%"
        '';
      };
    };
    
    # LaunchAgent to auto-start SketchyBar
    launchd.agents.sketchybar = {
      enable = true;
      config = {
        ProgramArguments = [ "${pkgs.sketchybar}/bin/sketchybar" ];
        KeepAlive = true;
        RunAtLoad = true;
        ProcessType = "Interactive";
        EnvironmentVariables = {
          PATH = "${pkgs.sketchybar}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        };
      };
    };
  };
}
