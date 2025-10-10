# AeroSpace Implementation Module
# This module implements the window management interface using AeroSpace.
# It translates abstract window management options into AeroSpace-specific configuration.

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.window-manager;
  aeroCfg = cfg.implementation.aerospace;
in {
  options.home.window-manager.implementation = {
    aerospace = {
      enable = mkEnableOption "Use AeroSpace as the window manager implementation" // {
        default = true;
      };
      
      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Additional AeroSpace-specific configuration in TOML format.
          This is appended to the generated configuration file.
        '';
        example = ''
          # Custom AeroSpace settings
          [[on-window-detected]]
          if.app-id = 'com.brave.Browser'
          run = 'move-node-to-workspace 1'
        '';
      };
    };
  };

  config = mkIf (cfg.enable && aeroCfg.enable) {
    # Install AeroSpace package
    home.packages = [ pkgs.aerospace ];
    
    # Generate AeroSpace configuration from abstract options
    home.file.".aerospace.toml".text = ''
      # AeroSpace configuration managed by Nix
      # See: https://nikitabobko.github.io/AeroSpace/guide
      
      # Start AeroSpace at login
      start-at-login = ${boolToString cfg.startAtLogin}
      
      # Normalization settings
      enable-normalization-flatten-containers = true
      enable-normalization-opposite-orientation-for-nested-containers = true
      
      # Accordion layout settings
      accordion-padding = 30
      
      # Default root container settings
      default-root-container-layout = '${cfg.defaultLayout}'
      default-root-container-orientation = 'auto'
      
      # Mouse follows focus when focused monitor changes
      on-focus-changed = ['move-mouse monitor-lazy-center']
      
      # Key mapping preset
      [key-mapping]
      preset = 'qwerty'
      
      # Gaps between windows (inner-*) and between monitor edges (outer-*)
      [gaps]
      inner.horizontal = ${toString cfg.gaps.inner}
      inner.vertical = ${toString cfg.gaps.inner}
      outer.left = ${toString cfg.gaps.outer}
      outer.bottom = ${toString cfg.gaps.outer}
      outer.top = ${toString cfg.gaps.outer}
      outer.right = ${toString cfg.gaps.outer}
      
      # Main mode bindings
      [mode.main.binding]
      
      ${optionalString (cfg.keybindings.terminal != null) ''
      # Launch terminal
      ${cfg.keybindings.modifier}-enter = """exec-and-forget osascript -e '
      tell application "${cfg.keybindings.terminal}"
          do script
          activate
      end tell'
      """
      ''}
      
      ${optionalString (cfg.keybindings.browser != null) ''
      # Launch browser
      ${cfg.keybindings.modifier}-b = """exec-and-forget osascript -e '
      tell application "${cfg.keybindings.browser}"
          activate
      end tell'
      """
      ''}
      
      ${optionalString (cfg.keybindings.passwordManager != null) ''
      # Launch password manager
      ${cfg.keybindings.modifier}-p = """exec-and-forget osascript -e '
      tell application "${cfg.keybindings.passwordManager}"
          activate
      end tell'
      """
      ''}
      
      # Layout management
      ${cfg.keybindings.modifier}-slash = 'layout tiles horizontal vertical'
      ${cfg.keybindings.modifier}-comma = 'layout accordion horizontal vertical'
      
      # Focus movement (vim keys)
      ${cfg.keybindings.modifier}-h = 'focus left'
      ${cfg.keybindings.modifier}-j = 'focus down'
      ${cfg.keybindings.modifier}-k = 'focus up'
      ${cfg.keybindings.modifier}-l = 'focus right'
      
      # Window movement (vim keys + shift)
      ${cfg.keybindings.modifier}-shift-h = 'move left'
      ${cfg.keybindings.modifier}-shift-j = 'move down'
      ${cfg.keybindings.modifier}-shift-k = 'move up'
      ${cfg.keybindings.modifier}-shift-l = 'move right'
      
      # Resize windows
      ${cfg.keybindings.modifier}-shift-minus = 'resize smart -50'
      ${cfg.keybindings.modifier}-shift-equal = 'resize smart +50'
      
      # Workspace management (1-10)
      ${cfg.keybindings.modifier}-1 = 'workspace 1'
      ${cfg.keybindings.modifier}-2 = 'workspace 2'
      ${cfg.keybindings.modifier}-3 = 'workspace 3'
      ${cfg.keybindings.modifier}-4 = 'workspace 4'
      ${cfg.keybindings.modifier}-5 = 'workspace 5'
      ${cfg.keybindings.modifier}-6 = 'workspace 6'
      ${cfg.keybindings.modifier}-7 = 'workspace 7'
      ${cfg.keybindings.modifier}-8 = 'workspace 8'
      ${cfg.keybindings.modifier}-9 = 'workspace 9'
      ${cfg.keybindings.modifier}-0 = 'workspace 10'
      
      # Move windows to workspaces with focus following
      ${cfg.keybindings.modifier}-shift-1 = 'move-node-to-workspace 1 --focus-follows-window'
      ${cfg.keybindings.modifier}-shift-2 = 'move-node-to-workspace 2 --focus-follows-window'
      ${cfg.keybindings.modifier}-shift-3 = 'move-node-to-workspace 3 --focus-follows-window'
      ${cfg.keybindings.modifier}-shift-4 = 'move-node-to-workspace 4 --focus-follows-window'
      ${cfg.keybindings.modifier}-shift-5 = 'move-node-to-workspace 5 --focus-follows-window'
      ${cfg.keybindings.modifier}-shift-6 = 'move-node-to-workspace 6 --focus-follows-window'
      ${cfg.keybindings.modifier}-shift-7 = 'move-node-to-workspace 7 --focus-follows-window'
      ${cfg.keybindings.modifier}-shift-8 = 'move-node-to-workspace 8 --focus-follows-window'
      ${cfg.keybindings.modifier}-shift-9 = 'move-node-to-workspace 9 --focus-follows-window'
      ${cfg.keybindings.modifier}-shift-0 = 'move-node-to-workspace 10 --focus-follows-window'
      
      # Workspace navigation
      ${cfg.keybindings.modifier}-tab = 'workspace-back-and-forth'
      ${cfg.keybindings.modifier}-shift-tab = 'move-workspace-to-monitor --wrap-around next'
      
      # Enter service mode
      ${cfg.keybindings.modifier}-shift-semicolon = 'mode service'
      
      # Service mode bindings
      [mode.service.binding]
      # Reload config and return to main mode
      esc = ['reload-config', 'mode main']
      
      # Reset layout
      r = ['flatten-workspace-tree', 'mode main']
      
      # Toggle floating/tiling layout
      f = ['layout floating tiling', 'mode main']
      
      # Close all windows but current
      backspace = ['close-all-windows-but-current', 'mode main']
      
      # Join with adjacent windows
      ${cfg.keybindings.modifier}-shift-h = ['join-with left', 'mode main']
      ${cfg.keybindings.modifier}-shift-j = ['join-with down', 'mode main']
      ${cfg.keybindings.modifier}-shift-k = ['join-with up', 'mode main']
      ${cfg.keybindings.modifier}-shift-l = ['join-with right', 'mode main']
      
      ${aeroCfg.extraConfig}
    '';
  };
}
