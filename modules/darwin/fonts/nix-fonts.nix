# Nix Fonts Implementation Module
# This module implements font management using nix-darwin's built-in fonts system.
# It translates abstract font options into nix-darwin font configuration.

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.darwin.fonts;
  implCfg = cfg.implementation.nix-fonts;
in {
  options.darwin.fonts.implementation = {
    nix-fonts = {
      enable = mkEnableOption "Use nix-darwin fonts system for font management" // {
        default = true;
      };
    };
  };

  config = mkIf (cfg.enable && implCfg.enable) {
    fonts.packages = with pkgs; 
      # Base packages specified by user
      cfg.packages
      
      # iA Writer fonts (monospace and variable-width)
      ++ optionals cfg.iaWriter.enable [
        ia-writer-mono      # Monospace font
        ia-writer-quattro   # Variable-width font
      ]
      
      # System default fonts
      ++ optionals cfg.systemDefaults.enable [
        texlivePackages.charter  # Serif font
      ]
      
      # Nerd Fonts for terminal (enhanced selection)
      ++ optionals cfg.nerdFonts.enable (
        map (font: pkgs.nerd-fonts.${font}) (
          # Map font names to nerd-fonts package names
          map (font: 
            if font == "IMWriting" then "im-writing"
            else if font == "FiraCode" then "fira-code"
            else if font == "JetBrainsMono" then "jetbrains-mono" 
            else if font == "Hack" then "hack"
            else if font == "SourceCodePro" then "sauce-code-pro"
            else if font == "Iosevka" then "iosevka"
            else if font == "UbuntuMono" then "ubuntu-mono"
            else font
          ) cfg.nerdFonts.fonts
        )
      );
    
    # Fonts are automatically installed system-wide through fonts.packages
    # No activation scripts needed - nix-darwin handles this declaratively
    
    # System font preferences
    system.defaults.NSGlobalDomain = mkMerge [
      (mkIf cfg.systemPreferences.enableFontSmoothing {
        AppleFontSmoothing = 
          if cfg.systemPreferences.fontSmoothingStyle == "light" then 1
          else if cfg.systemPreferences.fontSmoothingStyle == "medium" then 2
          else if cfg.systemPreferences.fontSmoothingStyle == "strong" then 3
          else 0; # automatic
      })
    ];
  };
}
