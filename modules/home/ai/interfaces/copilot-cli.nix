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
    home.packages = [ 
      cfg.package 
      
      # Smart wrapper that handles authentication conflicts
      (pkgs.writeShellScriptBin "gh-copilot-auth" ''
        # GitHub Copilot CLI uses gh CLI's OAuth credentials
        # Temporarily unset GITHUB_TOKEN to prevent conflicts with environment secrets
        exec env -u GITHUB_TOKEN ${cfg.package}/bin/gh-copilot "$@"
      '')
    ];
    
    # Shell aliases for common usage patterns
    home.shellAliases = {
      # Ensure gh copilot subcommand uses OAuth credentials (not env token)
      "gh copilot" = "env -u GITHUB_TOKEN gh copilot";
      # Provide a convenient alias for the auth-aware wrapper  
      "copilot" = "gh-copilot-auth";
    };
    
    # Documentation for authentication setup
    xdg.configFile."gh-copilot/README.md".text = ''
      # GitHub Copilot CLI Authentication
      
      This tool uses GitHub CLI's stored OAuth credentials, not environment variables.
      
      ## Setup (One-time)
      1. Authenticate with GitHub CLI:
         ```bash
         gh auth login --web
         ```
      
      2. Install the Copilot extension:
         ```bash
         gh extension install github/gh-copilot
         ```
      
      ## Usage
      ```bash
      # Get command suggestions
      gh copilot suggest "find all nix files recursively"
      
      # Explain complex commands  
      gh copilot explain "find . -name '*.nix' -type f | xargs wc -l"
      
      # Or use the auth-aware wrapper
      gh-copilot-auth suggest "your prompt here"
      copilot suggest "your prompt here"  # convenient alias
      ```
      
      ## Authentication Design
      - Uses GitHub CLI's OAuth token store (not GITHUB_TOKEN env var)
      - Prevents conflicts with AI secrets management system
      - Ensures proper scopes and permissions for Copilot features
      
      ## Troubleshooting
      - If authentication fails, run: `gh auth status`
      - To refresh token: `gh auth refresh --scopes copilot`
      - Check extension: `gh extension list`
    '';
  };
}