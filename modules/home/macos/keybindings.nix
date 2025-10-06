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

    targets.darwin.defaults = {
      # Global keyboard behavior
      NSGlobalDomain = {
        # Key repeat settings
        ApplePressAndHoldEnabled = cfg.pressAndHoldEnabled;
        InitialKeyRepeat = cfg.initialKeyRepeat;
        KeyRepeat = cfg.keyRepeat;
        
        # Keyboard navigation improvements
        AppleKeyboardUIMode = 3; # Enable full keyboard access for all controls
        
        # Smart text substitutions (generally disable for better typing experience)
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
      
      # Symbolic hotkeys configuration
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = mkMerge [
          # Note: Spotlight hotkeys are disabled by the Raycast module to avoid conflicts
          # Only apply custom symbolic hotkeys here
          cfg.customSymbolicHotkeys
        ];
      };
    };
    
    # Optional: Restart affected services to apply keyboard changes immediately
    home.activation.refreshKeyboardSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [[ -n "''${VERBOSE:-}" ]]; then
        echo "Refreshing macOS keyboard settings..."
      fi
      
      # Restart the preferences cache daemon to ensure changes take effect
      killall cfprefsd 2>/dev/null || true
      
      # Note: Some keyboard changes may require logout/login to take full effect
    '';
  };
}