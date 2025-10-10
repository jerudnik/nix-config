# Phase 2: Aggregator/Implementor Pattern - Comprehensive Audit

## Audit Criteria & Scoring Matrix

**Scoring System** (Max 8 points):
- Function name != Tool name: +2 points
- Contains tool-specific options: +2 points  
- Tool could be swapped: +2 points
- Complex implementation: +1 point
- High user value: +1 point

**Priority Levels:**
- **HIGH**: 6-8 points - Strong candidates
- **MEDIUM**: 4-5 points - Worth considering
- **LOW**: 2-3 points - Minimal benefit
- **NONE**: 0-1 points - Not applicable

---

## Darwin Modules Audit

### 1. theming/default.nix
- **Function**: System-wide theming
- **Tool**: Stylix
- **Named for**: Function ✓
- **Separation**: None - monolithic

**Analysis:**
- Function name (theming) != Tool name (Stylix) ✓ +2
- Contains Stylix-specific options (base16Scheme, etc.) ✓ +2
- Could swap to other themers (Catppuccin, base16, etc.) ✓ +2
- Complex implementation (214 lines, font config, auto-switching) ✓ +1
- High user value (affects all apps) ✓ +1

**Score: 8/8 - HIGH PRIORITY** 🔥

**Refactoring Benefits:**
- Easy to swap Stylix for other tools
- Clear separation of theming API vs implementation
- Can add multiple implementors (stylix, catppuccin, etc.)
- User config stays unchanged when swapping tools

---

### 2. fonts/default.nix
- **Function**: Font management
- **Tool**: Nix fonts + nerd-fonts packages
- **Named for**: Function ✓
- **Separation**: None

**Analysis:**
- Function name (fonts) != specific tool ✓ +2
- Contains implementation details (nerd-fonts mapping) ✓ +1
- Could potentially swap font sources (but unlikely) ✗ +0
- Moderate complexity (126 lines) +0.5
- Medium user value +0.5

**Score: 4/8 - MEDIUM PRIORITY**

**Notes:**
- Currently couples font selection with nerd-fonts package structure
- Could benefit from abstracting font families vs packages
- Lower priority - working well as-is

---

### 3. window-manager/default.nix  
- **Function**: Window manager support
- **Tool**: AeroSpace (deprecated, moved to home-manager)
- **Named for**: Function ✓
- **Separation**: N/A - deprecated

**Analysis:**
- Module is DEPRECATED
- Only provides shell aliases
- Actual implementation in home-manager

**Score: 0/8 - NONE (DEPRECATED)**

**Action**: Consider removing this module entirely

---

### 4. homebrew/default.nix
- **Function**: Homebrew package management
- **Tool**: nix-homebrew
- **Named for**: Tool ✗
- **Separation**: None, but appropriate

**Analysis:**
- Named for the tool (homebrew) ✗ +0
- Tool-agnostic wrapper around homebrew ✗ +0
- Cannot swap (it IS homebrew) ✗ +0
- Simple wrapper (79 lines) +0
- Medium value +0.5

**Score: 0.5/8 - NONE**

**Notes:**
- This is a tool-specific wrapper by design
- Aggregator/implementor pattern doesn't apply
- Module name matches function correctly

---

### 5. core/default.nix
- **Function**: Essential system packages
- **Tool**: None (package aggregation)
- **Named for**: Function ✓
- **Separation**: N/A

**Analysis:**
- Pure configuration, no specific tool
- Just installs git, curl, wget
- No implementation to separate

**Score: 0/8 - NONE**

---

### 6. keyboard/default.nix
- **Function**: Keyboard configuration
- **Tool**: macOS system keyboard API
- **Named for**: Function ✓
- **Separation**: N/A

**Analysis:**
- Direct macOS API wrapper
- No alternative tools available
- Simple configuration (49 lines)

**Score: 0/8 - NONE**

---

### 7. nix-settings/default.nix
- **Function**: Nix daemon configuration
- **Tool**: Nix (the tool itself)
- **Named for**: Function ✓
- **Separation**: N/A

**Analysis:**
- Configures Nix itself
- No alternative implementation possible
- Pure configuration wrapper

**Score: 0/8 - NONE**

---

### 8. security/default.nix
- **Function**: Security & authentication
- **Tool**: macOS PAM/Touch ID
- **Named for**: Function ✓
- **Separation**: N/A

**Analysis:**
- Direct macOS API wrapper
- No alternative implementations
- Simple configuration (43 lines)

**Score: 0/8 - NONE**

---

### 9. system-defaults/default.nix
- **Function**: macOS system defaults
- **Tool**: macOS defaults system
- **Named for**: Function ✓
- **Separation**: N/A

**Analysis:**
- Direct macOS API wrapper
- No alternative tools available
- Large but simple configuration

**Score: 0/8 - NONE**

---

## Home Modules Audit

### 10. window-manager/default.nix (home)
- **Function**: Window management
- **Tool**: AeroSpace
- **Named for**: Function ✓
- **Separation**: None - monolithic

**Analysis:**
- Function name (window-manager) != Tool name (AeroSpace) ✓ +2
- Contains AeroSpace-specific config (TOML format, bindings) ✓ +2
- Could swap to other window managers (yabai, Amethyst, etc.) ✓ +2
- Complex implementation (173 lines, detailed config) ✓ +1
- High user value (productivity) ✓ +1

