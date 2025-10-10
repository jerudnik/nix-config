# CLI Tools Aggregator Module
# This module provides an abstract interface for modern CLI tool management.
# It defines "what" CLI tools do without specifying "how" they're implemented.
# Implementation is delegated to backend modules (e.g., home-manager-native.nix).

{ config, lib, ... }:

with lib;

let
  cfg = config.home.cli-tools;
in {
  imports = [
    ../starship  # Use the new modular starship configuration
    ./home-manager-native.nix  # Home-manager native programs implementation backend
  ];
  options.home.cli-tools = {
    enable = mkEnableOption "Modern CLI tools collection";
    
    fileManager = {
      eza = mkEnableOption "Modern ls replacement (eza)" // { default = true; };
      zoxide = mkEnableOption "Smart directory navigation (zoxide)" // { default = true; };
      fzf = mkEnableOption "Fuzzy finder (fzf)" // { default = true; };
    };
    
    textTools = {
      bat = mkEnableOption "Syntax-highlighted cat (bat)" // { default = true; };
      ripgrep = mkEnableOption "Fast text search (ripgrep)" // { default = true; };
      fd = mkEnableOption "Fast find alternative (fd)" // { default = true; };
    };
    
    # Note: Starship configuration is now in ../starship module
    # Use home.starship.enable to configure starship
    
    
    # Shell integration control
    enableShellIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Enable shell integration for CLI tools (may conflict with custom aliases)";
    };
    
    # Note: Aliases are managed by the shell module to avoid conflicts
    # This module focuses on tool installation and configuration only
    
    # Optional: Modern system monitor (recommended)
    systemMonitor = mkOption {
      type = types.enum [ "none" "htop" "btop" ];
      default = "htop";
      description = "System monitor to install (btop has better Stylix theming)";
    };
    
    # Shell enhancements
    shellEnhancements = {
      direnv = mkEnableOption "Directory-specific environment variables (direnv)" // { default = true; };
      atuin = mkEnableOption "Magical shell history (atuin)" // { default = true; };
      mcfly = mkEnableOption "Intelligent command history search (alternative to atuin)" // { default = false; };
      payRespects = mkEnableOption "Command correction tool (pay-respects, modern thefuck alternative)" // { default = true; };
    };
    
    # Git enhancements
    gitTools = {
      delta = mkEnableOption "Better git diff viewer (delta)" // { default = true; };
      gitui = mkEnableOption "Blazing fast terminal UI for git (alternative to lazygit)" // { default = false; };
    };
  };

  # No config section here - all implementation is delegated to backend modules
  # Backend modules (like home-manager-native.nix) will implement the actual CLI tool configuration logic
}