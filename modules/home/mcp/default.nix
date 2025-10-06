# MCP (Model Context Protocol) servers configuration for Claude Desktop
{ lib, pkgs, config, ... }:

let
  cfg = config.home.mcp;
  inherit (lib) mkIf mkEnableOption types mkOption mapAttrs;
in
{
  options.home.mcp = {
    enable = mkEnableOption {
      description = ''MCP (Model Context Protocol) servers for Claude Desktop.
        
        MCP extends Claude's capabilities by connecting external tools and data sources.
        Servers run as separate processes and communicate via standardized protocol.
        
        Requires Claude Desktop to be installed and running.
        Configuration automatically restarts Claude when servers change.
        
        Common use cases:
        - GitHub repository integration
        - Local filesystem access
        - Database queries
        - Time/calendar utilities
        - Web scraping and API access'';
      example = true;
    };
    
    servers = mkOption {
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          command = mkOption {
            type = types.str;
            description = ''Absolute path to server binary (prefer Nix store paths for reproducibility).
              
              Use Nix store paths like `\${pkgs.mcp-server-git}/bin/mcp-server-git` 
              to ensure servers are available and version-controlled.'';
            example = "\${pkgs.github-mcp-server}/bin/server";
          };
          
          args = mkOption {
            type = types.listOf types.str;
            default = [];
            description = ''Command line arguments passed to the MCP server.
              
              Arguments are passed in order to the server process.
              Common uses include configuration files, working directories, or feature flags.'';
            example = [ "--config" "config.json" "--verbose" ];
          };
          
          env = mkOption {
            type = types.attrsOf types.str;
            default = {};
            description = ''Environment variables available to the MCP server process.
              
              Use for API keys, configuration paths, or runtime settings.
              Variables are isolated to each server process.'';
            example = { 
              GITHUB_TOKEN = "ghp_your_token_here";
              LOG_LEVEL = "debug";
              HOME_DIR = "$HOME";
            };
          };
        };
      }));
      default = {};
      description = ''MCP servers to configure for Claude Desktop.
        
        Each server extends Claude with specific capabilities:
        
        - **github**: Repository access, issues, PRs, code search
        - **filesystem**: File operations within specified directories  
        - **git**: Local repository operations and history
        - **time**: Date/time utilities and scheduling
        - **fetch**: Web scraping and HTTP requests
        
        Server processes start when Claude Desktop launches and remain active
        during the session. Failed servers are automatically restarted.'';
      example = lib.literalExpression ''
        {
          # GitHub integration with API token
          github = {
            command = "\${pkgs.github-mcp-server}/bin/server";
            args = [];
            env = { GITHUB_TOKEN = "ghp_your_token_here"; };
          };
          
          # Filesystem access (restricted to home directory)
          filesystem = {
            command = "\${pkgs.python3}/bin/python3";
            args = [ "./filesystem-server.py" "\${config.home.homeDirectory}" ];
          };
          
          # Git operations for local repositories
          git = {
            command = "\${pkgs.mcp-servers.mcp-server-git}/bin/mcp-server-git";
            args = [];
          };
        }'';
    };
    
    configPath = mkOption {
      type = types.str;
      default = "Library/Application Support/Claude/claude_desktop_config.json";
      description = ''Relative path from home directory to Claude Desktop configuration file.
        
        This is where Claude Desktop expects to find MCP server configurations.
        The path is platform-specific (macOS uses "Library/Application Support").
        
        Changing this path requires Claude Desktop restart to take effect.'';
      example = ".config/claude/claude_desktop_config.json";
    };
    
    additionalConfig = mkOption {
      type = types.attrs;
      default = {};
      description = ''Additional JSON configuration to merge into Claude Desktop config.
        
        Use this for Claude Desktop settings not covered by the MCP servers option.
        Values are merged with generated MCP server configuration.
        
        Common uses include UI preferences, feature flags, or experimental settings.'';
      example = {
        "ui.theme" = "dark";
        "features.experimental" = true;
        "logging.level" = "debug";
      };
    };
  };

  config = mkIf cfg.enable {
    # Configuration validations
    assertions = [
      {
        assertion = cfg.servers != {};
        message = "home.mcp.servers cannot be empty when MCP is enabled. Define at least one server or disable the module.";
      }
      {
        assertion = lib.all (server: lib.hasPrefix "/" server.command) (lib.attrValues cfg.servers);
        message = "All MCP server commands must be absolute paths. Use Nix store paths like '\${pkgs.package}/bin/executable'.";
      }
      {
        assertion = lib.all (server: server.command != "") (lib.attrValues cfg.servers);
        message = "MCP server commands cannot be empty. Specify the full path to the server executable.";
      }
      {
        assertion = (lib.length (lib.attrNames cfg.servers)) <= 20;
        message = "Too many MCP servers configured (max 20). Claude Desktop may have performance issues with excessive servers.";
      }
      {
        assertion = lib.all (name: lib.stringLength name <= 50) (lib.attrNames cfg.servers);
        message = "MCP server names must be 50 characters or less for Claude Desktop compatibility.";
      }
    ];
    # Generate Claude Desktop MCP configuration file
    # This file is read by Claude Desktop on startup to configure available MCP servers
    home.file.${cfg.configPath}.text = builtins.toJSON ({
      # Transform our structured server configuration into Claude Desktop's expected format
      mcpServers = mapAttrs (serverName: serverConfig: {
        command = serverConfig.command;  # Absolute path to server binary
        args = serverConfig.args;        # Command line arguments
        env = serverConfig.env;          # Environment variables
      }) cfg.servers;
    } // cfg.additionalConfig);  # Merge any additional Claude Desktop settings
    
    # Add helpful activation message when MCP servers are configured
    home.activation.mcp-server-info = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${if (cfg.servers != {}) then ''
        echo "";
        echo "🔌 MCP Servers configured for Claude Desktop:";
        ${builtins.concatStringsSep "\n" (map (name: ''        echo "   - ${name}";
        '') (builtins.attrNames cfg.servers))}
        echo "   Configuration: ~/${cfg.configPath}";
        echo "   💡 Restart Claude Desktop to load server changes.";
        echo "";
      '' else ""}
    '';
  };
}