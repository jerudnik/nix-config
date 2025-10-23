# WARP.md - MANDATORY CONFIGURATION RULES

**⚠️ CRITICAL: This file contains MANDATORY RULES that must be followed without exception when working with this nix-config repository. These are not suggestions or guidelines - they are hard requirements.**

**🚫 VIOLATIONS WILL BE REJECTED 🚫**

---

## QUICK REFERENCE FOR AGENTS

**Before making any changes, answer these questions:**

### 1. **What am I modifying?**
- **Host-specific system settings?** → `hosts/<hostname>/configuration.nix`
- **Shared system settings?** → `modules/common/system.nix`
- **User dotfiles/CLI tools?** → `home/jrudnik/home.nix` and `modules/home/`
- **macOS-specific system modules?** → `modules/darwin/`
- **NixOS-specific system modules?** → `modules/nixos/`

### 2. **Does a module already exist?**
- ✅ Check: `programs.<name>` in nixpkgs/home-manager first.
- ✅ Check: `modules/common/`, `modules/darwin/`, `modules/nixos/`, and `modules/home/`.
- ✅ If it exists, use it. Don't create a wrapper.

### 3. **Is the module registered?**
- ✅ Check: `modules/*/default.nix` to ensure the module is exported.

### 4. **Where do NSGlobalDomain writes go?**
- **ONLY** in `modules/darwin/system-settings/` (LAW 5, RULE 5.4).

### 5. **Build workflow:**
- **ALWAYS** use `./scripts/build.sh <hostname>` to test your changes for a specific host.

---

## DECISION FLOWCHART: WHERE DOES THIS GO?

```
┌─────────────────────────────┐
│ What are you configuring?   │
└─────────────┬───────────────┘
              │
              ├─→ Host-specific system settings (packages, services)?
              │   └─→ hosts/<hostname>/configuration.nix
              │
              ├─→ Shared settings for ALL systems (Nix config, user)?
              │   └─→ modules/common/
              │
              ├─→ macOS-specific system logic (defaults, services)?
              │   └─→ modules/darwin/
              │
              ├─→ NixOS-specific system logic (bootloader, kernel)?
              │   └─→ modules/nixos/
              │
              ├─→ User-specific dotfiles or CLI tools?
              │   ├─→ Shared across all hosts? → `modules/home/`
              │   └─→ Conditional per host? → `home/jrudnik/home.nix`
              │
              └─→ NSGlobalDomain write?
                  └─→ STOP! Only allowed in `modules/darwin/system-settings/`
```

---

# CONFIGURATION PURITY LAWS

## LAW 1: DECLARATIVE ONLY - NO IMPERATIVE ACTIONS

**RULE 1.1: No Manual System Modifications**
- ✅ **ONLY** modify files within the nix-config repository.

**RULE 1.2: Build Script Adherence**
- ✅ **ALWAYS** use `./scripts/build.sh <hostname>` to test.
- ✅ **ALWAYS** use `sudo ./scripts/switch.sh <hostname>` to apply.

## LAW 2: ARCHITECTURAL BOUNDARIES ARE SACRED

**RULE 2.1: Module Responsibility Separation**
- ✅ **`hosts/`**: Contains machine-specific configurations. Imports modules.
- ✅ **`home/`**: Contains user-specific configurations. Imports modules.
- ✅ **`modules/common/`**: Contains settings shared by ALL systems (Darwin and NixOS).
- ✅ **`modules/darwin/`**: Contains macOS-specific system modules.
- ✅ **`modules/nixos/`**: Contains NixOS-specific system modules.
- ✅ **`modules/home/`**: Contains user-specific (Home Manager) modules, shared across all hosts.

**RULE 2.2: Platform Separation Enforcement**
- ✅ **NEVER** put NixOS-specific options (e.g., `boot.loader`) in `modules/common/` without a `lib.mkIf pkgs.stdenv.isLinux` conditional.
- ✅ **NEVER** put Darwin-specific options in `modules/common/` without a `lib.mkIf pkgs.stdenv.isDarwin` conditional.
- ✅ Platform-specific logic belongs in `modules/darwin/` or `modules/nixos/`.

## LAW 4: BUILD AND TEST DISCIPLINE

**RULE 4.2: Configuration Logic Restrictions**
- ✅ **ALWAYS** keep host configs (`hosts/<hostname>/configuration.nix`) simple and declarative.
- ✅ **ALWAYS** move complex logic into reusable modules (`modules/`).
- ✅ **PRINCIPLE**: Host configs should be data, not code.

## LAW 6: FILE SYSTEM AND DIRECTORY RULES

