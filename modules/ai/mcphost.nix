{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.services.mcphost;
in {
  options.services.mcphost = {
    enable = mkEnableOption "Model Context Protocol host - CLI host for LLM tool integration";
    
    package = mkOption {
      type = types.package;
      default = pkgs.mcphost;
      description = "The mcphost package to use";
    };
    
    configFile = mkOption {
      type = types.path;
      default = "${config.xdg.configHome}/mcp/hosts/default.yaml";
      description = "Path to MCP host configuration file";
    };
    
    launchAgent = {
      enable = mkEnableOption "LaunchAgent service for MCP host" // { default = false; };
      
      logLevel = mkOption {
        type = types.enum [ "debug" "info" "warn" "error" ];
        default = "info";
        description = "Log level for MCP host service";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    
    # Create default configuration with secret management info
    xdg.configFile."mcp/hosts/default.yaml".text = ''
      # MCP Host Configuration
      # 
      # For API keys, use the AI secret management system:
      #   1. Enable: programs.ai.secrets.enable = true;
      #   2. Add keys: ai-add-secret ANTHROPIC_API_KEY "your-key"
      #   3. Keys will be automatically sourced as environment variables
      
      servers:
        - name: local
          command: ["${cfg.package}/bin/mcp", "host", "--stdio"]
          description: "Local MCP host"
    '';
    
    # Optional LaunchAgent for background service
    launchd.agents.mcphost = mkIf cfg.launchAgent.enable {
      enable = true;
      config = {
        ProgramArguments = [
          "${cfg.package}/bin/mcp"
          "host" 
          "--config" 
          cfg.configFile
          "--log-level"
          cfg.launchAgent.logLevel
        ];
        
        KeepAlive = true;
        RunAtLoad = true;
        
        # Environment variables for API keys
        EnvironmentVariables = {
          ANTHROPIC_API_KEY = "$ANTHROPIC_API_KEY";
          OPENAI_API_KEY = "$OPENAI_API_KEY";
          GOOGLE_API_KEY = "$GOOGLE_API_KEY";
        };
        
        # Logging
        StandardOutPath = "${config.xdg.stateHome}/mcp/host.log";
        StandardErrorPath = "${config.xdg.stateHome}/mcp/host.err.log";
        
        # Service metadata  
        Label = "org.mcphost.agent";
        ProcessType = "Background";
      };
    };
    
    # Create log directory
    xdg.dataFile."mcp/.keep".text = "";
  };
}