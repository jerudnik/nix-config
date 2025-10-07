# AI Interfaces  
# Direct LLM interaction tools and AI assistants
{
  imports = [
    ./claude-desktop.nix
    ./copilot-cli.nix
    ./goose-cli.nix
    # Note: claude-code, gemini-cli, and fabric-ai are available as nixpkgs modules
    # They're enabled directly in home.nix via:
    #   programs.claude-code.enable = true;
    #   programs.gemini-cli.enable = true;
    #   programs.fabric-ai.enable = true;
    # No custom wrapper modules needed - nixpkgs provides them
  ];
}
