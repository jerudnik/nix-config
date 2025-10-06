{ config, lib }:

let
  # Access Stylix colors for consistent theming
  inherit (config.lib.stylix) colors;
in {
  # OS section
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
      Fedora = "󰣛";
      SUSE = "";
      Gentoo = "󰣨";
      CentOS = "";
      Alpine = "";
      Amazon = "";
    };
  };
  
  # Username section
  username = {
    show_always = false;  # Only show when SSH or root
    style_user = "bg:#${colors.base09} fg:#${colors.base00}";
    style_root = "bg:#${colors.base08} fg:#${colors.base00}";  # Red for root
    format = "[ $user ]($style)";
    disabled = false;
  };
  
  # SSH hostname indicator
  hostname = {
    ssh_only = true;
    ssh_symbol = "🌐";
    format = "[$ssh_symbol$hostname]($style) ";
    style = "fg:#${colors.base0E}";
    trim_at = ".";  # Remove domain suffix
    disabled = false;
  };
  
  # Memory usage (shows when high)
  memory_usage = {
    disabled = false;
    threshold = 75;
    symbol = "󰍛";
    style = "fg:#${colors.base08}";
    format = "$symbol [$ram( | $swap)]($style) ";
  };
  
  # Sudo indicator (shows when using sudo)
  sudo = {
    disabled = false;
    symbol = "🧙 ";
    style = "bg:#${colors.base08} fg:#${colors.base00}";
    format = "[ $symbol ]($style)";
  };
}