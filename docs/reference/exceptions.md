# Exception Handling Documentation

This document tracks all exceptions to WARP.md compliance rules with technical justifications and periodic review requirements.

## 📋 **Current Exceptions**

### **UNFREE PACKAGES (LAW 5 Exceptions)**

Packages that require unfree licensing exceptions with technical justification:

#### ✅ **Raycast** - `allowUnfreePredicate`
- **Package:** `raycast` 
- **Reason:** Essential productivity tool for macOS, no suitable open-source alternative with equivalent feature set
- **Technical Limitation:** Nix cannot package proprietary Mac App Store applications effectively
- **Justification:** Productivity gains and system integration justify unfree exception
- **Review Date:** Next: 2025-04-04
- **Status:** ✅ Approved

#### ✅ **Warp Terminal** - `allowUnfreePredicate` 
- **Package:** `warp-terminal`
- **Source:** nixpkgs (installed via Home Manager)
- **Reason:** Modern terminal with AI features available in nixpkgs
- **Technical Limitation:** Requires unfree license for AI features
- **Installation:** Home Manager user packages (WARP-compliant: user application, not system-level)
- **Version Strategy:** nixpkgs version may lag ~1 week behind upstream; acceptable due to Warp's built-in auto-update capability
- **Justification:** Enhanced development experience, available in nixpkgs maintains declarative approach
- **Review Date:** Next: 2025-04-04  
- **Status:** ✅ Approved

---

### **HOMEBREW EXCEPTIONS (LAW 5 Exceptions)**

Applications installed via Homebrew due to nixpkgs limitations on aarch64-darwin:

#### ✅ **Claude Desktop** - Homebrew Cask
- **Package:** `claude`
- **Reason:** Not available in nixpkgs as of 2025-10-11
- **Alternative Analysis:**
  - **nixpkgs status**: No claude-desktop package exists
  - **upstream availability**: Official Anthropic releases via direct download and Homebrew cask only
  - **packaging complexity**: Electron app with frequent updates, no community packaging effort
- **Technical Justification:** Homebrew cask provides official, maintained distribution
- **Integration:** System-level via nix-homebrew + user MCP config via Home Manager
- **Reproducibility:** MCP servers use nixpkgs/mcp-servers-nix, only GUI uses Homebrew
- **Review Date:** Next: 2025-04-11
- **Status:** ✅ Approved

#### ✅ **Beeper** - Homebrew Cask
- **Package:** `beeper`
- **Reason:** Not available for aarch64-darwin in nixpkgs
- **Alternative Analysis:**
  - **nixpkgs status**: Package exists but only for x86_64-linux platform
  - **platform limitation**: `package.meta.platforms = ["x86_64-linux"]`
  - **Error message**: "Package 'beeper-4.1.186' is not available on the requested hostPlatform: aarch64-darwin"
- **Technical Justification:** Universal chat client (Matrix, Discord, Slack, etc.) with no macOS Apple Silicon support in nixpkgs
- **Justification:** Essential for unified communications across multiple platforms
- **Review Date:** Next: 2025-04-11
- **Status:** ✅ Approved

#### ✅ **Calibre** - Homebrew Cask
- **Package:** `calibre`
- **Reason:** Marked as broken in nixpkgs
- **Alternative Analysis:**
  - **nixpkgs status**: Package exists but marked as broken for aarch64-darwin
  - **Error message**: "Package 'calibre-8.10.0' is marked as broken, refusing to evaluate"
  - **packaging issue**: Build or runtime issues on Apple Silicon
- **Technical Justification:** eBook management and conversion tool with broken nixpkgs build
- **Justification:** Essential for academic/research document management
- **Review Date:** Next: 2025-04-11 (check if nixpkgs issue resolved)
- **Status:** ✅ Approved

#### ✅ **Jabref** - Homebrew Cask
- **Package:** `jabref`
- **Reason:** Not available for aarch64-darwin in nixpkgs
- **Alternative Analysis:**
  - **nixpkgs status**: Package exists in search but not available for aarch64-darwin
  - **platform limitation**: Platform restrictions prevent Apple Silicon installation
- **Technical Justification:** BibTeX reference manager not packaged for macOS ARM64
- **Justification:** Essential for academic/research bibliography management
- **Review Date:** Next: 2025-04-11
- **Status:** ✅ Approved

#### ✅ **Brain.fm** - Homebrew Cask
- **Package:** `brainfm`
- **Reason:** Not available in nixpkgs.
- **Alternative Analysis:**
  - **nixpkgs status**: No `brainfm` package exists.
  - **upstream availability**: Official releases via direct download and Homebrew cask only.
