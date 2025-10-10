# Development Environment Home Manager Native Implementation Module
# This module implements development environment configuration using home-manager's native features.
# It translates abstract development options into concrete home-manager configuration.

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.development;
  implCfg = cfg.implementation.home-manager-native;
in {
  options.home.development.implementation = {
    home-manager-native = {
      enable = mkEnableOption "Use home-manager native development environment configuration" // {
        default = true;
      };
    };
  };

  config = mkIf (cfg.enable && implCfg.enable) {
    # Configuration validations
    assertions = [
      {
        assertion = (cfg.editor == "vim") -> cfg.neovim;
        message = "If editor is set to 'vim', you should enable 'development.neovim = true' for better experience.";
      }
      {
        assertion = (lib.length cfg.extraPackages) <= 50;
        message = "Too many extra packages (max 50). Consider organizing packages into separate modules.";
      }
      {
        assertion = !(cfg.languages.node && cfg.languages.python && cfg.languages.rust && cfg.languages.go) || (cfg.utilities.enableBasicUtils);
        message = "When enabling multiple languages, basic utilities (jq, tree) are strongly recommended for development workflows.";
      }
    ];
    
    home.packages = with pkgs; [
      # Editor (git, curl, wget are provided by darwin.core system module)
    ] ++ [ pkgs.${cfg.editor} ]
    
    # Basic utilities
    ++ optionals cfg.utilities.enableBasicUtils [
      tree      # Directory tree viewer
      jq        # JSON processor
    ]
    
    # Git utilities
    ++ optionals cfg.utilities.lazygit [
      lazygit   # Simple terminal UI for git commands
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
    
    # GitHub CLI
    ++ optionals cfg.github.enable [ gh ]
    
    # Extra packages
    ++ cfg.extraPackages
    ++ cfg.utilities.extraUtils;
    
    # Configure programs
    programs = mkMerge [
      # GitHub CLI with shell completion
      (mkIf cfg.github.enable {
        gh = {
          enable = true;
          settings = {
            git_protocol = "https";
            editor = cfg.editor;
          };
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
