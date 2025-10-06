{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.programs.code2prompt;
in {
  options.programs.code2prompt = {
    enable = mkEnableOption "code2prompt - CLI tool that converts your codebase into a single LLM prompt";
    
    package = mkOption {
      type = types.package;
      default = pkgs.code2prompt;
      description = "The code2prompt package to use";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    
    # code2prompt is a standalone tool that doesn't require API keys
    # It converts local codebases into LLM-ready prompts with:
    # - Source tree visualization
    # - Prompt templating
    # - Token counting
  };
}