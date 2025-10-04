# Shell configuration module
#
# This module is the SINGLE SOURCE OF TRUTH for all shell aliases.
# 
# Alias Management Strategy:
# - All aliases are defined here to avoid conflicts
# - Modern tool aliases are conditional based on tool availability
# - User aliases take highest priority
# - Other modules should NOT define shell aliases
#
# Alias Categories:
# - Navigation: .., ..., cd → z
# - File operations: ls → eza, cat → bat
# - Text search: grep → rg, find → fd  
# - Nix operations: nrs, nrb, nfu, etc.
# - User custom: defined in configuration

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.shell;
in {
  options.home.shell = {
    enable = mkEnableOption "Shell configuration with Zsh and oh-my-zsh";
    
    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Custom shell aliases";
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
        description = "Enable aliases for modern CLI tools (requires tools to be installed)";
      };
      
      replaceLegacy = mkOption {
        type = types.bool;
        default = true;
        description = "Replace legacy commands (ls, cat, grep, find) with modern alternatives";
      };
    };
    
    ohMyZsh = {
      theme = mkOption {
        type = types.str;
        default = "robbyrussell";
        description = "Oh My Zsh theme to use";
      };
      
      plugins = mkOption {
        type = types.listOf types.str;
        default = [ "git" "macos" ];
        description = "Oh My Zsh plugins to enable";
      };
    };
    
    enableNixShortcuts = mkOption {
      type = types.bool;
      default = true;
      description = "Enable convenient Nix operation shortcuts";
    };
    
    configPath = mkOption {
      type = types.str;  # Use str since we need to interpolate in shell aliases
      default = "$HOME/nix-config";
      description = "Path to nix configuration for shortcuts";
    };
    
    hostName = mkOption {
      type = types.str;
      default = "parsley";
      description = "Host name for nix shortcuts";
    };
    
    debugEnvironment = mkOption {
      type = types.bool;
      default = false;
      description = "Enable debugging output for environment loading (helpful for troubleshooting PATH issues)";
    };
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      
      shellAliases = {
        # Navigation shortcuts
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        
        # Basic file operations (will be overridden by modern tools if enabled)
        ll = "ls -alF";
        la = "ls -A";
        l = "ls -CF";
      } // (optionalAttrs cfg.enableNixShortcuts {
        # Nix shortcuts
        nrs = "sudo darwin-rebuild switch --flake ${cfg.configPath}#${cfg.hostName}";
        nrb = "darwin-rebuild build --flake ${cfg.configPath}#${cfg.hostName}";
        nfu = "nix flake update";
        nfc = "nix flake check";
        ngc = "nix-collect-garbage -d && sudo nix-collect-garbage -d";
        # Environment refresh utilities
        refresh-env = "exec zsh";  # Restart shell to reload environment
        reload-path = "source ~/.zshrc";  # Reload shell configuration
      }) // (optionalAttrs (cfg.modernTools.enable && cfg.modernTools.replaceLegacy) {
        # Modern CLI tool replacements
        ls = "eza";
        ll = "eza -la";
        la = "eza -A";
        tree = "eza --tree";
        cat = "bat";
        grep = "rg";
        find = "fd";
        # cd = "z" is handled by zoxide shell integration below
      }) // (optionalAttrs cfg.modernTools.enable {
        # Modern CLI tool shortcuts (non-conflicting)
        exa = "eza";  # Legacy eza name
        rg = "rg";
        fd = "fd";
        # z is handled by zoxide shell integration, don't override it
        zi = "zoxide query -i";  # Interactive zoxide
        zb = "zoxide query -l";  # List zoxide database
      }) // cfg.aliases;
      
      oh-my-zsh = {
        enable = true;
        plugins = cfg.ohMyZsh.plugins;
        theme = cfg.ohMyZsh.theme;
      };
      
      # Initialize zoxide and environment after all other configuration
      initContent = mkIf cfg.modernTools.enable ''
        ${optionalString cfg.debugEnvironment "echo \"[DEBUG] Loading Nix environment profiles...\""}
        # Ensure all Nix profiles are properly sourced
        # This fixes common application availability issues
        for profile in /nix/var/nix/profiles/default ~/.nix-profile /etc/profiles/per-user/$USER; do
          if [ -f "$profile/etc/profile.d/nix.sh" ]; then
            ${optionalString cfg.debugEnvironment "echo \"[DEBUG] Sourcing $profile/etc/profile.d/nix.sh\""}
            source "$profile/etc/profile.d/nix.sh"
          fi
        done
        
        # Source home-manager session variables if they exist
        if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
          ${optionalString cfg.debugEnvironment "echo \"[DEBUG] Sourcing home-manager session variables\""}
          source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
        fi
        
        ${optionalString cfg.debugEnvironment "echo \"[DEBUG] PATH: $PATH\""}
        
        # Ensure zoxide creates its functions properly, then alias cd to z
        if command -v zoxide >/dev/null 2>&1; then
          eval "$(zoxide init zsh)"
          alias cd="z"
        fi
      '';
    };
    
    # Direnv for per-directory environments (essential for Nix development)
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    
    # Session variables to ensure proper PATH and environment
    home.sessionVariables = {
      # Ensure user profile is prioritized in PATH
      NIX_PATH = mkDefault "nixpkgs=$HOME/.nix-defexpr/channels/nixpkgs:$NIX_PATH";
    };
    
    # Additional session paths that commonly get missed
    home.sessionPath = [
      "$HOME/.nix-profile/bin"
      "/etc/profiles/per-user/$USER/bin"
    ];
  };
}