{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.home.browser.zen;
  inherit (lib) mkIf mkOption mkEnableOption types;
in
{
  # Import the zen-browser twilight Home Manager module
  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  options.home.browser.zen = {
    enable = mkEnableOption "Zen Browser (twilight channel) for enhanced browsing with privacy and customization";

    # Optional: allow custom settings passed to the default profile
    settings = mkOption {
      type = types.attrs;
      default = {};
      example = lib.literalExpression ''
        {
          "browser.startup.homepage" = "https://start.duckduckgo.com"\;
          "browser.shell.checkDefaultBrowser" = false;
          "privacy.donottrackheader.enabled" = true;
          "browser.search.defaultenginename" = "DuckDuckGo";
        }
      '';
      description = "Default profile preferences (about:config-style) for Zen Browser";
    };

    # Optional: allow multi-profile configs; if empty we create a default profile
    profiles = mkOption {
      type = types.attrs;
      default = {};
      example = lib.literalExpression ''
        {
          work = {
            id = 1;
            isDefault = false;
            settings = {
              "browser.startup.homepage" = "https://company.com"\;
            };
          };
        }
      '';
      description = "Multi-profile settings for programs.zen-browser.profiles";
    };

    # Package override option
    package = mkOption {
      type = types.package;
      default = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.twilight;
      example = lib.literalExpression "inputs.zen-browser.packages.\${pkgs.stdenv.hostPlatform.system}.twilight";
      description = "Zen Browser package to use (twilight recommended for reproducibility)";
    };

    # Default browser setting - now just a placeholder/documentation
    # Note: Setting default browser on macOS should be done manually or via system preferences
    setAsDefaultBrowser = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to set Zen Browser as the default browser (currently informational only - set manually via System Settings)";
    };
  };

  config = mkIf cfg.enable {
    # Darwin-only assertions for this setup
    assertions = [
      {
        assertion = pkgs.stdenv.isDarwin;
        message = "home.browser.zen is currently configured for macOS (Darwin) only";
      }
    ];

    # Configure via the programs.zen-browser interface from the twilight module
    programs.zen-browser = {
      enable = true;
      package = cfg.package;

      # If caller supplies profiles, use them; otherwise create a default profile
      profiles =
        if cfg.profiles != {} then cfg.profiles else {
          default = {
            id = 0;
            isDefault = true;
            settings = cfg.settings;
          };
        };
    };

    # Note: The setAsDefaultBrowser option is retained for configuration compatibility
    # but no longer attempts to set Launch Services handlers.
    # To set Zen as your default browser:
    # 1. Open System Settings > Desktop & Dock > Default web browser
    # 2. Select Zen Browser from the dropdown
  };
}
