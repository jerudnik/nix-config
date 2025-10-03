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
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      
      shellAliases = {
        # Basic file operations
        ll = "ls -alF";
        la = "ls -A";
        l = "ls -CF";
        ".." = "cd ..";
        "..." = "cd ../..";
      } // (optionalAttrs cfg.enableNixShortcuts {
        # Nix shortcuts
        nrs = "sudo darwin-rebuild switch --flake ${cfg.configPath}#${cfg.hostName}";
        nrb = "darwin-rebuild build --flake ${cfg.configPath}#${cfg.hostName}";
        nfu = "nix flake update";
        nfc = "nix flake check";
        ngc = "nix-collect-garbage -d && sudo nix-collect-garbage -d";
      }) // cfg.aliases;
      
      oh-my-zsh = {
        enable = true;
        plugins = cfg.ohMyZsh.plugins;
        theme = cfg.ohMyZsh.theme;
      };
    };
    
    # Direnv for per-directory environments (essential for Nix development)
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}