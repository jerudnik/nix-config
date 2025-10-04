{ config, pkgs, lib, inputs, outputs, ... }:

{
  imports = [
    outputs.homeManagerModules.shell
    outputs.homeManagerModules.development
    outputs.homeManagerModules.git
    outputs.homeManagerModules.cli-tools
    # Spotlight module removed - using Raycast for app launching
    outputs.homeManagerModules.window-manager
    outputs.homeManagerModules.raycast
  ];

  # Home Manager configuration
  home = {
    username = "jrudnik";
    homeDirectory = "/Users/jrudnik";
    stateVersion = "25.05";
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
  
  # Additional packages - most packages managed via modules
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
    
    # Spotlight module removed - using Raycast for app launching
    # Apps appear in standard locations automatically:
    # - Home Manager apps: ~/Applications/Home Manager Apps
    # - nix-darwin system apps: /Applications/Nix Apps
    
    window-manager.aerospace = {
      enable = true;
      # Uses the default configuration from the module with:
      # - Alt-based keybindings
      # - Clean window gaps and layout
      # - Warp terminal integration (Alt+Enter)
    };
    
    raycast = {
      enable = true;
      followSystemAppearance = true;
      globalHotkey = {
        keyCode = 49;        # Space key
        modifierFlags = 1048576;  # Command modifier (Cmd+Space)
      };
    };
    
  };
  
  # XDG directories
  xdg.enable = true;
}
