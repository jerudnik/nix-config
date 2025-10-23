# modules/home/version-control/default.nix
{ config, lib, ... }:

with lib;

let
  cfg = config.home.version-control;
in
{
  imports = [
    ./git.nix
  ];

  options.home.version-control = {
    enable = mkEnableOption "Enable version control tools";
  };

  config = mkIf cfg.enable {
    # High-level settings can go here
  };
}
