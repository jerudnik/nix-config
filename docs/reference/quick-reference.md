# Quick Reference

Essential commands and patterns for daily use of this Nix configuration.

## Quick Commands

### Build Operations

```bash
# Test build (no changes applied)
./scripts/build.sh build

# Apply configuration (system + home)  
./scripts/build.sh switch

# Check flake syntax and structure
./scripts/build.sh check

# Update all flake inputs
./scripts/build.sh update

# Clean up old generations
./scripts/build.sh clean

# Check theme switching status (when autoSwitch enabled)
nix-theme-switch
```

### Manual Commands

```bash
# System configuration
sudo darwin-rebuild switch --flake ~/nix-config#parsley
sudo darwin-rebuild build --flake ~/nix-config#parsley

# Home Manager only
home-manager switch --flake ~/nix-config#jrudnik@parsley
home-manager build --flake ~/nix-config#jrudnik@parsley

# Flake operations
nix flake check ~/nix-config
nix flake update ~/nix-config
```

### Shell Aliases (Available After Apply)

```bash
# Nix operations
nrs     # sudo darwin-rebuild switch --flake ~/nix-config#parsley
nrb     # darwin-rebuild build --flake ~/nix-config#parsley
nfu     # nix flake update
nfc     # nix flake check
ngc     # nix-collect-garbage -d && sudo nix-collect-garbage -d

# File operations
ll      # ls -alF
la      # ls -A
l       # ls -CF
..      # cd ..
...     # cd ../..
```

## Configuration Files

### Key Files to Edit

```bash
# System configuration (macOS defaults, system packages)
~/nix-config/hosts/parsley/configuration.nix

# User configuration (shell, packages, programs)
~/nix-config/home/jrudnik/home.nix

# Main flake (inputs, outputs, structure)
~/nix-config/flake.nix
```

### File Structure Quick Navigation

```
~/nix-config/
├── flake.nix                    # Main configuration
├── hosts/parsley/
│   └── configuration.nix        # System settings
├── home/jrudnik/
│   └── home.nix                 # User settings
├── modules/
│   ├── darwin/                  # System modules
│   ├── home/                    # Home modules
│   └── nixos/                   # Linux modules
├── scripts/build.sh             # Build script
└── docs/                        # Documentation
```

## Common Patterns

### Adding Packages

**System packages (all tools installed here):**
```nix
# In hosts/parsley/configuration.nix
environment.systemPackages = with pkgs; [
  # Essential CLI tools
  git curl wget
  
  # Development tools
  nodejs yarn docker kubectl
  rustc cargo go python3
  
  # Utilities
  htop ripgrep fzf eza bat fd
];
```

**Home Manager (configuration only):**
```nix
# In home/jrudnik/home.nix
# Home Manager configures tools, doesn't install them
programs.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "you@example.com";
};

programs.zsh = {
  enable = true;
  shellAliases = {
    k = "kubectl";
  };
};
```

### Configuring Programs

**Shell (zsh with oh-my-zsh):**
```nix
# In home/jrudnik/home.nix
programs.zsh = {
  enable = true;
  enableCompletion = true;
  
  shellAliases = {
    deploy = "cd ~/projects && ./deploy.sh";
    logs = "tail -f /var/log/system.log";
  };
  
  oh-my-zsh = {
    enable = true;
    plugins = [ "git" "macos" "docker" "node" ];
    theme = "robbyrussell";
  };
};
```

**Git configuration:**
```nix
programs.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your.email@example.com";
  
  extraConfig = {
    init.defaultBranch = "main";
    core.editor = "micro";
    pull.rebase = false;
  };
};
```

### System Settings

**Pane-based configuration:**
```nix
# In hosts/parsley/configuration.nix
darwin.system-settings = {
  enable = true;
  
  # Desktop & Dock pane
  desktopAndDock = {
    dock = {
      autohide = true;
      orientation = "bottom";
      showRecents = false;
      minimizeToApp = true;
      
      # Dock applications
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
  
  # General pane (includes Finder)
  general = {
    textInput = {
      disableAutomaticCapitalization = true;
      disableAutomaticSpellingCorrection = true;
    };
    
    panels = {
      expandSavePanel = true;
    };
    
    finder = {
      showAllExtensions = true;
      showPathbar = true;
      showStatusBar = true;
      defaultViewStyle = "column";
    };
  };
};
```

