# John's Nix Configuration

> **📚 Documentation:** See [`docs/`](docs/) for comprehensive guides

A clean, simple Nix configuration for macOS using nix-darwin and Home Manager, without external frameworks or abstractions.

**Migration Note:** This configuration was migrated from a previous Nilla-based setup to eliminate framework dependencies and improve maintainability.

## Structure

```
~/nix-config/
├── flake.nix                 # Main flake configuration
├── home/
│   └── jrudnik/
│       └── home.nix          # Home-manager config for user jrudnik
├── hosts/
│   └── parsley/
│       └── configuration.nix # Darwin system config for host parsley
├── lib/                      # Shared library functions
├── modules/
│   ├── darwin/              # Reusable Darwin system modules
│   ├── home/                # Reusable home-manager modules
│   └── nixos/               # Reusable NixOS system modules (future)
├── overlays/                # Custom package overlays
├── scripts/                 # Helper scripts
│   └── build.sh            # Build/switch/check script
└── secrets/                 # Encrypted secrets (age/gpg)
```

## Quick Start

1. **Build configuration (test):**
   ```bash
   ./scripts/build.sh build
   ```

2. **Apply configuration:**
   ```bash
   ./scripts/build.sh switch
   ```

3. **Check configuration:**
   ```bash
   ./scripts/build.sh check
   ```

4. **Update flake inputs:**
   ```bash
   ./scripts/build.sh update
   ```

5. **Clean old generations:**
   ```bash
   ./scripts/build.sh clean
   ```

## Manual Commands

- **Build:** `darwin-rebuild build --flake ~/nix-config`
- **Switch:** `darwin-rebuild switch --flake ~/nix-config`
- **Home Manager (standalone):** `home-manager switch --flake ~/nix-config#jrudnik@parsley`

## Migration from dot-nilla

This configuration is migrated from a previous Nilla-based setup to be simpler and more maintainable:

- ✅ Direct nix-darwin and home-manager usage
- ✅ No external framework dependencies
- ✅ Clean, understandable structure
- ✅ Standard Nix community patterns
- ✅ Easier debugging and maintenance

## Features

### System (nix-darwin)
- Touch ID for sudo
- Sensible macOS defaults (Dock, Finder, etc.)
- Nix binary cache configuration
- Automatic garbage collection

### Home Manager
- Zsh with oh-my-zsh
- Git configuration
- Direnv integration
- Essential development tools (Rust, Go, Python)
- Micro text editor

## Adding Configuration

### New Darwin Module
1. Create `modules/darwin/my-module/default.nix`
2. Add to `modules/darwin/default.nix`
3. Import in `hosts/parsley/configuration.nix`

### New Home Manager Module
1. Create `modules/home/my-module/default.nix` 
2. Add to `modules/home/default.nix`
3. Import in `home/jrudnik/home.nix`

### New Host
1. Create `hosts/new-host/configuration.nix`
2. Add to `flake.nix` in `darwinConfigurations`

### New User
1. Create `home/new-user/home.nix`
2. Add to `flake.nix` in `homeConfigurations`