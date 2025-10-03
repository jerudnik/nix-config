{ config, pkgs, lib, inputs, outputs, ... }:

{
  # Home Manager configuration
  home = {
    username = "jrudnik";
    homeDirectory = "/Users/jrudnik";
    stateVersion = "25.05";
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Shell configuration
  programs = {
    # Zsh configuration
    zsh = {
      enable = true;
      enableCompletion = true;
      
      # Basic shell aliases
      shellAliases = {
        ll = "ls -alF";
        la = "ls -A";
        l = "ls -CF";
        ".." = "cd ..";
        "..." = "cd ../..";
        
        # Nix shortcuts
        nrs = "sudo darwin-rebuild switch --flake ~/nix-config#parsley";
        nrb = "darwin-rebuild build --flake ~/nix-config#parsley";
        nfu = "nix flake update";
        nfc = "nix flake check";
        ngc = "nix-collect-garbage -d && sudo nix-collect-garbage -d";
      };
      
      # Use built-in oh-my-zsh with minimal safe plugins
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"      # Safe built-in git shortcuts
          "macos"    # macOS specific commands
        ];
        theme = "robbyrussell";  # Safe built-in theme
      };
    };

    # Git configuration
    git = {
      enable = true;
      userName = "jrudnik";
      userEmail = "john.rudnik@gmail.com";
      
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = false;
        push.default = "simple";
      };
    };

    # Direnv for per-directory environments
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  # Essential packages
  home.packages = with pkgs; [
    # Development tools
    git
    curl
    wget
    
    # Text editor
    micro     # Modern, user-friendly terminal editor
    
    # Basic utilities  
    tree      # Directory tree viewer
    jq        # JSON processor
    
    # Development languages (from your original config)
    rustc
    cargo
    go
    python3
  ];

  # Essential environment variables
  home.sessionVariables = {
    EDITOR = "micro";
    # SHELL is managed by nix-darwin system configuration
  };

  # XDG directories
  xdg.enable = true;
}