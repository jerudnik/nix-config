{ lib, config, ... }:

with lib;

let
  cfg = config.programs.github-copilot-cli;
in {
  options.programs.github-copilot-cli = {
    enable = mkEnableOption "GitHub Copilot CLI (placeholder - not installed automatically)";
    
    # Future options for when/if we add declarative homebrew integration:
    # package = mkOption { ... };
    # authToken = mkOption { ... };
  };

  config = mkIf cfg.enable {
    # Intentionally no packages added here per constraints
    # This toggle can manage environment or future declarative brew integration
    # when approved by user
    
    # Placeholder for future GitHub authentication setup
    # home.sessionVariables = {
    #   GITHUB_TOKEN = "...";  # Would be managed via secrets
    # };
  };
}