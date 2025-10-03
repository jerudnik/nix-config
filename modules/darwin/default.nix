# Darwin (macOS) system modules
{
  core = import ./core/default.nix;
  security = import ./security/default.nix;
  nix-settings = import ./nix-settings/default.nix;
  system-defaults = import ./system-defaults/default.nix;
}
