# Appearance System Settings Pane
# This file defines OPTIONS ONLY for the Appearance settings pane.
# The actual configuration is implemented in the parent default.nix aggregator.
# Note: These settings write to NSGlobalDomain.

{ lib, ... }:

with lib;

{
  options.darwin.system-settings.appearance = {
    automaticSwitchAppearance = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically switch between light and dark mode";
    };
    
    hideMenuBar = mkOption {
      type = types.bool;
      default = false;
      description = "Hide the macOS menu bar";
    };
  };
}
