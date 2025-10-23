# modules/home/shell-prompt/starship.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.shell-prompt.starship;
in
{
  options.home.shell-prompt.starship = {
    enable = mkEnableOption "Enable Starship prompt";
    preset = mkOption {
      type = types.str;
      default = "powerline";
      description = "Starship preset";
    };
    showLanguages = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of languages to show in the prompt";
    };
    showSystemInfo = mkOption {
      type = types.bool;
      default = true;
      description = "Show system info";
    };
    showTime = mkOption {
      type = types.bool;
      default = true;
      description = "Show time";
    };
    showBattery = mkOption {
      type = types.bool;
      default = false;
      description = "Show battery status";
    };
    cmdDurationThreshold = mkOption {
      type = types.int;
      default = 4000;
      description = "Command duration threshold";
    };
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = {
        format = ''
          [](fg:green bg:gray)
          $username
          [](fg:gray bg:blue)
          $directory
          [](fg:blue bg:yellow)
          $git_branch
          $git_status
          [](fg:yellow bg:cyan)
          $c
          $rust
          $golang
          $nodejs
          $php
          $java
          [](fg:cyan bg:magenta)
          $time
          [](fg:magenta bg:gray)
        '';
      };
    };
  };
}
