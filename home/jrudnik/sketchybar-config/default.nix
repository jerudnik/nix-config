{ pkgs }:

{
  # Enhanced SketchyBar with Lua configuration
  home.packages = with pkgs; [
    sketchybar
    sbarlua  # Lua bindings for SketchyBar
    aerospace  # Make sure aerospace is available for scripts
  ];

  # Declarative SketchyBar configuration files
  xdg.configFile = {
    # Main SketchyBar executable configuration
    "sketchybar/sketchybarrc" = {
      text = ''
        #!/usr/bin/env ${pkgs.lua54Packages.lua}/bin/lua
        -- Enhanced SketchyBar configuration with AeroSpace integration
        package.path = package.path .. ";$HOME/.local/share/sketchybar_lua/?.so"
        
        -- Load the sketchybar Lua module
        sbar = require("sketchybar")
        
        -- Initialize SketchyBar
        sbar.begin_config()
        
        -- Load main configuration
        require("init")
        
        -- End configuration and run
        sbar.end_config()
        sbar.event_loop()
      '';
      executable = true;
    };

    # Core Lua configuration files
    "sketchybar/init.lua".source = ./lua/init.lua;
    "sketchybar/settings.lua".source = ./lua/settings.lua;
    "sketchybar/bar.lua".source = ./lua/bar.lua;
    "sketchybar/colors.lua".source = ./lua/colors.lua;

    # Helper modules
    "sketchybar/helpers/format.lua".source = ./lua/helpers/format.lua;

    # Individual item configurations
    "sketchybar/items/aerospace.lua".source = ./lua/items/aerospace.lua;
    "sketchybar/items/wifi.lua".source = ./lua/items/wifi.lua;
    "sketchybar/items/battery.lua".source = ./lua/items/battery.lua;
    "sketchybar/items/volume.lua".source = ./lua/items/volume.lua;
    "sketchybar/items/clock.lua".source = ./lua/items/clock.lua;
  };

  # Install sbarlua library declaratively
  home.file.".local/share/sketchybar_lua/sketchybar.so" = {
    source = "${pkgs.sbarlua}/lib/lua/5.4/sketchybar.so";
  };

  # LaunchAgent to start enhanced SketchyBar
  launchd.agents.sketchybar = {
    enable = true;
    config = {
      ProgramArguments = [ "${pkgs.sketchybar}/bin/sketchybar" ];
      KeepAlive = true;
      RunAtLoad = true;
    };
  };
}