{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.programs.ai.diagnostics;
  aiDoctorScript = pkgs.writeShellScriptBin "ai-doctor" ''
    #!/bin/bash
    
    echo "🔍 AI Tools Diagnostics Report"
    echo "===============================" 
    echo ""
    
    # Check secret management first
    echo "🔐 Secret Management:"
    echo "--------------------"
    if command -v ai-list-secrets &> /dev/null; then
        echo "✅ AI secret management enabled"
        echo "   Loading secrets from keychain..."
        eval "$(ai-source-secrets 2>/dev/null)" || echo "   ⚠️  Failed to load some secrets"
    else
        echo "❌ AI secret management not configured"
        echo "   Enable with: programs.ai.secrets.enable = true;"
    fi
    echo ""
    
    # Check environment variables
    echo "📋 Environment Variables:"
    echo "-------------------------"
    
    check_env_var() {
        local var_name=$1
        if [ -n "''${!var_name:-}" ]; then
            local value="''${!var_name}"
            echo "✅ $var_name: Set (''${#value} chars)"
        else
            echo "❌ $var_name: Not set"
        fi
    }
    
    check_env_var "ANTHROPIC_API_KEY"
    check_env_var "OPENAI_API_KEY"
    check_env_var "GEMINI_API_KEY"
    check_env_var "GROQ_API_KEY"
    check_env_var "HUGGINGFACE_API_KEY"
    check_env_var "GITHUB_TOKEN"
    echo ""
    echo ""
    
    # Check installed tools
    echo "🛠️  Installed AI Tools:"
    echo "----------------------"
    
    check_tool() {
        local tool=$1
        local name=$2
        if command -v "$tool" &> /dev/null; then
            echo "✅ $name: Available"
        else
            echo "❌ $name: Not installed"
        fi
    }
    
    check_tool "fabric" "Fabric AI"
    check_tool "gemini" "Gemini CLI"
    check_tool "claude-code" "Claude Code"
    check_tool "mcphost" "MCP Host"
    check_tool "code2prompt" "Code2Prompt"
    check_tool "files-to-prompt" "Files to Prompt"
    check_tool "goose" "Goose CLI"
    echo ""
    
    echo "📝 Quick Usage Examples:"
    echo "------------------------"
    echo "• fabric --list                    # List available patterns"
    echo "• gemini 'Explain quantum computing'  # Ask Gemini"
    echo "• code2prompt .                    # Convert current dir to prompt"
    echo "• files-to-prompt *.nix            # Combine Nix files for LLM"
    echo "• goose --help                     # Get help with Goose"
    echo ""
  '';
  
in {
  options.programs.ai.diagnostics = {
    enable = mkEnableOption "AI tools diagnostics and verification utilities";
  };

  config = mkIf cfg.enable {
    home.packages = [ aiDoctorScript ];
  };
}