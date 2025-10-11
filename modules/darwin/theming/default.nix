# Theming Aggregator Module
# This module provides an abstract interface for system-wide theming.
# It defines "what" theming does without specifying "how" it's implemented.
# Implementation is delegated to backend modules (e.g., stylix.nix).

{ config, lib, ... }:

with lib;

let
  cfg = config.darwin.theming;
in {
  imports = [
    ./stylix.nix  # Stylix implementation backend
  ];

  options.darwin.theming = {
    enable = mkEnableOption "System-wide theming";
    
    colorScheme = mkOption {
      type = types.enum [
        # Gruvbox variants
        "gruvbox-material-dark-medium" "gruvbox-material-light-medium"
        "gruvbox-dark-hard" "gruvbox-dark-medium" "gruvbox-dark-soft"
        "gruvbox-light-hard" "gruvbox-light-medium" "gruvbox-light-soft"
        # Catppuccin variants  
        "catppuccin-latte" "catppuccin-frappe" "catppuccin-macchiato" "catppuccin-mocha"
        # Tokyo Night variants
        "tokyo-night" "tokyo-night-dark" "tokyo-night-light" "tokyo-night-storm"
        # Nord and similar cool themes
        "nord" "one-dark" "dracula" "solarized-dark" "solarized-light"
        # Popular modern themes
        "rose-pine" "rose-pine-dawn" "rose-pine-moon"
        "kanagawa" "everforest" "github" "github-dark"
        # Monochrome options
        "black-metal" "white" "grayscale-dark" "grayscale-light"
      ];
      default = "gruvbox-material-dark-medium";
      description = ''
        Base16 color scheme to use for system-wide theming.
        This is an abstract option - the implementation backend will apply it.
      '';
      example = "catppuccin-mocha";
    };
    
    # Automatic light/dark switching with theme pairs
    autoSwitch = {
      enable = mkEnableOption ''
        Automatic light/dark theme switching based on system appearance.
        Implementation may vary by backend.
      '';
      
      lightScheme = mkOption {
        type = types.str;
        default = "gruvbox-material-light-medium";
        description = "Color scheme to use in light mode";
        example = "gruvbox-material-light-medium";
      };
      
      darkScheme = mkOption {
        type = types.str;
        default = "gruvbox-material-dark-medium";
        description = "Color scheme to use in dark mode";
        example = "gruvbox-material-dark-medium";
      };
    };
    
    wallpaper = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Wallpaper image to use for theming.
        Backend will extract colors and apply theme accordingly.
      '';
      example = literalExpression "./wallpapers/gruvbox-landscape.jpg";
    };
    
    polarity = mkOption {
      type = types.enum [ "light" "dark" "either" ];
      default = "either";
      description = ''
        Theme polarity preference:
        - "light": Force light theme
        - "dark": Force dark theme
        - "either": Allow automatic light/dark switching
      '';
    };
    
    fonts = {
      monospace = {
        package = mkOption {
          type = types.nullOr types.package;
          default = null;
          description = ''
            Monospace font package.
            If null, implementation will use its default.
          '';
        };
        
        name = mkOption {
          type = types.str;
          default = "iMWritingMono Nerd Font";
          description = "Monospace font name to use";
        };
      };
      
      sansSerif = {
        package = mkOption {
          type = types.nullOr types.package;
          default = null;
          description = ''
            Sans-serif font package.
            If null, implementation will use its default.
          '';
        };
        
        name = mkOption {
          type = types.str;
          default = "iMWritingQuat Nerd Font Propo";
          description = "Sans-serif font name to use";
        };
      };
      
      serif = {
        package = mkOption {
          type = types.nullOr types.package;
          default = null;
          description = ''
            Serif font package.
            If null, implementation will use its default.
          '';
        };
        
        name = mkOption {
          type = types.str;
          default = "Charter";
          description = "Serif font name to use";
        };
      };
      
      sizes = {
        terminal = mkOption {
          type = types.int;
          default = 14;
          description = "Font size for terminal applications";
        };
        
        applications = mkOption {
          type = types.int;
          default = 12;
          description = "Font size for GUI applications";
        };
        
        desktop = mkOption {
          type = types.int;
          default = 11;
          description = "Font size for desktop/UI elements";
        };
      };
    };
  };

  # No config section here - all implementation is delegated to backend modules
  # Backend modules (like stylix.nix) will implement the actual theming logic
}