**Score: 8/8 - HIGH PRIORITY** 🔥

**Refactoring Benefits:**
- Easy to swap AeroSpace for yabai, Amethyst, etc.
- Clear window-manager API vs tool-specific bindings
- Can support multiple window managers simultaneously
- Better testability

---

### 11. starship/default.nix
- **Function**: Shell prompt
- **Tool**: Starship
- **Named for**: Tool ✗
- **Separation**: Partial (theme modules)

**Analysis:**
- Named for the tool (starship) ✗ +0
- Already has modular structure (themes, modules) ✓ +1
- Could potentially swap to other prompts (powerlevel10k, oh-my-posh) +1
- Complex implementation (modular design) ✓ +1
- High user value +1

**Score: 4/8 - MEDIUM PRIORITY**

**Notes:**
- Already partially follows aggregator pattern with themes
- Module name should perhaps be "prompt" not "starship"
- Good candidate but already well-structured

---

### 12. shell/default.nix
- **Function**: Shell configuration
- **Tool**: Zsh + oh-my-zsh
- **Named for**: Function ✓
- **Separation**: None

**Analysis:**
- Function name (shell) != specific tools (Zsh, oh-my-zsh) ✓ +2
- Contains tool-specific options (oh-my-zsh themes, plugins) ✓ +2
- Could swap to other shells (bash, fish) or frameworks ✓ +1
- Complex implementation (220+ lines, alias management) ✓ +1
- High user value ✓ +1

**Score: 7/8 - HIGH PRIORITY** 🔥

**Refactoring Benefits:**
- Separate shell API from Zsh/oh-my-zsh implementation
- Could add fish, bash implementors
- Clear contract for alias management
- Better for multi-shell users

---

### 13. cli-tools/default.nix
- **Function**: Modern CLI tools
- **Tool**: Multiple (eza, bat, ripgrep, etc.)
- **Named for**: Function ✓
- **Separation**: Partial (per-tool)

**Analysis:**
- Generic function name ✓ +1
- Each tool is independently configured ✓ +1
- Tools are already swappable (fd vs find, etc.) +0.5
- Moderate complexity +0.5
- High value +1

**Score: 4/8 - MEDIUM PRIORITY**

**Notes:**
- Already fairly well-structured
- Each tool is independent
- Could benefit from consistent patterns

---

### 14. development/default.nix
- **Function**: Development environment
- **Tool**: Multiple (rustc, go, python, etc.)
- **Named for**: Function ✓
- **Separation**: Per-language

**Analysis:**
- Generic function name ✓ +1
- Language-specific configurations ✓ +1
- Languages are independent +0.5
- Moderate complexity +0.5
- High value +1

**Score: 4/8 - MEDIUM PRIORITY**

**Notes:**
- Already well-organized
- Each language is independent
- Pattern is already reasonable

---

### 15. git/default.nix
- **Function**: Git configuration
- **Tool**: Git
- **Named for**: Tool/Function (same)
- **Separation**: N/A

**Analysis:**
- Git configuration for Git itself
- No alternative tools
- Simple configuration wrapper

**Score: 0/8 - NONE**

---

### 16. security/default.nix (home)
- **Function**: Security tools
- **Tool**: Bitwarden
- **Named for**: Function ✓
- **Separation**: None

**Analysis:**
- Function name (security) != Tool name (Bitwarden) ✓ +2
- Contains Bitwarden-specific options ✓ +1
- Could swap to other password managers (1Password, KeePass) ✓ +2
- Simple implementation +0
- High user value +1

**Score: 6/8 - HIGH PRIORITY** 🔥

**Refactoring Benefits:**
- Easy to swap Bitwarden for 1Password, KeePassXC, etc.
- Clear password manager API vs tool implementation
- Users can switch password managers easily

---

## Priority Summary

### 🔥 HIGH PRIORITY (Score 6-8)
1. **darwin/theming** (8/8) - Stylix implementation
2. **home/window-manager** (8/8) - AeroSpace implementation  
3. **home/shell** (7/8) - Zsh/oh-my-zsh implementation
4. **home/security** (6/8) - Bitwarden implementation

### ⚠️ MEDIUM PRIORITY (Score 4-5)
5. **darwin/fonts** (4/8) - Font package management
6. **home/starship** (4/8) - Already partially modular
7. **home/cli-tools** (4/8) - Already fairly independent
8. **home/development** (4/8) - Already well-organized

### ✅ LOW/NONE (Score 0-3)
- All other modules are appropriately designed and don't benefit from this pattern

---

## Recommended Refactoring Order

Based on impact, complexity, and architectural value:

1. **darwin/theming** - Highest score, clear candidate, high impact
2. **home/window-manager** - Highest score, enables window manager flexibility
3. **home/security** - Clear benefit, enables password manager choice
4. **home/shell** - Complex but valuable, enables multi-shell support

**Medium Priority (Phase 2b if desired):**
- home/starship - Already partially done, polish existing structure
- darwin/fonts - Lower impact but clean separation value

**Skip:**
- All others - Already well-designed for their purpose

---

## Next Steps

1. ✅ Complete this audit
2. Refactor darwin/theming (aggregator + stylix implementor)
3. Test and verify theming refactoring
4. Refactor home/window-manager (aggregator + aerospace implementor)
5. Document the pattern in WARP.md
6. Update architecture documentation
