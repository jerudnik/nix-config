# Development Environment Aggregator Module
# This module provides an abstract interface for development environment configuration.
# It defines "what" development environments do without specifying "how" they're implemented.
# Implementation is delegated to backend modules (e.g., home-manager-native.nix).

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.development;
in {
  imports = [
    ./home-manager-native.nix  # Home-manager native development environment implementation backend
  ];
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

  # No config section here - all implementation is delegated to backend modules
  # Backend modules (like home-manager-native.nix) will implement the actual development environment logic
}