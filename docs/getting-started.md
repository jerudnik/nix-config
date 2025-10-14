# Getting Started with Nix Configuration

This guide will help you get up and running with this clean Nix configuration system using nix-darwin and Home Manager.

> **📚 Essential Reading:**
|> - **[`workflow.md`](guides/workflow.md)** - Complete workflow reference ⚡
|> - **[`modular-architecture.md`](guides/modular-architecture.md)** - Advanced modular design 🏗️
|> - **[`architecture.md`](reference/architecture.md)** - System architecture overview
|> - **[`exceptions.md`](reference/exceptions.md)** - Exception handling framework 🛡️
|> - **[`quick-reference.md`](reference/quick-reference.md)** - Quick commands and patterns

## Prerequisites

- macOS (Apple Silicon or Intel)
- Nix package manager installed with flakes enabled
- Basic familiarity with command line
- Git repository cloned locally

## Quick Start

### 1. Clone and Enter Directory
```bash
git clone https://github.com/jerudnik/nix-config.git ~/nix-config
cd ~/nix-config
```

### 2. Test Configuration Build
```bash
# Test system configuration build
./scripts/build.sh build

# Or manually:
darwin-rebuild build --flake .#parsley
```

### 3. Apply Configuration
```bash
# Apply system configuration (includes Home Manager)
./scripts/build.sh switch

# Or manually:
sudo darwin-rebuild switch --flake .#parsley
```

### 4. Verify Installation
```bash
# Check if packages are available
which micro git go python3 tree jq

# Check if aliases work
alias ll nrs nrb

# Check git config
git config --get user.name
git config --get user.email
```

## Configuration Structure

### Core Components

- **`flake.nix`** - Main flake definition with inputs and outputs
- **`hosts/parsley/configuration.nix`** - System configuration using nix-darwin
- **`home/jrudnik/home.nix`** - User configuration using Home Manager
- **`modules/`** - Reusable modules for darwin, home-manager, and nixos
- **`scripts/build.sh`** - Convenient build/switch/check script

### System vs Home Configuration

**System Configuration (`hosts/parsley/configuration.nix`)**
Controls **system-wide settings**:
- Security policies and authentication (Touch ID, firewall)
- System defaults (Dock, Finder, global preferences)
- **All package installation** (CLI, TUI, and GUI tools)
- Nix daemon configuration
- User account definitions

**Home Configuration (`home/jrudnik/home.nix`)**
Controls **user-specific configuration**:
- Shell configuration and aliases
- Program dotfiles and settings
- Git configuration
- User preferences and custom patterns

**Note**: System installs tools, Home Manager configures them.

## Common Tasks

### Modify System Settings

Edit `hosts/parsley/configuration.nix`:
```nix
# Pane-based System Settings configuration
darwin.system-settings = {
  enable = true;
  
  # Desktop & Dock pane
  desktopAndDock = {
    dock = {
      autohide = true;
      orientation = "bottom";
      showRecents = false;
      
      # Dock applications (customize to your preferences)
      persistentApps = [
        "/Applications/Nix Apps/Warp.app"
        "/Applications/Nix Apps/Zen Browser (Twilight).app"
        "/System/Applications/Messages.app"
      ];
      
      # Dock folders
      persistentOthers = [
        "/Users/jrudnik/Downloads"
        "/Users/jrudnik/Documents"
      ];
    };
  };
  
  # Keyboard pane
  keyboard = {
    keyRepeat = 2;
    initialKeyRepeat = 15;
    remapCapsLockToControl = true;
  };
};

# Automatic light/dark theme switching
darwin.theming = {
  enable = true;
  colorScheme = "gruvbox-material-dark-medium";
  polarity = "either";  # Essential for auto-switching
  
  autoSwitch = {
    enable = true;
    lightScheme = "gruvbox-material-light-medium";
    darkScheme = "gruvbox-material-dark-medium";
  };
};
```

### Add Development Tools

Tools are installed at the system level in `hosts/parsley/configuration.nix`:
```nix
environment.systemPackages = with pkgs; [
  # Essential CLI tools
  git curl wget
  
  # Current development tools
  micro tree jq
  rustc cargo go python3
  
  # Add new tools here
  nodejs yarn
  docker
  kubectl
];
```

Configure them in `home/jrudnik/home.nix`:
```nix
# Home Manager configures tools installed by the system
programs.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "you@example.com";
};

programs.zsh = {
  enable = true;
  shellAliases = {
    k = "kubectl";
    d = "docker";
  };
};
```

### Update Shell Configuration

Edit the zsh configuration in `home/jrudnik/home.nix`:
```nix
programs.zsh = {
  enable = true;
  enableCompletion = true;
  
  shellAliases = {
    # Current aliases
    ll = "ls -alF";
    nrs = "sudo darwin-rebuild switch --flake ~/nix-config#parsley";
    
    # Add custom aliases
    deploy = "cd ~/projects && ./deploy.sh";
    logs = "tail -f /var/log/system.log";
  };
  
  oh-my-zsh = {
    enable = true;
    plugins = [
      "git" "macos"
      # Add more plugins
      "docker" "node" "rust"
    ];
    theme = "robbyrussell";
  };
};
```

### Configure MCP for Claude Desktop

