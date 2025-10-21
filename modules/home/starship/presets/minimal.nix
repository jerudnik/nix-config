# Minimal Preset for Starship
# 
# Layout: Clean, simple prompt with minimal visual elements
# Colors: All colors sourced from Stylix (config.lib.stylix.colors)
#
# This is a LAYOUT PRESET, not a color theme.
# Colors automatically adapt to your Stylix theme (light/dark mode switching).

{ config, lib }:

with lib;

let
  # Access Stylix colors for consistent theming
  inherit (config.lib.stylix) colors;
in {
  # Minimal format - single line, essential info only
  format = concatStrings [
    "$directory"
    "$git_branch"
    "$git_status"
    "$character"
  ];
  
  # Keep prompt clean
  add_newline = true;
  
  # Directory
  directory = {
    style = "bold fg:#${colors.base0D}";
    format = "[$path]($style) ";
    truncation_length = 3;
    truncation_symbol = "…/";
  };
  
  # Git branch
  git_branch = {
    symbol = "";
    style = "fg:#${colors.base0E}";
    format = "[$symbol $branch]($style) ";
  };
  
  # Git status
  git_status = {
    style = "fg:#${colors.base08}";
    format = "[$all_status$ahead_behind]($style) ";
  };
  
  # Prompt character
  character = {
    success_symbol = "[❯](bold fg:#${colors.base0B})";
    error_symbol = "[❯](bold fg:#${colors.base08})";
    vicmd_symbol = "[❮](bold fg:#${colors.base0A})";
  };
}
