{ config, pkgs, ... }:

{
  # Home Manager configuration
  home = {
    stateVersion = "25.05";

    packages = with pkgs; [
      psst
      age
      sops
    ];
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

  home.syncthing = {
    enable = true;
    autoStart = true;
    openWebUI = false;
  };

  home.thunderbird = {
    enable = true;
    profiles.default.isDefault = true;
    privacy = {
      enableDo-not-track = true;
      disable-telemetry = true;
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

  programs.ai = {
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
}
