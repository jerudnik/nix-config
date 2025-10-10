# Shell Configuration Aggregator Module
# This module provides an abstract interface for shell configuration.
# It defines "what" shell configuration does without specifying "how" it's implemented.
# Implementation is delegated to backend modules (e.g., zsh.nix).
#
# SINGLE SOURCE OF TRUTH for shell aliases:
# - All aliases defined through this interface
# - Modern tool aliases conditional on availability
# - User aliases take highest priority
# - Other modules should NOT define shell aliases

{ config, lib, ... }:

with lib;

let
  cfg = config.home.shell;
in {
  imports = [
    ./zsh.nix  # Zsh/Oh-My-Zsh implementation backend
  ];

  options.home.shell = {
    enable = mkEnableOption "Shell configuration and environment";
    
    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = ''
        Custom shell aliases.
        These take highest priority and will override any other aliases.
      '';
      example = literalExpression ''
        {
          deploy = "cd ~/projects && ./deploy.sh";
          logs = "tail -f /var/log/system.log";
        }
      '';
    };
    
    modernTools = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable aliases for modern CLI tools.
          Requires tools to be installed (eza, bat, ripgrep, fd, etc.).
        '';
      };
      
      replaceLegacy = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Replace legacy commands with modern alternatives.
          ls→eza, cat→bat, grep→rg, find→fd, cd→z
        '';
      };
    };
    
    nixShortcuts = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''Enable convenient Nix operation shortcuts (nrs, nrb, nfu, etc.)'';
      };
      
      configPath = mkOption {
        type = types.str;
        default = "$HOME/nix-config";
        description = ''Path to nix configuration for shortcuts'';
      };
      
      hostName = mkOption {
        type = types.str;
        default = "parsley";
        description = ''Host name for nix rebuild shortcuts'';
      };
    };
    
    debugEnvironment = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable debugging output for environment loading.
        Helpful for troubleshooting PATH and application availability issues.
      '';
    };
  };

  # No config section here - all implementation is delegated to backend modules
  # Backend modules (like zsh.nix) will implement the actual shell configuration logic
}
