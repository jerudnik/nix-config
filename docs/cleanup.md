# System Cleanup Guide

Comprehensive guide for cleaning up old Nix generations and optimizing your system after migration.

## Current System Analysis

Based on your system analysis, you have:
- **28 system generations** accumulated during dot-nilla experimentation
- **14GB Nix store** with potential for cleanup
- **Successful new configuration** (generation 28 is current and working)

## Quick Cleanup

### Automated Cleanup Script

Use the provided cleanup script for safe, guided cleanup:

```bash
# Interactive cleanup with options
./scripts/cleanup.sh

# Conservative cleanup (60+ days old)
./scripts/cleanup.sh conservative

# Standard cleanup (30+ days old) 
./scripts/cleanup.sh standard

# Aggressive cleanup (7+ days old)
./scripts/cleanup.sh aggressive
```

### Manual Cleanup Commands

**Safe system cleanup:**
```bash
# Remove system generations older than 30 days
sudo nix-collect-garbage --delete-older-than 30d

# Remove user profile generations
nix-collect-garbage -d

# Optimize store (deduplicate files)
sudo nix store optimise

# Verify store integrity
sudo nix-store --verify --check-contents
```

## Detailed Cleanup Process

### 1. System Generations Cleanup

**Check current generations:**
```bash
# List all system generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Show last 5 generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -5
```

**Remove old generations safely:**
```bash
# Conservative: Keep last 60 days
sudo nix-collect-garbage --delete-older-than 60d

# Standard: Keep last 30 days  
sudo nix-collect-garbage --delete-older-than 30d

# Aggressive: Keep last 7 days
sudo nix-collect-garbage --delete-older-than 7d
```

### 2. User Profile Cleanup

Since you're using integrated Home Manager, user profile cleanup is minimal:

```bash
# Clean user generations
nix-collect-garbage -d

# Check user profile status
ls -la ~/.nix-profile/
```

### 3. Nix Store Optimization

**Deduplicate identical files:**
```bash
# Run store optimization (can take time but saves significant space)
sudo nix store optimise
```

**Check store health:**
```bash
# Verify store integrity and repair if needed
sudo nix-store --verify --check-contents --repair

# Check for broken references
nix-store --query --requisites /run/current-system | xargs nix-store --verify
```

### 4. Disk Space Analysis

**Monitor cleanup progress:**
```bash
# Before cleanup
du -sh /nix/store

# Check specific components
du -sh /nix/var/nix/profiles/
du -sh ~/.nix-profile/

# After cleanup - should be significantly smaller
du -sh /nix/store
```

## Post-Migration Specific Cleanup

### Remove Old Framework Dependencies

Your migration from dot-nilla means old framework-specific packages can be cleaned up:

**Check for old dependencies:**
```bash
# List packages in current system
nix-store --query --requisites /run/current-system | grep -E "(nilla|pins)" || echo "No old framework dependencies found"
```

### Clean Build Artifacts

**Remove build artifacts from migration:**
```bash
# Remove any result symlinks from old builds
find ~/dot-nilla -name "result*" -type l -delete 2>/dev/null || true

# Clean up any temporary build files
find ~/dot-nilla -name "*.tmp" -delete 2>/dev/null || true
```

## Automated Maintenance

### Built-in Automatic Cleanup

Your new configuration includes automatic maintenance:

```nix
# In hosts/parsley/configuration.nix
nix = {
  # Automatic garbage collection
  gc = {
    automatic = true;
    interval = { Weekday = 7; Hour = 3; Minute = 15; };  # Weekly on Sunday at 3:15 AM
    options = "--delete-older-than 30d";
  };
  
  # Automatic store optimization
  settings.auto-optimise-store = true;
  optimise.automatic = true;
};
```

### Manual Maintenance Schedule

**Weekly (Quick):**
```bash
./scripts/build.sh clean
```

**Monthly (Thorough):**
```bash
./scripts/cleanup.sh conservative
```

**Quarterly (Deep Clean):**
```bash
./scripts/cleanup.sh aggressive
```

## Safety Considerations

### Before Cleanup

1. **Ensure current system works:**
   ```bash
   # Test current configuration builds
   ./scripts/build.sh build
   ```

2. **Keep recent generations:**
   - Always keep at least the last 2-3 generations
   - Never delete the current generation

3. **Backup important data:**
   - Your configuration is in git (safe)
   - System can always be rebuilt

### Emergency Recovery

**If something goes wrong:**

```bash
# List available generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nix-env --rollback --profile /nix/var/nix/profiles/system

# Switch to specific generation
sudo nix-env --switch-generation 27 --profile /nix/var/nix/profiles/system

# Then activate the generation
sudo /nix/var/nix/profiles/system/activate
```

## Expected Results

### After Conservative Cleanup (60+ days)
- Remove ~15-20 old generations
- Free up ~3-5GB of disk space
- Keep recent experiments safe

### After Standard Cleanup (30+ days)
- Remove ~20-25 old generations  
- Free up ~5-8GB of disk space
- Keep last month of changes

### After Aggressive Cleanup (7+ days)
- Remove ~25+ old generations
- Free up ~8-12GB of disk space
- Only keep very recent changes

### Store Optimization Results
- Additional ~10-30% space savings
- Deduplicated identical files
- Improved system performance

## Troubleshooting

### Common Issues

**Permission errors:**
```bash
# Ensure proper permissions for nix daemon
sudo launchctl stop org.nixos.nix-daemon
sudo launchctl start org.nixos.nix-daemon
```

**Store corruption:**
```bash
# Repair store if corruption detected
sudo nix-store --repair --verify --check-contents
```

**Disk space still high:**
```bash
# Find large directories in nix store
du -h /nix/store | sort -h | tail -20

# Check for non-Nix large files
du -h / | sort -h | tail -20 | grep -v "/nix/"
```

### Monitoring Commands

```bash
# Check current disk usage
df -h /

# Monitor nix store size over time
watch -n 60 'du -sh /nix/store'

# Check active references
nix-store --query --requisites /run/current-system | wc -l
```

## Best Practices Going Forward

1. **Regular maintenance:** Use automatic cleanup settings
2. **Monitor disk usage:** Check store size monthly
3. **Test before cleanup:** Always verify current system works
4. **Gradual cleanup:** Start conservative, get more aggressive over time
5. **Document changes:** Keep track of what you're cleaning up

This cleanup process will significantly reduce your Nix store size while maintaining system safety and the ability to rollback if needed.