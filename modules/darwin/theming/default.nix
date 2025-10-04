{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.darwin.theming;
in {
  options.darwin.theming = {
    enable = mkEnableOption "System-wide theming with Stylix";
    
    colorScheme = mkOption {
      type = types.str;
      default = "gruvbox-material-dark-medium";
      description = "Base16 color scheme to use";
      example = "gruvbox-material-light-medium";
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
    stylix = {
      enable = true;
      
      # Base16 color scheme
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.colorScheme}.yaml";
      
      # Wallpaper (optional)
      image = cfg.wallpaper;
      
      # Theme polarity for auto light/dark switching
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
    
    # Install base16-schemes for color scheme selection
    environment.systemPackages = with pkgs; [
      base16-schemes
    ];
  };
}