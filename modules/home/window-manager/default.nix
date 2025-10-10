# Window Manager Aggregator Module
# This module provides an abstract interface for tiling window management.
# It defines "what" window management does without specifying "how" it's implemented.
# Implementation is delegated to backend modules (e.g., aerospace.nix).

{ config, lib, ... }:

with lib;

let
  cfg = config.home.window-manager;
in {
  imports = [
    ./aerospace.nix  # AeroSpace implementation backend
  ];

  options.home.window-manager = {
    enable = mkEnableOption "Tiling window manager";
    
    startAtLogin = mkOption {
      type = types.bool;
      default = true;
      description = ''Whether to start the window manager automatically at login'';
    };
    
    defaultLayout = mkOption {
      type = types.enum [ "tiles" "accordion" ];
      default = "tiles";
      description = ''
        Default layout for new workspaces.
        Implementation may support additional layouts.
      '';
    };
    
    gaps = {
      inner = mkOption {
        type = types.int;
        default = 8;
        description = ''Gap size between windows (in pixels)'';
      };
      
      outer = mkOption {
        type = types.int;
        default = 8;
        description = ''Gap size between windows and screen edges (in pixels)'';
      };
    };
    
    keybindings = {
      modifier = mkOption {
        type = types.enum [ "alt" "cmd" "ctrl" ];
        default = "alt";
        description = ''
          Primary modifier key for window management shortcuts.
          Common choices: "alt" for macOS, "cmd" for power users.
        '';
      };
      
      terminal = mkOption {
        type = types.nullOr types.str;
        default = "Warp";
        description = ''
          Terminal application name to launch with modifier+enter.
          Set to null to disable this keybinding.
        '';
        example = "Alacritty";
      };
      
      browser = mkOption {
        type = types.nullOr types.str;
        default = "Zen Browser (Twilight)";
        description = ''
          Browser application name to launch with modifier+b.
          Set to null to disable this keybinding.
        '';
        example = "Firefox";
      };
      
      passwordManager = mkOption {
        type = types.nullOr types.str;
        default = "Bitwarden";
        description = ''
          Password manager application name to launch with modifier+p.
          Set to null to disable this keybinding.
        '';
        example = "1Password";
      };
    };
  };

  # No config section here - all implementation is delegated to backend modules
  # Backend modules (like aerospace.nix) will implement the actual window management logic
}
