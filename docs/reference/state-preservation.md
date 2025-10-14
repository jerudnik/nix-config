# State Preservation Strategy

This document outlines the strategy for preserving application state within the `nix-config` repository, It identifies the key directories that applications use to store their data and clarifies why these directories should remain unmanaged by Nix.

## 1. Core Principle: Separate State from Configuration

As defined in `WARP.md`, this configuration framework strictly separates system and application *configuration* from application *state*.

- **Configuration**: Managed declaratively by Nix. This includes application settings, system preferences, and package installations. It is reproducible and version-controlled.
- **State**: Managed by the applications themselves. This includes login sessions, user data, caches, cookies, and any other runtime-generated data. It is persistent and intentionally *not* managed by Nix.

## 2. Why State is Not Managed by Nix

The primary goal is to ensure that user data and application sessions are **preserved** across system rebuilds. A `darwin-rebuild switch` operation is designed to be non-destructive to the user's home directory. By leaving stateful directories unmanaged, we guarantee:

- **No Data Loss**: Your login sessions, browser history, and application settings will not be wiped out when the system configuration is updated.
- **Application Integrity**: Applications continue to function as expected, managing their own data without interference.
- **Simplicity**: It avoids the complexity and risk of trying to manage dynamic, frequently changing application data within a declarative framework.

## 3. Key Application Data Locations

The following directories in your home folder (`~/`) are the primary locations where your key applications store their state. These directories **must not** be managed by `home-manager`'s `home.file` or other declarative mechanisms.

### Browser Data

- **Zen Browser**: `~/Library/Application Support/Zen/`
  - **Contents**: User profiles, browsing history, cookies, and login sessions.

### Terminal and Developer Tools

- **Warp**: `~/Library/Application Support/dev.warp.Warp-Stable/`
  - **Contents**: Themes, custom configurations, and session state.
- **Claude**: `~/Library/Application Support/Claude/`
  - **Contents**: Login sessions and application preferences.

### Email Client

- **Thunderbird**: `~/Library/Application Support/Thunderbird/`
  - **Contents**: Email profiles, locally stored mail, account settings, and login tokens.

## 4. Summary

| Application   | Data Location                                    | Managed by Nix? |
|---------------|--------------------------------------------------|-----------------|
| Zen Browser   | `~/Library/Application Support/Zen/`             | **No**          |
| Warp          | `~/Library/Application Support/dev.warp.Warp-Stable/` | **No**          |
| Thunderbird   | `~/Library/Application Support/Thunderbird/`     | **No**          |
| Claude        | `~/Library/Application Support/Claude/`          | **No**          |

By adhering to this separation of concerns, the `nix-config` provides a robust, reproducible system configuration without compromising the persistence of your personal data and application state.