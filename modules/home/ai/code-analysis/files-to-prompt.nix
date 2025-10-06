{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.programs.files-to-prompt;
in {
  options.programs.files-to-prompt = {
    enable = mkEnableOption "files-to-prompt - concatenate a directory full of files into a single prompt for LLMs";
    
    package = mkOption {
      type = types.package;
      default = pkgs.files-to-prompt;
      description = "The files-to-prompt package to use";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    
    # files-to-prompt is a standalone tool that doesn't require API keys
    # It processes local files and directories to create LLM-ready prompts
  };
}