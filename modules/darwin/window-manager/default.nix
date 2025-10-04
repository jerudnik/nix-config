{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.darwin.window-manager;
  
  # Default AeroSpace configuration
  defaultConfig = ''
    # AeroSpace configuration
    # See: https://github.com/nikitabobko/AeroSpace/blob/main/docs/config-examples.md

    # You can use it to add commands that run after login to macOS user session.
    # 'start-at-login' needs to be 'true' for 'after-login-command' to work
    after-login-command = []

    # You can use it to add commands that run after AeroSpace startup.
    after-startup-command = []

    # Start AeroSpace at login
    start-at-login = true

    # Normalizations. See: https://nikitabobko.github.io/AeroSpace/guide.html#normalization
    enable-normalization-flatten-containers = true
    enable-normalization-opposite-orientation-for-nested-containers = true

    # See: https://nikitabobko.github.io/AeroSpace/guide.html#layouts
    # The 'accordion-padding' specifies the size of accordion padding
    # You can set 0 to disable the padding feature
    accordion-padding = 30

    # Possible values: tiles|accordion
    default-root-container-layout = 'tiles'

    # Possible values: horizontal|vertical|auto
    # 'auto' means: wide monitor (anything wider than high) gets horizontal orientation,
    #               tall monitor (anything higher than wide) gets vertical orientation
    default-root-container-orientation = 'auto'

    # Possible values: (qwerty|dvorak)
    # See https://nikitabobko.github.io/AeroSpace/guide.html#key-mapping
    key-mapping.preset = 'qwerty'

    # Mouse follows focus when focused monitor changes
    # Drop it from your config, if you don't like this behavior
    # See https://nikitabobko.github.io/AeroSpace/guide.html#on-focus-changed
    on-focus-changed = ['move-mouse monitor-lazy-center']
    
    # Notify SketchyBar when workspace changes (for workspace indicators)
    # See: https://nikitabobko.github.io/AeroSpace/guide.html#exec-on-workspace-change
    exec-on-workspace-change = [
      '/bin/bash',
      '-c',
      'sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE'
    ]

    # Gaps between windows (inner-*) and between monitor edges (outer-*).
    # Possible values:
    # - Constant:     gaps.outer.top = 8
    # - Per monitor:  gaps.outer.top = [{ monitor.main = 16 }, { monitor."some-pattern" = 32 }, 8]
    #                 In this example, 8 is a default value that is used as a fallback.
    #                 Monitor pattern is the same as for 'workspace-to-monitor-force-assignment'.
    #                 See: https://nikitabobko.github.io/AeroSpace/guide.html#assign-workspaces-to-monitors
    [gaps]
    inner.horizontal = 8
    inner.vertical = 8
    outer.left = 8
    outer.bottom = 8
    outer.top = 40  # 32px SketchyBar height + 8px margin
    outer.right = 8

    # 'main' binding mode declaration
    # See: https://nikitabobko.github.io/AeroSpace/guide.html#binding-modes
    # 'main' binding mode must be always presented
    [mode.main.binding]

    # All possible keys:
    # - Letters.        a, b, c, ..., z
    # - Numbers.        0, 1, 2, ..., 9
    # - Keypad numbers. keypad0, keypad1, keypad2, ..., keypad9
    # - F-keys.         f1, f2, ..., f20
    # - Special keys.   minus, equal, period, comma, slash, backslash, quote, semicolon, backtick,
    #                   leftSquareBracket, rightSquareBracket, space, enter, esc, backspace, tab
    # - Keypad special. keypadClear, keypadDecimalMark, keypadDivide, keypadEnter, keypadEqual,
    #                   keypadMinus, keypadMultiply, keypadPlus
    # - Arrows.         left, down, up, right

    # All possible modifiers: cmd, alt, ctrl, shift

    # All possible commands: https://nikitabobko.github.io/AeroSpace/commands.html

    # See: https://nikitabobko.github.io/AeroSpace/commands.html#exec-and-forget
    # You can uncomment the following lines to open up terminal with alt + enter shortcut (like in i3)
    # alt-enter = '''exec-and-forget osascript -e '
    # tell application "Terminal"
    #     do script
    #     activate
    # end tell'
    # '''

    # See: https://nikitabobko.github.io/AeroSpace/commands.html#layout
    alt-slash = 'layout tiles horizontal vertical'
    alt-comma = 'layout accordion horizontal vertical'

    # See: https://nikitabobko.github.io/AeroSpace/commands.html#focus
    alt-h = 'focus left'
    alt-j = 'focus down'
    alt-k = 'focus up'
    alt-l = 'focus right'

    # See: https://nikitabobko.github.io/AeroSpace/commands.html#move
    alt-shift-h = 'move left'
    alt-shift-j = 'move down'
    alt-shift-k = 'move up'
    alt-shift-l = 'move right'

    # See: https://nikitabobko.github.io/AeroSpace/commands.html#resize
    alt-shift-minus = 'resize smart -50'
    alt-shift-equal = 'resize smart +50'

    # See: https://nikitabobko.github.io/AeroSpace/commands.html#workspace
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

    # See: https://nikitabobko.github.io/AeroSpace/commands.html#move-node-to-workspace
    # Using --focus-follows-window to update SketchyBar immediately
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

    # See: https://nikitabobko.github.io/AeroSpace/commands.html#workspace-back-and-forth
    alt-tab = 'workspace-back-and-forth'
    # See: https://nikitabobko.github.io/AeroSpace/commands.html#move-workspace-to-monitor
    alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'

    # See: https://nikitabobko.github.io/AeroSpace/commands.html#mode
    alt-shift-semicolon = 'mode service'

    # 'service' binding mode declaration.
    # See: https://nikitabobko.github.io/AeroSpace/guide.html#binding-modes
    [mode.service.binding]
    esc = ['reload-config', 'mode main']
    r = ['flatten-workspace-tree', 'mode main'] # reset layout
    #s = ['layout sticky tiling', 'mode main'] # sticky is not yet supported https://github.com/nikitabobko/AeroSpace/issues/2
    f = ['layout floating tiling', 'mode main'] # Toggle between floating and tiling layout
    backspace = ['close-all-windows-but-current', 'mode main']

    alt-shift-h = ['join-with left', 'mode main']
    alt-shift-j = ['join-with down', 'mode main']
    alt-shift-k = ['join-with up', 'mode main']
    alt-shift-l = ['join-with right', 'mode main']
  '';
in {
  options.darwin.window-manager = {
    enable = mkEnableOption "AeroSpace tiling window manager";
    
    package = mkOption {
      type = types.package;
      default = pkgs.aerospace;
      description = "AeroSpace package to use";
    };
    
    startAtLogin = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to start AeroSpace at login";
    };
    
    config = mkOption {
      type = types.lines;
      default = defaultConfig;
      description = "AeroSpace configuration in TOML format";
      example = literalExpression ''
        # Custom AeroSpace config
        start-at-login = true
        default-root-container-layout = 'accordion'
      '';
    };
    
    gaps = {
      inner = mkOption {
        type = types.int;
        default = 8;
        description = "Inner gaps between windows";
      };
      
      outer = mkOption {
        type = types.int;
        default = 8;
        description = "Outer gaps between windows and monitor edges";
      };
    };
    
    bindings = {
      modifier = mkOption {
        type = types.enum [ "alt" "cmd" "ctrl" ];
        default = "alt";
        description = "Primary modifier key for AeroSpace bindings";
      };
    };
  };

  config = mkIf cfg.enable {
    # Install AeroSpace
    environment.systemPackages = [ cfg.package ];
    
    # Create AeroSpace configuration directory and file
    environment.etc."aerospace/aerospace.toml".text = cfg.config;
    
    # Make AeroSpace.app available in /Applications for proper macOS integration
    # This ensures the app can be found by macOS for login items and permissions
    system.activationScripts.aerospace.text = ''
      echo "Setting up AeroSpace.app..."
      
      # Create symlink to Applications for proper macOS integration
      if [[ ! -e "/Applications/AeroSpace.app" ]]; then
        echo "Creating AeroSpace.app symlink in /Applications"
        ln -sf "${cfg.package}/Applications/AeroSpace.app" "/Applications/AeroSpace.app"
      fi
    '';
    
    # Use launchd to start AeroSpace at login (more reliable than AppleScript)
    # This creates a user agent that launches AeroSpace when the user logs in
    launchd.user.agents.aerospace = mkIf cfg.startAtLogin {
      serviceConfig = {
        ProgramArguments = [ "/usr/bin/open" "-a" "/Applications/AeroSpace.app" ];
        RunAtLoad = true;
        KeepAlive = false;
        ProcessType = "Interactive";
      };
    };
    
    # Optional: Add shell aliases for common aerospace commands
    environment.interactiveShellInit = ''
      # AeroSpace aliases
      alias aero='aerospace'
      alias aero-list='aerospace list-windows --all'
      alias aero-reload='aerospace reload-config'
      
      # Helper to manually start AeroSpace.app if needed
      alias aero-start='open ${cfg.package}/Applications/AeroSpace.app'
    '';
  };
}