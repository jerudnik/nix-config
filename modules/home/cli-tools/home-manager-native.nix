# CLI Tools Home Manager Native Implementation Module
# This module implements CLI tool configuration using home-manager's native programs.
# It translates abstract CLI tool options into concrete home-manager configuration.

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.cli-tools;
  implCfg = cfg.implementation.home-manager-native;
in {
  options.home.cli-tools.implementation = {
    home-manager-native = {
      enable = mkEnableOption "Use home-manager native program configurations" // {
        default = true;
      };
    };
  };

  config = mkIf (cfg.enable && implCfg.enable) {
    # Install CLI tools
    # Note: Some tools (eza, zoxide, fzf, bat, starship) are installed via programs.* 
    # configuration below, so they don't need to be in home.packages
    home.packages = with pkgs; []
      ++ optionals cfg.textTools.ripgrep [ ripgrep ]
      ++ optionals cfg.textTools.fd [ fd ]
      # System monitor (Stylix themes btop beautifully)
      ++ optional (cfg.systemMonitor == "htop") htop
      ++ optional (cfg.systemMonitor == "btop") btop
      # Shell enhancements
      ++ optional cfg.shellEnhancements.payRespects pay-respects
      # Git tools
      ++ optional cfg.gitTools.delta delta
      ++ optional cfg.gitTools.gitui gitui
      # warp-terminal is installed system-wide via darwin.core module
      ;
    
    # Configure individual tools
    # Note: These programs.* configurations handle both package installation and shell integration
    # Shell aliases for these tools are managed by the shell module to avoid conflicts
    # Complex tools (starship, alacritty) are configured in separate submodules
    programs = {
      # Eza (modern ls)
      eza = mkIf cfg.fileManager.eza {
        enable = true;
        enableZshIntegration = cfg.enableShellIntegration;
        git = true;
        icons = "auto";
      };
      
      # Zoxide (smart cd)
      # NOTE: Zoxide shell integration is handled manually in shell module to avoid conflicts
      zoxide = mkIf cfg.fileManager.zoxide {
        enable = true;
        enableZshIntegration = false;  # Handled manually in shell module
      };
      
      # Fzf (fuzzy finder)
      fzf = mkIf cfg.fileManager.fzf {
        enable = true;
        enableZshIntegration = cfg.enableShellIntegration;
        # Only set defaultCommand if fd is enabled, otherwise use default
        defaultCommand = optionalString cfg.textTools.fd "fd --type f";
      };
      
      # Bat (syntax-highlighted cat)
      bat = mkIf cfg.textTools.bat {
        enable = true;
        config = {
          theme = mkDefault "base16"; # Will be themed by Stylix
          style = mkDefault "numbers,changes,header";
          pager = mkDefault "less -FR";
        };
      };
      
      # Direnv (directory-specific environments)
      direnv = mkIf cfg.shellEnhancements.direnv {
        enable = true;
        enableZshIntegration = cfg.enableShellIntegration;
        nix-direnv.enable = true; # Better Nix support
      };
      
      # Atuin (magical shell history)
      atuin = mkIf cfg.shellEnhancements.atuin {
        enable = true;
        enableZshIntegration = cfg.enableShellIntegration;
        settings = {
          auto_sync = true;
          sync_frequency = "10m";
          sync_address = "https://api.atuin.sh";
          search_mode = "fuzzy";
          filter_mode_shell_up_key_binding = "directory";
          show_preview = true;
          max_preview_height = 4;
          exit_mode = "return-original";
          word_jump_mode = "emacs";
          scroll_context_lines = 1;
        };
      };
      
      # McFly (alternative to atuin)
      mcfly = mkIf cfg.shellEnhancements.mcfly {
        enable = true;
        enableZshIntegration = cfg.enableShellIntegration;
        keyScheme = "emacs";
        fuzzySearchFactor = 2;
      };
      
      # Note: Starship configuration is now handled in ../starship module
      # Note: System monitor (htop/btop) gets automatic Stylix theming when installed
      # Note: pay-respects, delta, gitui are installed as packages (no special config needed)
      # Note: lazygit is available via development module utilities.lazygit option
    };
    
    # Note: Shell aliases are managed by the shell module
    
    # Environment variables
    home.sessionVariables = mkMerge [
      # Bat theme (will be overridden by Stylix if enabled)
      (mkIf cfg.textTools.bat {
        BAT_THEME = mkDefault "base16";
      })
      
      # Fzf default options (use mkDefault to allow Stylix to override)
      (mkIf cfg.fileManager.fzf {
        FZF_DEFAULT_OPTS = mkDefault "--height 40% --layout=reverse --border";
      })
    ];
  };
}
