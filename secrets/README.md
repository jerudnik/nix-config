# Secrets Management

This directory contains the encrypted secrets for the `nix-config` repository. All secrets are encrypted using `sops` with an `age` key.

## Workflow

### Adding a New Secret

1.  **Create a YAML file** in this directory with the secret's contents. For example, `new-secret.yaml`:

    ```yaml
    my_api_key: "your-secret-value"
    ```

2.  **Encrypt the file** using the `sops` command:

    ```bash
    sops -e new-secret.yaml > new-secret.enc.yaml
    ```

3.  **Delete the plaintext file**:

    ```bash
    rm new-secret.yaml
    ```

4.  **Add the encrypted file to `configuration.nix`** to make it available to the system:

    ```nix
    sops.secrets."my-secret" = {
      sopsFile = ./secrets/new-secret.enc.yaml;
      owner = "jrudnik";
    };
    ```

### Editing an Existing Secret

To edit an existing secret, use the `sops` command with the encrypted file:

```bash
sops secrets/existing-secret.enc.yaml
```

This will open the file in your default editor for you to make changes. When you save and close the file, it will be re-encrypted automatically.
