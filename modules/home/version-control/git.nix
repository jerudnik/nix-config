# modules/home/version-control/git.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.version-control.git;
in
{
  options.home.version-control.git = {
    enable = mkEnableOption "Enable git";
    userName = mkOption {
      type = types.str;
      description = "Git user name";
    };
    userEmail = mkOption {
      type = types.str;
      description = "Git user email";
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;
    };
  };
}
