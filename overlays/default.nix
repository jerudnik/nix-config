# Custom overlays
{ inputs }:
{
  mcp-servers = final: prev: {
    mcp-servers = inputs.mcp-servers-nix.packages.${prev.system} or {};
  };

  zen-browser = import ./zen-browser.nix { inherit inputs; };
}
