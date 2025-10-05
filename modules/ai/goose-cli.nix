{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.programs.goose-cli;
in {
  options.programs.goose-cli = {
    enable = mkEnableOption "Goose CLI - open-source, extensible AI agent for code tasks";
    
    package = mkOption {
      type = types.package;
      default = pkgs.goose-cli;
      description = "The goose-cli package to use";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    
    # Goose CLI supports multiple LLM providers and requires API keys:
    # - OPENAI_API_KEY for OpenAI models
    # - ANTHROPIC_API_KEY for Anthropic models  
    # - GOOGLE_API_KEY for Google models
    # These should be set via secrets management or manual export
  };
}