{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.darwin.security;
in {
  options.darwin.security = {
    enable = mkEnableOption "Darwin security settings and authentication";
    
    touchIdForSudo = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Touch ID for sudo authentication";
    };
    
    primaryUser = mkOption {
      type = types.str;
      description = "Primary user for the system (required for user-specific defaults)";
      example = "jrudnik";
    };
  };

  config = mkIf cfg.enable {
    # Validate required configuration
    assertions = [{
      assertion = cfg.primaryUser != "";
      message = "darwin.security.primaryUser must be set when security module is enabled";
    }];
    
    # Enable Touch ID for sudo
    security.pam.services.sudo_local.touchIdAuth = mkIf cfg.touchIdForSudo true;
    
    # Set primary user for system-wide user defaults
    system.primaryUser = cfg.primaryUser;
    
    # Define user account
    users.users.${cfg.primaryUser} = {
      name = cfg.primaryUser;
      home = "/Users/${cfg.primaryUser}";
    };
  };
}