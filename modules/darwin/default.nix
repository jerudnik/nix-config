# Darwin (macOS) system modules
{
  core = import ./core/default.nix;
  security = import ./security/default.nix;
  nix-settings = import ./nix-settings/default.nix;
  system-settings = import ./system-settings/default.nix;
  homebrew = import ./homebrew/default.nix;
  theming = import ./theming/default.nix;
  fonts = import ./fonts/default.nix;
}
