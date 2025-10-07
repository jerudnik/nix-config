{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.darwin.theming;
in {
  options.darwin.theming = {
    enable = mkEnableOption "System-wide theming with Stylix";
    
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
      description = "Base16 color scheme to use from popular themes";
      example = "catppuccin-mocha";
    };
    
    # Automatic light/dark switching with theme pairs
    autoSwitch = {
      enable = mkEnableOption "Enable automatic light/dark theme switching based on macOS system appearance";
      
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
      description = "Wallpaper image to use for theming";
      example = literalExpression "./wallpapers/gruvbox-landscape.jpg";
    };
    
    # Note: Stylix automatically detects and themes installed applications
    # No manual target configuration needed!
    
    polarity = mkOption {
      type = types.enum [ "light" "dark" "either" ];
      default = "either";
      description = "Theme polarity - either allows automatic light/dark switching";
    };
    
    fonts = {
      monospace = {
        package = mkOption {
          type = types.nullOr types.package;
          default = null;
          description = "Monospace font package (iM-Writing Nerd Font provides iA Writer aesthetic with icons)";
        };
        
        name = mkOption {
          type = types.str;
          default = "iMWritingMono Nerd Font";
          description = "Monospace font name";
        };
      };
      
      sansSerif = {
        package = mkOption {
          type = types.nullOr types.package;
          default = null;
          description = "Sans-serif font package (iM-Writing Quat provides proportional iA Writer aesthetic)";
        };
        
        name = mkOption {
          type = types.str;
          default = "iMWritingQuat Nerd Font";
          description = "Sans-serif font name";
        };
      };
      
      serif = {
        package = mkOption {
          type = types.nullOr types.package;
          default = null;
          description = "Serif font package";
        };
        
        name = mkOption {
          type = types.str;
          default = "Charter";
          description = "Serif font name";
        };
      };
      
      sizes = {
        terminal = mkOption {
          type = types.int;
          default = 14;
          description = "Terminal font size";
        };
        
        applications = mkOption {
          type = types.int;
          default = 12;
          description = "Application font size";
        };
        
        desktop = mkOption {
          type = types.int;
          default = 11;
          description = "Desktop/UI font size";
        };
      };
    };
    
    # Note: Stylix automatically detects and themes available programs
    # No need to explicitly configure targets in most cases
  };

  config = mkIf cfg.enable {
    # Install base16-schemes for color scheme selection
    environment.systemPackages = with pkgs; [
      base16-schemes
    ] ++ lib.optionals cfg.autoSwitch.enable [
      # Theme switching utility
      (pkgs.writeShellScriptBin "nix-theme-switch" ''
        #!/usr/bin/env bash
        set -euo pipefail
        
        LIGHT_THEME="${cfg.autoSwitch.lightScheme}"
        DARK_THEME="${cfg.autoSwitch.darkScheme}"
        CONFIG_DIR="$(dirname "$0")/../.."
        CONFIG_FILE="$CONFIG_DIR/hosts/parsley/configuration.nix"
        
        # Get current macOS appearance
        APPEARANCE=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light")
        
        if [[ "$APPEARANCE" == "Dark" ]]; then
          TARGET_THEME="$DARK_THEME"
          echo "🌙 macOS is in Dark Mode - switching to: $TARGET_THEME"
        else
          TARGET_THEME="$LIGHT_THEME"
          echo "☀️  macOS is in Light Mode - switching to: $TARGET_THEME"
        fi
        
        echo "Current theme will be: $TARGET_THEME"
        echo ""
        echo "To apply automatic theme switching:"
        echo "1. Your config already has autoSwitch enabled"
        echo "2. Stylix will use polarity = 'either' to automatically adapt"
        echo "3. The base theme ($TARGET_THEME) provides the foundation"
        echo ""
        echo "💡 Tip: Change System Preferences > General > Appearance to test!"
      '')
    ];
    
    stylix = {
      enable = true;
      
      # Use configured color scheme
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.colorScheme}.yaml";
      
      # Wallpaper (optional)
      image = cfg.wallpaper;
      
      # Enable automatic light/dark switching within the theme
      polarity = cfg.polarity;
      
      # Font configuration
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.im-writing;
          name = cfg.fonts.monospace.name;
        };
        sansSerif = {
          package = pkgs.nerd-fonts.im-writing;
          name = cfg.fonts.sansSerif.name;
        };
        serif = {
          package = pkgs.texlivePackages.charter;
          name = cfg.fonts.serif.name;
        };
        sizes = {
          terminal = cfg.fonts.sizes.terminal;
          applications = cfg.fonts.sizes.applications;
          desktop = cfg.fonts.sizes.desktop;
        };
      };
      
      # Stylix will automatically theme detected programs
      # Let Stylix auto-detect and theme everything - no manual overrides needed
      # targets = {
      #   # Stylix auto-detects applications, so we don't need to configure this
      # };
    };
  };
}