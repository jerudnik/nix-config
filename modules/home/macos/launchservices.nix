{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.macos.launchservices;
in {
  options.home.macos.launchservices = {
    enable = mkEnableOption "macOS Launch Services configuration for default applications";
    
    handlers = mkOption {
      type = types.listOf types.attrs;
      default = [];
      example = literalExpression ''
        [
          {
            LSHandlerURLScheme = "http";
            LSHandlerRoleAll = "zen.browser";
          }
          {
            LSHandlerContentType = "public.plain-text";
            LSHandlerRoleAll = "com.apple.TextEdit";
          }
          {
            LSHandlerContentTag = "py";
            LSHandlerContentTagClass = "public.filename-extension";
            LSHandlerRoleAll = "com.microsoft.VSCode";
          }
        ]
      '';
      description = ''
        List of LSHandlers for configuring default applications.
        
        Each handler should specify one of:
        - LSHandlerURLScheme (for URL schemes like http, https, mailto)
        - LSHandlerContentType (for MIME types like public.html, public.plain-text)
        - LSHandlerContentTag + LSHandlerContentTagClass (for file extensions)
        
        And must include LSHandlerRoleAll with the target application's bundle ID.
        
        This module aggregates handlers from all sources to avoid conflicts.
      '';
    };
  };

  config = mkIf cfg.enable {
    # macOS platform assertion
    assertions = [
      {
        assertion = pkgs.stdenv.isDarwin;
        message = "home.macos.launchservices is only available on macOS (Darwin)";
      }
    ];

    # Write all handlers to Launch Services configuration
    targets.darwin.defaults."com.apple.LaunchServices/com.apple.launchservices.secure" = {
      LSHandlers = lib.unique cfg.handlers;
    };
    
    # Refresh Launch Services database after configuration changes
    home.activation.refreshLaunchServices = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [[ -n "''${VERBOSE:-}" ]]; then
        echo "Refreshing macOS Launch Services database..."
      fi
      
      # Kill and refresh the Launch Services database
      # This ensures that our new default application settings take effect
      /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
        -kill -r -domain local -domain system -domain user 2>/dev/null || true
    '';
  };
}