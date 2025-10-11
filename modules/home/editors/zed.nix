{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.editors.zed;
in {
  options.home.editors.zed = {
    enable = mkEnableOption "Zed Text Editor";

    settings = mkOption {
      type = with types; attrsOf (oneOf [ bool str int (listOf str) ]);
      default = {};
      description = "Custom settings for Zed's settings.json.";
    };
    
    extensions = mkOption {
      type = types.listOf types.str;
      default = [
        "nix"              # Nix language support
        "toml"             # TOML syntax
      ];
      description = "List of Zed extensions to auto-install";
      example = literalExpression ''[ "nix" "rust" "toml" "dockerfile" ]'';
    };
    
    enableGitHubCopilot = mkOption {
      type = types.bool;
      default = false;
      description = "Enable GitHub Copilot integration (requires manual OAuth login)";
    };
    
    theme = mkOption {
      type = types.str;
      default = "Gruvbox Dark Hard";
      description = "Zed color theme";
    };
    
    fontSize = mkOption {
      type = types.int;
      default = 14;
      description = "Editor font size";
    };
  };

  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      
      # Extensions to auto-install
      extensions = cfg.extensions;
      
      userSettings = {
        # Telemetry (privacy first)
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
        
        # Theme and appearance (mkDefault allows theming module to override)
        theme = mkDefault cfg.theme;
        buffer_font_size = mkDefault cfg.fontSize;
        
        # Editor behavior
        tab_size = 2;
        soft_wrap = "editor_width";
        auto_save = "on_focus_change";
        format_on_save = "on";
        
        # Git integration
        git = {
          git_gutter = "tracked_files";
          inline_blame = {
            enabled = true;
          };
        };
        
        # GitHub Copilot (requires manual OAuth)
        features = mkIf cfg.enableGitHubCopilot {
          copilot = true;
        };
        
        # LSP settings
        lsp = {
          rust-analyzer = {
            binary = {
              path = "${pkgs.rust-analyzer}/bin/rust-analyzer";
            };
          };
        };
        
      } // cfg.settings;  # Allow custom settings to override defaults
    };
    
    # Reminder about GitHub/Copilot OAuth
    home.activation.zedOAuthReminder = mkIf cfg.enableGitHubCopilot (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        echo "🤖 Zed: GitHub Copilot requires manual OAuth login on first run"
        echo "   Open Zed → Settings → Copilot → Sign in with GitHub"
      ''
    );
  };
}
