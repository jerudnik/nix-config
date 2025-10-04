{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.darwin.sketchybar;
in {
  imports = [
    ./theme.nix  # Stylix theme integration
  ];
  options.darwin.sketchybar = {
    enable = mkEnableOption "SketchyBar - highly customizable macOS status bar";
    
    position = mkOption {
      type = types.enum [ "top" "bottom" ];
      default = "top";
      description = "Position of the status bar";
    };
    
    height = mkOption {
      type = types.int;
      default = 32;
      description = "Height of the status bar in pixels";
    };
    
    margin = mkOption {
      type = types.int;
      default = 0;
      description = "Margin around the status bar";
    };
    
    cornerRadius = mkOption {
      type = types.int;
      default = 9;
      description = "Corner radius for the status bar";
    };
    
    shadow = mkEnableOption "Drop shadow for the status bar" // { default = true; };
    
    blur = mkEnableOption "Background blur effect" // { default = true; };
    
    topmost = mkEnableOption "Keep bar above all other windows" // { default = true; };
    
    components = {
      clock = mkEnableOption "Clock component" // { default = true; };
      battery = mkEnableOption "Battery component" // { default = true; };
      wifi = mkEnableOption "WiFi component" // { default = true; };
      volume = mkEnableOption "Volume component" // { default = true; };
      workspaces = mkEnableOption "AeroSpace workspace indicators" // { default = true; };
      systemStats = mkEnableOption "CPU/Memory usage" // { default = true; };
    };
    
    # Allow custom configuration override
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional SketchyBar configuration";
      example = ''
        sketchybar --add item my_item right \
                  --set my_item label="Custom"
      '';
    };
    
    package = mkOption {
      type = types.package;
      default = pkgs.sketchybar;
      description = "SketchyBar package to use";
    };
  };

  config = mkIf cfg.enable {
    # Install SketchyBar and required fonts
    environment.systemPackages = with pkgs; [
      cfg.package
    ];

    # Create SketchyBar configuration directory and files
    environment.etc."sketchybar/sketchybarrc" = {
      text = ''
        #!/bin/bash
        
        # This is a basic SketchyBar configuration
        # Colors will be automatically managed by Stylix theming system
        
        # Source Stylix-generated colors
        source /etc/sketchybar/colors.sh
        
        # Remove all existing items
        ${cfg.package}/bin/sketchybar --remove '/.*/'
        
        # Global bar settings
        ${cfg.package}/bin/sketchybar --bar \
          height=${toString cfg.height} \
          position=${cfg.position} \
          margin=${toString cfg.margin} \
          corner_radius=${toString cfg.cornerRadius} \
          y_offset=0 \
          drawing=on \
          ${optionalString cfg.topmost "topmost=on"} \
          ${optionalString cfg.shadow "shadow=on"} \
          ${optionalString cfg.blur "blur_radius=20"}
        
        # Default item settings with Nerd Font support
        ${cfg.package}/bin/sketchybar --default \
          icon.font="FiraCode Nerd Font Mono:Regular:16.0" \
          label.font="SF Pro:Semibold:13.0" \
          padding_left=5 \
          padding_right=5
        
        ${optionalString cfg.components.workspaces ''
        # AeroSpace workspace indicators
        for i in {1..10}; do
          ${cfg.package}/bin/sketchybar --add item space.$i left \
                    --set space.$i \
                      associated_display=1 \
                      icon="$i" \
                      click_script="${pkgs.aerospace}/bin/aerospace workspace $i" \
                      script="/bin/bash /etc/sketchybar/plugins/aerospace.sh $i"
        done
        
        # Subscribe all workspace items to aerospace events
        # This ensures they update when workspaces change
        ${cfg.package}/bin/sketchybar --add event aerospace_workspace_change
        for i in {1..10}; do
          ${cfg.package}/bin/sketchybar --subscribe space.$i aerospace_workspace_change
        done
        ''}
        
        ${optionalString cfg.components.clock ''
        # Clock
        ${cfg.package}/bin/sketchybar --add item clock right \
                  --set clock \
                    icon=" " \
                    script="date '+%a %b %d  %I:%M %p'" \
                    update_freq=30
        ''}
        
        ${optionalString cfg.components.battery ''
        # Battery
        ${cfg.package}/bin/sketchybar --add item battery right \
                  --set battery \
                    script="/bin/bash /etc/sketchybar/plugins/battery.sh" \
                    update_freq=120
        
        ${cfg.package}/bin/sketchybar --subscribe battery system_woke power_source_change
        ''}
        
        ${optionalString cfg.components.volume ''
        # Volume
        ${cfg.package}/bin/sketchybar --add item volume right \
                  --set volume \
                    script="/bin/bash /etc/sketchybar/plugins/volume.sh"
        
        ${cfg.package}/bin/sketchybar --subscribe volume volume_change
        ''}
        
        ${optionalString cfg.components.wifi ''
        # WiFi
        ${cfg.package}/bin/sketchybar --add item wifi right \
                  --set wifi \
                    script="/bin/bash /etc/sketchybar/plugins/wifi.sh" \
                    update_freq=10
        ''}
        
        ${optionalString cfg.components.systemStats ''
        # System stats
        ${cfg.package}/bin/sketchybar --add item cpu right \
                  --set cpu \
                    icon=" " \
                    script="/bin/bash /etc/sketchybar/plugins/cpu.sh" \
                    update_freq=5
        ''}
        
        # Custom configuration
        ${cfg.extraConfig}
        
        # Force all scripts to run the first time (optional)
        ${cfg.package}/bin/sketchybar --update
      '';
    };

    # Create plugin directory and scripts
    environment.etc."sketchybar/plugins/aerospace.sh" = {
      text = ''
        #!/bin/bash
        
        # AeroSpace workspace indicator script
        WORKSPACE="$1"
        FOCUSED=$(${pkgs.aerospace}/bin/aerospace list-workspaces --focused)
        
        if [ "$WORKSPACE" = "$FOCUSED" ]; then
          ${cfg.package}/bin/sketchybar --set space.$WORKSPACE background.drawing=on
        else
          ${cfg.package}/bin/sketchybar --set space.$WORKSPACE background.drawing=off
        fi
      '';
    };

    environment.etc."sketchybar/plugins/battery.sh" = {
      text = ''
        #!/bin/bash
        
        PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
        CHARGING=$(pmset -g batt | grep 'AC Power')
        
        if [[ $PERCENTAGE -ge 90 ]]; then
          ICON="󰁹"
        elif [[ $PERCENTAGE -ge 80 ]]; then
          ICON="󰂂"
        elif [[ $PERCENTAGE -ge 70 ]]; then
          ICON="󰂁"
        elif [[ $PERCENTAGE -ge 60 ]]; then
          ICON="󰂀"
        elif [[ $PERCENTAGE -ge 50 ]]; then
          ICON="󰁿"
        elif [[ $PERCENTAGE -ge 40 ]]; then
          ICON="󰁾"
        elif [[ $PERCENTAGE -ge 30 ]]; then
          ICON="󰁽"
        elif [[ $PERCENTAGE -ge 20 ]]; then
          ICON="󰁼"
        else
          ICON="󰁺"
        fi
        
        if [[ $CHARGING != "" ]]; then
          ICON="󰂄"
        fi
        
        ${cfg.package}/bin/sketchybar --set battery icon="$ICON" label="''${PERCENTAGE}%"
      '';
    };

    environment.etc."sketchybar/plugins/volume.sh" = {
      text = ''
        #!/bin/bash
        
        VOLUME=$(osascript -e "output volume of (get volume settings)")
        MUTED=$(osascript -e "output muted of (get volume settings)")
        
        if [[ $MUTED == "true" ]]; then
          ICON="󰸈"
          LABEL="Muted"
        else
          case $((($VOLUME + 12) / 25)) in
            [4-9]) ICON="󰕾" ;;
            [1-3]) ICON="󰖀" ;;
            *) ICON="󰕿" ;;
          esac
          LABEL="''${VOLUME}%"
        fi
        
        ${cfg.package}/bin/sketchybar --set volume icon="$ICON" label="$LABEL"
      '';
    };

    environment.etc."sketchybar/plugins/wifi.sh" = {
      text = ''
        #!/bin/bash
        
        # Get WiFi info using networksetup (more reliable)
        WIFI_DEVICE=$(networksetup -listallhardwareports | grep -A 1 Wi-Fi | tail -n 1 | awk '{print $2}')
        SSID=$(networksetup -getairportnetwork "$WIFI_DEVICE" 2>/dev/null | cut -d":" -f2 | sed 's/^ *//')
        
        if [[ -n "$SSID" && "$SSID" != "You are not associated with an AirPort network." ]]; then
          ${cfg.package}/bin/sketchybar --set wifi icon="󰖩" label="$SSID"
        else
          ${cfg.package}/bin/sketchybar --set wifi icon="󰖪" label="No WiFi"
        fi
      '';
    };

    environment.etc."sketchybar/plugins/cpu.sh" = {
      text = ''
        #!/bin/bash
        
        CPU_USAGE=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s/8}')
        MEMORY_PRESSURE=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{print 100-$5}' | cut -d'.' -f1)
        
        ${cfg.package}/bin/sketchybar --set cpu label="$CPU_USAGE% 󰍛 ''${MEMORY_PRESSURE}%"
      '';
    };
    
    # Create startup wrapper script
    environment.etc."sketchybar/start.sh" = {
      text = ''
        #!/bin/bash
        # Start SketchyBar and wait for it to initialize
        ${cfg.package}/bin/sketchybar &
        SKETCHYBAR_PID=$!
        
        # Wait for sketchybar to be ready
        sleep 2
        
        # Load configuration
        /bin/bash /etc/sketchybar/sketchybarrc
        
        # Keep script alive so launchd thinks service is running
        wait $SKETCHYBAR_PID
      '';
    };
    
    # Make SketchyBar scripts executable
    system.activationScripts.sketchybarScripts.text = ''
      chmod +x /etc/sketchybar/sketchybarrc
      chmod +x /etc/sketchybar/start.sh
      chmod +x /etc/sketchybar/plugins/aerospace.sh
      chmod +x /etc/sketchybar/plugins/battery.sh
      chmod +x /etc/sketchybar/plugins/volume.sh
      chmod +x /etc/sketchybar/plugins/wifi.sh
      chmod +x /etc/sketchybar/plugins/cpu.sh
    '';

    # Launch SketchyBar automatically with configuration
    launchd.user.agents.sketchybar = {
      serviceConfig = {
        ProgramArguments = [ "/bin/bash" "/etc/sketchybar/start.sh" ];
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/tmp/sketchybar.out.log";
        StandardErrorPath = "/tmp/sketchybar.err.log";
        ProcessType = "Interactive";
      };
    };

    # Hide native macOS menu bar when using SketchyBar
    system.defaults.NSGlobalDomain._HIHideMenuBar = true;
    
    # Disable hot corners to avoid conflicts
    system.defaults.dock.wvous-bl-corner = mkDefault 1; # Disabled
    system.defaults.dock.wvous-br-corner = mkDefault 1; # Disabled
    system.defaults.dock.wvous-tl-corner = mkDefault 1; # Disabled  
    system.defaults.dock.wvous-tr-corner = mkDefault 1; # Disabled
  };
}