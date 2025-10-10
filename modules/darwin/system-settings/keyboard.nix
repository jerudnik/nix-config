# Keyboard System Settings Pane
# This file defines OPTIONS ONLY for the Keyboard settings pane.
# The actual configuration is implemented in the parent default.nix aggregator.
# Note: These settings write to NSGlobalDomain.

{ lib, ... }:

with lib;

{
  options.darwin.system-settings.keyboard = {
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
  };
}
