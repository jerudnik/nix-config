# YubiKey Setup Guide

This guide walks you through setting up your YubiKey for SSH authentication, GPG signing, and age encryption with your nix-config.

## Prerequisites

✅ YubiKey 5 Series (or YubiKey 4)  
✅ USB-C to USB-A adapter (if needed)  
✅ YubiKey support enabled in your `home.nix` configuration  
✅ System rebuilt with `nrs`

## What Gets Configured

Your nix-config automatically sets up:

- **yubikey-manager** (`ykman`) - CLI tool for YubiKey configuration
- **yubikey-agent** - SSH agent using PIV slots on YubiKey
- **yubico-piv-tool** - PIV certificate and key management
- **GPG with smart card support** - For code signing and encryption
- **age-plugin-yubikey** - Hardware-backed age encryption
- **yubikey-touch-detector** - Visual feedback when YubiKey needs touch
- **Shell aliases** - Convenient shortcuts (e.g., `yk`, `yk-info`)

## Quick Start

### 1. Verify YubiKey Detection

```bash
# Check if YubiKey is detected
yk-info

# Expected output:
# Device type: YubiKey 5 NFC
# Serial number: 12345678
# Firmware version: 5.4.3
# ...
```

### 2. Set PIN and PUK (First Time Only)

The YubiKey PIV application uses a PIN and PUK (PIN Unblocking Key):

```bash
# Change default PIN (default is 123456)
ykman piv access change-pin

# Change default PUK (default is 12345678)
ykman piv access change-puk

# Change management key (optional, for advanced users)
ykman piv access change-management-key --generate --protect
```

**Important:** Store your PIN and PUK in a secure location (like Bitwarden)!

## SSH Authentication with YubiKey

### Generate SSH Key on YubiKey

Your SSH key will be stored in PIV slot 9a (Authentication):

```bash
# Generate EC P-256 key (recommended)
ykman piv keys generate --algorithm ECCP256 9a pubkey.pem

# Generate self-signed certificate
ykman piv certificates generate --subject "SSH Key" 9a pubkey.pem

# Export public key in SSH format
ssh-keygen -D /usr/local/lib/libykcs11.dylib -e > ~/.ssh/id_yubikey.pub

# Or get it directly from the agent
ssh-add -L > ~/.ssh/id_yubikey.pub
```

### Add Public Key to Services

```bash
# Copy your public key
cat ~/.ssh/id_yubikey.pub

# Add to GitHub:
# https://github.com/settings/keys

# Add to servers:
ssh-copy-id -i ~/.ssh/id_yubikey.pub user@server
```

### Test SSH Authentication

```bash
# List keys from agent
ssh-add -L

# Test SSH connection (will require YubiKey touch)
ssh -T git@github.com

# Test server connection
ssh user@server
```

**Note:** You'll need to touch your YubiKey for each SSH authentication!

## GPG Signing with YubiKey

### Generate GPG Key on YubiKey

```bash
# Enter GPG card management
gpg --card-edit

# At the gpg/card> prompt:
gpg/card> admin              # Enter admin mode
gpg/card> generate           # Generate new key on card

# Follow the prompts:
# - Choose key expiration (recommend 1-2 years)
# - Enter your name and email
# - Set PIN (required for signing)
```

### Configure Git Signing

```bash
# Get your GPG key ID
gpg --list-keys --keyid-format LONG

# Output will show:
# pub   rsa4096/0x1234567890ABCDEF 2025-01-13 [SC]
#       ^^^^^^^^^^^^^^^^^^^^^^^
#       This is your key ID

# Add to your home.nix:
programs.git.signing.key = "0x1234567890ABCDEF";
```

Then rebuild: `nrs`

### Test GPG Signing

```bash
# Check GPG can see your YubiKey
yk-gpg

# Make a signed commit
git commit -S -m "Test signed commit"

# Verify signature
git log --show-signature -1
```

### Export GPG Public Key

```bash
# Export for GitHub/GitLab
gpg --armor --export your.email@example.com > gpg-public-key.asc

# Add to GitHub:
# https://github.com/settings/gpg/new
```

## Age Encryption with YubiKey

### Generate Age Identity

```bash
# Generate age identity on YubiKey
age-plugin-yubikey --generate -o ~/.config/age/yubikey-identity.txt

# Get the public key (recipient)
age-plugin-yubikey --identity ~/.config/age/yubikey-identity.txt --list-all
```

