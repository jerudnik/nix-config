# Nix Configuration Architecture

A clean, modular, multi-system approach to managing system configurations using Nix, nix-darwin, and Home Manager.

## Overview

This configuration system manages multiple machines (macOS and NixOS) from a single, coherent codebase. It uses established patterns—nix-darwin for macOS, NixOS for Linux, and Home Manager for user dotfiles—while emphasizing modularity, maintainability, and a clear separation of concerns.

### Core Principles

1.  **Multi-System Support**: Natively manage macOS and NixOS hosts.
2.  **Separation of Concerns**: Strict boundaries between system (`hosts`), user (`home`), and shared logic (`modules`).
3.  **Modularity**: Reusable modules for shared functionality across platforms.
4.  **Declarative Hosts**: Host configurations are simple, declarative entry points.
5.  **Maintainability**: The structure is designed to be easy to understand, extend, and debug.

## Directory Structure

```
nix-config/
├── flake.nix             # ❄️ Main entry point: Defines all system and user configurations.
│
├── hosts/                  # 🖥️ Machine-specific SYSTEM configurations.
│   ├── parsley/            #    (macOS host)
│   │   └── configuration.nix
│   └── thinkpad/           #    (NixOS host)
│       └── configuration.nix
│
├── home/                   # 👤 User-specific HOME configurations.
│   └── jrudnik/
│       └── home.nix
│
├── modules/                # 🧩 Reusable configuration modules.
│   ├── common/             #    Shared across ALL systems (Darwin & NixOS).
│   ├── darwin/             #    🍏 macOS-specific SYSTEM modules.
│   ├── home/               #    👤 User-specific (Home Manager) modules.
│   └── nixos/              #    🐧 Linux-specific SYSTEM modules.
│
├── overlays/               # 🎨 Custom package modifications.
└── scripts/                # 🛠️ Utility scripts (build, switch, etc.).
```

## Configuration Layers

This system is organized into four distinct layers:

### 1. Flake Layer (`flake.nix`)

-   **Defines Inputs**: `nixpkgs`, `nix-darwin`, `home-manager`, etc.
-   **Constructs Outputs**: Builds `darwinConfigurations` and `nixosConfigurations` using helper functions (`mkDarwin`, `mkNixos`).
-   **Exports Modules**: Makes the module sets (`common`, `darwin`, `home`, `nixos`) available to all configurations.
-   **Injects Dependencies**: Passes `specialArgs` (like `inputs`, `outputs`, and `host`) to all modules.

### 2. Host Layer (`hosts/<hostname>/configuration.nix`)

-   **System Entry Point**: The primary configuration for a single machine.
-   **Imports Modules**: Imports system-level modules from `modules/darwin` or `modules/nixos`.
-   **Sets Host-Specifics**: Defines hostname, system packages, hardware settings, and system services.
-   **Integrates Home Manager**: Specifies which user configuration from `home/` to apply to this host.

### 3. User Layer (`home/<username>/home.nix`)

-   **User Entry Point**: The primary configuration for a single user, portable across hosts.
-   **Imports Modules**: Imports user-level modules from `modules/home`.
-   **Conditional Logic**: Uses the `host` argument to apply host-specific settings (e.g., different window managers for macOS vs. Linux).
-   **Defines User Environment**: Manages dotfiles, user-level packages, and application settings.

### 4. Module Layer (`modules/`)

-   **Reusable Logic**: Contains the bulk of the configuration logic, organized by scope.
-   **`modules/common/`**: Shared system-level settings for both macOS and NixOS (e.g., Nix configuration, user accounts, timezone). Platform-specific options MUST be conditional (`lib.mkIf`).
-   **`modules/darwin/`**: macOS-specific system modules (e.g., Homebrew, system settings, security).
-   **`modules/nixos/`**: NixOS-specific system modules (e.g., bootloader, kernel, filesystem).
-   **`modules/home/`**: User-level modules, shared across all hosts (e.g., shell, editors, git).

## Data Flow

```
flake.nix
    │
    ├─► `mkDarwin` helper for macOS hosts
    │   │
    │   └─► hosts/parsley/configuration.nix
    │       │
    │       ├─► imports modules/common/*
    │       ├─► imports modules/darwin/*
    │       └─► integrates home/jrudnik/home.nix
    │
    └─► `mkNixos` helper for NixOS hosts
        │
        └─► hosts/thinkpad/configuration.nix
            │
            ├─► imports modules/common/*
            ├─► imports modules/nixos/*
            └─► integrates home/jrudnik/home.nix
```
The `home/jrudnik/home.nix` file receives the `host` object, allowing it to adapt its configuration based on the machine it's being deployed to.

## Package Management Strategy

The strategy remains consistent: the **system** installs all tools, and **Home Manager** configures them.

-   **System Packages**: Defined in `hosts/<hostname>/configuration.nix` via `environment.systemPackages`. This includes all GUI apps, CLI tools, and TUI apps.
-   **User Configuration**: Handled in `home/jrudnik/home.nix` and `modules/home/` via `programs.*` options. This manages dotfiles and user-specific settings.

This ensures a clean separation between tool availability (system) and user preferences (home).

## Configuration Patterns

### Host Configuration Example

A host configuration is lean and declarative.

```nix
# hosts/parsley/configuration.nix (macOS)
{ ... }: {
  # Set host-specifics
  networking.hostName = "parsley";

  # Import system modules
  imports = [
    outputs.darwinModules.core
    outputs.darwinModules.security
    outputs.darwinModules.system-settings
  ];

  # Install system-wide packages for this host
  environment.systemPackages = with pkgs; [ zed-editor warp-terminal ];
}
```

### User Configuration Example

The user configuration is portable and conditional.

```nix
# home/jrudnik/home.nix
{ pkgs, lib, host, ... }: {
  # Set user-specifics
  home.username = "jrudnik";

  # Conditional settings based on the host OS
  home.window-manager = lib.mkIf (pkgs.stdenv.isDarwin) {
    enable = true; # Enables yabai/skhd via a module
  };

  programs.foot = lib.mkIf (pkgs.stdenv.isLinux) {
    enable = true; # Use foot terminal on Linux
  };
}
```

## Build Process

The build process is now host-specific.

```bash
# Test build for a specific host
./scripts/build.sh parsley
./scripts/build.sh thinkpad

# Apply changes for a specific host
sudo ./scripts/switch.sh parsley
sudo ./scripts/switch.sh thinkpad
```

## Best Practices

-   **Host-Specific First**: If a setting applies to only one machine, put it in `hosts/<hostname>/configuration.nix`.
-   **Promote to Common**: If you find yourself duplicating a system setting across multiple hosts, move it to a `modules/common/` module with appropriate conditionals.
-   **Keep User Config Portable**: `home/jrudnik/home.nix` should be able to be deployed on any host. Use conditionals for OS or hostname differences.

## Next Steps

-   **[Module Options Reference](module-options.md)** - Complete documentation of all module options.
-   **[Workflow Guide](../guides/workflow.md)** - Development and build processes for the multi-system setup.
-   **[Modular Architecture Guide](../guides/modular-architecture.md)** - Advanced module patterns.
-   **[Getting Started](../getting-started.md)** - Quick start guide for new users and hosts.
