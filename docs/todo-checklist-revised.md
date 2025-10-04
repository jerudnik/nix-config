
### 1. **Enhanced Productivity Shortcuts**
- [ ] **Lazygit**
  A simple terminal UI for git commands
  Available in nixpkgs

- [ ] **Simplify Starship**
  - Add an blank line at the top of terminal window
  - Cut down on the powerline clutter

### 2. **macOS System Polish**
- [ ] **Keyboard & trackpad settings** - Add to `darwin/system-defaults`
  ```nix
  system.defaults = {
    trackpad = {
      Clicking = true;           # Tap to click
      TrackpadThreeFingerDrag = true;
    };
    NSGlobalDomain = {
      KeyRepeat = 2;            # Fast key repeat
      InitialKeyRepeat = 15;    # Short delay
    };
  };
  ```

- [ ] **Energy & performance settings**
  ```nix
  # Add to system-defaults or create new module
  system.defaults.dock.minimize-to-application = true;
  ```

### 3. **GitHub Integration**  
- [x] **GitHub CLI** - ✅ Added to development module with shell completion
  ```nix
  development.github.enable = true;  # Enables gh with shell completion
  ```
- [x] **Git productivity aliases** - ✅ Added curated git alias set to git module
  - Workflow shortcuts (st, co, sw, br, ci, cm, etc.)
  - Advanced logging (lg, ll, today, week, standup)
  - Safety features (psf for force-with-lease, uncommit, undo)
  - Development helpers (tree view, alias listing)
- [x] **Shell productivity aliases** - ✅ Enhanced shell module with curated shortcuts
  - System monitoring (ports, myip, localip, free, top)
  - File operations with modern tool integration (cat→bat, grep→rg, find→fd, ls→eza)
  - Productivity shortcuts (c, h, j, reload, path, edit)

---

## 🚀 **Future Considerations (Lower Priority)**

### 7. **Advanced Git Workflow**
- [ ] **Git hooks** - Automated linting/testing

### 8. **System Monitoring**  
- [ ] **Log analysis tools** - If you need system debugging

### 9. **Security Enhancements**
- [ ] **Additional security tools** - Secrets management, using hardware passkeys (Yubikey NFC 5)
- [ ] **VPN configuration** - If we need VPN automation

