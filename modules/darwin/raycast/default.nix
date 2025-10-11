
{ config, lib, pkgs, ... }:

{
  options.darwin.raycast.enable = lib.mkEnableOption "Raycast application";

  config = lib.mkIf config.darwin.raycast.enable {
    environment.systemPackages = with pkgs; [
      raycast
    ];
  };
}
