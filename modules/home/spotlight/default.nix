{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.spotlight;
in {
  options.home.spotlight = {
    enable = mkEnableOption "Enhanced Spotlight integration for Nix applications";
    
    appsFolder = mkOption {
      type = types.str;
      default = "Applications/home-manager";
      description = "Folder name in ~/Applications for home-manager apps";
    };

    systemAppsFolder = mkOption {
      type = types.str;
      default = "Applications/nix-darwin";
      description = "Folder name in ~/Applications for system-level nix-darwin apps";
    };

    linkSystemApps = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to create symlinks for system-level apps in the system apps folder";
    };

    reindexInterval = mkOption {
      type = types.str;
      default = "daily";
      description = "How often to reindex Spotlight database (hourly, daily, weekly)";
    };
  };
  
  config = mkIf cfg.enable {
    # Create improved symlinks for home-manager GUI applications
    # This replaces the default "Home Manager Apps" folder with a cleaner name
    home.file."${cfg.appsFolder}".source = let
      apps = pkgs.buildEnv {
        name = "home-manager-applications";
        paths = config.home.packages;
        pathsToLink = "/Applications";
      };
    in mkIf pkgs.stdenv.targetPlatform.isDarwin "${apps}/Applications";
    
    # Create symlink to system-level nix-darwin apps when enabled
    home.file."${cfg.systemAppsFolder}" = mkIf (cfg.linkSystemApps && pkgs.stdenv.targetPlatform.isDarwin) {
      source = config.lib.file.mkOutOfStoreSymlink "/run/current-system/Applications";
    };
    
    # Add shell aliases for manual Spotlight management
    home.shellAliases = {
      "spotlight-reindex" = "sudo mdutil -i on / && sudo mdutil -E /";
      "spotlight-status" = "mdutil -s /";
    };
    
    # Launchd service to periodically reindex Spotlight
    launchd.agents.spotlight-reindex = {
      enable = cfg.reindexInterval != "never";
      config = {
        ProgramArguments = [
          "/bin/sh"
          "-c"
          "mdutil -i on / 2>/dev/null || true; mdutil -E / 2>/dev/null || true"
        ];
        StartCalendarInterval = {
          Hour = 2;
          Minute = 0;
        } // (if cfg.reindexInterval == "weekly" then { Weekday = 0; } else {});
        RunAtLoad = false;
        StandardErrorPath = "/tmp/spotlight-reindex.err";
        StandardOutPath = "/tmp/spotlight-reindex.out";
      };
    };
    
    # Session variables to help GUI applications
    home.sessionVariables = {
      XDG_DATA_DIRS = "$HOME/.nix-profile/share:/run/current-system/sw/share:$XDG_DATA_DIRS";
    };
  };
}
