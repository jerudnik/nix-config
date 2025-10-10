# Zsh Implementation Module
# This module implements the shell interface using Zsh and Oh-My-Zsh.
# It translates abstract shell options into Zsh-specific configuration.

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.shell;
  zshCfg = cfg.implementation.zsh;
in {
  options.home.shell.implementation = {
    zsh = {
      enable = mkEnableOption "Use Zsh with Oh-My-Zsh as the shell implementation" // {
        default = true;
      };
      
      theme = mkOption {
        type = types.enum [ 
          "robbyrussell" "agnoster" "powerlevel10k" "spaceship"
          "pure" "minimal" "refined" "gallois" "bira" "clean"
          "daveverwer" "dieter" "dogenpunk" "dpoggi" "dst"
          "duellj" "eastwood" "essembeh" "evan" "fishy"
          "flazz" "fox" "frisk" "fwalch" "gallifrey"
          "garyblessington" "gentoo" "geoffgarside" "gianu"
          "gnzh" "gozilla" "half-life" "humza" "imajes"
          "intheloop" "itchy" "jaischeema" "jbergantine"
          "jispwoso" "jnrowe" "jonathan" "josh" "jreese"
          "jtriley" "juanghurtado" "junkfood" "kafeitu"
          "kardan" "kennethreitz" "kiwi" "kolo" "kphoen"
          "lambda" "linuxonly" "lukerandall" "macovsky"
          "maran" "mh" "michelebologna" "miloshadzic"
          "mortalscumbag" "mrtazz" "murilasso" "muse"
          "nanotech" "nebirhos" "nicoulaj" "norm"
          "obraun" "peepcode" "philips" "pmcgee"
          "re5et" "rgm" "risto" "rkj" "rkj-repos"
          "sammy" "simple" "simonoff" "sonicradish"
          "sorin" "sporty_256" "steeef" "strug"
          "sunaku" "sunrise" "superjarin" "suvash"
          "takashiyoshida" "terminalparty" "theunraveler"
          "tjkirch" "tonotdo" "trapd00r" "wedisagree"
          "wezm" "wezm+" "xiong-chiamiov" "xiong-chiamiov-plus"
          "ys" "zhann" 
        ];
        default = "robbyrussell";
        description = "Oh My Zsh theme to use from available themes";
      };
      
      plugins = mkOption {
        type = types.listOf types.str;
        default = [ "git" "macos" ];
        description = "Oh My Zsh plugins to enable";
      };
    };
  };

  config = mkIf (cfg.enable && zshCfg.enable) {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      
      shellAliases = {
        # Basic navigation from abstract config
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        
        # Basic file operations
        ll = "ls -alF";
        la = "ls -A";
        l = "ls -CF";
      } // (optionalAttrs cfg.nixShortcuts.enable {
        # Nix operation shortcuts
        nrs = "sudo darwin-rebuild switch --flake ${cfg.nixShortcuts.configPath}#${cfg.nixShortcuts.hostName}";
        nrb = "darwin-rebuild build --flake ${cfg.nixShortcuts.configPath}#${cfg.nixShortcuts.hostName}";
        nfu = "nix flake update";
        nfc = "nix flake check";
        ngc = "nix-collect-garbage -d && sudo nix-collect-garbage -d";
        # Environment refresh utilities
        refresh-env = "exec zsh";
        reload-path = "source ~/.zshrc";
      }) // (optionalAttrs (cfg.modernTools.enable && cfg.modernTools.replaceLegacy) {
        # Modern CLI tool replacements
        ls = "eza";
        ll = "eza -la";
        la = "eza -A";
        tree = "eza --tree";
        cat = "bat";
        grep = "rg";
        find = "fd";
      }) // (optionalAttrs cfg.modernTools.enable {
        # Modern CLI tool shortcuts (non-conflicting)
        exa = "eza";
        rg = "rg";
        fd = "fd";
        zi = "zoxide query -i";
        zb = "zoxide query -l";
        
        # Git enhancements
        lg = "lazygit";
        tig = "gitui";
        gdiff = "delta";
        
        # System monitoring
        top = "btop";
        htop = "btop";
        
        # Development shortcuts  
        serve = "python3 -m http.server 8000";
        myip = "curl -s https://httpbin.org/ip | jq -r .origin";
        ports = "sudo lsof -iTCP -sTCP:LISTEN -n -P";
        
        # Command correction
        fuck = "pay-respects";
        
        # Quick editing
        edit = "$EDITOR";
        e = "$EDITOR";
      }) // cfg.aliases;
      
      oh-my-zsh = {
        enable = true;
        plugins = zshCfg.plugins;
        theme = zshCfg.theme;
      };
      
      # Initialize environment and tools
      initContent = ''
        ${optionalString cfg.debugEnvironment "echo \"[DEBUG] Loading Nix environment profiles...\""}
        # Ensure all Nix profiles are properly sourced
        for profile in /nix/var/nix/profiles/default ~/.nix-profile /etc/profiles/per-user/$USER; do
          if [ -f "$profile/etc/profile.d/nix.sh" ]; then
            ${optionalString cfg.debugEnvironment "echo \"[DEBUG] Sourcing $profile/etc/profile.d/nix.sh\""}
            source "$profile/etc/profile.d/nix.sh"
          fi
        done
        
        # Source home-manager session variables
        if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
          ${optionalString cfg.debugEnvironment "echo \"[DEBUG] Sourcing home-manager session variables\""}
          source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
        fi
        
        ${optionalString cfg.debugEnvironment "echo \"[DEBUG] PATH: $PATH\""}
        
        # Initialize zoxide if enabled
        ${optionalString cfg.modernTools.enable ''
          if command -v zoxide >/dev/null 2>&1; then
            eval "$(zoxide init zsh)"
            alias cd="z"
          fi
        ''}
      '';
    };
    
    # Direnv for per-directory environments
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    
    # Session variables
    home.sessionVariables = {
      NIX_PATH = mkDefault "nixpkgs=$HOME/.nix-defexpr/channels/nixpkgs:$NIX_PATH";
    };
    
    # Session paths
    home.sessionPath = [
      "$HOME/.nix-profile/bin"
      "/etc/profiles/per-user/$USER/bin"
    ];
  };
}
