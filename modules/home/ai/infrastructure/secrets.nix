{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.ai.secrets;

in {
  options.programs.ai.secrets = {
    enable = mkEnableOption "macOS Keychain integration for AI tool secrets";
    
    keys = mkOption {
      type = types.listOf types.str;
      default = [
        "ANTHROPIC_API_KEY"
        "OPENAI_API_KEY"
        "GEMINI_API_KEY"
        "GROQ_API_KEY"
        "TOGETHER_API_KEY"
        "PERPLEXITY_API_KEY"
        "MISTRAL_API_KEY"
        "COHERE_API_KEY"
        "HUGGINGFACE_API_KEY"
        "GITHUB_TOKEN"
      ];
      description = "List of environment variable names to source from keychain";
      example = literalExpression ''[ "ANTHROPIC_API_KEY" "OPENAI_API_KEY" ]'';
    };
    
    shellIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to automatically source secrets in shell sessions";
    };
  };

  config = mkIf cfg.enable {
    # Add secret management commands to PATH
    home.packages = [
      (pkgs.writeScriptBin "ai-add-secret" ''#!/bin/bash
set -e

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <KEY_NAME> <SECRET_VALUE>"
  echo ""
  echo "Available keys: ${lib.concatStringsSep ", " cfg.keys}"
  echo ""
  echo "Example:"
  echo "  $0 ANTHROPIC_API_KEY sk-ant-..."
  exit 1
fi

KEY_NAME="$1"
SECRET_VALUE="$2"
SERVICE_NAME="ai-tools-$KEY_NAME"

# Validate key name
if [[ ! " ${lib.concatStringsSep " " cfg.keys} " =~ " $KEY_NAME " ]]; then
  echo "Error: '$KEY_NAME' is not a configured secret key."
  echo "Available keys: ${lib.concatStringsSep ", " cfg.keys}"
  exit 1
fi

# Add to keychain (will update if exists)
/usr/bin/security add-generic-password \
  -s "$SERVICE_NAME" \
  -a "$USER" \
  -w "$SECRET_VALUE" \
  -U

echo "✓ Added '$KEY_NAME' to keychain service '$SERVICE_NAME'"
'')
      (pkgs.writeScriptBin "ai-remove-secret" ''#!/bin/bash
set -e

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <KEY_NAME>"
  echo ""
  echo "Available keys: ${lib.concatStringsSep ", " cfg.keys}"
  exit 1
fi

KEY_NAME="$1"
SERVICE_NAME="ai-tools-$KEY_NAME"

# Remove from keychain
/usr/bin/security delete-generic-password \
  -s "$SERVICE_NAME" 2>/dev/null || true

echo "✓ Removed '$KEY_NAME' from keychain service '$SERVICE_NAME'"
'')
      (pkgs.writeScriptBin "ai-list-secrets" ''
        #!/bin/bash
        echo "AI Tool Secret Keys (configured in nix-config):"
        ${lib.concatMapStringsSep "\n" (key: ''
          SERVICE="ai-tools-${key}"
          if /usr/bin/security find-generic-password -s "$SERVICE" >/dev/null 2>&1; then
            echo "  ✓ ${key}"
          else
            echo "  ✗ ${key} (not in keychain)"
          fi
        '') cfg.keys}
        
        echo ""
        echo "Commands:"
        echo "  ai-add-secret <KEY> <VALUE>    # Add/update a secret"
        echo "  ai-remove-secret <KEY>         # Remove a secret" 
        echo "  ai-source-secrets [--debug]    # Source secrets to environment"
      '')
      (pkgs.writeScriptBin "ai-source-secrets" ''#!/bin/bash
# AI Tools Keychain Secret Sourcing
# This script exports environment variables from macOS Keychain

${lib.concatMapStringsSep "\n" (key: ''export ${key}="$(/usr/bin/security find-generic-password -s "ai-tools-${key}" -w 2>/dev/null || echo "")"
'') cfg.keys}

# Optional: Print loaded keys (for debugging, values hidden)
if [[ "$1" == "--debug" ]]; then
  echo "AI Secrets loaded from keychain:"
${lib.concatMapStringsSep "\n" (key: ''  if [[ -n "$${key}" ]]; then
    echo "  ✓ ${key} (''${#${key}} chars)"
  else
    echo "  ✗ ${key} (not found in keychain)"
  fi'') cfg.keys}
fi
'')
    ];

    # Shell integration - automatically source secrets
    programs.zsh.initContent = mkIf cfg.shellIntegration ''
      # AI Tools - Source secrets from keychain
      eval "$(ai-source-secrets)"
    '';
    
    programs.bash.initExtra = mkIf cfg.shellIntegration ''
      # AI Tools - Source secrets from keychain  
      eval "$(ai-source-secrets)"
    '';
    
    # Create a file with instructions
    xdg.configFile."ai-tools/secrets-setup.md".text = ''
      # AI Tools Secret Management
      
      This nix-config uses macOS Keychain to securely store AI API keys.
      
      ## Adding Secrets
      
      ```bash
      # Add an API key to keychain
      ai-add-secret ANTHROPIC_API_KEY "sk-ant-your-key-here"
      ai-add-secret OPENAI_API_KEY "sk-your-openai-key"
      ai-add-secret GEMINI_API_KEY "your-gemini-key"
      ```
      
      ## Managing Secrets
      
      ```bash
      # List all configured secret keys
      ai-list-secrets
      
      # Remove a secret
      ai-remove-secret ANTHROPIC_API_KEY
      
      # Manually source secrets (usually automatic)
      ai-source-secrets
      
      # Debug secret loading
      ai-source-secrets --debug
      ```
      
      ## Configured Keys
      
      ${lib.concatMapStringsSep "\n" (key: "- `${key}`") cfg.keys}
      
      ## Security Notes
      
      - Secrets are stored in macOS Keychain with your user account
      - Access requires your login or Touch ID authentication
      - Secrets are automatically sourced in new shell sessions
      - Use `security` command directly for advanced keychain management
      
      ## Adding New Keys
      
      To add support for new API keys, update the `keys` list in your nix configuration:
      
      ```nix
      programs.ai.secrets = {
        enable = true;
        keys = [
          "ANTHROPIC_API_KEY"
          "YOUR_NEW_KEY"
          # ... other keys
        ];
      };
      ```
    '';
  };
}