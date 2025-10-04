{ config, pkgs, lib, inputs, outputs, ... }:

{
  imports = [
    outputs.darwinModules.core
    outputs.darwinModules.security
    outputs.darwinModules.nix-settings
    outputs.darwinModules.system-defaults
    outputs.darwinModules.keyboard
    outputs.darwinModules.homebrew
    outputs.darwinModules.window-manager
    outputs.darwinModules.theming
    outputs.darwinModules.fonts
    # outputs.darwinModules.sketchybar  # Removed - using nix-darwin service
  ];

  # Host identification
  networking = {
    hostName = "parsley";
    computerName = "parsley";
    localHostName = "parsley";
  };

  # Module configuration
  darwin = {
    core.enable = true;
    
    security = {
      enable = true;
      primaryUser = "jrudnik";
      touchIdForSudo = true;
    };
    
    nix-settings = {
      enable = true;
      trustedUsers = [ "jrudnik" ];
    };
    
    system-defaults = {
      enable = true;
      # Hide macOS menu bar since we're using SketchyBar
      globalDomain.hideMenuBar = true;
      # All other settings use module defaults, can override here if needed
    };
    
    keyboard = {
      enable = true;
      # remapCapsLockToControl = true (default)
    };
    
    homebrew = {
      enable = true;
      # Homebrew casks
      casks = [ "warp" ];
    };
    
    window-manager = {
      enable = true;
      # Uses default AeroSpace configuration with Alt-based bindings
    };
    
    theming = {
      enable = true;
      # Uses Gruvbox Material with auto light/dark switching
      colorScheme = "gruvbox-material-dark-medium";
      polarity = "either"; # Allows automatic light/dark switching
      
      # Optional: Set a wallpaper to generate colors from
      # wallpaper = ./wallpapers/your-wallpaper.jpg;
      
      # Easy color scheme alternatives to try:
      # colorScheme = "gruvbox-material-light-medium";  # Light version
      # colorScheme = "catppuccin-mocha";               # Purple theme
      # colorScheme = "tokyo-night-dark";               # Blue theme  
      # colorScheme = "nord";                           # Cool gray theme
    };
    
    fonts = {
      enable = true;
      # iA Writer fonts enabled by default
      # Charter serif font enabled by default
    };
    
    # Remove custom sketchybar module - using nix-darwin service instead
  };
  
  # SketchyBar status bar using nix-darwin service
  services.sketchybar = {
    enable = true;
    extraPackages = with pkgs; [
      jq  # For JSON processing in scripts
      aerospace  # For workspace integration
    ];
    config = ''
      #!/bin/bash
      
      # SketchyBar Configuration with AeroSpace integration
      
      # Remove all existing items
      sketchybar --remove '/.*/' 
      
      # Global bar settings
      sketchybar --bar \
        height=32 \
        position=top \
        margin=0 \
        corner_radius=9 \
        y_offset=0 \
        color=0xaa1d2021 \
        drawing=on \
        topmost=on \
        shadow=on \
        blur_radius=20
      
      # Default item settings
      sketchybar --default \
        icon.font="FiraCode Nerd Font Mono:Regular:16.0" \
        icon.color=0xffd4be98 \
        label.font="SF Pro:Semibold:13.0" \
        label.color=0xffd4be98 \
        background.color=0xff32302f \
        background.corner_radius=4 \
        background.height=24 \
        padding_left=5 \
        padding_right=5
      
      # AeroSpace workspace indicators
      for i in {1..10}; do
        sketchybar --add item space.$i left \
                   --set space.$i \
                     associated_display=1 \
                     icon="$i" \
                     icon.color=0xffd4be98 \
                     background.color=0xff32302f \
                     click_script="aerospace workspace $i" \
                     script="$HOME/.config/sketchybar/plugins/aerospace.sh $i"
      done
      
      # Subscribe all workspace items to aerospace events
      sketchybar --add event aerospace_workspace_change
      for i in {1..10}; do
        sketchybar --subscribe space.$i aerospace_workspace_change
      done
      
      # Clock
      sketchybar --add item clock right \
                 --set clock \
                   icon=" " \
                   icon.color=0xffd4be98 \
                   label.color=0xffd4be98 \
                   background.color=0xff32302f \
                   script="date '+%a %b %d  %I:%M %p'" \
                   update_freq=30
      
      # Battery
      sketchybar --add item battery right \
                 --set battery \
                   icon.color=0xffd4be98 \
                   label.color=0xffd4be98 \
                   background.color=0xff32302f \
                   script="$HOME/.config/sketchybar/plugins/battery.sh" \
                   update_freq=120 \
                 --subscribe battery system_woke power_source_change
      
      # Volume
      sketchybar --add item volume right \
                 --set volume \
                   icon.color=0xffd4be98 \
                   label.color=0xffd4be98 \
                   background.color=0xff32302f \
                   script="$HOME/.config/sketchybar/plugins/volume.sh" \
                 --subscribe volume volume_change
      
      # WiFi
      sketchybar --add item wifi right \
                 --set wifi \
                   icon.color=0xffd4be98 \
                   label.color=0xffd4be98 \
                   background.color=0xff32302f \
                   script="$HOME/.config/sketchybar/plugins/wifi.sh" \
                   update_freq=10
      
      # CPU/Memory
      sketchybar --add item cpu right \
                 --set cpu \
                   icon=" " \
                   icon.color=0xffd4be98 \
                   label.color=0xffd4be98 \
                   background.color=0xff32302f \
                   script="$HOME/.config/sketchybar/plugins/cpu.sh" \
                   update_freq=5
      
      # Force all scripts to run
      sketchybar --update
      echo "SketchyBar configuration loaded successfully"
    '';
  };
}
