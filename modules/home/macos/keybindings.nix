{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.macos.keybindings;
in {
  options.home.macos.keybindings = {
    enable = mkEnableOption "macOS keyboard and hotkey configuration";
    
    keyRepeat = mkOption {
      type = types.int;
      default = 2;
      example = 1;
      description = ''
        Key repeat speed when holding down a key.
        Lower values = faster repetition. Range: 1-120.
        System Preferences equivalent: Fast (1) to Slow (120).
      '';
    };
    
    initialKeyRepeat = mkOption {
      type = types.int;
      default = 15;
      example = 10;
      description = ''
        Delay before key repeat starts when holding down a key.
        Lower values = shorter delay. Range: 1-120.
        System Preferences equivalent: Short (1) to Long (120).
      '';
    };
    
    pressAndHoldEnabled = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to show accent character selector when holding down keys.
        When false, holding keys will repeat the character instead.
        Recommended: false for faster typing experience.
      '';
    };
    
    customSymbolicHotkeys = mkOption {
      type = types.attrsOf types.attrs;
      default = {};
      example = literalExpression ''
        {
          # Disable Mission Control (default Ctrl+Up)
          "26" = {
            enabled = false;
          };
          # Custom hotkey example
          "27" = {
            enabled = true;
            value = {
              parameters = [ 65535 10 1048576 ]; # Cmd+Enter
              type = "standard";
            };
          };
        }
      '';
      description = ''
        Custom symbolic hotkey configuration for advanced users.
        
        This allows fine-tuned control over system hotkeys beyond the basic options.
        Keys are numeric identifiers for specific system functions.
        
        Common hotkey IDs:
        - 26: Mission Control
        - 27: Move focus to menu bar  
        - 60/64: Show Spotlight search
        - 61/65: Show Finder search window
        
        Each hotkey can be enabled/disabled or have custom key combinations.
      '';
    };
  };

  config = mkIf cfg.enable {
    # macOS platform assertion
    assertions = [
      {
        assertion = pkgs.stdenv.isDarwin;
        message = "home.macos.keybindings is only available on macOS (Darwin)";
      }
    ];

    # IMPORTANT: NSGlobalDomain settings removed to prevent conflicts.
    # ALL keyboard settings (KeyRepeat, InitialKeyRepeat, etc.) are now
    # managed exclusively by nix-darwin in modules/darwin/system-defaults
    # to prevent cfprefsd cache corruption that causes System Settings blank panes.
    #
    # This module now only manages symbolic hotkeys (com.apple.symbolichotkeys),
    # which is application-level configuration, not system-wide NSGlobalDomain.
    
    targets.darwin.defaults = {
      # Symbolic hotkeys configuration
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = mkMerge [
          # Apply custom symbolic hotkeys
          cfg.customSymbolicHotkeys
        ];
      };
    };
    
    # NOTE: cfprefsd management removed - now handled by nix-darwin's
    # postUserActivation script to ensure proper coordination.
  };
}