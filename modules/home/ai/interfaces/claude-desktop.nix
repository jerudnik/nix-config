# Claude Desktop AI Assistant
# 
# MCP servers are now configured via mcp-servers-nix in home.nix
# This module just provides documentation and installation notice
{ lib, config, ... }:

with lib;

let
  cfg = config.programs.claude-desktop;
in {
  options.programs.claude-desktop = {
    enable = mkEnableOption {
      description = ''Claude Desktop AI assistant application.
        
        Installed via Homebrew: `brew install --cask claude`
        
        MCP (Model Context Protocol) servers are configured via mcp-servers-nix.
        See home.nix for MCP server configuration.
        
        Provides:
        - Direct Claude AI conversations
        - MCP server integration (configured via mcp-servers-nix)
        - File upload and analysis capabilities
        - Project-based conversation management'';
      example = true;
    };
  };

  config = mkIf cfg.enable {
    # MCP configuration now handled by mcp-servers-nix in home.nix
    # No packages added per WARP.md constraints
    
    # Installation notice
    home.activation.claude-desktop-notice = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "🤖 Claude Desktop: MCP servers configured via mcp-servers-nix";
    '';
  };
}
