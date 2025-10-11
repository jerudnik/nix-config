{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.editors.zed;
in {
  options.home.editors.zed = {
    enable = mkEnableOption "Zed Text Editor";

    settings = mkOption {
      type = with types; attrsOf (oneOf [ bool str int (listOf str) ]);
      default = {};
      description = "Custom settings for Zed's settings.json.";
    };
  };

  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      userSettings = {
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
      } // cfg.settings;
    };
  };
}
