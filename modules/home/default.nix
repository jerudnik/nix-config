# Home Manager modules
{
  shell = import ./shell/default.nix;
  development = import ./development/default.nix;
  git = import ./git/default.nix;
  cli-tools = import ./cli-tools/default.nix;
  window-manager = import ./window-manager/default.nix;
  security = import ./security/default.nix;
  ai = import ./ai/default.nix;
  # mcp module removed - using mcp-servers-nix directly
  

}
