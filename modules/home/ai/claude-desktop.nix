{ lib, config, ... }:

with lib;

let
  cfg = config.programs.claude-desktop;
in {
  options.programs.claude-desktop = {
    enable = mkEnableOption "Claude Desktop (placeholder - not installed automatically)";
    
    # Future options for when/if we add declarative homebrew integration:
    # cask = mkOption { ... };
    # configPath = mkOption { ... };
  };

  config = mkIf cfg.enable {
    # Intentionally no packages added here per constraints
    # This toggle can manage future declarative homebrew cask installation
    # when approved by user
    
    # Available via: `brew install --cask claude`
    # Would be added to darwin.homebrew.casks when ready
  };
}