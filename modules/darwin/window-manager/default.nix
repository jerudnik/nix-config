{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.darwin.window-manager;
in {
  options.darwin.window-manager = {
    enable = mkEnableOption "Enable basic window manager support (deprecated - use home-manager aerospace instead)";
  };

  config = mkIf cfg.enable {
    # This module is deprecated in favor of the home-manager aerospace module
    # Keep minimal functionality for backwards compatibility
    
    # Optional: Add shell aliases for common aerospace commands
    environment.interactiveShellInit = ''
      # AeroSpace aliases (if available)
      if command -v aerospace >/dev/null 2>&1; then
        alias aero='aerospace'
        alias aero-list='aerospace list-windows --all'
        alias aero-reload='aerospace reload-config'
      fi
    '';
    
    # Print a deprecation warning
    system.activationScripts.windowManager.text = ''
      echo "Warning: darwin.window-manager module is deprecated."
      echo "Please use 'home.window-manager.aerospace.enable = true' in your home-manager config instead."
      echo "The home-manager module provides better configuration management."
    '';
  };
}
