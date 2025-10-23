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
}
