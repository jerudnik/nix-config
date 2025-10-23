# modules/common/default.nix
{
  system = import ./system.nix;
  user = import ./user.nix;
}
