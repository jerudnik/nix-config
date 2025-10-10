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
    ./nix-fonts.nix  # Nix-darwin fonts implementation backend
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
        description = "Enable font smoothing system-wide";
      };
      
      fontSmoothingStyle = mkOption {
        type = types.enum [ "automatic" "light" "medium" "strong" ];
        default = "automatic";
        description = "Font smoothing style preference";
      };
    };
  };

  # No config section here - all implementation is delegated to backend modules
  # Backend modules (like nix-fonts.nix) will implement the actual font management logic
}
