# Fonts Aggregator Module
# This module provides an abstract interface for system font management.
# It defines "what" font management does without specifying "how" it's implemented.
# Implementation is delegated to backend modules (e.g., nix-fonts.nix).

{ config, lib, ... }:

with lib;

let
  cfg = config.darwin.fonts;
in {
  imports = [
    ./nix-fonts.nix       # Nix-darwin fonts implementation backend
  ];

  options.darwin.fonts = {
    enable = mkEnableOption "System font management";
    
    packages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional font packages to install system-wide";
      example = literalExpression "[ pkgs.fira-code ]";
    };
    
    iaWriter = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Install iA Writer font family (Mono and Quattro)";
      };
    };
    
    systemDefaults = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Install common system fonts (Charter, etc.)";
      };
    };
    
    # Nerd Fonts for terminal icons
    nerdFonts = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Install Nerd Fonts for terminal symbols";
      };
      
      fonts = mkOption {
        type = types.listOf types.str;
        default = [ 
          "IMWriting"        # iA Writer aesthetic with Nerd Font icons
          "FiraCode"
          "JetBrainsMono" 
          "Hack"
          "SourceCodePro"
          "Iosevka"
          "UbuntuMono"
        ];
        description = "List of Nerd Fonts to install for terminal use";
      };
      
      defaultMonospace = mkOption {
        type = types.str;
        default = "iMWritingMono Nerd Font";
        description = "Preferred monospace font for applications";
      };
    };
    
    # System font preferences
    systemPreferences = {
      enableFontSmoothing = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable font smoothing system-wide.
          
          This improves font rendering on external displays and with custom fonts.
          Note: macOS system UI fonts (menu bar, Finder, Dock) are hardcoded to
          San Francisco and cannot be changed via any API or configuration.
        '';
      };
      
      fontSmoothingStyle = mkOption {
        type = types.enum [ "automatic" "light" "medium" "strong" ];
        default = "medium";
        description = ''
          Font smoothing intensity:
          - automatic (0): Let macOS decide based on display
          - light (1): Minimal smoothing
          - medium (2): Balanced smoothing (recommended for Retina displays)
          - strong (3): Maximum smoothing (for non-Retina displays)
        '';
      };
    };
  };

  # No config section here - all implementation is delegated to backend modules
  # Backend modules (like nix-fonts.nix) will implement the actual font management logic
}