**RULE 6.3: Module Organization Standards**
```
✅ CORRECT STRUCTURE:
nix-config/
├── hosts/
│   ├── parsley/      # (macOS)
│   └── thinkpad/     # (NixOS)
├── home/
│   └── jrudnik/
└── modules/
    ├── common/       # Shared system settings
    ├── darwin/       # macOS-specific system modules
    ├── home/         # User-specific (HM) modules
    └── nixos/        # NixOS-specific system modules
```

---
*(Existing laws 3, 5, 7, 8, 9, and other rules remain unchanged but are now interpreted within this new multi-system structure.)*
---

## COMMON VIOLATIONS (DO NOT DO THESE)

### ❌ VIOLATION 1: Putting Host-Specific Config in a Common Module

**BAD: Hardcoding a hostname or specific package in a common module**
```nix
# modules/common/system.nix
{
  # ❌ WRONG: This package is only for the media-server
  environment.systemPackages = [ pkgs.jellyfin ];
}
```

**GOOD: Host-specific configuration in the host's file**
```nix
# hosts/media-server/configuration.nix
{
  # ✅ CORRECT: This package is specific to this host
  environment.systemPackages = [ pkgs.jellyfin ];
}
```

### ❌ VIOLATION 2: Mixing System and User Configuration

**BAD: Defining user-level settings in a system configuration**
```nix
# hosts/parsley/configuration.nix
{
  # ❌ WRONG: User-specific git config in a system file
  programs.git = {
    userName = "jrudnik";
    userEmail = "john.rudnik@gmail.com";
  };
}
```

**GOOD: Separating system and user configurations**
```nix
# hosts/parsley/configuration.nix
# System-level concerns only.

# home/jrudnik/home.nix
{
  # ✅ CORRECT: User-specific git config in the user's home file
  programs.git = {
    userName = "jrudnik";
    userEmail = "john.rudnik@gmail.com";
  };
}
```

### ❌ VIOLATION 3: Putting Platform-Specific Logic in Common Modules

**BAD: Unconditional NixOS option in a common module**
```nix
# modules/common/system.nix
{
  # ❌ WRONG: This will break macOS builds
  boot.loader.systemd-boot.enable = true;
}
```

**GOOD: Using conditionals or platform-specific modules**
```nix
# modules/common/system.nix
{
  # ✅ CORRECT: Conditional logic makes it safe for all platforms
  boot.loader.systemd-boot.enable = lib.mkIf pkgs.stdenv.isLinux true;
}

# OR even better, move it to a NixOS-specific module:
# modules/nixos/bootloader.nix
{
  boot.loader.systemd-boot.enable = true;
}
```

---

## MCP TOOL USAGE PATTERNS FOR AGENTS

### Pattern 1: Understanding the Architecture

**Before proposing changes, understand the structure:**

```bash
# Step 1: Read core documentation
MCP filesystem: Read docs/reference/architecture.md

# Step 2: Examine the new structure
MCP filesystem: List hosts/
MCP filesystem: List modules/common/
MCP filesystem: List home/jrudnik/
```

### Pattern 2: Adding a New Host

**When adding a new machine, e.g., 'new-pc':**

```bash
# Step 1: Create the host directory
MCP filesystem: mkdir hosts/new-pc

# Step 2: Create the host's configuration.nix
MCP filesystem: create hosts/new-pc/configuration.nix
# Content should import common modules and set host-specific options,
# like hostname and hardware settings.

# Step 3: Add the new host to flake.nix
MCP filesystem: edit flake.nix
# Add 'new-pc = mkNixos { name = "new-pc"; system = "..."; };'
# to nixosConfigurations.

# Step 4: Test the new host's configuration
Agent thinks: I need to run the build script for the new host.
`./scripts/build.sh new-pc`
```

---

## AGENT PRE-FLIGHT CHECKLIST

Before proposing any changes, verify:

- [ ] **Verified module location**: Confirmed correct placement (`hosts/`, `home/`, or `modules/`).
- [ ] **Platform check**: Ensured no unconditional platform-specific options are in `modules/common/`.
- [ ] **Read documentation**: Reviewed `docs/reference/architecture.md` for the new structure.
- [ ] **Build plan**: Prepared to test with `./scripts/build.sh <hostname>`.
- [ ] **No violations**: Double-checked against Common Violations section.

---

*Last Updated: 2025-10-23*
*Version: 3.0*
*Changelog: Major overhaul for multi-system architecture. Updated directory structure, decision flowcharts, rules, and examples to reflect the new `hosts/`, `home/`, and `modules/common/` directories.*
