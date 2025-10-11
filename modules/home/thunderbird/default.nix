{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.thunderbird;
in
{
  options.home.thunderbird = {
    enable = mkEnableOption "Thunderbird email client configuration";
    
    profiles = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          isDefault = mkOption {
            type = types.bool;
            default = false;
            description = "Whether this is the default profile";
          };
          
          settings = mkOption {
            type = types.attrs;
            default = {};
            description = "Thunderbird preferences to set";
            example = literalExpression ''
              {
                "mail.openpgp.enable" = true;
                "mail.collect_addressbook" = "jsaddrbook://history.sqlite";
                "privacy.donottrackheader.enabled" = true;
              }
            '';
          };
        };
      });
      default = {};
      description = "Thunderbird profiles configuration";
    };
    
    # Common useful settings exposed as options
    privacy = {
      enableDoNotTrack = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Do Not Track header";
      };
      
      disableTelemetry = mkOption {
        type = types.bool;
        default = true;
        description = "Disable telemetry and data collection";
      };
    };
    
    features = {
      enableOpenPGP = mkOption {
        type = types.bool;
        default = true;
        description = "Enable OpenPGP encryption support";
      };
      
      enableCalendar = mkOption {
        type = types.bool;
        default = true;
        description = "Enable calendar (Lightning) integration";
      };
      
      compactFolders = mkOption {
        type = types.bool;
        default = true;
        description = "Automatically compact folders";
      };
    };
    
    appearance = {
      theme = mkOption {
        type = types.enum [ "auto" "light" "dark" ];
        default = "auto";
        description = "UI theme (auto follows system appearance)";
      };
      
      fontSize = mkOption {
        type = types.int;
        default = 14;
        description = "Base font size for emails";
      };
    };
  };

  config = mkIf cfg.enable {
    # Note: Thunderbird itself is installed via nix-darwin
    # This module configures preferences only
    
    programs.thunderbird = {
      enable = true;
      
      profiles = mapAttrs (name: profileCfg: {
        isDefault = profileCfg.isDefault;
        
        settings = {
          # Privacy settings
          "privacy.donottrackheader.enabled" = cfg.privacy.enableDoNotTrack;
          "datareporting.healthreport.uploadEnabled" = !cfg.privacy.disableTelemetry;
          "datareporting.policy.dataSubmissionEnabled" = !cfg.privacy.disableTelemetry;
          
          # Feature settings
          "mail.openpgp.enable" = cfg.features.enableOpenPGP;
          "calendar.timezone.local" = "America/New_York";  # Adjust as needed
          "mail.prompt_purge_threshhold" = cfg.features.compactFolders;
          
          # Appearance
          "ui.systemUsesDarkTheme" = mkIf (cfg.appearance.theme == "dark") 1;
          "font.size.variable.x-western" = cfg.appearance.fontSize;
          
          # Useful defaults
          "mail.collect_addressbook" = "jsaddrbook://history.sqlite";
          "mailnews.default_sort_order" = 2;  # Descending (newest first)
          "mailnews.default_sort_type" = 18;  # Sort by date
          
        } // profileCfg.settings;  # Allow custom settings to override
      }) cfg.profiles;
    };
    
    # Note about OAuth accounts
    home.activation.thunderbirdOAuthReminder = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "📧 Thunderbird: Email accounts (Gmail, Outlook, etc.) require manual OAuth setup"
      echo "   Preferences are managed declaratively, but account credentials are stateful"
    '';
  };
}
