# YubiKey Hardware Security Module
# Provides YubiKey support for SSH authentication, GPG signing, and age encryption
#
# Features:
# - Hardware-backed SSH keys via yubikey-agent
# - GPG smart card support for code signing
# - Age encryption with YubiKey plugin
# - YubiKey management tools
# - Touch notification feedback
#
# Usage:
#   home.security.yubikey.enable = true;
#   home.security.yubikey.sshAgent.enable = true;
#   home.security.yubikey.gpg.enable = true;

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.security.yubikey;
in
{
  options.home.security.yubikey = {
    enable = mkEnableOption "YubiKey hardware security support";
    
    sshAgent = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable yubikey-agent as the SSH agent.
          Provides hardware-backed SSH authentication with touch requirement.
          
          Note: This replaces the default SSH agent.
        '';
      };
      
      pinEntry = mkOption {
        type = types.enum [ "mac" "curses" "tty" ];
        default = "mac";
        description = ''
          PIN entry program for YubiKey SSH agent.
          - "mac": Native macOS PIN entry dialog
          - "curses": Terminal-based PIN entry
          - "tty": Simple TTY PIN entry
        '';
      };
    };
    
    gpg = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable GPG with YubiKey smart card support.
          Allows storing GPG keys on YubiKey for signing and encryption.
        '';
      };
      
      enableGitSigning = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Configure git to use GPG signing with YubiKey.
          Requires GPG keys to be stored on your YubiKey.
        '';
      };
    };
    
    ageEncryption = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable age encryption with YubiKey plugin.
          Allows encrypting/decrypting age files using YubiKey hardware.
        '';
      };
    };
    
    touchDetector = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable visual feedback when YubiKey is waiting for touch.
          Shows notifications when YubiKey needs user interaction.
        '';
      };
    };
    
    tools = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        yubikey-manager       # CLI tool for YubiKey configuration
        yubico-piv-tool      # PIV smart card operations
      ];
      description = ''
        Additional YubiKey management tools to install.
        Common tools:
        - yubikey-manager: Main CLI for configuring YubiKey
        - yubico-piv-tool: PIV certificate and key management
        - yubikey-personalization: OTP configuration
      '';
    };
  };

  config = mkIf cfg.enable {
    # Install YubiKey management tools
    home.packages = cfg.tools ++ optionals cfg.ageEncryption.enable [
      pkgs.age-plugin-yubikey
    ] ++ optionals cfg.touchDetector.enable [
      pkgs.yubikey-touch-detector
    ];
    
    # SSH Agent configuration
    programs.ssh = mkIf cfg.sshAgent.enable {
      enable = true;
      
      extraConfig = ''
        # YubiKey SSH Agent
        # Keys are stored on YubiKey PIV slots
        IdentityAgent "''${XDG_RUNTIME_DIR}/yubikey-agent/yubikey-agent.sock"
      '';
    };
    
    # YubiKey SSH Agent service
    launchd.agents.yubikey-agent = mkIf cfg.sshAgent.enable {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.yubikey-agent}/bin/yubikey-agent"
          "-l"
          "''${XDG_RUNTIME_DIR}/yubikey-agent/yubikey-agent.sock"
        ];
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "''${HOME}/Library/Logs/yubikey-agent.log";
        StandardErrorPath = "''${HOME}/Library/Logs/yubikey-agent.log";
        EnvironmentVariables = {
          PINENTRY_PROGRAM = mkDefault (
            if cfg.sshAgent.pinEntry == "mac" then "${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac"
            else if cfg.sshAgent.pinEntry == "curses" then "${pkgs.pinentry-curses}/bin/pinentry-curses"
            else "${pkgs.pinentry-tty}/bin/pinentry-tty"
          );
        };
      };
    };
    
    # GPG configuration with YubiKey support
    programs.gpg = mkIf cfg.gpg.enable {
      enable = true;
      
      settings = {
        # Use agent for key operations
        use-agent = true;
        
        # Prefer stronger algorithms
        personal-cipher-preferences = "AES256 AES192 AES";
        personal-digest-preferences = "SHA512 SHA384 SHA256";
        personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
        
        # Default key preferences
        default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
        
        # Strong cipher for symmetric encryption
        s2k-cipher-algo = "AES256";
        s2k-digest-algo = "SHA512";
        cert-digest-algo = "SHA512";
        
        # Disable weak algorithms
        disable-cipher-algo = "3DES";
        weak-digest = "SHA1";
        
        # Display long key IDs
        keyid-format = "0xlong";
        
        # Display fingerprint
        with-fingerprint = true;
        
        # Cross-certify subkeys
        require-cross-certification = true;
        
        # Don't include version in output
        no-emit-version = true;
        
        # Don't include comment in output  
        no-comments = true;
        
        # Use UTF-8
        charset = "utf-8";
        
        # Show Unix timestamps
        fixed-list-mode = true;
      };
    };
    
    # GPG Agent configuration for YubiKey
    services.gpg-agent = mkIf cfg.gpg.enable {
      enable = true;
      enableSshSupport = !cfg.sshAgent.enable;  # Don't conflict with yubikey-agent
      
      # PIN entry program
      pinentryPackage = mkDefault (
        if cfg.sshAgent.pinEntry == "mac" then pkgs.pinentry_mac
        else if cfg.sshAgent.pinEntry == "curses" then pkgs.pinentry-curses
        else pkgs.pinentry-tty
      );
      
      # Smart card daemon for YubiKey
      enableScDaemon = true;
      
      # Cache settings
      defaultCacheTtl = 600;        # 10 minutes
      defaultCacheTtlSsh = 600;
      maxCacheTtl = 7200;           # 2 hours
      maxCacheTtlSsh = 7200;
    };
    
    # Git signing with YubiKey GPG
    programs.git = mkIf (cfg.gpg.enable && cfg.gpg.enableGitSigning) {
      signing = {
        signByDefault = mkDefault true;
        # Note: User must set their GPG key ID
        # key = "0x1234567890ABCDEF";  # Set this in home.nix
      };
    };
    
    # YubiKey Touch Detector service
    launchd.agents.yubikey-touch-detector = mkIf cfg.touchDetector.enable {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.yubikey-touch-detector}/bin/yubikey-touch-detector"
          "--libnotify"
        ];
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "''${HOME}/Library/Logs/yubikey-touch-detector.log";
        StandardErrorPath = "''${HOME}/Library/Logs/yubikey-touch-detector.log";
      };
    };
    
    # Shell aliases for common YubiKey operations
    home.shellAliases = {
      # YubiKey management
      yk = "ykman";
      yk-info = "ykman info";
      yk-list = "ykman list";
      
      # PIV operations
      yk-piv = "yubico-piv-tool";
      yk-piv-status = "yubico-piv-tool -a status";
      
      # GPG smart card
      yk-gpg = "gpg --card-status";
      yk-gpg-edit = "gpg --card-edit";
      
      # SSH operations
      yk-ssh-add = "ssh-add -L";  # List keys from agent
      yk-ssh-test = "ssh-add -T ~/.ssh/id_*.pub || echo 'No keys loaded'";
    };
    
    # Activation script to create directories and show setup instructions
    home.activation.yubikeySetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Create YubiKey agent socket directory
      mkdir -p "''${XDG_RUNTIME_DIR}/yubikey-agent"
      
      # Show setup instructions on first activation
      if [ ! -f "$HOME/.config/yubikey-configured" ]; then
        $DRY_RUN_CMD cat <<EOF
        
🔐 YubiKey Support Enabled!

Next steps to set up your YubiKey:

1. Generate SSH key on YubiKey (PIV slot 9a):
   ykman piv keys generate --algorithm ECCP256 9a pubkey.pem
   ykman piv certificates generate --subject "SSH Key" 9a pubkey.pem

2. Generate GPG key on YubiKey:
   gpg --card-edit
   > admin
   > generate

3. For age encryption with YubiKey:
   age-plugin-yubikey --generate -o yubikey-identity.txt
   
4. Test SSH agent:
   ssh-add -L

📚 Full documentation: docs/guides/yubikey-setup.md

EOF
        touch "$HOME/.config/yubikey-configured"
      fi
    '';
  };
}
