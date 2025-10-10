# Trackpad System Settings Pane
# This file defines OPTIONS ONLY for the Trackpad settings pane.
# The actual configuration is implemented in the parent default.nix aggregator.
# Note: These settings write to NSGlobalDomain.

{ lib, ... }:

with lib;

{
  options.darwin.system-defaults.trackpad = {
    naturalScrolling = mkOption {
      type = types.bool;
      default = false;
      description = "Enable natural scrolling (reversed scrolling direction)";
    };
  };
}
