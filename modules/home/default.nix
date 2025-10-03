# Home-manager modules
{
  shell = import ./shell/default.nix;
  development = import ./development/default.nix;
  git = import ./git/default.nix;
}
