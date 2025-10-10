# Bitwarden Implementation Module
# This module implements the password manager interface using Bitwarden.
# It translates abstract password manager options into Bitwarden-specific configuration.
#
# WARP LAW 4.3 COMPLIANCE:
# - Installation: Bitwarden GUI app installed via nix-darwin (system-level)
# - Configuration: Managed here via home-manager (user-level)
# - Separation: Clear division between "install" and "configure"

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.security;
  bwCfg = cfg.implementation.bitwarden;
in {
  options.home.security.implementation = {
    bitwarden = {
      enable = mkEnableOption "Use Bitwarden as the password manager implementation" // {
        default = true;
      };
      
      # CLI tool installation (optional, separate from GUI)
      cli = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Install Bitwarden CLI for terminal access.
            Note: Currently disabled by default due to broken nixpkgs package.
          '';
        };
        
        package = mkOption {
          type = types.package;
          default = pkgs.bitwarden-cli;
          description = "Bitwarden CLI package (user-level tool)";
        };
      };
    };
  };

  config = mkIf (cfg.enable && bwCfg.enable) {
    # Darwin-only assertion
    assertions = [
      {
        assertion = pkgs.stdenv.isDarwin;
        message = "home.security with Bitwarden implementation is currently configured for macOS only";
      }
    ];
    
    # Install CLI tool if requested (user-level package, not GUI)
    home.packages = lib.optionals bwCfg.cli.enable [
      bwCfg.cli.package
    ];
    
    # Configure Bitwarden desktop preferences via macOS defaults
    # This uses abstract options from the aggregator
    targets.darwin.defaults."com.bitwarden.desktop" = {
      # Biometric/Touch ID unlock
      "biometricUnlock" = cfg.unlockMethod == "biometric";
      
      # Window behavior - translate abstract options to Bitwarden settings
      "minimizeToTrayOnStart" = cfg.startBehavior == "minimized";
      "closeToTray" = cfg.windowBehavior == "minimize-to-tray";
      
      # Auto-lock timeout (convert from abstract to Bitwarden format)
      "lockTimeout" = cfg.lockTimeout;
      
      # Security settings - Bitwarden-specific defaults
      "clearClipboard" = 20;  # Clear clipboard after 20 seconds
      "disableFavicon" = false;
      "enableAutoFillOnPageLoad" = false;  # Security: require manual autofill
      
      # Integration settings
      "enableStartupSecurityCheck" = true;
      "enableBrowserIntegration" = true;
      "enableBrowserIntegrationFingerprint" = true;
    };
    
    # Auto-start via launchd agent (macOS-specific)
    launchd.agents."bitwarden-autostart" = mkIf cfg.autoStart {
      enable = true;
      config = {
        Label = "org.home-manager.bitwarden.autostart";
        ProgramArguments = 
          if cfg.startBehavior == "minimized"
          then [ "/usr/bin/open" "-a" "Bitwarden" "--hidden" ]
          else [ "/usr/bin/open" "-a" "Bitwarden" ];
        RunAtLoad = true;
        ProcessType = "Interactive";
        LimitLoadToSessionType = "Aqua";
      };
    };
    
    # Shell integration for CLI (if enabled)
    programs.zsh.shellAliases = mkIf bwCfg.cli.enable {
      bw = "bitwarden-cli";
      bws = "bitwarden-cli sync";
      bwl = "bitwarden-cli list";
      bwg = "bitwarden-cli get";
    };
    
    programs.bash.shellAliases = mkIf bwCfg.cli.enable {
      bw = "bitwarden-cli";
      bws = "bitwarden-cli sync";
      bwl = "bitwarden-cli list";
      bwg = "bitwarden-cli get";
    };
  };
}
