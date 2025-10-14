# Secrets Management

This directory contains encrypted secrets for the nix-config repository. All secrets are encrypted using `sops` with `age` encryption.

## Structure

- `system.enc.yaml` - System-level secrets (SSH keys, service credentials)
- `user.enc.yaml` - User-level secrets (API keys, development tokens)
- `.sops.yaml` (in repo root) - SOPS configuration defining encryption keys

## Your Age Public Key

Your age public key: `age10h5mq3ktk6xrzjr0umaraz7v2p5q2tx39jkjulfwegs7wemyesusd4d0yf`  
Private key location: `~/.config/sops/age/keys.txt`

## Workflow

### Creating a New Secrets File

1. Create a plaintext YAML file with your secrets:
   ```yaml
   my_secret: "secret-value"
   nested:
     secret: "another-value"
   ```

2. Encrypt it with SOPS:
   ```bash
   sops -e secrets/my-file.yaml > secrets/my-file.enc.yaml
   ```

3. Delete the plaintext file:
   ```bash
   rm secrets/my-file.yaml
   ```

### Editing Encrypted Secrets

To edit an existing encrypted file:
```bash
sops secrets/system.enc.yaml
# or
sops secrets/user.enc.yaml
```

SOPS will decrypt the file, open it in your editor, and re-encrypt it when you save.

### Adding Secrets to Your Configuration

**System-level (nix-darwin):**  
Edit `hosts/parsley/configuration.nix`:
```nix
sops.secrets."path/to/secret" = {
  owner = "jrudnik";
  path = "/desired/path";
  mode = "0600";
};
```

**User-level (home-manager):**  
Edit `home/jrudnik/home.nix`:
```nix
sops.secrets."path/to/secret" = {
  path = "${config.home.homeDirectory}/.secrets/secret-name";
};
```

### Accessing Secrets

After rebuilding your configuration:
- **System secrets**: Available at `/run/secrets/<secret-name>` or custom path
- **User secrets**: Available at configured paths (e.g., `~/.secrets/github-token`)
- **As environment variables** (if configured): `$GITHUB_TOKEN`, etc.

## Security Notes

- Never commit unencrypted secret files
- Keep your age private key secure (`~/.config/sops/age/keys.txt`)
- Only `.enc.yaml` files should be in version control
- Secrets are decrypted at system activation time

## Quick Reference

**Encrypt a file:**
```bash
sops -e secrets/file.yaml > secrets/file.enc.yaml
```

**Edit encrypted file:**
```bash
sops secrets/file.enc.yaml
```

**View encrypted file:**
```bash
sops -d secrets/file.enc.yaml
```

**Rebuild after secret changes:**
```bash
nrs  # Applies both system and user secrets
```
