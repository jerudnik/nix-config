# Application Availability Troubleshooting

This guide addresses common issues where applications installed via nix-darwin and home-manager aren't available in your shell.

## Quick Fixes

Try these solutions in order:

### 1. Reload Shell Environment
```bash
# Option A: Restart shell (recommended)
refresh-env

# Option B: Reload configuration
reload-path
```

### 2. Verify PATH Configuration
```bash
# Check if Nix paths are in PATH
echo $PATH

# Expected paths should include:
# - /etc/profiles/per-user/$USER/bin
# - ~/.nix-profile/bin
# - /run/current-system/sw/bin
```

### 3. Check Application Installation
```bash
# Verify binaries exist
ls -la /etc/profiles/per-user/$USER/bin/ | grep your-app

# Check specific application
which your-application-name
```

## Debugging Steps

### Enable Debug Mode
Add to your home configuration:

```nix
home.shell = {
  enable = true;
  debugEnvironment = true;  # Add this line
  # ... other config
};
```

Then rebuild and open a new shell to see debug output.

### Manual Environment Loading
If automatic loading fails, manually source profiles:

```bash
# Source system profiles
for profile in /nix/var/nix/profiles/default ~/.nix-profile /etc/profiles/per-user/$USER; do
  if [ -f "$profile/etc/profile.d/nix.sh" ]; then
    source "$profile/etc/profile.d/nix.sh"
  fi
done

# Source home-manager session variables (if they exist)
if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
  source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
fi
```

## Common Issues & Solutions

### Issue: Applications installed but not in PATH

**Symptoms**: `which app-name` returns "not found" despite successful build

**Solution**: 
1. Check if using integrated home-manager mode (you are)
2. Ensure shell configuration is properly reloaded
3. Verify PATH includes `/etc/profiles/per-user/$USER/bin`

```bash
# Quick fix
refresh-env
```

### Issue: Environment variables not set

**Symptoms**: Applications complain about missing environment variables

**Solution**: Verify session variables are loaded:
```bash
# Check if session variables file exists
ls -la ~/.nix-profile/etc/profile.d/hm-session-vars.sh

# If missing, this indicates home-manager integration issue
# Try manual environment reload
reload-path
```

### Issue: Legacy applications interfering

**Symptoms**: Old versions of applications taking precedence

**Solution**: Check for legacy Nix profiles:
```bash
# Check for old installations
ls -la ~/.nix-profile/bin/

# If you see old applications, clean up
nix-collect-garbage -d
sudo nix-collect-garbage -d
```

### Issue: Shell not loading Nix environment

**Symptoms**: Fresh terminal doesn't have Nix applications

**Solution**: Verify shell configuration:
```bash
# Check if .zshrc is managed by home-manager
ls -la ~/.zshrc

# Should be a symlink to nix store
# If not, home-manager integration may be broken
```

## Advanced Diagnostics

### Check Nix Profile Status
```bash
# List current generations
nix-env --list-generations

# Check profile paths
echo $NIX_PROFILES
```

### Verify Home Manager Integration
```bash
# Check if home-manager is integrated with nix-darwin
# This should show your user configuration
nix eval .#darwinConfigurations.parsley.config.home-manager.users.jrudnik.home.username
```

### PATH Analysis
```bash
# Detailed PATH analysis
echo $PATH | tr ':' '\n' | nl

# Check each PATH entry
for dir in $(echo $PATH | tr ':' '\n'); do
  echo "=== $dir ==="
  ls -la "$dir" 2>/dev/null | head -3 || echo "Directory not accessible"
done
```

## Prevention

### Keep Environment Fresh
Add to your workflow:
```bash
# After any nix-darwin/home-manager changes
./scripts/build.sh switch
refresh-env  # Start fresh shell
```

### Regular Maintenance
```bash
# Weekly cleanup to prevent conflicts
ngc  # alias for garbage collection
```

### Configuration Best Practices
1. Use integrated mode (nix-darwin managing home-manager) ✅ You're doing this
2. Let home-manager handle user applications ✅ You're doing this  
3. Avoid manual PATH modifications in shell configs
4. Use module options instead of direct package lists when possible

This systematic approach should resolve most application availability issues with your nix-darwin and home-manager setup.