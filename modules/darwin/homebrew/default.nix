{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.darwin.homebrew;
in {
  options.darwin.homebrew = {
    enable = mkEnableOption "Homebrew package management via nix-homebrew";
    
    brews = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of Homebrew formulae to install";
      example = literalExpression ''[ "htop" "neovim" "ripgrep" ]'';
    };
    
    casks = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of Homebrew casks to install";
      example = literalExpression ''[ "firefox" "visual-studio-code" "discord" ]'';
    };
    
    masApps = mkOption {
      type = types.attrsOf types.int;
      default = {};
      description = "Mac App Store apps to install (name = app store id)";
      example = literalExpression ''{
        "1Password 7" = 1333542190;
        "Logic Pro" = 634148309;
      }'';
    };
    
    onActivation = {
      autoUpdate = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to automatically update Homebrew and its packages";
      };
      
      upgrade = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to upgrade packages on activation";
      };
      
      cleanup = mkOption {
        type = types.enum [ "none" "uninstall" "zap" ];
        default = "none";
        description = "Cleanup strategy for unused packages";
      };
    };
  };

  config = mkIf cfg.enable {
    # Configure homebrew packages (nix-homebrew handles installation)
    homebrew = {
      enable = true;
      
      # Package lists
      brews = cfg.brews;
      casks = cfg.casks;
      masApps = cfg.masApps;
      
      # Activation behavior
      onActivation = {
        autoUpdate = cfg.onActivation.autoUpdate;
        upgrade = cfg.onActivation.upgrade;
        cleanup = cfg.onActivation.cleanup;
      };
      
      # Global settings
      global = {
        brewfile = true;  # Enable Brewfile support
      };
    };
  };
}