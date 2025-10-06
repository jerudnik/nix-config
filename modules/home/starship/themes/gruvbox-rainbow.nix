{ config, lib }:

with lib;

let
  # Access Stylix colors for consistent theming
  inherit (config.lib.stylix) colors;
in {
  # Rainbow format - each section has a different background color
  format = concatStrings [
    "[](bg:#${colors.base09})"
    "$os"
    "$username"
    "[](bg:#${colors.base0A} fg:#${colors.base09})"
    "$directory"
    "[](fg:#${colors.base0A} bg:#${colors.base0B})"
    "$git_branch"
    "$git_status"
    "[](fg:#${colors.base0B} bg:#${colors.base0D})"
    "$nodejs"
    "$rust"
    "$golang"
    "$python"
    "$nix_shell"
    "[](fg:#${colors.base0D} bg:#${colors.base0C})"
    "$docker_context"
    "$package"
    "[](fg:#${colors.base0C} bg:#${colors.base08})"
    "$time"
    "[](fg:#${colors.base08})"
    " "
    "$cmd_duration"
    "$jobs"
    "$battery"
    "$status"
    "$character"
  ];
  
  # OS and username section (orange background)
  os = {
    disabled = false;
    style = "bg:#${colors.base09} fg:#${colors.base00}";
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
  
  username = {
    show_always = true;
    style_user = "bg:#${colors.base09} fg:#${colors.base00}";
    style_root = "bg:#${colors.base09} fg:#${colors.base00}";
    format = "[ $user ]($style)";
    disabled = false;
  };
  
  # Directory section (yellow background)
  directory = {
    style = "bg:#${colors.base0A} fg:#${colors.base00}";
    format = "[ $path ]($style)";
  };
  
  # Git section (green background)
  git_branch = {
    style = "bg:#${colors.base0B} fg:#${colors.base00}";
    format = "[ $symbol $branch ]($style)";
  };
  
  git_status = {
    style = "bg:#${colors.base0B} fg:#${colors.base00}";
    format = "[$all_status$ahead_behind ]($style)";
  };
  
  # Docker and package section (cyan background)
  docker_context = {
    symbol = " ";
    style = "bg:#${colors.base0C} fg:#${colors.base00}";
    format = "[ $symbol $context ]($style)";
    only_with_files = true;
  };
  
  package = {
    symbol = "󰏗 ";
    style = "bg:#${colors.base0C} fg:#${colors.base00}";
    format = "[ $symbol $version ]($style)";
  };
  
  # Time section (red background)
  time = {
    disabled = false;
    time_format = "%R";
    style = "bg:#${colors.base08} fg:#${colors.base00}";
    format = "[ 󰅐 $time ]($style)";
  };
  
  # Prompt character with Stylix colors
  character = {
    success_symbol = "[❯](bold fg:#${colors.base0B})";
    error_symbol = "[❯](bold fg:#${colors.base08})";
    vicmd_symbol = "[❮](bold fg:#${colors.base0A})";
  };
}