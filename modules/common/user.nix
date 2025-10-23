{ config, pkgs, ... }:

{
  # Common user configuration
  users.users.jrudnik = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  # Set the default shell for all users
  programs.zsh.enable = true;
}
