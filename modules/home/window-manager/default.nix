{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.window-manager.aerospace;
in {
  options.home.window-manager.aerospace = {
    enable = mkEnableOption "AeroSpace tiling window manager";
    
    settings = mkOption {
      type = with types; attrsOf (oneOf [ bool int str (listOf str) ]);
      default = {};
      description = "AeroSpace configuration settings";
      example = {
        start-at-login = true;
        default-root-container-layout = "tiles";
        gaps = {
          inner = { horizontal = 8; vertical = 8; };
          outer = { left = 8; right = 8; top = 40; bottom = 8; };
        };
      };
    };
    
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional configuration in TOML format";
      example = ''
        # Custom settings
        [[on-window-detected]]
        if.app-id = 'com.brave.Browser'
        run = 'move-node-to-workspace 1'
      '';
    };
  };

  config = mkIf cfg.enable {
    # Install aerospace package
    home.packages = [ pkgs.aerospace ];
    
    # Create user-specific AeroSpace configuration
    home.file.".aerospace.toml".text = ''
      # AeroSpace configuration managed by Nix
      # See: https://nikitabobko.github.io/AeroSpace/guide
      
      # Start AeroSpace at login
      start-at-login = true
      
      # Normalization settings
      enable-normalization-flatten-containers = true
      enable-normalization-opposite-orientation-for-nested-containers = true
      
      # Accordion layout settings
      accordion-padding = 30
      
      # Default root container settings
      default-root-container-layout = 'tiles'
      default-root-container-orientation = 'auto'
      
      # Mouse follows focus when focused monitor changes
      on-focus-changed = ['move-mouse monitor-lazy-center']
      
      # Key mapping preset
      [key-mapping]
      preset = 'qwerty'
      
      # Gaps between windows (inner-*) and between monitor edges (outer-*)
      [gaps]
      inner.horizontal = 8
      inner.vertical = 8
      outer.left = 8
      outer.bottom = 8
      outer.top = 8   # Standard margin
      outer.right = 8
      
      # Main mode bindings
      [mode.main.binding]
      # Launch applications
      alt-enter = """exec-and-forget osascript -e '
      tell application "Warp"
          do script
          activate
      end tell'
      """
      
      alt-b = """exec-and-forget osascript -e '
      tell application "Zen Browser (Twilight)"
          activate
      end tell'
      """
      
      alt-p = """exec-and-forget osascript -e '
      tell application "Bitwarden"
          activate
      end tell'
      """
      
      # Layout management
      alt-slash = 'layout tiles horizontal vertical'
      alt-comma = 'layout accordion horizontal vertical'
      
      # Focus movement
      alt-h = 'focus left'
      alt-j = 'focus down'
      alt-k = 'focus up'
      alt-l = 'focus right'
      
      # Window movement
      alt-shift-h = 'move left'
      alt-shift-j = 'move down'
      alt-shift-k = 'move up'
      alt-shift-l = 'move right'
      
      # Resize windows
      alt-shift-minus = 'resize smart -50'
      alt-shift-equal = 'resize smart +50'
      
      # Workspace management
      alt-1 = 'workspace 1'
      alt-2 = 'workspace 2'
      alt-3 = 'workspace 3'
      alt-4 = 'workspace 4'
      alt-5 = 'workspace 5'
      alt-6 = 'workspace 6'
      alt-7 = 'workspace 7'
      alt-8 = 'workspace 8'
      alt-9 = 'workspace 9'
      alt-0 = 'workspace 10'
      
      # Move windows to workspaces with focus following
      alt-shift-1 = 'move-node-to-workspace 1 --focus-follows-window'
      alt-shift-2 = 'move-node-to-workspace 2 --focus-follows-window'
      alt-shift-3 = 'move-node-to-workspace 3 --focus-follows-window'
      alt-shift-4 = 'move-node-to-workspace 4 --focus-follows-window'
      alt-shift-5 = 'move-node-to-workspace 5 --focus-follows-window'
      alt-shift-6 = 'move-node-to-workspace 6 --focus-follows-window'
      alt-shift-7 = 'move-node-to-workspace 7 --focus-follows-window'
      alt-shift-8 = 'move-node-to-workspace 8 --focus-follows-window'
      alt-shift-9 = 'move-node-to-workspace 9 --focus-follows-window'
      alt-shift-0 = 'move-node-to-workspace 10 --focus-follows-window'
      
      # Workspace navigation
      alt-tab = 'workspace-back-and-forth'
      alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'
      
      # Enter service mode
      alt-shift-semicolon = 'mode service'
      
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
      alt-shift-h = ['join-with left', 'mode main']
      alt-shift-j = ['join-with down', 'mode main']
      alt-shift-k = ['join-with up', 'mode main']
      alt-shift-l = ['join-with right', 'mode main']
      
      ${cfg.extraConfig}
    '';
  };
}
