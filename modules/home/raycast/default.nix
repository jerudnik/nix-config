{ config, lib, pkgs, ... }:

let
  cfg = config.home.raycast;
  inherit (lib) mkIf mkOption mkEnableOption types mkMerge;
in
{
  options.home.raycast = {
    enable = mkEnableOption "Raycast launcher installed and configured declaratively";

    package = mkOption {
      type = types.package;
      default = pkgs.raycast;
      example = lib.literalExpression "pkgs.raycast";
      description = "Raycast application package from nixpkgs (unfree)";
    };

    followSystemAppearance = mkOption {
      type = types.bool;
      default = true;
      description = "Follow system appearance for light/dark mode";
    };

    globalHotkey = mkOption {
      type = types.nullOr (types.submodule {
        options = {
          keyCode = mkOption {
            type = types.int;
            example = 49;
            description = "Key code for the global hotkey (49 = space)";
          };
          modifierFlags = mkOption {
            type = types.int;
            example = 1048576;
            description = "Modifier flags (1048576 = Cmd, 524288 = Option, 262144 = Ctrl, 131072 = Shift)";
          };
        };
      });
      default = {
        keyCode = 49;        # Space key
        modifierFlags = 1048576;  # Command key
      };
      description = "Global hotkey configuration for Raycast activation";
    };

    # Escape hatch for additional known-safe keys with strict value typing
    extraDefaults = mkOption {
      type = types.attrsOf (types.oneOf [ types.bool types.int types.float types.str ]);
      default = {};
      example = { "onboarding_setupHotkey" = true; };
      description = "Additional com.raycast.macos defaults for documented Raycast keys";
    };
  };

  config = mkIf cfg.enable {
    # Darwin-only assertion
    assertions = [
      { 
        assertion = pkgs.stdenv.isDarwin; 
        message = "home.raycast is only supported on macOS (Darwin)"; 
      }
    ];

    # Install Raycast via nixpkgs only (no Homebrew)
    home.packages = [ cfg.package ];

    # Configure preferences declaratively via targets.darwin.defaults only
    targets.darwin.defaults."com.raycast.macos" = mkMerge [
      {
        # Follow system appearance setting
        raycastShouldFollowSystemAppearance = cfg.followSystemAppearance;
        
        # Enable hotkey monitoring
        "mainWindow_isMonitoringGlobalHotkeys" = true;
        
        # Mark onboarding as complete to prevent setup dialogs
        onboardingCompleted = true;
        "onboarding_setupHotkey" = true;
      }
      
      # Configure global hotkey if specified
      (mkIf (cfg.globalHotkey != null) {
        raycastGlobalHotkey = cfg.globalHotkey;
      })
      
      # Merge any additional defaults
      cfg.extraDefaults
    ];

    # Disable macOS Spotlight shortcuts to avoid conflicts
    targets.darwin.defaults."com.apple.symbolichotkeys" = {
      AppleSymbolicHotKeys = {
        # Disable "Show Spotlight search" (Cmd+Space)
        "64" = {
          enabled = false;
          value = {
            parameters = [ 32 49 1048576 ];
            type = "standard";
          };
        };
        # Disable "Show Finder search window" (Cmd+Option+Space)
        "65" = {
          enabled = false;
          value = {
            parameters = [ 32 49 1572864 ];
            type = "standard";
          };
        };
      };
    };
  };
}