{ config, lib }:

let
  # Access Stylix colors for consistent theming
  inherit (config.lib.stylix) colors;
in {
  time = {
    disabled = false;
    time_format = "%R";  # 24-hour format (HH:MM)
    style = "bg:#${colors.base08} fg:#${colors.base00}";
    format = "[ 󰅐 $time ]($style)";
    
    # Alternative time formats (can be customized)
    # time_format = "%T";     # Full time with seconds (HH:MM:SS)
    # time_format = "%I:%M %p"; # 12-hour format with AM/PM
    # time_format = "%H:%M:%S %Z"; # With timezone
  };
}