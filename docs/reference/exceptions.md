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
- **Unfree Packages:** ≤ 5 packages maximum
- **Homebrew Exceptions:** ≤ 2 applications maximum  
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

**Last Updated:** 2025-10-07  
**Next Review Due:** 2025-04-04  
**Maintained By:** Configuration Management
