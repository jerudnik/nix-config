{ config, pkgs, lib, inputs, outputs, ... }:

{
  imports = [
    outputs.homeManagerModules.shell
    outputs.homeManagerModules.development
    outputs.homeManagerModules.git
    outputs.homeManagerModules.cli-tools
    outputs.homeManagerModules.spotlight
    outputs.homeManagerModules.window-manager
    # Enhanced SketchyBar with Lua configuration
    (import ./sketchybar.nix { inherit pkgs; })
  ];

  # Home Manager configuration
  home = {
    username = "jrudnik";
    homeDirectory = "/Users/jrudnik";
    stateVersion = "25.05";
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
  
  # Additional packages (moved warp to Homebrew cask)
  # home.packages = with pkgs; [ ];
  
  # Note: nixpkgs config is managed globally via useGlobalPkgs in flake.nix

  # Module configuration
  home = {
    shell = {
      enable = true;
      configPath = "~/nix-config";
      hostName = "parsley";
      # Can add custom aliases here if needed
      aliases = {
        # Example: deploy = "cd ~/projects && ./deploy.sh";
      };
    };
    
    development = {
      enable = true;
      languages = {
        rust = true;
        go = true;
        python = true;
      };
      editor = "micro";
      # Optional: Enable Emacs - it has excellent Stylix theming support!
      emacs = true;    # Emacs with automatic Stylix theming enabled!
      neovim = false;  # Alternative: Neovim with automatic theming
    };
    
    git = {
      enable = true;
      userName = "jrudnik";
      userEmail = "john.rudnik@gmail.com";
    };
    
    cli-tools = {
      enable = true;
      # All modern CLI tools with sensible defaults
      # Includes: eza, bat, ripgrep, fd, zoxide, fzf, starship, alacritty
      
      # Optional: Modern system monitor (btop has beautiful Stylix theming)
      systemMonitor = "btop";  # Options: "none", "htop", "btop"
    };
    
    spotlight = {
      enable = true;
      appsFolder = "Applications/home-manager";  # Home Manager apps folder
      linkSystemApps = true;  # Link system-level nix-darwin apps
      systemAppsFolder = "Applications/nix-darwin";  # System apps folder
      reindexInterval = "daily";  # Periodic reindexing
    };
    
    window-manager.aerospace = {
      enable = true;
      # Uses the default configuration from the module with:
      # - Alt-based keybindings
      # - Integration with SketchyBar
      # - Proper gaps for the status bar
      # - Warp terminal integration (Alt+Enter)
    };
    
  };
  
  # XDG directories
  xdg.enable = true;
}
