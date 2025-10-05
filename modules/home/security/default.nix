{ config, lib, pkgs, ... }:

let
  cfg = config.home.security;
  inherit (lib) mkIf mkOption mkEnableOption types;
in
{
  options.home.security = {
    bitwarden = {
      enable = mkEnableOption "Bitwarden password manager with desktop app and CLI";

      package = mkOption {
        type = types.package;
        default = pkgs.bitwarden;
        example = lib.literalExpression "pkgs.bitwarden";
        description = "Bitwarden desktop application package";
      };

      cli = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Whether to install Bitwarden CLI for terminal access (currently disabled due to broken package)";
        };

        package = mkOption {
          type = types.package;
          default = pkgs.bitwarden-cli;
          example = lib.literalExpression "pkgs.bitwarden-cli";
          description = "Bitwarden CLI package";
        };
      };

      autoStart = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to automatically start Bitwarden at login";
      };

      # macOS-specific settings
      enableTouchID = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Touch ID unlock for Bitwarden (macOS only)";
      };

      minimizeToTray = mkOption {
        type = types.bool;
        default = true;
        description = "Minimize Bitwarden to system tray instead of closing";
      };

      startMinimized = mkOption {
        type = types.bool;
        default = false;
        description = "Start Bitwarden minimized to system tray";
      };

      lockTimeout = mkOption {
        type = types.nullOr types.int;
        default = 15;
        example = 30;
        description = "Auto-lock timeout in minutes (null to disable)";
      };
    };
  };

  config = mkIf cfg.bitwarden.enable {
    # Darwin-only assertions
    assertions = [
      {
        assertion = pkgs.stdenv.isDarwin;
        message = "home.security.bitwarden is currently configured for macOS (Darwin) only";
      }
    ];

    # Install Bitwarden desktop application
    home.packages = with pkgs; [
      cfg.bitwarden.package
    ] ++ lib.optionals cfg.bitwarden.cli.enable [
      cfg.bitwarden.cli.package
    ];

    # Configure Bitwarden desktop preferences via macOS defaults
    targets.darwin.defaults."com.bitwarden.desktop" = {
      # Enable Touch ID if supported and requested
      "biometricUnlock" = cfg.bitwarden.enableTouchID;
      
      # Minimize to tray behavior
      "minimizeToTrayOnStart" = cfg.bitwarden.startMinimized;
      "closeToTray" = cfg.bitwarden.minimizeToTray;
      
      # Auto-lock settings
      "lockTimeout" = cfg.bitwarden.lockTimeout;
      
      # Security settings
      "clearClipboard" = 20;  # Clear clipboard after 20 seconds
      "disableFavicon" = false;
      "enableAutoFillOnPageLoad" = false;  # Security: require manual autofill
      
      # Update settings
      "enableStartupSecurityCheck" = true;
      "enableBrowserIntegration" = true;
      "enableBrowserIntegrationFingerprint" = true;
    };

    # Optional: Auto-start via launchd agent
    launchd.agents."bitwarden-autostart" = mkIf cfg.bitwarden.autoStart {
      enable = true;
      config = {
        Label = "org.home-manager.bitwarden.autostart";
        ProgramArguments = [ "/usr/bin/open" "-a" "Bitwarden" ];
        RunAtLoad = true;
        ProcessType = "Interactive";
        LimitLoadToSessionType = "Aqua";
      } // lib.optionalAttrs cfg.bitwarden.startMinimized {
        # If start minimized is enabled, use the --hidden flag
        ProgramArguments = [ "/usr/bin/open" "-a" "Bitwarden" "--hidden" ];
      };
    };

    # Shell integration for CLI
    programs.zsh.shellAliases = mkIf cfg.bitwarden.cli.enable {
      bw = "bitwarden-cli";
      bws = "bitwarden-cli sync";
      bwl = "bitwarden-cli list";
      bwg = "bitwarden-cli get";
    };

    programs.bash.shellAliases = mkIf cfg.bitwarden.cli.enable {
      bw = "bitwarden-cli";
      bws = "bitwarden-cli sync";
      bwl = "bitwarden-cli list";
      bwg = "bitwarden-cli get";
    };
  };
}