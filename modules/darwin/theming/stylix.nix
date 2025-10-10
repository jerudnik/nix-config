# Stylix Implementation Module
# This module implements the theming interface using Stylix as the backend.
# It translates abstract theming options into Stylix-specific configuration.

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.darwin.theming;
in {
  options.darwin.theming.implementation = {
    stylix = {
      enable = mkEnableOption "Use Stylix as the theming implementation" // {
        default = true;
      };
    };
  };

  config = mkIf (cfg.enable && cfg.implementation.stylix.enable) {
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
    
    # Configure Stylix with abstract theming options
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
    };
  };
}
