# Darwin (macOS) system modules
{
  core = import ./core/default.nix;
  security = import ./security/default.nix;
  nix-settings = import ./nix-settings/default.nix;
  system-defaults = import ./system-defaults/default.nix;
  keyboard = import ./keyboard/default.nix;
  homebrew = import ./homebrew/default.nix;
}
