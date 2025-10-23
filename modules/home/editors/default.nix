# modules/home/editors/default.nix
{ config, lib, ... }:

with lib;

let
  cfg = config.home.editors;
in
{
  imports = [
    ./zed.nix
  ];

  options.home.editors = {
    enable = mkEnableOption "Enable text editors";
  };

  config = mkIf cfg.enable {
    # High-level editor settings can go here
  };
}