- **Technical Justification:** Proprietary application with no Nix packaging available.
- **Justification:** Essential for focus and productivity.
- **Review Date:** Next: 2025-04-11
- **Status:** ✅ Approved (pending documentation)

#### ✅ **Nimble Commander** - Homebrew Cask
- **Package:** `nimble-commander`
- **Reason:** Not available in nixpkgs.
- **Alternative Analysis:**
  - **nixpkgs status**: No `nimble-commander` package exists.
  - **upstream availability**: Official releases via direct download and Homebrew cask only.
- **Technical Justification:** Dual-pane file manager for macOS with no Nix packaging available.
- **Justification:** Core workflow tool for file management.
- **Review Date:** Next: 2025-04-11
- **Status:** ✅ Approved (pending documentation)

---

## 🔄 **Exception Review Process**

### **Quarterly Review Schedule**
- **Q1 Review:** January 15
- **Q2 Review:** April 15  
- **Q3 Review:** July 15
- **Q4 Review:** October 15

### **Review Criteria**
1. **Alternative Assessment:** Check if open-source alternatives have emerged
2. **Technical Validity:** Verify technical limitations still exist
3. **Usage Justification:** Confirm continued necessity and value
4. **Compliance Impact:** Assess effect on overall WARP.md adherence

### **Exception Approval Process**
1. **Document Technical Limitation:** Specific error messages or technical reasons
2. **Research Alternatives:** Thorough investigation of nixpkgs and open-source options
3. **Justify Business Value:** Clear articulation of necessity
4. **Set Review Date:** Maximum 6-month review cycle
5. **Update This Document:** Maintain current exception list

---

## 📖 **Exception Templates**

### **Unfree Package Exception Template**
```markdown
#### **[PACKAGE NAME]** - `allowUnfreePredicate`
- **Package:** `package-name`
- **Reason:** [Why this package is needed]
- **Technical Limitation:** [Specific nixpkgs/packaging issues]
- **Justification:** [Business/technical value justification]
- **Review Date:** Next: [YYYY-MM-DD]
- **Status:** [Pending/Approved/Rejected/Deprecated]
```

### **Homebrew Exception Template** 
```markdown
#### **[APPLICATION NAME]** - Homebrew Cask
- **Package:** `application-name`
- **Reason:** [Why nixpkgs installation failed]
- **Technical Limitation:** [Specific error messages/issues]
- **Nixpkgs Status:** [Not available/Broken/Packaging issues]
- **Justification:** [Why this application is essential]
- **Review Date:** Next: [YYYY-MM-DD]
- **Status:** [Pending/Approved/Rejected/Deprecated]
```

---

## 🎯 **Compliance Goals**

### **Target Metrics**
- **Unfree Packages:** ≤ 5 packages maximum (Current: 2)
- **Homebrew Exceptions:** ≤ 5 applications maximum (Current: 4)  
- **Review Compliance:** 100% exceptions reviewed quarterly
- **Documentation Currency:** All exceptions documented within 48 hours

### **Improvement Strategy**
1. **Regular Nixpkgs Monitoring:** Track package availability improvements
2. **Alternative Research:** Continuous evaluation of open-source alternatives  
3. **Upstream Contribution:** Contribute to nixpkgs packaging when feasible
4. **Exception Reduction:** Actively work to minimize exception count over time

---

## 📚 **Historical Exceptions**

### **Resolved Exceptions**
Document previously resolved exceptions to prevent regression:

#### **Warp Terminal via Homebrew** - ✅ RESOLVED (2025-01-04)
- **Previous Status:** Homebrew cask exception
- **Resolution:** Migrated to nixpkgs with `allowUnfreePredicate`  
- **Technical Solution:** Unfree package management in flake configuration
- **Lesson Learned:** Always verify nixpkgs availability before assuming Homebrew necessity

#### **Warp Terminal System-Level Installation** - ✅ RESOLVED (2025-10-07)
- **Previous Status:** Installed via darwin.core (nix-darwin system packages)
- **Issue:** Violated WARP.md RULE 4.3 (non-essential package in system packages)
- **Resolution:** Moved to Home Manager user packages
- **Cleanup:** Removed redundant Homebrew cask installation
- **Technical Solution:** User-level installation via home.packages in home-manager
- **Lesson Learned:** GUI applications belong in Home Manager, not system packages, even when using nixpkgs

---

**Last Updated:** 2025-10-11  
**Next Review Due:** 2025-04-11  
**Maintained By:** Configuration Management
