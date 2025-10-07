# AI Infrastructure
# Supporting systems and secret management
# Note: MCP server configuration now handled by mcp-servers-nix (see home.nix)
{
  imports = [
    ./secrets.nix
  ];
}