### Encrypt/Decrypt Files

```bash
# Encrypt a file
age --encrypt --recipient age1yubikey1... secret.txt > secret.txt.age

# Decrypt (requires YubiKey touch + PIN)
age --decrypt --identity ~/.config/age/yubikey-identity.txt secret.txt.age
```

### Use with SOPS

You can use your YubiKey for SOPS encryption:

```yaml
# Add to .sops.yaml
keys:
  - &yubikey age1yubikey1...  # Your age-yubikey recipient

creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
      - age:
          - *yubikey
```

## Troubleshooting

### YubiKey Not Detected

```bash
# Check if YubiKey is recognized
ykman list

# Check USB connection
system_profiler SPUSBDataType | grep -A 10 Yubico

# Restart pcscd (smart card daemon)
sudo killall pcscd
```

### SSH Agent Not Working

```bash
# Check if yubikey-agent is running
launchctl list | grep yubikey-agent

# View agent logs
tail -f ~/Library/Logs/yubikey-agent.log

# Restart agent
launchctl stop com.apple.yubikey-agent
launchctl start com.apple.yubikey-agent
```

### GPG Can't Find Card

```bash
# Restart GPG agent
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent

# Check card status
gpg --card-status
```

### PIN Entry Not Showing

If PIN entry dialogs don't appear:

```bash
# Check pinentry program
echo "GETINFO pid" | pinentry-mac

# Verify in home.nix configuration:
# home.security.yubikey.sshAgent.pinEntry = "mac";
```

## Security Best Practices

### PIN Requirements

- **PIN:** 6-8 digits, used for normal operations
- **PUK:** 8 digits, used to unblock PIN
- **Admin PIN:** 8 digits, used for administrative operations

### Backup Strategy

⚠️ **Important:** YubiKey keys cannot be exported!

**For SSH:**
- Generate backup keys on a second YubiKey
- Or use traditional SSH keys as backup

**For GPG:**
- Generate keys offline first
- Import to YubiKey (keeps backup)
- Store backup on encrypted USB drive

**For Age:**
- Keep identity file backed up securely
- Or use multiple YubiKeys with same slot

### Touch Requirement

- Touch is required for each operation (SSH, GPG signing, etc.)
- This prevents unauthorized use even if computer is unlocked
- Configure touch policy: `ykman piv keys set-touch-policy 9a always`

## Useful Shell Aliases

Your configuration includes these aliases:

```bash
yk               # Short for ykman
yk-info          # Show YubiKey information
yk-list          # List connected YubiKeys
yk-piv           # PIV tool
yk-piv-status    # PIV slot status
yk-gpg           # GPG card status
yk-gpg-edit      # Edit GPG card
yk-ssh-add       # List SSH keys from agent
```

## PIV Slot Reference

YubiKey PIV slots and their common uses:

| Slot | Purpose | Common Use |
|------|---------|------------|
| 9a   | Authentication | **SSH keys** (default) |
| 9c   | Digital Signature | Code signing, documents |
| 9d   | Key Management | Encryption keys |
| 9e   | Card Authentication | Physical access |

## Advanced: Multiple YubiKeys

To use multiple YubiKeys:

1. Generate keys on both YubiKeys with same subject
2. Add both public keys to services
3. Both will work interchangeably

```bash
# On second YubiKey, use same commands:
ykman piv keys generate --algorithm ECCP256 9a pubkey2.pem
ykman piv certificates generate --subject "SSH Key" 9a pubkey2.pem
```

## Resources

- [YubiKey Manager CLI Guide](https://docs.yubico.com/software/yubikey/tools/ykman/)
- [YubiKey PIV Guide](https://developers.yubico.com/PIV/)
- [GPG Smart Card How-To](https://github.com/drduh/YubiKey-Guide)
- [age-plugin-yubikey Documentation](https://github.com/str4d/age-plugin-yubikey)

## Next Steps

After setting up your YubiKey:

1. ✅ Test SSH authentication to GitHub/servers
2. ✅ Test GPG signing in git commits  
3. ✅ Configure backup authentication methods
4. ✅ Add YubiKey public key to all services
5. ✅ Store PIN/PUK securely in Bitwarden
6. ✅ Consider getting a backup YubiKey

---

**Questions?** Check the [YubiKey FAQ](https://support.yubico.com/) or file an issue in your nix-config repo.
