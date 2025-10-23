{ config, pkgs, lib, ... }:

let
  isLinux = pkgs.stdenv.isLinux;
in
{
  # Common system configuration
  boot.loader.systemd-boot.enable = lib.mkIf isLinux true;
  boot.loader.efi.canTouchEfiVariables = lib.mkIf isLinux true;

  networking.hostName = lib.mkDefault "nixos"; # Default hostname
  networking.networkmanager.enable = lib.mkIf isLinux true;

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs.config.allowUnfree = true;

  # Common packages for all systems
  environment.systemPackages = with pkgs; [
    # Modern Unix replacements
    eza             # Modern ls
    zoxide          # Smart cd
    fzf             # Fuzzy finder
    bat             # Better cat
    ripgrep         # Better grep
    fd              # Better find
    btop            # System monitor

    # Shell enhancements
    direnv          # Environment switcher
    atuin           # Shell history
    mcfly           # History search
    pay-respects    # Error correction
    delta           # Better diff

    # Development tools
    rustc
    cargo
    go
    python3
    nodejs
    micro           # Terminal text editor
    neovim          # Vim-based editor
    tree            # Directory visualization
    jq              # JSON processor
    lazygit         # Git TUI
    gh              # GitHub CLI
  ];

  # Declarative secret management
  sops = {
    age.keyFile = "/Users/jrudnik/.config/sops/age/keys.txt";
    secrets = {
      # SSH keys for system services
      "ssh/github_deploy_key" = {
        owner = "jrudnik";
        path = "/Users/jrudnik/.ssh/github_deploy_key";
        mode = "0600";
      };

      # Service credentials
      "services/backup_service_token" = {
        owner = "jrudnik";
      };

      "services/monitoring_api_key" = {
        owner = "jrudnik";
      };
    };
  };
}
