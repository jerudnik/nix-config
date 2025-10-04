{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.development;
in {
  options.home.development = {
    enable = mkEnableOption "Development environment and tools";
    
    languages = {
      rust = mkEnableOption "Rust development tools";
      go = mkEnableOption "Go development tools";  
      python = mkEnableOption "Python development tools";
      node = mkEnableOption "Node.js development tools";
    };
    
    editor = mkOption {
      type = types.enum [ "micro" "nano" "vim" "emacs" ];
      default = "micro";
      description = "Default text editor";
    };
    
    # Optional: enable editors with excellent Stylix theming
    emacs = mkEnableOption "Emacs with excellent Stylix theming";
    neovim = mkEnableOption "Neovim with Stylix theming (alternative to Emacs)";
    
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional development packages";
      example = literalExpression "[ pkgs.docker pkgs.kubectl ]";
    };
    
    utilities = {
      enableBasicUtils = mkOption {
        type = types.bool;
        default = true;
        description = "Enable basic development utilities (tree, jq, etc.)";
      };
      
      extraUtils = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "Additional utility packages";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Always include git and basic tools
      git curl wget
    ] 
    # Editor
    ++ [ pkgs.${cfg.editor} ]
    
    # Basic utilities
    ++ optionals cfg.utilities.enableBasicUtils [
      tree      # Directory tree viewer
      jq        # JSON processor
    ]
    
    # Language-specific tools
    ++ optionals cfg.languages.rust [
      rustc cargo
    ]
    ++ optionals cfg.languages.go [
      go
    ]
    ++ optionals cfg.languages.python [
      python3
    ]
    ++ optionals cfg.languages.node [
      nodejs yarn
    ]
    
    # Optional editor packages
    # Note: Emacs is handled by programs.emacs, not direct package installation
    ++ optionals cfg.neovim [ neovim ]
    
    # Extra packages
    ++ cfg.extraPackages
    ++ cfg.utilities.extraUtils;
    
    # Configure editors with theming support where applicable
    programs = mkMerge [
      # Emacs with Stylix theming (Stylix has excellent Emacs support)
      (mkIf cfg.emacs {
        emacs = {
          enable = true;
          # Stylix will automatically apply colors, fonts, and generate theme
          # No additional configuration needed - Stylix handles everything!
        };
      })
      
      # Neovim with Stylix theming (alternative to Emacs)
      (mkIf cfg.neovim {
        neovim = {
          enable = true;
          defaultEditor = mkIf (cfg.editor == "neovim") true;
          # Stylix will automatically apply colors and fonts
        };
      })
    ];
    
    # Essential environment variables
    home.sessionVariables = {
      EDITOR = cfg.editor;
      # Note: SHELL is automatically managed by the system, do not override
    };
  };
}