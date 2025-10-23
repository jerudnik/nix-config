# modules/home/editors/zed.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.editors.zed;
in
{
  options.home.editors.zed = {
    enable = mkEnableOption "Enable Zed editor";
    extensions = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of Zed extensions to install";
    };
    enableGitHubCopilot = mkOption {
      type = types.bool;
      default = false;
      description = "Enable GitHub Copilot";
    };
    theme = mkOption {
      type = types.str;
      default = "Gruvbox Dark Hard";
      description = "Zed theme";
    };
    fontSize = mkOption {
      type = types.int;
      default = 14;
      description = "Font size";
    };
  };

  config = mkIf cfg.enable {
    programs.zed = {
      enable = true;
      extensions = cfg.extensions;
      settings = {
        theme = cfg.theme;
        "ui_font_size" = cfg.fontSize;
        "buffer_font_size" = cfg.fontSize;
        "copilot.enabled" = cfg.enableGitHubCopilot;
      };
    };
  };
}
