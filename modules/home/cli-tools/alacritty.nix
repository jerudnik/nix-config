{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.cli-tools;
in {
  config = mkIf (cfg.enable && cfg.terminals.alacritty) {
    programs.alacritty = {
      enable = true;
      settings = {
        window = {
          decorations = "buttonless";
          dynamic_title = true;
          option_as_alt = "Both";
        };
        
        font = {
          size = mkDefault 14; # Will be overridden by Stylix if theming is enabled
        };
        
        mouse = {
          hide_when_typing = true;
        };
        
        selection = {
          save_to_clipboard = true;
        };
        
        # Shell integration
        terminal = {
          shell = {
            program = "${pkgs.zsh}/bin/zsh";
            args = [ "--login" ];
          };
        };
      };
    };
  };
}