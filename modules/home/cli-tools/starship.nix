{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.cli-tools;
in {
  config = mkIf (cfg.enable && cfg.prompt.starship) {
    programs.starship = {
      enable = true;
      enableZshIntegration = cfg.enableShellIntegration;
      settings = {
        # Minimal, fast configuration
        add_newline = false;
        format = concatStrings [
          "$directory"
          "$git_branch"
          "$git_state"
          "$git_status"
          "$cmd_duration"
          "$line_break"
          "$jobs"
          "$character"
        ];
        
        directory = {
          style = "blue";
          truncation_length = 3;
          truncate_to_repo = true;
        };
        
        git_branch = {
          style = "bright-black";
          format = "[$symbol$branch]($style) ";
        };
        
        git_status = {
          style = "bright-black";
          format = "([\\[$all_status$ahead_behind\\]]($style) )";
        };
        
        cmd_duration = {
          style = "yellow";
          format = "[$duration]($style) ";
          disabled = false;
          min_time = 2000;
        };
        
        character = {
          success_symbol = "[❯](green)";
          error_symbol = "[❯](red)";
        };
      };
    };
  };
}