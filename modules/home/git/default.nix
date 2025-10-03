{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.git;
in {
  options.home.git = {
    enable = mkEnableOption "Git configuration";
    
    userName = mkOption {
      type = types.str;
      description = "Git user name";
      example = "John Doe";
    };
    
    userEmail = mkOption {
      type = types.str;
      description = "Git user email";
      example = "john@example.com";
    };
    
    defaultBranch = mkOption {
      type = types.str;
      default = "main";
      description = "Default branch name for new repositories";
    };
    
    editor = mkOption {
      type = types.str;
      default = "micro";
      description = "Default Git editor";
    };
    
    extraConfig = mkOption {
      type = types.attrsOf (types.oneOf [ types.str types.bool types.int ]);
      default = {};
      description = "Additional Git configuration options";
      example = literalExpression ''
        {
          diff.tool = "vimdiff";
          merge.tool = "vimdiff";
        }
      '';
    };
    
    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Git aliases";
      example = literalExpression ''
        {
          st = "status";
          co = "checkout";
          br = "branch";
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;
      
      extraConfig = {
        init.defaultBranch = cfg.defaultBranch;
        core.editor = cfg.editor;
        pull.rebase = false;
        push.default = "simple";
      } // cfg.extraConfig;
      
      aliases = cfg.aliases;
    };
  };
}