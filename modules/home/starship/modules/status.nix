{ config, lib, cmdDurationThreshold }:

let
  # Access Stylix colors for consistent theming
  inherit (config.lib.stylix) colors;
in {
  # Command execution time (right-side indicator)
  cmd_duration = {
    min_time = cmdDurationThreshold;  # Configurable threshold
    style = "fg:#${colors.base04}";
    format = "took [$duration]($style) ";
    
    # Show different icons based on duration
    show_milliseconds = false;
    disabled = false;
  };
  
  # Background jobs indicator
  jobs = {
    threshold = 1;
    symbol = "⚡";
    style = "fg:#${colors.base08}";
    format = "[$symbol$number]($style) ";
    
    # Alternative symbols for different job counts
    symbol_threshold = 4;
    number_threshold = 2;
    disabled = false;
  };
  
  # Exit status indicator (shows on command failure)
  status = {
    disabled = false;
    style = "fg:#${colors.base08}";
    symbol = "✘";
    success_symbol = "";  # Don't show anything on success
    format = "[$symbol$status]($style) ";
    
    # Map common exit codes to meaningful symbols
    map_symbol = true;
    pipestatus = true;  # Show pipestatus for command chains
    pipestatus_separator = "|";
    pipestatus_format = "[$pipestatus => $symbol$common_meaning$signal_name$maybe_int]($style)";
  };
  
  # Shell indicator (shows which shell is active)
  shell = {
    disabled = false;
    bash_indicator = "bsh";
    fish_indicator = "fsh"; 
    zsh_indicator = "zsh";
    powershell_indicator = "psh";
    ion_indicator = "ion";
    elvish_indicator = "esh";
    tcsh_indicator = "tsh";
    nu_indicator = "nu";
    xonsh_indicator = "xsh";
    cmd_indicator = "cmd";
    unknown_indicator = "?";
    style = "fg:#${colors.base06}";
    format = "[$indicator]($style) ";
  };
  
  # Environment variable indicators
  env_var = [
    {
      variable = "SHELL";
      default = "unknown";
      format = "with [$env_value]($style) ";
      style = "fg:#${colors.base05}";
      disabled = true;  # Disabled by default, can be enabled per-environment
    }
  ];
}