# Home Manager modules
{
  shell = import ./shell/default.nix;
  development = import ./development/default.nix;
  git = import ./git/default.nix;
  cli-tools = import ./cli-tools/default.nix;
  spotlight = import ./spotlight/default.nix;
  window-manager = import ./window-manager/default.nix;
  raycast = import ./raycast/default.nix;
}
