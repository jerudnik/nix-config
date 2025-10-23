# Getting Started with Nix Configuration

This guide will help you get up and running with this multi-system Nix configuration.

> **📚 Essential Reading First:**
> - **[`architecture.md`](reference/architecture.md)** - Understand the multi-system structure.
> - **[`workflow.md`](guides/workflow.md)** - Learn the daily development workflow.

## Prerequisites

-   A machine running macOS or NixOS.
-   Nix package manager installed with flakes enabled.
-   Git installed and configured.

## Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/jerudnik/nix-config.git ~/nix-config
cd ~/nix-config
```

### 2. Test the Configuration Build for Your Host
You must specify which host configuration you want to build.

```bash
# For the 'parsley' (macOS) host:
./scripts/build.sh parsley

# For the 'thinkpad' (NixOS) host:
./scripts/build.sh thinkpad
```

### 3. Apply the Configuration to Your Host
This command will build the configuration and activate it on your current machine.

```bash
# For the 'parsley' (macOS) host:
sudo ./scripts/switch.sh parsley

# For the 'thinkpad' (NixOS) host:
sudo ./scripts/switch.sh thinkpad
```

### 4. Verify the Installation
After the switch is complete, open a new terminal session to ensure all changes are loaded.

```bash
# Check if a new package is available
which zed-editor

# Check if a shell alias works
lg # Should expand to 'lazygit'

# Check git config
git config --get user.name
```

## Configuration Structure

-   **`flake.nix`**: The main entry point. It defines how to build each host.
-   **`hosts/`**: Contains system-level configurations, one directory per machine.
-   **`home/`**: Contains user-level configurations (dotfiles, etc.).
-   **`modules/`**: Contains reusable code (modules) organized by scope: `common`, `darwin`, `nixos`, and `home`.

## Common Tasks

### Add a Package to a Single Host

1.  Open the host's configuration file (e.g., `hosts/parsley/configuration.nix`).
2.  Add the package to `environment.systemPackages`.

    ```nix
    # hosts/parsley/configuration.nix
    environment.systemPackages = with pkgs; [
      # ... other packages
      htop # Add your new package here
    ];
    ```

3.  Rebuild for that host:
    ```bash
    ./scripts/build.sh parsley && sudo ./scripts/switch.sh parsley
    ```

### Add a Shared Setting for All Systems

1.  Open a common module (e.g., `modules/common/system.nix`).
2.  Add the new configuration. Remember to use conditionals if the option is platform-specific.

    ```nix
    # modules/common/system.nix
    { lib, pkgs, ... }: {
      # Enable tailscale on all systems
      services.tailscale.enable = true;

      # Allow opening firewall ports only on Linux
      networking.firewall.allowedTCPPorts = lib.mkIf pkgs.stdenv.isLinux [ 80 443 ];
    }
    ```

3.  Rebuild any host to apply the change:
    ```bash
    ./scripts/build.sh <hostname>
    ```

### Modify Your User (Home) Configuration

1.  Open `home/jrudnik/home.nix` to modify settings that apply to your user on **all** hosts.
2.  Use conditionals if a setting should only apply to a specific OS or host.

    ```nix
    # home/jrudnik/home.nix
    { lib, pkgs, host, ... }: {
      # This alias is available on all systems
      home.shell.aliases.g = "git";

      # This setting only applies on macOS
      home.sketchybar = lib.mkIf (pkgs.stdenv.isDarwin) {
        enable = true;
      };

      # This setting only applies to the 'thinkpad'
      services.mako = lib.mkIf (host.name == "thinkpad") {
        enable = true; # A notification daemon for Linux
      };
    }
    ```

## Adding a New Machine

Follow the workflow guide for instructions on how to add a new host to this configuration. The process is straightforward and involves creating a new host directory and adding an entry to `flake.nix`.

## Troubleshooting

-   **Build Failure?** Run the build command with `--show-trace` to get a detailed error log (e.g., `./scripts/build.sh parsley --show-trace`).
-   **Changes Not Applied?** Make sure you've opened a new terminal session. Some changes, especially to your shell, require a restart.
-   **Permission Issues?** Remember to use `sudo` with the `switch.sh` script.

## Next Steps

-   **[Workflow Guide](guides/workflow.md)** - Dive deeper into the daily development workflow.
-   **[Modular Architecture Guide](guides/modular-architecture.md)** - Understand how to create and use modules.
-   **[Module Options Reference](reference/module-options.md)** - See all available configuration options.