Model Context Protocol (MCP) enables Claude Desktop to connect to external tools:

1. **Enable MCP module** in `home/jrudnik/home.nix`:
```nix
home.mcp = {
  enable = true;
  servers = {
    # Safe filesystem access (home directory only)
    filesystem = {
      command = "${pkgs.python3}/bin/python3";
      args = [ "${config.home.homeDirectory}/nix-config/modules/home/mcp/filesystem-server.py" "${config.home.homeDirectory}" ];
    };
    
    # Git operations
    git = {
      command = "${pkgs.mcp-servers.mcp-server-git}/bin/mcp-server-git";
    };
    
    # Time utilities
    time = {
      command = "${pkgs.mcp-servers.mcp-server-time}/bin/mcp-server-time";
    };
    
    # Web fetch capability
    fetch = {
      command = "${pkgs.mcp-servers.mcp-server-fetch}/bin/mcp-server-fetch";
    };
    
    # GitHub integration (optional - requires GITHUB_TOKEN)
    github = {
      command = "${pkgs.github-mcp-server}/bin/server";
      env = {
        # GITHUB_TOKEN = "your-token";  # Add for private repos
      };
    };
  };
};
```

2. **Install Claude Desktop** (already configured in system):
Claude Desktop will be installed via Homebrew when you apply the configuration.

3. **Test MCP servers** (after building):
```bash
# Verify MCP configuration file exists
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json

# Test filesystem server manually
echo '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {"roots": {"listChanged": true}}, "clientInfo": {"name": "test", "version": "1.0.0"}}}' | python3 ~/nix-config/modules/home/mcp/filesystem-server.py ~
```

4. **Use in Claude Desktop**:
- Launch Claude Desktop
- Ask Claude to read files: "What files are in my Documents folder?"
- Request git information: "Show me recent commits in this repository"
- Get time information: "What time is it in Tokyo?"
- Fetch web content: "Get the content from https://example.com"

See **[MCP Integration Guide](reference/mcp.md)** for complete documentation.

### Apply Changes

After making modifications:
```bash
# Test the build first
./scripts/build.sh build

# Apply the changes
./scripts/build.sh switch

# Or check for issues
./scripts/build.sh check
```

## Advanced Usage

### Create Custom Modules

1. **Create a Darwin module** (`modules/darwin/my-feature/default.nix`):
```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.my-feature;
in {
  options.my-feature = {
    enable = mkEnableOption "My custom feature";
    
    setting = mkOption {
      type = types.str;
      default = "default-value";
      description = "Custom setting description";
    };
  };

  config = mkIf cfg.enable {
    # Implementation here
  };
}
```

2. **Add to module exports** (`modules/darwin/default.nix`):
```nix
{
  my-feature = import ./my-feature;
}
```

3. **Import and use in host configuration**:
```nix
# In hosts/parsley/configuration.nix
imports = [
  # Add your module import
];

# Configure it
my-feature = {
  enable = true;
  setting = "custom-value";
};
```

### Manage Multiple Hosts

1. **Create new host directory**: `hosts/new-host/configuration.nix`
2. **Add to flake.nix**:
```nix
darwinConfigurations = {
  parsley = nix-darwin.lib.darwinSystem { ... };
  new-host = nix-darwin.lib.darwinSystem {
    inherit system specialArgs;
    modules = [
      ./hosts/new-host/configuration.nix
      # Add home-manager integration
    ];
  };
};
```
3. **Build with**: `darwin-rebuild switch --flake .#new-host`

### Manage Multiple Users

1. **Create new user directory**: `home/new-user/home.nix`
2. **Add to flake.nix**:
```nix
homeConfigurations = {
  "jrudnik@parsley" = home-manager.lib.homeManagerConfiguration { ... };
  "new-user@parsley" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = specialArgs;
    modules = [ ./home/new-user/home.nix ];
  };
};
```

## Troubleshooting

### Configuration Won't Build
```bash
# Check flake syntax
nix flake check

# Build with detailed output
darwin-rebuild build --flake .#parsley --show-trace

# Check for specific errors
./scripts/build.sh build 2>&1 | less
```

### Packages Not Available After Switch
```bash
# Restart your shell session
exec zsh

# Or manually source the environment
source ~/.nix-profile/etc/profile.d/hm-session-vars.sh
```

### Rollback Changes
```bash
# List system generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nix-env --rollback --profile /nix/var/nix/profiles/system

# List home-manager generations
home-manager generations
```

### Permission Issues
```bash
# Make sure you're using sudo for darwin-rebuild switch
sudo darwin-rebuild switch --flake .#parsley

# Check file permissions in the nix-config directory
ls -la ~/nix-config/
```

## Next Steps

- **[Workflow Guide](guides/workflow.md)** - Learn the development workflow
- **[Architecture Guide](reference/architecture.md)** - Understand the system design
- **[MCP Integration Guide](reference/mcp.md)** - Configure Claude Desktop with MCP servers
- **[Module Options Reference](reference/module-options.md)** - Complete module configuration reference

## Migration from Other Systems

This configuration was designed to be:
- **Framework-independent**: No external abstractions like Nilla
- **Community-standard**: Following established Nix patterns
- **Maintainable**: Clear separation of concerns and minimal complexity
- **Extensible**: Easy to add modules and customize