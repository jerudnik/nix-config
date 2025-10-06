# Custom overlays
{ inputs }: {
  # MCP servers overlay - provides packages from mcp-servers-nix
  mcp-servers = final: prev: {
    mcp-servers = inputs.mcp-servers-nix.packages.${prev.system} or {};
  };
  
  # Add custom overlays here when needed
  # Example:
  # my-custom-overlay = final: prev: {
  #   myCustomPackage = prev.myCustomPackage.overrideAttrs (old: {
  #     # modifications
  #   });
  # };
}
