{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.darwin.keyboard;
in {
  options.darwin.keyboard = {
    enable = mkEnableOption "Keyboard configuration and key remapping";
    
    remapCapsLockToControl = mkOption {
      type = types.bool;
      default = true;
      description = "Remap Caps Lock key to Control";
    };
    
    remapCapsLockToEscape = mkOption {
      type = types.bool;
      default = false;
      description = "Remap Caps Lock key to Escape (conflicts with remapCapsLockToControl)";
    };
    
    enableFnKeys = mkOption {
      type = types.bool;
      default = true;
      description = "Use F1, F2, etc. as standard function keys instead of media keys";
    };
  };

  config = mkIf cfg.enable {
    # Validate that only one caps lock remapping is enabled
    assertions = [{
      assertion = !(cfg.remapCapsLockToControl && cfg.remapCapsLockToEscape);
      message = "Cannot remap Caps Lock to both Control and Escape simultaneously";
    }];
    
    system = {
      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = cfg.remapCapsLockToControl;
        remapCapsLockToEscape = cfg.remapCapsLockToEscape;
      };
      
      defaults.NSGlobalDomain = {
        "com.apple.keyboard.fnState" = cfg.enableFnKeys;
      };
    };
  };
}