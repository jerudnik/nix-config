# modules/home/shell-prompt/default.nix
{ config, lib, ... }:

with lib;

let
  cfg = config.home.shell-prompt;
in
{
  imports = [
    ./starship.nix
  ];

  options.home.shell-prompt = {
    enable = mkEnableOption "Enable shell prompt customization";
  };

  config = mkIf cfg.enable {
    # High-level prompt settings can go here
  };
}
