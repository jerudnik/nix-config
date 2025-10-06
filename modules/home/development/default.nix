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
      
      lazygit = mkEnableOption "Lazygit - simple terminal UI for git commands";
      
      extraUtils = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "Additional utility packages";
      };
    };
    
    github = {
      enable = mkEnableOption "GitHub CLI (gh) with shell completion";
    };
  };

  config = mkIf cfg.enable {
    # Configuration validations
    assertions = [
      {
        assertion = !(cfg.emacs && cfg.neovim);
        message = "Cannot enable both Emacs and Neovim. Choose one editor to avoid conflicts.";
      }
      {
        assertion = (cfg.editor == "emacs") -> cfg.emacs;
        message = "If editor is set to 'emacs', you must also enable 'development.emacs = true'.";
      }
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