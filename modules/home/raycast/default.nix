
{ config, lib, pkgs, ... }:

{
  options.home.raycast = {
    enable = lib.mkEnableOption "Raycast configuration";
  };

  config = lib.mkIf config.home.raycast.enable {
    launchd.agents.raycast = {
      enable = true;
      config = {
        KeepAlive = true;
        ProcessType = "Interactive";
        ProgramArguments = [
          "${config.home.homeDirectory}/Applications/Home Manager Apps/Raycast.app/Contents/MacOS/Raycast"
        ];
        StandardErrorPath = "${config.xdg.cacheHome}/raycast.log";
        StandardOutPath = "${config.xdg.cacheHome}/raycast.log";
      };
    };

    targets.darwin.defaults = {
      "com.raycast.macos" = {
        "NSStatusItem Visible raycastIcon" = 0;
        "permissions.folders.read:${config.home.homeDirectory}/Desktop" = true;
        "permissions.folders.read:${config.home.homeDirectory}/Documents" = true;
        "permissions.folders.read:${config.home.homeDirectory}/Downloads" = true;
        "permissions.folders.read:cloudStorage" = true;
        "permissions.folders.read:removableVolumes" = true;
        navigationCommandStyleIdentifierKey = "macos";
        onboardingCompleted = true;
        raycastPreferredWindowMode = "compact";
      };
    };
  };
}
