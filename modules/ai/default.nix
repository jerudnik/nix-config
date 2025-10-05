{ lib, ... }:

{
  imports = [
    ./mcphost.nix
    ./code2prompt.nix
    ./files-to-prompt.nix
    ./goose-cli.nix
    ./copilot-cli.nix
    ./claude-desktop.nix
    ./diagnostics.nix
  ];
}
