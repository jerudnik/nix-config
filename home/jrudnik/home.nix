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
  };

  sops.defaultSopsFile = ./user.enc.yaml;

  home.sessionVariables = {
    GITHUB_TOKEN = "$(cat ${config.home.homeDirectory}/.secrets/github-token 2>/dev/null || echo '')";
    OPENAI_API_KEY = "$(cat ${config.home.homeDirectory}/.secrets/openai-api-key 2>/dev/null || echo '')";
    ANTHROPIC_API_KEY = "$(cat ${config.home.homeDirectory}/.secrets/anthropic-api-key 2>/dev/null || echo '')";
  };

  home.shell.nixShortcuts = {
    enable = true;
    configPath = "~/nix-config";
    hostName = host.name;
  };

  # macOS-specific settings
  home.window-manager = lib.mkIf isDarwin {
    enable = true;
  };

  home.raycast = lib.mkIf isDarwin {
    enable = true;
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
  
  programs.ai.secrets = {
    enable = isDarwin;
    shellIntegration = isDarwin;
  };

  # Linux-specific settings
  programs.i3status.enable = lib.mkIf isLinux true;
  services.mako.enable = lib.mkIf isLinux true;
}
