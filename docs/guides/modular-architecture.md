# Modular Architecture Guide

Understanding the advanced modular design of this multi-system Nix configuration.

## Overview

This configuration uses the **NixOS Module Pattern** to create a highly modular, reusable, and type-safe system that manages both macOS and NixOS hosts from a single codebase.

### Key Benefits

-   **Multi-System by Design**: Natively supports both Darwin and NixOS.
-   **Type Safety**: Rich options with validation and documentation.
-   **Reusability**: `modules/common/` and `modules/home/` provide shared logic to eliminate code duplication.
-   **Maintainability**: Clear separation of concerns between host, user, and module layers.
-   **Scalability**: Easily add new hosts, users, and features.

---

## The Module Pattern

Every module follows this standard pattern:

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.namespace.moduleName; # Shorthand for the module's options
in {
  # The public API for the module
  options.namespace.moduleName = {
    enable = lib.mkEnableOption "Description of the module";
    # ... other options
  };

  # The implementation
  config = lib.mkIf cfg.enable {
    # ... Nix code that applies the configuration
  };
}
```

---

## Module Categories

The `modules/` directory is organized into four distinct categories, each with a clear responsibility:

### 1. `modules/common/` (System-Level, Shared)

-   **Scope**: System-level (nix-darwin or NixOS).
-   **Platform**: Applies to **both** macOS and NixOS.
-   **Purpose**: Contains configuration that is shared across all machines, regardless of OS.
-   **Examples**: Nix daemon settings (`nix.nixPath`), user account creation (`users.users.<name>`), timezone (`time.timeZone`).
-   **CRITICAL RULE**: Any platform-specific option within a common module **must** be wrapped in a conditional (`lib.mkIf pkgs.stdenv.isDarwin` or `lib.mkIf pkgs.stdenv.isLinux`).

### 2. `modules/darwin/` (System-Level, macOS-Specific)

-   **Scope**: System-level (nix-darwin).
-   **Platform**: Applies **only** to macOS.
-   **Purpose**: Contains modules that are specific to the macOS operating system.
-   **Examples**: Homebrew setup (`nix-homebrew`), macOS system settings (`system.defaults`), security settings (`security.pam`).

### 3. `modules/nixos/` (System-Level, NixOS-Specific)

-   **Scope**: System-level (NixOS).
-   **Platform**: Applies **only** to NixOS.
-   **Purpose**: Contains modules that are specific to the NixOS operating system.
-   **Examples**: Bootloader configuration (`boot.loader`), kernel modules (`boot.kernelModules`), filesystems (`fileSystems`).

### 4. `modules/home/` (User-Level, Shared)

-   **Scope**: User-level (Home Manager).
-   **Platform**: Applies to **both** macOS and NixOS.
-   **Purpose**: Contains user-specific dotfiles and application configurations that are shared across all machines for a given user.
-   **Examples**: Shell configuration (`programs.zsh`), editor setup (`programs.neovim`), git settings (`programs.git`).

---

## Extending the Architecture

### Adding a New Host

Adding a new machine to the configuration is simple.

1.  **Create Host Directory**:
    ```bash
    mkdir hosts/new-machine
    ```

2.  **Create `configuration.nix`**:
    This file is the entry point for the new machine. It should import the necessary modules and set host-specific options.

    *Example for a new NixOS host:*
    ```nix
    # hosts/new-machine/configuration.nix
    { pkgs, outputs, ... }: {
      imports = [
        # Import any relevant NixOS modules
        outputs.nixosModules.some-feature
      ];

      # Host-specific settings
      networking.hostName = "new-machine";
      system.stateVersion = "25.05";

      # Install packages specific to this machine
      environment.systemPackages = with pkgs; [ docker ];
    }
    ```

3.  **Add Host to `flake.nix`**:
    In your `flake.nix`, add the new host to the appropriate configuration set.

    ```nix
    # flake.nix
    nixosConfigurations = {
      thinkpad = mkNixos { name = "thinkpad"; system = "x86_64-linux"; };
      # Add the new machine here
      new-machine = mkNixos { name = "new-machine"; system = "x86_64-linux"; };
    };
    ```

4.  **Build to Verify**:
    ```bash
    ./scripts/build.sh new-machine
    ```

### Adding a New Common Module

If you have a system setting that applies to both macOS and NixOS, create a common module.

1.  **Create the Module File**:
    ```nix
    # modules/common/my-shared-feature.nix
    { config, lib, pkgs, ... }: {
      options.common.my-shared-feature = {
        enable = lib.mkEnableOption "My shared feature";
      };

      config = lib.mkIf config.common.my-shared-feature.enable {
        # This setting works on both platforms
        services.tailscale.enable = true;

        # This setting is NixOS-specific, so it must be conditional
        networking.firewall.trustedInterfaces = lib.mkIf pkgs.stdenv.isLinux [ "tailscale0" ];
      };
    }
    ```

2.  **Export the Module**:
    Add the new module to `modules/common/default.nix`.

    ```nix
    # modules/common/default.nix
    {
      system = import ./system.nix;
      user = import ./user.nix;
      my-shared-feature = import ./my-shared-feature.nix; # Add this
    }
    ```

3.  **Use the Module**:
    The module is now available to be imported in any host's `configuration.nix`.

---

## Summary

This modular architecture provides:
-   A clear and scalable structure for managing multiple, diverse systems.
-   Maximum code reuse through `common` and `home` modules.
-   Strict separation between platform-specific and shared logic.
-   A maintainable and idiomatic Nix codebase that follows best practices.
