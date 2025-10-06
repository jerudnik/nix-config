{ lib, config, ... }:

with lib;

let
  cfg = config.programs.claude-desktop;
in {
  options.programs.claude-desktop = {
    enable = mkEnableOption {
      description = ''Claude Desktop AI assistant application.
        
        Currently managed as an exception to WARP.md due to unavailability in nixpkgs.
        Must be installed manually via Homebrew: `brew install --cask claude`
        
        Provides:
        - Direct Claude AI conversations
        - MCP (Model Context Protocol) server integration
        - File upload and analysis capabilities
        - Project-based conversation management
        
        See: docs/exceptions.md for technical justification and review schedule.'';
      example = true;
    };
    
    mcpServers = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          command = mkOption {
            type = types.str;
            description = "Command to start the MCP server";
            example = "\${pkgs.github-mcp-server}/bin/server";
          };
          args = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Arguments to pass to the MCP server command";
            example = [ "--config" "config.json" ];
          };
          env = mkOption {
            type = types.attrsOf types.str;
            default = {};
            description = "Environment variables for the MCP server";
            example = { GITHUB_TOKEN = "ghp_example"; };
          };
        };
      });
      default = {};
      description = ''MCP (Model Context Protocol) servers to configure for Claude Desktop.
        
        These extend Claude's capabilities with external tools and data sources.
        Common servers include GitHub integration, filesystem access, and time utilities.
        
        Configuration is written to Claude Desktop's config file and requires app restart.'';
      example = literalExpression ''
        {
          github = {
            command = "\${pkgs.github-mcp-server}/bin/server";
            args = [];
            env = { GITHUB_TOKEN = "ghp_your_token_here"; };
          };
          filesystem = {
            command = "\${pkgs.python3}/bin/python3";
            args = [ "/path/to/filesystem-server.py" "/allowed/directory" ];
          };
        }'';
    };
    
    # Future options for when/if we add declarative homebrew integration:
    # cask = mkOption { ... };
    # configPath = mkOption { ... };
  };

  config = mkIf cfg.enable {
    # Intentionally no packages added here per WARP.md constraints
    # Claude Desktop must be installed manually via Homebrew until available in nixpkgs
    
    # Generate Claude Desktop MCP configuration if servers are defined
    home.file.".config/claude/claude_desktop_config.json" = mkIf (cfg.mcpServers != {}) {
      text = builtins.toJSON {
        mcpServers = cfg.mcpServers;
      };
    };
    
    # Installation instructions displayed when module is enabled
    home.activation.claude-desktop-installation-notice = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "";
      echo "⚠️  Claude Desktop Installation Required:";
      echo "   Run: brew install --cask claude";
      echo "   Then restart the application to load MCP servers.";
      echo "";
      echo "📋 MCP Servers configured: ${toString (length (attrNames cfg.mcpServers))}";
      echo "   Configuration written to ~/.config/claude/claude_desktop_config.json";
      echo "";
    '';
    
    # Available via: `brew install --cask claude`
    # Would be added to darwin.homebrew.casks when declarative homebrew is approved
  };
}