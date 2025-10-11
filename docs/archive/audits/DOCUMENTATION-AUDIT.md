# Documentation Audit Report
**Date:** 2025-01-10  
**Audit Scope:** Complete repository documentation vs. current configuration state

## 🔴 **Critical Discrepancies Found**

### **1. README.md - Module Count Incorrect**

**Current State:**
- **Darwin modules:** 7 (not 9)
- **Home modules:** 9 (not 7)

**README Claims:**
- Line 21: "darwin/ # Reusable Darwin system modules (9 modules)"
- Line 31: "home/ # Reusable home-manager modules (7 modules)"
- Line 87: "15 reusable modules" (actually 16)
- Line 97: "16 reusable modules (9 darwin + 7 home)" 

**Actual Modules:**
- **Darwin (7):** core, security, nix-settings, system-settings, homebrew, theming, fonts
- **Home (9):** shell, development, git, cli-tools, window-manager, security, mcp, starship, ai

**Fix Required:** Update all module counts throughout README.md

---

### **2. README.md - Deprecated Modules Referenced**

**Lines 26-28 show modules that don't exist:**
```
├── system-defaults/ # macOS system preferences  ← WRONG: renamed to system-settings
├── keyboard/        # Keyboard & input settings ← WRONG: merged into system-settings
├── window-manager/  # AeroSpace tiling window manager ← WRONG: removed (moved to home)
```

**Lines 36-40 show home modules that don't exist:**
```
├── raycast/         # Raycast launcher configuration ← WRONG: doesn't exist
└── macos/           # Native macOS UI integration ← WRONG: doesn't exist  
    ├── launchservices/ # Default applications ← WRONG: doesn't exist
    └── keybindings/    # Keyboard & hotkeys ← WRONG: doesn't exist
```

**Fix Required:** Update structure to match actual modules

---

### **3. README.md - Example Configuration Outdated**

**Lines 140-168 show OLD configuration:**
```nix
system-defaults = {  ← WRONG: should be system-settings
  enable = true;
  dock = { ... };  ← WRONG: should be desktopAndDock.dock
};

keyboard.enable = true;  ← WRONG: module removed
window-manager.enable = true;  ← WRONG: module removed
```

**Fix Required:** Update example to current pane-based system-settings structure

---

### **4. README.md - Home Configuration Example References Non-Existent Modules**

**Lines 197-211 reference modules that don't exist:**
```nix
macos.launchservices = { ... };  ← WRONG: doesn't exist
macos.keybindings = { ... };     ← WRONG: doesn't exist
```

**Fix Required:** Update to show actual home modules (starship, mcp, security, etc.)

---

### **5. WARP.md - Does Not Document system-settings Organization**

**Line 25 reference:**
```
- ✅ **ONLY** use `targets.darwin.defaults` for system preferences
```

**Missing:**
- No mention of system-settings pane-based organization
- No mention that system-settings is the ONLY module that should write to NSGlobalDomain
- No documentation of the keyboard module merge

**Fix Required:** Add section documenting system-settings as single source of truth for NSGlobalDomain

---

### **6. architecture.md - Module Counts Wrong**

**Module counts don't reflect reality** - same issues as README.md

**Fix Required:** Update architecture.md to match current 7 darwin + 9 home structure

---

## ⚠️ **Moderate Discrepancies**

### **7. Root Directory Cleanup Needed**

**Obsolete files in root:**
- `PHASE2-AUDIT.md` - Audit complete, should be archived
- `PHASE2-EXECUTION-PLAN.md` - Plan complete, should be archived

**Action:** Move to `docs/archive/phase2/`

---

### **8. docs/ Directory Has Outdated System-Settings Files**

**Obsolete system-settings documentation:**
- `docs/SYSTEM-SETTINGS-FIX.md` - Issue resolved
- `docs/system-settings-permanent-fix.md` - Redundant with darwin-modules-conflicts.md
- `docs/preference-domain-audit.md` - Superseded by darwin-modules-conflicts.md

**Action:** Archive or remove these files

---

### **9. docs/raycast-removal.md Exists But Module Doesn't**

**File:** `docs/raycast-removal.md`

**Issue:** Discusses removing Raycast, but:
- README still mentions Raycast integration
- No actual Raycast module exists in codebase

**Action:** Either remove doc or clarify that Raycast was never fully integrated

---

## ✅ **Documentation That Is Correct**

### **Accurate Documentation:**
- ✅ `docs/darwin-modules-conflicts.md` - Up to date with merge resolution
- ✅ `docs/workflow.md` - Build processes accurate
- ✅ `docs/cleanup.md` - Cleanup scripts documented correctly
- ✅ `docs/exceptions.md` - Nixpkgs exceptions properly documented
- ✅ `docs/ai-tools.md` - AI tools configuration accurate
- ✅ `docs/mcp.md` - MCP server configuration accurate

---

## 📋 **Recommended Actions**

### **Priority 1 - Critical Fixes:**
1. ✅ Update README.md module structure and counts
2. ✅ Update README.md example configurations
3. ✅ Update WARP.md with system-settings rules
4. ✅ Update architecture.md module counts

### **Priority 2 - Cleanup:**
5. ✅ Archive PHASE2-*.md files
6. ✅ Archive obsolete system-settings docs
7. ✅ Review and clean up docs/ directory

### **Priority 3 - Enhancement:**
8. ✅ Create quick reference for new pane-based system-settings
9. ✅ Update getting-started.md if needed
10. ✅ Add migration guide for old configurations

---

## 📊 **Summary Statistics**

| Category | Count | Status |
|----------|-------|--------|
| **Total Docs** | 45+ | Audited |
| **Critical Issues** | 6 | Needs fixing |
| **Moderate Issues** | 3 | Should fix |
| **Correct Docs** | 6+ | No action |
| **Obsolete Files** | 5+ | Archive |

---

## 🎯 **Next Steps**

1. Create branch for documentation updates
2. Fix critical discrepancies in order
3. Archive obsolete documentation
4. Test that examples in documentation actually work
5. Commit and merge documentation updates

---

## 📝 **Audit Notes**

- This audit focused on structural and factual accuracy
- Did not audit prose/grammar/style
- Did not audit code examples for syntax (only for accuracy)
- Recommended to re-audit after Phase 4 if more refactoring occurs
