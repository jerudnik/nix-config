# Security/Password Manager Aggregator Module
# This module provides an abstract interface for password management.
# It defines "what" password management does without specifying "how" it's implemented.
# Implementation is delegated to backend modules (e.g., bitwarden.nix).
#
# WARP LAW 4.3 COMPLIANCE NOTE:
# - GUI Applications (like Bitwarden.app): Installed via nix-darwin
# - Configuration: Managed via home-manager (this module)
# - CLI Tools: Installed via home-manager if needed

{ config, lib, ... }:

with lib;

let
  cfg = config.home.security;
in
{
  imports = [
    ./bitwarden.nix  # Bitwarden implementation backend
  ];

  options.home.security = {
    enable = mkEnableOption "Password manager and security tools";
    
    autoStart = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to automatically start the password manager at login.
        Implementation will handle the actual startup mechanism.
      '';
    };
    
    unlockMethod = mkOption {
      type = types.enum [ "password" "biometric" "pin" ];
      default = "biometric";
      description = ''
        Primary unlock method for the password manager.
        - "password": Traditional master password
        - "biometric": Touch ID, Face ID, or similar
        - "pin": Numeric PIN code
        Implementation may not support all methods.
      '';
    };
    
    lockTimeout = mkOption {
      type = types.nullOr types.int;
      default = 15;
      example = 30;
      description = ''
        Auto-lock timeout in minutes.
        Set to null to disable automatic locking.
      '';
    };
    
    windowBehavior = mkOption {
      type = types.enum [ "close" "minimize" "minimize-to-tray" ];
      default = "minimize-to-tray";
      description = ''
        Behavior when closing the password manager window.
        - "close": Exit the application completely
        - "minimize": Minimize to taskbar/dock
        - "minimize-to-tray": Minimize to system tray (if supported)
      '';
    };
    
    startBehavior = mkOption {
      type = types.enum [ "normal" "minimized" ];
      default = "normal";
      description = ''
        How the password manager should start.
        - "normal": Open with visible window
        - "minimized": Start minimized/hidden
      '';
    };
  };

  # No config section here - all implementation is delegated to backend modules
  # Backend modules (like bitwarden.nix) will implement the actual password manager logic
}
