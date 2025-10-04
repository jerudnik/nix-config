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
          # Use iM-Writing Mono Nerd Font as default (iA Writer aesthetic with Nerd Font icons)
          normal = {
            family = mkDefault "iMWritingMonoNerdFont";
            style = mkDefault "Regular";
          };
          bold = {
            family = mkDefault "iMWritingMonoNerdFont";
            style = mkDefault "Bold";
          };
          italic = {
            family = mkDefault "iMWritingMonoNerdFont";
            style = mkDefault "Italic";
          };
          bold_italic = {
            family = mkDefault "iMWritingMonoNerdFont";
            style = mkDefault "Bold Italic";
          };
        };
        
        scrolling = {
          history = 10000;
          multiplier = 3;
        };
        
        mouse = {
          hide_when_typing = true;
        };
        
        selection = {
          save_to_clipboard = true;
        };
        
        cursor = {
          style = {
            shape = "Block";
            blinking = "On";
          };
          blink_interval = 500;
        };
        
        # Better rendering performance
        env = {
          TERM = "xterm-256color";
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