**Theme switching:**
```nix
# Automatic light/dark theme switching
darwin.theming = {
  enable = true;
  colorScheme = "gruvbox-material-dark-medium";
  polarity = "either";
  
  autoSwitch = {
    enable = true;
    lightScheme = "gruvbox-material-light-medium";
    darkScheme = "gruvbox-material-dark-medium";
  };
};
```

## Troubleshooting

### Build Issues

```bash
# Detailed error output
nix flake check --show-trace
darwin-rebuild build --flake ~/nix-config#parsley --show-trace

# Check specific configuration
nix eval ~/nix-config#darwinConfigurations.parsley.config.system.build.toplevel
```

### Package Not Found

```bash
# Search for packages
nix search nixpkgs package-name

# Check if package is available in current nixpkgs
nix eval nixpkgs#package-name.meta.description
```

### Rollback

```bash
# List system generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback system
sudo nix-env --rollback --profile /nix/var/nix/profiles/system

# List home generations
home-manager generations

# Rollback home (rebuild with previous generation)
home-manager switch --flake ~/nix-config#jrudnik@parsley --rollback
```

### Permission Issues

```bash
# Fix ownership
sudo chown -R jrudnik:staff ~/nix-config

# Ensure proper nix daemon
sudo launchctl stop org.nixos.nix-daemon
sudo launchctl start org.nixos.nix-daemon
```

## Maintenance

### Regular Updates

```bash
# Weekly maintenance routine
cd ~/nix-config

# Update and apply
./scripts/build.sh update
./scripts/build.sh switch

# Clean up old generations
./scripts/build.sh clean
```

### Git Workflow

```bash
# Daily workflow
git add .
git commit -m "feat: add nodejs development environment"
git push

# Feature development
git checkout -b feature/new-setup
# make changes
git push -u origin feature/new-setup
```

### Health Checks

```bash
# Check store size
du -sh /nix/store

# Verify store integrity
nix-store --verify --check-contents

# Check for broken symlinks
find /nix/store -type l -exec test ! -e {} \; -print
```

## Environment Variables

### Useful Variables

```bash
# Current generation info
echo $NIX_PROFILE
echo $HOME/.nix-profile

# Nix store paths
echo $NIX_STORE

# Check current generation
nix-env --list-generations --profile $NIX_PROFILE
```

### Shell Integration

```bash
# Source nix environment (if needed)
source ~/.nix-profile/etc/profile.d/nix.sh

# Home Manager session variables
source ~/.nix-profile/etc/profile.d/hm-session-vars.sh
```

## Package Searching

### Find Packages

```bash
# Search nixpkgs
nix search nixpkgs nodejs
nix search nixpkgs python3

# Show package info
nix eval nixpkgs#nodejs.meta.description
nix eval nixpkgs#python3.version
```

### Check Package Versions

```bash
# Current nixpkgs version
nix eval nixpkgs#lib.version

# Package versions
nix eval nixpkgs#nodejs.version
nix eval nixpkgs#go.version
nix eval nixpkgs#rustc.version
```

## Testing Changes

### Safe Testing Workflow

```bash
# 1. Make changes to configuration
$EDITOR ~/nix-config/home/jrudnik/home.nix

# 2. Check syntax
nix flake check ~/nix-config

# 3. Test build
./scripts/build.sh build

# 4. Apply if build succeeds
./scripts/build.sh switch

# 5. Verify changes
which new-package
alias new-alias
```

### Incremental Testing

```bash
# Test only system config
nix build ~/nix-config#darwinConfigurations.parsley.system

# Test only home config
nix build ~/nix-config#homeConfigurations."jrudnik@parsley".activationPackage

# Test specific parts
darwin-rebuild build --flake ~/nix-config#parsley
home-manager build --flake ~/nix-config#jrudnik@parsley
```

This quick reference covers the most common operations you'll need for daily use of your Nix configuration.