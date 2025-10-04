{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.darwin.fonts;
in {
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
    
    systemDefaults = mkOption {
      type = types.bool;
      default = true;
      description = "Install common system fonts (Charter, etc.)";
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

  config = mkIf cfg.enable {
    fonts = {
      packages = with pkgs; 
        # Base packages specified by user
        cfg.packages
        
        # iA Writer fonts (monospace and variable-width)
        ++ optionals cfg.iaWriter.enable [
          ia-writer-mono      # Monospace font
          ia-writer-quattro   # Variable-width font
        ]
        
        # System default fonts
        ++ optionals cfg.systemDefaults [
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
    };
    
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