# WARP.md Compliance Remediation Plan

**Plan Date**: 2025-10-04T19:06:34Z  
**Status**: Research Phase - Identifying Community Solutions  
**Scope**: Complete WARP.md compliance resolution

---

## 📋 Issue Inventory & Logical Ordering

### **TIER 1: CRITICAL COMPLIANCE VIOLATIONS (Must Fix)**

#### **Issue 1.1: Warp Terminal Nixpkgs Migration** 
- **Law Violated**: LAW 5 (Nixpkgs-First Installation)
- **Severity**: High (Primary rule violation)
- **Discovery**: MCP research revealed warp-terminal IS available in nixpkgs
- **Current State**: `hosts/parsley/configuration.nix:51` - `casks = [ "warp" ];`
- **Required Action**: Migrate from Homebrew cask to nixpkgs package
- **Complexity**: Low (straightforward package swap)
- **Dependencies**: None

#### **Issue 1.2: Remove Informational Activation Scripts**
- **Law Violated**: LAW 1.1 & 1.3 (Declarative Only, No External State)
- **Severity**: Medium (Violates purity principles) 
- **Locations**:
  - `modules/darwin/fonts/default.nix:114` - Informational font script
  - `modules/darwin/window-manager/default.nix:27` - Deprecation warning script
- **Required Action**: Remove both activation scripts
- **Complexity**: Low (simple deletion)
- **Dependencies**: None

### **TIER 2: ARCHITECTURAL IMPROVEMENTS (Should Fix)**

#### **Issue 2.1: Oversized Module - Starship Configuration**
- **Law Violated**: LAW 2.2 (One Module, One Concern) - Guideline
- **Severity**: Low (Maintainability concern, not rule violation)
- **Location**: `modules/home/cli-tools/starship.nix` - 278 lines
- **Problem**: Extensive Starship prompt configuration in single file
- **Required Action**: Split into logical components
- **Complexity**: Medium (requires careful refactoring)
- **Dependencies**: None

#### **Issue 2.2: Oversized Module - Shell Configuration**  
- **Law Violated**: LAW 2.2 (One Module, One Concern) - Guideline
- **Severity**: Low (Maintainability concern, not rule violation)
- **Location**: `modules/home/shell/default.nix` - 210 lines
- **Problem**: Handles shell, aliases, oh-my-zsh, and environment setup
- **Required Action**: Modularize into focused components
- **Complexity**: Medium (requires logical separation)
- **Dependencies**: None

### **TIER 3: MINOR OPTIMIZATIONS (Could Fix)**

#### **Issue 3.1: Type Specificity Improvements**
- **Law Violated**: LAW 3.1 (Strict Type Usage) - Best Practice
- **Severity**: Very Low (Improvement, not violation)
- **Locations**: 29 uses of `types.str` where more specific types could apply
- **Problem**: Some path options could use `types.path`
- **Required Action**: Review and update specific type usage
- **Complexity**: Low (targeted updates)
- **Dependencies**: None

#### **Issue 3.2: Other Oversized Modules**
- **Law Violated**: LAW 2.2 (One Module, One Concern) - Guideline  
- **Severity**: Very Low (Acceptable as-is per research)
- **Locations**: 
  - `modules/home/cli-tools/default.nix`: 179 lines
  - `modules/home/window-manager/default.nix`: 161 lines
  - `modules/darwin/system-defaults/default.nix`: 156 lines
  - `modules/darwin/theming/default.nix`: 147 lines
  - `modules/darwin/fonts/default.nix`: 131 lines
- **Assessment**: Research indicates these handle cohesive functionality
- **Required Action**: Monitor, consider if growth continues
- **Complexity**: N/A (No immediate action needed)
- **Dependencies**: None

### **TIER 4: PROCESS & DOCUMENTATION (Infrastructure)**

#### **Issue 4.1: Missing Exception Documentation Framework**
- **Law Violated**: LAW 5.2 (Exception Documentation Requirements)
- **Severity**: Low (Process improvement)
- **Problem**: No `docs/exceptions/` directory or framework
- **Required Action**: Create documentation structure and guidelines
- **Complexity**: Low (documentation task)
- **Dependencies**: None

#### **Issue 4.2: Automated Options Documentation**
- **Law Violated**: LAW 6.2 (Documentation Synchronization) - Best Practice
- **Severity**: Very Low (Future-proofing)
- **Problem**: Manual documentation maintenance risk
- **Required Action**: Implement nixosOptionsDoc generation
- **Complexity**: Medium (requires build integration)
- **Dependencies**: None

---

## 🎯 Proposed Implementation Strategy

### **Phase 1: Immediate Compliance (Essential)**
**Goal**: Achieve 100% WARP.md compliance with critical violations
**Timeline**: Current session
**Issues Addressed**: 1.1, 1.2

### **Phase 2: Architecture Enhancement (Recommended)**  
**Goal**: Improve maintainability and long-term sustainability
**Timeline**: Follow-up session
**Issues Addressed**: 2.1, 2.2

### **Phase 3: Polish & Future-Proofing (Optional)**
**Goal**: Optimize and establish best practices
**Timeline**: Future iterations
**Issues Addressed**: 3.1, 4.1, 4.2

---

## 🔬 Research Agenda: Community Solutions

Before implementing changes, research proven community approaches:

### **Research Topic 1: Nixpkgs Unfree Package Management**
- **Question**: How do others handle unfree packages like warp-terminal in nix-darwin/home-manager?
- **Focus**: Best practices for unfree package allowlists and installation patterns
- **Tools**: GitHub search, NixOS community configs, Context7 documentation

### **Research Topic 2: Activation Script Alternatives**
- **Question**: What declarative alternatives exist for font management and module deprecation?
- **Focus**: Pure nix-darwin approaches to replace activation scripts
- **Tools**: nix-darwin documentation, GitHub examples, NixOS discourse

### **Research Topic 3: Large Module Splitting Patterns**
- **Question**: How do experienced users split large configuration modules?
- **Focus**: Starship and shell configuration modularization examples
- **Tools**: Popular nix configs on GitHub, module organization patterns

### **Research Topic 4: Type Safety Best Practices**
- **Question**: When to use `types.path` vs `types.str` in nix modules?
- **Focus**: NixOS module type usage patterns and conventions
- **Tools**: nixpkgs module examples, NixOS manual references

---

## 📝 Next Steps

1. **Conduct MCP Research** - Gather community examples for each research topic
2. **Refine Implementation Plan** - Incorporate learnings from research
3. **Execute Phase 1** - Implement critical compliance fixes
4. **Validate & Test** - Ensure changes work correctly
5. **Document Learnings** - Update approach based on results

---

## 🎨 Success Criteria

### **Phase 1 Success**:
- ✅ Warp Terminal installed via nixpkgs (not Homebrew)
- ✅ No activation scripts in configuration
- ✅ `./scripts/build.sh build` passes cleanly
- ✅ 100% WARP.md compliance achieved

### **Phase 2 Success**:
- ✅ No modules exceed ~150 lines (reasonable threshold)
- ✅ Clear separation of concerns in large modules
- ✅ Improved maintainability without compromising functionality

### **Phase 3 Success**:
- ✅ Optimal type usage throughout modules
- ✅ Exception documentation framework established
- ✅ Automated documentation generation implemented

This plan prioritizes **simplicity** and **proven approaches** while maintaining strict adherence to WARP.md principles.