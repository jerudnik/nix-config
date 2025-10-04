{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.darwin.core;
in {
  options.darwin.core = {
    enable = mkEnableOption "Essential Darwin system packages and configuration";
    
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional system packages to install";
      example = literalExpression "[ pkgs.htop pkgs.neofetch ]";
    };
  };

  config = mkIf cfg.enable {
    # Essential system packages - minimal but necessary
    environment.systemPackages = with pkgs; [
      git     # Essential for system operations and nix
      curl    # Required for downloads and scripts  
      wget    # Basic network utility
      warp-terminal  # Modern terminal with AI features (unfree)
    ] ++ cfg.extraPackages;

    # System architecture
    nixpkgs.hostPlatform = "aarch64-darwin";
    
    # Shell configuration - enable zsh system-wide
    programs = {
      zsh.enable = true;
      bash.completion.enable = true;
    };
  };
}