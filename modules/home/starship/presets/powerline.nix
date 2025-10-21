# Powerline Preset for Starship
# 
# Layout: Powerline-style prompt with arrow separators and colored sections
# Colors: All colors sourced from Stylix (config.lib.stylix.colors)
# Inspired by: Starship's pastel-powerline preset
#
# This is a LAYOUT PRESET, not a color theme.
# Colors automatically adapt to your Stylix theme (light/dark mode switching).

{ config, lib }:

with lib;

let
  # Access Stylix colors for consistent theming
  inherit (config.lib.stylix) colors;
  
  # Powerline arrow separators
  arrow_right = "";
  arrow_left = "";
in {
  # Simplified powerline format - compact and clean
  format = concatStrings [
    "[ ](#${colors.base0E})"
    "$os"
    "$username"
    "[ ](fg:#${colors.base0E} bg:#${colors.base08})"
    "$directory"
    "$git_branch"
    "$git_status"
    "[ ](fg:#${colors.base09} bg:#${colors.base0A})"
    "$time"
    "[ ](#${colors.base0A}) "
    "$character"
  ];
  
  # Disable blank line at start
  add_newline = false;
  
  # OS symbol (purple/magenta section)
  os = {
    disabled = false;
    style = "bg:#${colors.base0E}";
    symbols = {
      Macos = "󰀵";
      Linux = "󰌽";
      Windows = "󰍲";
      Ubuntu = "󰕈";
      Debian = "󰣚";
      Arch = "󰣇";
      NixOS = "󱄅";
    };
  };
  
  # Username (purple/magenta section)
  username = {
    show_always = true;
    style_user = "bg:#${colors.base0E} fg:#${colors.base00}";
    style_root = "bg:#${colors.base0E} fg:#${colors.base00}";
    format = "[ $user ](${"$"}style)";
    disabled = false;
  };
  
  # Directory (red section)
  directory = {
    style = "bg:#${colors.base08} fg:#${colors.base00}";
    format = "[ $path ](${"$"}style)";
    truncation_length = 2;
    truncation_symbol = "…/";
    
    substitutions = {
      "Documents" = "󰈙 ";
      "Downloads" = " ";
      "Music" = " ";
      "Pictures" = " ";
      "Developer" = "󰲋 ";
      "Projects" = "󰲋 ";
      "Desktop" = "󰇄 ";
      "~" = " ";
    };
  };
  
  # Git branch (orange section)
  git_branch = {
    symbol = "";
    style = "bg:#${colors.base09} fg:#${colors.base00}";
    format = "[ ](fg:#${colors.base08} bg:#${colors.base09})[ $symbol $branch ](${"$"}style)";
  };
  
  # Git status (orange section)
  git_status = {
    style = "bg:#${colors.base09} fg:#${colors.base00}";
    format = "[$all_status$ahead_behind ](${"$"}style)";
  };
  
  # Programming languages (blue section)
  c = {
    symbol = " ";
    style = "bg:#${colors.base0D} fg:#${colors.base00}";
    format = "[ $symbol($version) ](${"$"}style)";
  };
  
  elixir = {
    symbol = " ";
    style = "bg:#${colors.base0D} fg:#${colors.base00}";
    format = "[ $symbol($version) ](${"$"}style)";
  };
  
  elm = {
    symbol = " ";
    style = "bg:#${colors.base0D} fg:#${colors.base00}";
    format = "[ $symbol($version) ](${"$"}style)";
  };
  
  golang = {
    symbol = " ";
    style = "bg:#${colors.base0D} fg:#${colors.base00}";
    format = "[ $symbol($version) ](${"$"}style)";
  };
  
  gradle = {
    style = "bg:#${colors.base0D} fg:#${colors.base00}";
    format = "[ $symbol($version) ](${"$"}style)";
  };
  
  haskell = {
    symbol = " ";
    style = "bg:#${colors.base0D} fg:#${colors.base00}";
    format = "[ $symbol($version) ](${"$"}style)";
  };
  
  java = {
    symbol = " ";
    style = "bg:#${colors.base0D} fg:#${colors.base00}";
    format = "[ $symbol($version) ](${"$"}style)";
  };
  
  julia = {
    symbol = " ";
    style = "bg:#${colors.base0D} fg:#${colors.base00}";
    format = "[ $symbol($version) ](${"$"}style)";
  };
  
  nodejs = {
    symbol = "";
    style = "bg:#${colors.base0D} fg:#${colors.base00}";
    format = "[ $symbol($version) ](${"$"}style)";
  };
  
  nim = {
    symbol = "󰆥 ";
    style = "bg:#${colors.base0D} fg:#${colors.base00}";
    format = "[ $symbol($version) ](${"$"}style)";
  };
  
  rust = {
    symbol = "";
    style = "bg:#${colors.base0D} fg:#${colors.base00}";
    format = "[ $symbol($version) ](${"$"}style)";
  };
  
  scala = {
    symbol = " ";
    style = "bg:#${colors.base0D} fg:#${colors.base00}";
    format = "[ $symbol($version) ](${"$"}style)";
  };
  
  python = {
    symbol = "";
    style = "bg:#${colors.base0D} fg:#${colors.base00}";
    format = "[ $symbol($version) ](${"$"}style)";
  };
  
  # Nix shell indicator
  nix_shell = {
    disabled = false;
    symbol = "❄️ ";
    style = "bg:#${colors.base0D} fg:#${colors.base00}";
    format = "[ $symbol ](${"$"}style)";
  };
  
  # Docker context (cyan section)
  docker_context = {
    symbol = " ";
    style = "bg:#${colors.base0C} fg:#${colors.base00}";
    format = "[ $symbol$context ](${"$"}style)";
    only_with_files = true;
  };
  
  # Time (yellow section)
  time = {
    disabled = false;
    time_format = "%R"; # Hour:Minute Format
    style = "bg:#${colors.base0A} fg:#${colors.base00}";
    format = "[ 󰅐 $time ](${"$"}style)";
  };
  
  # Prompt character (on new line for cleaner input)
  character = {
    success_symbol = "[❯](bold fg:#${colors.base0B})";
    error_symbol = "[❯](bold fg:#${colors.base08})";
    vicmd_symbol = "[❮](bold fg:#${colors.base0A})";
  };
  
  # Command duration (shown after prompt)
  cmd_duration = {
    min_time = 4000;
    format = "[ $duration](fg:#${colors.base03})";
  };
  
  # Status indicator
  status = {
    disabled = false;
    format = "[ $symbol$status](fg:#${colors.base08})";
  };
}
