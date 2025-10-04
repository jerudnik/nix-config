{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.cli-tools;
in {
  imports = [
    ./starship.nix
    ./alacritty.nix
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
    
    prompt = {
      starship = mkEnableOption "Cross-shell prompt (starship)" // { default = true; };
    };
    
    terminals = {
      alacritty = mkEnableOption "GPU-accelerated terminal (alacritty)" // { default = true; };
      warp = mkEnableOption "Warp terminal (managed via Homebrew cask)" // { default = false; }; # Managed in homebrew config, not Nix
    };
    
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
  };

  config = mkIf cfg.enable {
    # Install CLI tools
    # Note: Some tools (eza, zoxide, fzf, bat, starship, alacritty) are installed via programs.* 
    # configuration below, so they don't need to be in home.packages
    home.packages = with pkgs; []
      ++ optionals cfg.textTools.ripgrep [ ripgrep ]
      ++ optionals cfg.textTools.fd [ fd ]
      # System monitor (Stylix themes btop beautifully)
      ++ optional (cfg.systemMonitor == "htop") htop
      ++ optional (cfg.systemMonitor == "btop") btop
      # warp-terminal is managed via Homebrew cask, not Nix package
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
      
      # Note: Starship configuration is handled in ./starship.nix
      # Note: Alacritty configuration is handled in ./alacritty.nix
      # Note: System monitor (htop/btop) gets automatic Stylix theming when installed
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