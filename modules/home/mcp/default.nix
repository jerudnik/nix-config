# MCP (Model Context Protocol) servers configuration for Claude Desktop
{ lib, pkgs, config, ... }:

let
  cfg = config.home.mcp;
  inherit (lib) mkIf mkEnableOption types mkOption mapAttrs;
in
{
  options.home.mcp = {
    enable = mkEnableOption "MCP servers for Claude Desktop";
    
    servers = mkOption {
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          command = mkOption {
            type = types.str;
            description = "Absolute path to server binary (prefer Nix store path)";
          };
          
          args = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Arguments to pass to the MCP server";
          };
          
          env = mkOption {
            type = types.attrsOf types.str;
            default = {};
            description = "Environment variables for the server";
          };
        };
      }));
      default = {};
      description = "Declared MCP servers for Claude Desktop";
    };
    
    configPath = mkOption {
      type = types.str;
      default = "Library/Application Support/Claude/claude_desktop_config.json";
      description = "Relative path from home directory to Claude Desktop MCP config";
    };
    
    additionalConfig = mkOption {
      type = types.attrs;
      default = {};
      description = "Additional configuration to merge into Claude Desktop config";
    };
  };

  config = mkIf cfg.enable {
    # Generate Claude Desktop config JSON
    home.file.${cfg.configPath}.text = builtins.toJSON ({
      mcpServers = mapAttrs (n: v: {
        command = v.command;
        args = v.args;
        env = v.env;
      }) cfg.servers;
    } // cfg.additionalConfig);
  };
}