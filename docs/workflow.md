# Workflow Guide

Complete reference for working with this Nix configuration effectively.

## Daily Workflow

### Making Changes

1. **Edit configuration files**
   ```bash
   cd ~/nix-config
   
   # Edit system settings
   $EDITOR hosts/parsley/configuration.nix
   
   # Edit user settings
   $EDITOR home/jrudnik/home.nix
   ```

2. **Test changes**
   ```bash
   # Quick syntax check
   nix flake check
   
   # Test build without applying
   ./scripts/build.sh build
   ```

3. **Apply changes**
   ```bash
   # Apply system and home configuration
   ./scripts/build.sh switch
   ```

4. **Verify changes**
   ```bash
   # Check if new packages are available
   which new-package
   
   # Test new aliases or settings
   alias new-alias
   ```

### Using Build Scripts

The `scripts/build.sh` script provides convenient commands:

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
```

### Shell Aliases

After applying your configuration, these aliases are available:

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

## Development Patterns

### Adding New Packages

**For development tools (user-specific):**
```nix
# Edit home/jrudnik/home.nix
home.packages = with pkgs; [
  # Existing packages
  git curl wget micro tree jq
  rustc cargo go python3
  
  # Add new packages
  nodejs_20    # Specific version
  yarn
  docker
  kubectl
  terraform
];
```

**For system-wide tools:**
```nix
# Edit hosts/parsley/configuration.nix
environment.systemPackages = with pkgs; [
  git
  curl
  wget
  # Add minimal system tools only
];
```

### Configuring Programs

**Shell configuration:**
```nix
# In home/jrudnik/home.nix
programs.zsh = {
  enable = true;
  enableCompletion = true;
  
  shellAliases = {
    # Add custom aliases
    deploy = "cd ~/projects && ./deploy.sh";
    logs = "sudo tail -f /var/log/system.log";
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
  userName = "John Rudnik";
  userEmail = "john.rudnik@gmail.com";
  
  extraConfig = {
    init.defaultBranch = "main";
    pull.rebase = false;
    push.default = "simple";
    
    # Add more git settings
    core.editor = "micro";
    diff.tool = "vimdiff";
  };
};
```

### System Settings

**macOS defaults:**
```nix
# In hosts/parsley/configuration.nix
system.defaults = {
  dock = {
    autohide = true;
    orientation = "bottom";
    show-recents = false;
    # Minimize windows into application icon
    minimize-to-application = true;
  };
  
  finder = {
    AppleShowAllExtensions = true;
    ShowPathbar = true;
    ShowStatusBar = true;
    # Show full path in title
    _FXShowPosixPathInTitle = true;
  };
  
  NSGlobalDomain = {
    # Disable automatic capitalization and corrections
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
    
    # Expand save dialogs by default
    NSNavPanelExpandedStateForSaveMode = true;
  };
};
```

## Version Management

### Flake Updates

```bash
# Update all inputs
./scripts/build.sh update

# Update specific input
nix flake lock --update-input nixpkgs

# Update and apply
./scripts/build.sh update && ./scripts/build.sh switch
```

### Rollback Strategy

**System rollbacks:**
```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nix-env --rollback --profile /nix/var/nix/profiles/system

# Rollback to specific generation
sudo nix-env --switch-generation 42 --profile /nix/var/nix/profiles/system
```

**Home Manager rollbacks:**
```bash
# List home generations
home-manager generations

# Rollback home configuration
home-manager switch --flake .#jrudnik@parsley --rollback
```

### Generation Management

```bash
# Clean up old generations (older than 30 days)
./scripts/build.sh clean

# Manual cleanup
sudo nix-collect-garbage --delete-older-than 30d
nix-collect-garbage --delete-older-than 30d
```

## Development Workflow

### Testing Changes

1. **Incremental testing:**
   ```bash
   # Test specific parts
   nix build .#darwinConfigurations.parsley.system
   nix build '.#homeConfigurations."jrudnik@parsley".activationPackage'
   ```

2. **Dry run:**
   ```bash
   # See what would change
   darwin-rebuild build --flake .#parsley --show-trace
   ```

3. **Safe switching:**
   ```bash
   # Build first, then switch
   ./scripts/build.sh build && ./scripts/build.sh switch
   ```

### Debugging Issues

**Build failures:**
```bash
# Detailed error output
nix flake check --show-trace
darwin-rebuild build --flake .#parsley --show-trace

# Check specific configuration
nix eval .#darwinConfigurations.parsley.config.system.build.toplevel
```

**Runtime issues:**
```bash
# Check if services are running
sudo launchctl list | grep nix

# Restart nix daemon
sudo launchctl stop org.nixos.nix-daemon
sudo launchctl start org.nixos.nix-daemon

# Check system logs
log stream --predicate 'subsystem == "com.apple.system"'
```

### Performance Tips

1. **Use binary caches:**
   ```nix
   # In hosts/parsley/configuration.nix
   nix.settings = {
     substituters = [
       "https://cache.nixos.org/"
       "https://nix-community.cachix.org"
     ];
   };
   ```

2. **Optimize builds:**
   ```bash
   # Enable store optimization
   nix.optimise.automatic = true;
   
   # Parallel builds
   nix.settings.max-jobs = "auto";
   ```

3. **Faster rebuilds:**
   ```bash
   # Only rebuild home config
   home-manager switch --flake .#jrudnik@parsley
   
   # Skip building if no changes
   darwin-rebuild switch --flake .#parsley --fast
   ```

## Collaboration Workflow

### Git Workflow

```bash
# Standard workflow
cd ~/nix-config
git add .
git commit -m "feat: add nodejs development environment"
git push

# Feature branches for major changes
git checkout -b feature/new-development-setup
# Make changes
git push -u origin feature/new-development-setup
# Create PR on GitHub
```

### Configuration Sharing

```bash
# Share current configuration
git clone https://github.com/jerudnik/nix-config.git
cd nix-config
./scripts/build.sh switch

# Customize for different user/host
cp -r home/jrudnik home/newuser
cp -r hosts/parsley hosts/newhost
# Edit configurations as needed
```

### Documentation Updates

When adding new features:

1. Update relevant documentation in `docs/`
2. Add examples to configuration files
3. Update the main `README.md` if needed
4. Document any breaking changes

## Best Practices

1. **Always test before applying:**
   ```bash
   ./scripts/build.sh build && ./scripts/build.sh switch
   ```

2. **Keep configurations minimal:**
   - System config: Essential system settings only
   - Home config: User-specific tools and preferences

3. **Use version control effectively:**
   - Commit working configurations
   - Use descriptive commit messages
   - Tag stable releases

4. **Regular maintenance:**
   ```bash
   # Weekly update and cleanup
   ./scripts/build.sh update
   ./scripts/build.sh switch
   ./scripts/build.sh clean
   ```

5. **Monitor system health:**
   ```bash
   # Check Nix store size
   du -sh /nix/store
   
   # Check for broken symlinks
   nix-store --verify --check-contents
   ```