{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.programs.github-copilot-cli;
in {
  options.programs.github-copilot-cli = {
    enable = mkEnableOption "GitHub Copilot CLI - AI pair programmer in your terminal";
    
    package = mkOption {
      type = types.package;
      default = pkgs.gh-copilot;
      description = "The GitHub Copilot CLI package to use";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    
    # GitHub Copilot CLI requires authentication via GitHub CLI
    # 1. First install and auth with: gh auth login
    # 2. Then install copilot extension: gh extension install github/gh-copilot
    # 3. Usage: gh copilot suggest "git command to undo last commit"
    #          gh copilot explain "complex command here"
    
    # Note: Authentication is handled via gh CLI and doesn't require
    # additional API keys in the secrets system
  };
}