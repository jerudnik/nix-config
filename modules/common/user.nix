{ config, pkgs, ... }:

{
  # Home Manager configuration
  home = {
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  stylix.targets = {
    alacritty.enable = true;
    bat.enable = true;
    btop.enable = true;
    fzf.enable = true;
    vim.enable = true;
    neovim.enable = true;
    lazygit.enable = true;
    gtk.enable = true;
  };

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets = {
      "api_keys/github_token" = { path = "${config.home.homeDirectory}/.secrets/github-token"; };
      "api_keys/openai_api_key" = { path = "${config.home.homeDirectory}/.secrets/openai-api-key"; };
      "api_keys/anthropic_api_key" = { path = "${config.home.homeDirectory}/.secrets/anthropic-api-key"; };
      "development/database_url" = { path = "${config.home.homeDirectory}/.secrets/database-url"; };
      "development/redis_url" = { path = "${config.home.homeDirectory}/.secrets/redis-url"; };
      "ssh/github_personal_key" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0600";
      };
    };
  };

  xdg.enable = true;

  xdg.configFile."fabric/patterns" = {
    source = ./../../modules/home/ai/patterns/fabric/tasks;
    recursive = true;
  };
}
