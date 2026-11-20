# Flake
![main](https://github.com/Emin017/flake/actions/workflows/test.yml/badge.svg?branch=master)

## Usage

### Use flake to rebuild nix configuration

macOS:

```shell
# We use nix-darwin on macOS: https://github.com/LnL7/nix-darwin
# Bash:
darwin-rebuild switch --flake .#MacBook
# or Zsh:
darwin-rebuild switch --flake ".#MacBook"
```

Windows(WSL):

```shell
# Bash:
sudo nixos-rebuild switch --flake .#WSL
# or Zsh:
sudo nixos-rebuild switch --flake ".#WSL"
```

### Manage secrets with agenix

Enter the development shell and select an admin identity:

```shell
nix develop
export AGENIX_IDENTITY="$HOME/.ssh/your-admin-key"
```

Show all helper commands:

```shell
agenix-help
```

Authorize a host, then follow the printed instructions to update `agenix-rules.nix`:

```shell
agenix-onboard wsl /path/to/ssh_host_ed25519_key.pub
agenix-rekey
```

Decrypt a host's initial password, or any other secret, into the clipboard:

```shell
agenix-password wsl
agenix-decrypt system/hosts/wsl/secrets/wsl-user-password.age
```

The identity argument is optional for decrypt and rekey helpers; `AGENIX_IDENTITY` or agenix's default SSH identities are used instead. Never commit private keys or decrypted secrets, and clear clipboard history after pasting secrets.

### Format nix files

```shell
nix fmt
```
