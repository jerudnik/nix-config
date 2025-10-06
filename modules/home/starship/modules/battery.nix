{ config, lib }:

let
  # Access Stylix colors for consistent theming
  inherit (config.lib.stylix) colors;
in {
  battery = {
    full_symbol = "󰂄";
    charging_symbol = "󰂄";
    discharging_symbol = "󰂃";
    unknown_symbol = "󰁽";
    empty_symbol = "󰂎";
    
    # Color-coded battery display based on charge level
    display = [
      {
        threshold = 15;  # Critical level - red
        style = "fg:#${colors.base08}";
        discharging_symbol = "󰂎";
      }
      {
        threshold = 30;  # Low level - orange  
        style = "fg:#${colors.base09}";
        discharging_symbol = "󰁻";
      }
      {
        threshold = 50;  # Medium level - yellow
        style = "fg:#${colors.base0A}";
        discharging_symbol = "󰁾";
      }
      {
        threshold = 80;  # Good level - green
        style = "fg:#${colors.base0B}";
        discharging_symbol = "󰂀";
      }
      {
        threshold = 100; # Full - blue
        style = "fg:#${colors.base0D}";
        discharging_symbol = "󰂂";
      }
    ];
    
    format = "[$symbol$percentage]($style) ";
    disabled = false;
  };
}