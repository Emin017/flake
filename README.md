# Flake

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

### Format nix files

```shell
nix fmt
```