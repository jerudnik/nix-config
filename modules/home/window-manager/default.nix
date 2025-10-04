{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.window-manager;
in {
  options.home.window-manager = {
    aerospace = {
      enable = mkEnableOption "User-specific AeroSpace configuration";
      
      configFile = mkOption {
        type = types.lines;
        default = "";
        description = "User-specific AeroSpace configuration content";
        example = literalExpression ''
          # User customizations for AeroSpace
          [gaps]
          inner.horizontal = 12
          inner.vertical = 12
          
          [mode.main.binding]
          # Custom keybindings
          cmd-enter = 'exec-and-forget open -a Terminal'
        '';
      };
      
      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = "Additional configuration to append to the system AeroSpace config";
      };
    };
  };

  config = mkIf cfg.aerospace.enable {
    # Create user-specific AeroSpace config if provided
    home.file.".aerospace.toml" = mkIf (cfg.aerospace.configFile != "") {
      text = cfg.aerospace.configFile;
    };
    
    # Note: AeroSpace will look for config in this order:
    # 1. ~/.aerospace.toml (user-specific, created here)
    # 2. /etc/aerospace/aerospace.toml (system-wide, created by darwin module)
    # 3. Built-in defaults
  };
}