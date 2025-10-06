# AI Tools Nixpkgs Availability Inventory

Generated: 2025-01-05T03:50:56Z

## ✅ Available in Nixpkgs (Primary Implementation)

### Core AI Tools
- **fabric-ai** (1.4.308) - Framework for augmenting humans using AI with modular prompts
- **gemini-cli** (0.6.1) - AI agent that brings Gemini directly into your terminal
- **mcphost** (0.19.2) - CLI host application for Model Context Protocol (MCP)
- **claude-code** (2.0.1) - Agentic coding tool for terminal

### Code Analysis & Prompt Generation
- **code2prompt** (1.1.0) - CLI tool that converts codebase into LLM prompt with source tree
- **files-to-prompt** (0.6) - Concatenate directory of files into single LLM prompt
- **goose-cli** (1.6.0) - Open-source, extensible AI agent for code tasks

### GitHub Copilot Ecosystem
- **gh-copilot** (1.1.1) - Ask for assistance right in your terminal
- **github-copilot-cli** (0.0.328) - GitHub Copilot CLI brings Copilot directly to terminal
- **copilot-language-server** (1.377.0) - Use GitHub Copilot via Language Server Protocol

## 🚫 Not Available in Nixpkgs (Homebrew Candidates)

### GUI Applications
- **Claude Desktop** - Available as Homebrew cask: `claude`

## 📋 Implementation Plan

### Phase 1: Nixpkgs-First Implementation
All tools listed under "Available in Nixpkgs" will be implemented as Nix modules with feature flags.

### Phase 2: Homebrew Integration (Optional)
Tools not available in nixpkgs can be added later via declarative homebrew integration.

## Module Structure

```
modules/ai/
├── default.nix           # Aggregator module
├── fabric-ai.nix        # Fabric AI framework
├── gemini-cli.nix       # Gemini CLI client
├── mcphost.nix          # MCP protocol host
├── claude-code.nix      # Claude Code terminal tool
├── code2prompt.nix      # Code to prompt converter
├── files-to-prompt.nix  # Files to prompt tool
├── goose-cli.nix        # Goose AI agent
├── copilot-cli.nix      # GitHub Copilot CLI (stub)
└── claude-desktop.nix   # Claude Desktop (stub)
```

## Constraint Adherence

✅ **Nixpkgs-first**: All primary tools available in nixpkgs  
✅ **No editor integrations**: Pure CLI tools only  
✅ **Feature flags**: All modules disabled by default  
✅ **Modular design**: Each tool gets own module  
✅ **WARP.md compliance**: Following Law 5 (Source Integrity)