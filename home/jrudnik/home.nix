{ config, pkgs, lib, inputs, outputs, host, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    outputs.homeManagerModules.shell
    outputs.homeManagerModules.development
    outputs.homeManagerModules.git
    outputs.homeManagerModules.cli-tools
    outputs.homeManagerModules.editors
    (lib.mkIf isDarwin outputs.homeManagerModules.window-manager)
    outputs.homeManagerModules.security
    outputs.homeManagerModules.ai
    (lib.mkIf isDarwin outputs.homeManagerModules.raycast)
    outputs.homeManagerModules.syncthing
    outputs.homeManagerModules.thunderbird
    (lib.mkIf isDarwin outputs.homeManagerModules.sketchybar)
  ];

  # Home Manager configuration
  home = {
    username = "jrudnik";
    homeDirectory = lib.mkIf isDarwin "/Users/jrudnik" (lib.mkIf isLinux "/home/jrudnik");
    stateVersion = "25.05";
    
    packages = with pkgs; [
      psst
      age
      sops
    ];
  };

  sops = {
    defaultSopsFile = ./user.enc.yaml;
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    secrets = {
      "api_keys/github_token" = { path = "${config.home.homeDirectory}/.secrets/github-token"; };
      "api_keys/openai_api_key" = { path = "${config.home.homeDirectory}/.secrets/openai-api-key"; };
      "api_keys/anthropic_api_key" = { path = "${config.home.homeDirectory}/.secrets/anthropic-api-key"; };
      "development/database_url" = { path = "${config.home.homeDirectory}/.secrets/database-url"; };
      "development/redis_url" = { path = "${config.home.homeDirectory}/.secrets/redis-url"; };
      "ssh/github_personal_key" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0600";
      };
    };
  };

  home.sessionVariables = {
    GITHUB_TOKEN = "$(cat ${config.home.homeDirectory}/.secrets/github-token 2>/dev/null || echo '')";
    OPENAI_API_KEY = "$(cat ${config.home.homeDirectory}/.secrets/openai-api-key 2>/dev/null || echo '')";
    ANTHROPIC_API_KEY = "$(cat ${config.home.homeDirectory}/.secrets/anthropic-api-key 2>/dev/null || echo '')";
  };

  programs.home-manager.enable = true;
  
  stylix.targets = {
    alacritty.enable = true;
    bat.enable = true;
    btop.enable = true;
    fzf.enable = true;
    vim.enable = true;
    neovim.enable = true;
    lazygit.enable = true;
    gtk.enable = true;
  };
  
  programs.alacritty.enable = true;

  home.editors.zed = {
    enable = true;
    extensions = [ "nix" "toml" "dockerfile" "html" "make" "markdown" "yaml" "rust" ];
    enableGitHubCopilot = false;
    theme = "Gruvbox Dark Hard";
    fontSize = 14;
  };

  home.shell = {
    enable = true;
    nixShortcuts = {
      enable = true;
      configPath = "~/nix-config";
      hostName = host.name;
    };
    modernTools.enable = true;
    aliases.lg = "lazygit";
  };
    
  home.development = {
    enable = true;
    languages = { rust = true; go = true; python = true; };
    editor = "micro";
    neovim = false;
    github.enable = true;
    utilities.lazygit = true;
  };
    
  home.git = {
    enable = true;
    userName = "jrudnik";
    userEmail = "john.rudnik@gmail.com";
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      pushf = "push --force-with-lease";
      unstage = "reset HEAD --";
      amend = "commit --amend";
      undo = "reset --soft HEAD~1";
      last = "log -1 HEAD";
      visual = "log --oneline --graph --decorate --all";
      recent = "for-each-ref --sort=-committerdate refs/heads/ --format='%(committerdate:short) %(refname:short)'";
      please = "push --force-with-lease";
      commend = "commit --amend --no-edit";
    };
  };
    
  home.cli-tools = {
    enable = true;
    systemMonitor = "btop";
  };
    
  home.starship = {
    enable = true;
    preset = "powerline";
    showLanguages = [ "nodejs" "rust" "golang" "python" "nix_shell" ];
    showSystemInfo = true;
    showTime = true;
    showBattery = false;
    cmdDurationThreshold = 4000;
  };

  home.window-manager = lib.mkIf isDarwin {
    enable = true;
  };

  home.raycast = lib.mkIf isDarwin {
    enable = true;
  };
    
  home.syncthing = {
    enable = true;
    autoStart = true;
    openWebUI = false;
  };
    
  home.thunderbird = {
    enable = true;
    profiles.default.isDefault = true;
    privacy = {
      enableDoNotTrack = true;
      disableTelemetry = true;
    };
    features = {
      enableOpenPGP = true;
      enableCalendar = true;
      compactFolders = true;
    };
    appearance = {
      theme = "auto";
      fontSize = 14;
    };
  };
    
  home.sketchybar = lib.mkIf isDarwin {
    enable = false;
    position = "top";
    height = 32;
    font = "SF Pro";
    aerospace = {
      enable = true;
      workspaces = [ "1" "2" "3" "4" "5" ];
    };
    showCalendar = true;
    showBattery = true;
    showWifi = true;
    showVolume = true;
    showCpu = true;
  };

  home.file = lib.mkIf isDarwin {
    "Library/Application Support/Claude/claude_desktop_config.json".source =
      inputs.mcp-servers-nix.lib.mkConfig pkgs {
        programs = {
          filesystem = {
            enable = true;
            args = [ config.home.homeDirectory ];
          };
          github.enable = true;
          git.enable = true;
          time.enable = true;
          fetch.enable = true;
        };
      };
  };
  
  home.security = {
    enable = true;
    autoStart = false;
    unlockMethod = lib.mkIf isDarwin "biometric" (lib.mkIf isLinux "password");
    lockTimeout = 15;
    windowBehavior = "minimize-to-tray";
    startBehavior = "normal";
    
    yubikey = {
      enable = true;
      sshAgent = {
        enable = true;
        pinEntry = lib.mkIf isDarwin "mac" (lib.mkIf isLinux "gtk2");
      };
      gpg = {
        enable = true;
        enableGitSigning = true;
      };
      ageEncryption.enable = true;
      touchDetector.enable = isLinux;
    };
  };
  
  programs.ai = {
    secrets = {
      enable = isDarwin;
      shellIntegration = isDarwin;
    };
    code2prompt.enable = true;
    files-to-prompt.enable = true;
    goose-cli.enable = false;
    fabric-ai = {
      enable = true;
      enablePatternsAliases = true;
      enableYtAlias = true;
    };
    github-copilot-cli.enable = true;
    claude-desktop.enable = false;
    claude-code.enable = true;
    gemini-cli.enable = true;
    diagnostics.enable = true;
  };
  
  xdg.enable = true;
  
  xdg.configFile."fabric/patterns" = {
    source = ./../../modules/home/ai/patterns/fabric/tasks;
    recursive = true;
  };
}
