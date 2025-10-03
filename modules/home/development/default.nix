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
      type = types.enum [ "micro" "nano" "vim" "code" ];
      default = "micro";
      description = "Default text editor";
    };
    
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
    
    # Extra packages
    ++ cfg.extraPackages
    ++ cfg.utilities.extraUtils;
    
    # Essential environment variables
    home.sessionVariables = {
      EDITOR = cfg.editor;
      # Note: SHELL is automatically managed by the system, do not override
    };
  };
}