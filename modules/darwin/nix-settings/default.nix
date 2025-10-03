{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.darwin.nix-settings;
in {
  options.darwin.nix-settings = {
    enable = mkEnableOption "Nix daemon configuration and optimization";
    
    trustedUsers = mkOption {
      type = types.listOf types.str;
      default = [ "root" ];
      description = "List of trusted users for nix operations";
    };
    
    garbageCollection = {
      automatic = mkOption {
        type = types.bool;
        default = true;
        description = "Enable automatic garbage collection";
      };
      
      interval = mkOption {
        type = types.attrs;
        default = { Weekday = 7; Hour = 3; Minute = 15; };
        description = "Garbage collection schedule";
      };
      
      options = mkOption {
        type = types.str;
        default = "--delete-older-than 30d";
        description = "Garbage collection options";
      };
    };
    
    optimizeStore = mkOption {
      type = types.bool;
      default = true;
      description = "Enable automatic store optimization";
    };
    
    extraSubstituters = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional binary cache substituters";
    };
    
    extraPublicKeys = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional trusted public keys";
    };
  };

  config = mkIf cfg.enable {
    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        
        # Trusted users for nix operations
        trusted-users = [ "root" ] ++ cfg.trustedUsers;
        
        # Binary caches for faster builds
        substituters = [
          "https://cache.nixos.org/"
          "https://nix-community.cachix.org"
        ] ++ cfg.extraSubstituters;
        
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ] ++ cfg.extraPublicKeys;
      };
      
      # Garbage collection
      gc = mkIf cfg.garbageCollection.automatic {
        automatic = true;
        interval = cfg.garbageCollection.interval;
        options = cfg.garbageCollection.options;
      };
      
      # Store optimization
      optimise.automatic = cfg.optimizeStore;
    };
  };
}