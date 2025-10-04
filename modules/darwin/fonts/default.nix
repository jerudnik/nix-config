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
        ];
    };
    
    # Ensure fonts are available system-wide
    # This makes them available to all applications, including Alacritty
    system.activationScripts.fonts = {
      text = ''
        echo "Activating system fonts..."
        # The fonts.packages configuration automatically handles system font installation
      '';
    };
  };
}