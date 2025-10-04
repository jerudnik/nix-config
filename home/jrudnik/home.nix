{ config, pkgs, lib, inputs, outputs, ... }:

{
  imports = [
    outputs.homeManagerModules.shell
    outputs.homeManagerModules.development
    outputs.homeManagerModules.git
    outputs.homeManagerModules.cli-tools
    outputs.homeManagerModules.spotlight
  ];

  # Home Manager configuration
  home = {
    username = "jrudnik";
    homeDirectory = "/Users/jrudnik";
    stateVersion = "25.05";
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
  
  # Additional packages (moved warp to Homebrew cask)
  # home.packages = with pkgs; [ ];
  
  # Note: nixpkgs config is managed globally via useGlobalPkgs in flake.nix

  # Module configuration
  home = {
    shell = {
      enable = true;
      configPath = "~/nix-config";
      hostName = "parsley";
      # Can add custom aliases here if needed
      aliases = {
        # Example: deploy = "cd ~/projects && ./deploy.sh";
      };
    };
    
    development = {
      enable = true;
      languages = {
        rust = true;
        go = true;
        python = true;
      };
      editor = "micro";
      # Optional: Enable Emacs - it has excellent Stylix theming support!
      emacs = true;    # Emacs with automatic Stylix theming enabled!
      neovim = false;  # Alternative: Neovim with automatic theming
    };
    
    git = {
      enable = true;
      userName = "jrudnik";
      userEmail = "john.rudnik@gmail.com";
    };
    
    cli-tools = {
      enable = true;
      # All modern CLI tools with sensible defaults
      # Includes: eza, bat, ripgrep, fd, zoxide, fzf, starship, alacritty
      
      # Optional: Modern system monitor (btop has beautiful Stylix theming)
      systemMonitor = "btop";  # Options: "none", "htop", "btop"
    };
    
    spotlight = {
      enable = true;
      appsFolder = "Applications/home-manager";  # Home Manager apps folder
      linkSystemApps = true;  # Link system-level nix-darwin apps
      systemAppsFolder = "Applications/nix-darwin";  # System apps folder
      reindexInterval = "daily";  # Periodic reindexing
    };
  };

  # XDG directories
  xdg.enable = true;
  
  # SketchyBar plugin scripts
  xdg.configFile."sketchybar/plugins/aerospace.sh" = {
    text = ''
      #!/bin/bash
      
      WORKSPACE="$1"
      FOCUSED=$(aerospace list-workspaces --focused)
      
      if [ "$WORKSPACE" = "$FOCUSED" ]; then
        sketchybar --set space.$WORKSPACE background.drawing=on background.color=0xff7c6f64
      else
        sketchybar --set space.$WORKSPACE background.drawing=on background.color=0xff32302f
      fi
    '';
    executable = true;
  };
  
  xdg.configFile."sketchybar/plugins/battery.sh" = {
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
      
      sketchybar --set battery icon="$ICON" label="''${PERCENTAGE}%"
    '';
    executable = true;
  };
  
  xdg.configFile."sketchybar/plugins/volume.sh" = {
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
      
      sketchybar --set volume icon="$ICON" label="$LABEL"
    '';
    executable = true;
  };
  
  xdg.configFile."sketchybar/plugins/wifi.sh" = {
    text = ''
      #!/bin/bash
      
      WIFI_DEVICE=$(networksetup -listallhardwareports | grep -A 1 Wi-Fi | tail -n 1 | awk '{print $2}')
      SSID=$(networksetup -getairportnetwork "$WIFI_DEVICE" 2>/dev/null | cut -d":" -f2 | sed 's/^ *//')
      
      if [[ -n "$SSID" && "$SSID" != "You are not associated with an AirPort network." ]]; then
        sketchybar --set wifi icon="󰖩" label="$SSID"
      else
        sketchybar --set wifi icon="󰖪" label="No WiFi"
      fi
    '';
    executable = true;
  };
  
  xdg.configFile."sketchybar/plugins/cpu.sh" = {
    text = ''
      #!/bin/bash
      
      CPU_USAGE=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s/8}')
      MEMORY_PRESSURE=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{print 100-$5}' | cut -d'.' -f1)
      
      sketchybar --set cpu label="$CPU_USAGE% 󰍛 ''${MEMORY_PRESSURE}%"
    '';
    executable = true;
  };
}
