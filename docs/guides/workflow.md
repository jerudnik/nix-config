# Workflow Guide

Complete reference for working with this multi-system Nix configuration effectively.

## Daily Workflow

### Making Changes

1.  **Identify the Scope**:
    -   **System-wide change for one host?** → `hosts/<hostname>/configuration.nix`
    -   **Shared system change for all hosts?** → `modules/common/`
    -   **User-specific change for all hosts?** → `home/jrudnik/home.nix` or `modules/home/`

2.  **Edit Configuration Files**:
    ```bash
    cd ~/nix-config

    # Edit system settings for a specific host
    $EDITOR hosts/parsley/configuration.nix

    # Edit user settings (applies to all hosts)
    $EDITOR home/jrudnik/home.nix
    ```

3.  **Test Changes for a Specific Host**:
    You must now specify which host you are building for.

    ```bash
    # Test build for the 'parsley' (macOS) host
    ./scripts/build.sh parsley

    # Test build for the 'thinkpad' (NixOS) host
    ./scripts/build.sh thinkpad
    ```

4.  **Apply Changes to a Specific Host**:
    ```bash
    # Apply system and home configuration to 'parsley'
    sudo ./scripts/switch.sh parsley

    # Apply system and home configuration to 'thinkpad'
    sudo ./scripts/switch.sh thinkpad
    ```

### Using Build Scripts

The build scripts now require a `<hostname>` argument.

```bash
# Test build for a host
./scripts/build.sh <hostname>

# Apply configuration to a host
sudo ./scripts/switch.sh <hostname>

# Check flake syntax (no hostname needed)
nix flake check

# Update all flake inputs (no hostname needed)
nix flake update
```

## Development Patterns

### Adding a New Host

1.  **Create Host Directory**: `mkdir hosts/new-machine`
2.  **Create `configuration.nix`**: Add host-specific settings and import necessary modules.
3.  **Add to `flake.nix`**: Add a new entry in `nixosConfigurations` or `darwinConfigurations`.
4.  **Build**: `./scripts/build.sh new-machine`

### Adding a New Package to a Host

Install packages at the system level in the host's configuration file.

```nix
# Edit hosts/thinkpad/configuration.nix
environment.systemPackages = with pkgs; [
  # Add packages specific to this host
  docker
  kubectl
];
```

Then, configure the package in `home/jrudnik/home.nix`, possibly with a conditional if it's not available on all systems.

```nix
# Edit home/jrudnik/home.nix
programs.docker = lib.mkIf (host.name == "thinkpad") {
  enable = true;
};
```

### Adding a Shared Module

1.  **Create the Module**:
    -   Shared system setting? → `modules/common/`
    -   macOS-specific setting? → `modules/darwin/`
    -   User-specific setting? → `modules/home/`

2.  **Export the Module**: Add it to the `default.nix` in its directory.

3.  **Import and Use**: Import the module in the relevant `configuration.nix` or `home.nix`.

## Version Management

### Flake Updates

```bash
# Update all inputs
nix flake update
```

### Rollback Strategy

Rollbacks are now host-specific.

**System Rollbacks (NixOS)**:
```bash
# On the thinkpad host
sudo nixos-rebuild --rollback
```

**System Rollbacks (macOS)**:
```bash
# On the parsley host
sudo darwin-rebuild --rollback
```

**Home Manager Rollbacks**:
Home Manager rollbacks are tied to the system generation. When you roll back the system, Home Manager rolls back with it.

## Best Practices

1.  **Always Test Before Applying**:
    ```bash
    ./scripts/build.sh <hostname> && sudo ./scripts/switch.sh <hostname>
    ```
2.  **Keep Host Configs Minimal**: Most logic should be in `modules`. Host configs should be for data (packages, settings), not complex code.
3.  **Use Conditionals**: In shared files like `modules/common/user.nix` or `home/jrudnik/home.nix`, use `lib.mkIf pkgs.stdenv.isDarwin` or `lib.mkIf (host.name == "parsley")` to handle differences between machines.
