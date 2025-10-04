{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.sketchybar;
in {
  options.home.sketchybar = {
    enable = mkEnableOption "SketchyBar status bar with Lua configuration";
    
    package = mkOption {
      type = types.package;
      default = pkgs.sketchybar;
      description = "SketchyBar package to use";
    };
  };

  config = mkIf cfg.enable {
    # Install SketchyBar and sbarlua
    home.packages = with pkgs; [
      cfg.package
      sbarlua  # Lua bindings for SketchyBar
      jq       # For JSON processing in scripts
    ];

    # Create SketchyBar configuration directory
    xdg.configFile = {
      # Main configuration files
      "sketchybar/sketchybarrc" = {
        text = ''
          #!/usr/bin/env ${pkgs.lua54Packages.lua}/bin/lua
          -- Load the sketchybar-package and prepare the helper binaries
          require("init")
          
          -- Enable hot reloading
          sbar.exec("sketchybar --hotload true")
        '';
        executable = true;
      };
      
      # Lua modules
      "sketchybar/init.lua" = {
        source = ./config/init.lua;
      };
      
      "sketchybar/bar.lua" = {
        source = ./config/bar.lua;
      };
      
      "sketchybar/colors.lua" = {
        source = ./config/colors.lua;
      };
      
      "sketchybar/icons.lua" = {
        source = ./config/icons.lua;
      };
      
      "sketchybar/settings.lua" = {
        source = ./config/settings.lua;
      };
      
      # Items directory
      "sketchybar/items" = {
        source = ./config/items;
        recursive = true;
      };
      
      # Helpers directory  
      "sketchybar/helpers" = {
        source = ./config/helpers;
        recursive = true;
      };
    };

    # Install sbarlua library
    home.file.".local/share/sketchybar_lua/sketchybar.so" = {
      source = "${pkgs.sbarlua}/lib/lua/5.4/sketchybar.so";
    };
    
    # LaunchAgent to start SketchyBar
    launchd.agents.sketchybar = {
      enable = true;
      config = {
        ProgramArguments = [ "${cfg.package}/bin/sketchybar" ];
        KeepAlive = true;
        RunAtLoad = true;
      };
    };
  };
}