# Keyboard System Settings Pane
# This file defines OPTIONS ONLY for the Keyboard settings pane.
# The actual configuration is implemented in the parent default.nix aggregator.
# Note: These settings write to NSGlobalDomain.

{ lib, ... }:

with lib;

{
  options.darwin.system-settings.keyboard = {
    # Key repeat and behavior settings (write to NSGlobalDomain)
    keyRepeat = mkOption {
      type = types.int;
      default = 2;
      example = 1;
      description = ''Key repeat speed (1-120, lower = faster)'';
    };
    
    initialKeyRepeat = mkOption {
      type = types.int;
      default = 15;
      example = 10;
      description = ''Delay before key repeat starts (1-120, lower = shorter)'';
    };
    
    pressAndHoldEnabled = mkOption {
      type = types.bool;
      default = false;
      description = ''Show accent character selector when holding keys (false = repeat character)'';
    };
    
    keyboardUIMode = mkOption {
      type = types.int;
      default = 3;
      description = ''Keyboard navigation mode (3 = full keyboard access for all controls)'';
    };
    
    # Function key behavior (writes to NSGlobalDomain)
    enableFnKeys = mkOption {
      type = types.bool;
      default = true;
      description = ''Use F1, F2, etc. as standard function keys instead of media keys'';
    };
    
    # Key remapping settings (writes to system.keyboard)
    remapCapsLockToControl = mkOption {
      type = types.bool;
      default = true;
      description = ''Remap Caps Lock key to Control'';
    };
    
    remapCapsLockToEscape = mkOption {
      type = types.bool;
      default = false;
      description = ''Remap Caps Lock key to Escape (conflicts with remapCapsLockToControl)'';
    };
  };
}
