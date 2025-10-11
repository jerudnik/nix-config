{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.syncthing;
in
{
  options.home.syncthing = {
    enable = mkEnableOption "Syncthing continuous file synchronization";
    
    autoStart = mkOption {
      type = types.bool;
      default = true;
      description = "Start Syncthing automatically at login";
    };
    
    openWebUI = mkOption {
      type = types.bool;
      default = false;
      description = "Open web UI automatically when Syncthing starts";
    };
  };

  config = mkIf cfg.enable {
    # Note: Syncthing itself is installed via environment.systemPackages in darwin config
    # This module only configures the service/auto-start behavior
    
    # Create launchd service for auto-start on macOS
    launchd.agents.syncthing = mkIf cfg.autoStart {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.syncthing}/bin/syncthing"
          "-no-browser"
          "-no-restart"
        ];
        KeepAlive = true;
        ProcessType = "Background";
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/Syncthing/stdout.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/Syncthing/stderr.log";
      };
    };
    
    # Create log directory
    home.activation.createSyncthingLogs = mkIf cfg.autoStart (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p ${config.home.homeDirectory}/Library/Logs/Syncthing
      ''
    );
    
    # Optional: Open web UI after service starts
    # Note: The web UI runs on http://127.0.0.1:8384 by default
    home.activation.openSyncthingUI = mkIf (cfg.autoStart && cfg.openWebUI) (
      lib.hm.dag.entryAfter ["createSyncthingLogs"] ''
        # Wait a moment for Syncthing to start
        $DRY_RUN_CMD sleep 2
        $DRY_RUN_CMD open http://127.0.0.1:8384
      ''
    );
  };
}
