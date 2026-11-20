# Agenix workflow helpers sourced by devShells.default.
# Identity selection: explicit argument, AGENIX_IDENTITY, then agenix defaults.

_agenix_repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || {
    printf 'Run this command inside the flake repository.\n' >&2
    return 1
  }
}

agenix-decrypt() {
  if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    printf 'Usage: agenix-decrypt SECRET [IDENTITY]\n' >&2
    return 2
  fi

  local secret="$1"
  local identity="${2:-${AGENIX_IDENTITY:-}}"

  if [ ! -f "$secret" ]; then
    printf 'Secret not found: %s\n' "$secret" >&2
    return 1
  fi
  if [ -n "$identity" ] && [ ! -r "$identity" ]; then
    printf 'Identity not readable: %s\n' "$identity" >&2
    return 1
  fi

  local plaintext
  if [ -n "$identity" ]; then
    plaintext=$(agenix -d "$secret" -i "$identity") || return $?
  else
    plaintext=$(agenix -d "$secret") || return $?
  fi

  if command -v wl-copy >/dev/null 2>&1; then
    printf '%s\n' "$plaintext" | wl-copy || {
      unset plaintext
      return 1
    }
  elif command -v pbcopy >/dev/null 2>&1; then
    printf '%s\n' "$plaintext" | pbcopy || {
      unset plaintext
      return 1
    }
  else
    printf 'No supported clipboard command found.\n' >&2
    unset plaintext
    return 1
  fi

  unset plaintext
  printf 'Decrypted %s to clipboard; clear it after use.\n' "$secret"
}

agenix-rekey() {
  if [ "$#" -gt 1 ]; then
    printf 'Usage: agenix-rekey [IDENTITY]\n' >&2
    return 2
  fi

  local identity="${1:-${AGENIX_IDENTITY:-}}"
  if [ -n "$identity" ] && [ ! -r "$identity" ]; then
    printf 'Identity not readable: %s\n' "$identity" >&2
    return 1
  fi

  if [ -n "$identity" ]; then
    agenix -r -i "$identity" && agenix -c
  else
    agenix -r && agenix -c
  fi
}

agenix-password() {
  if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    printf 'Usage: agenix-password HOST [IDENTITY]\n' >&2
    return 2
  fi

  local host="$1"
  local root
  root=$(_agenix_repo_root) || return $?
  local secret="$root/system/hosts/$host/secrets/$host-user-password.age"

  if [ ! -f "$secret" ]; then
    printf 'No default password secret for host %s:\n%s\n' "$host" "$secret" >&2
    printf 'Use agenix-decrypt SECRET [IDENTITY] for a custom path.\n' >&2
    return 1
  fi

  printf 'Save the decrypted password in Bitwarden, then clear clipboard history.\n'
  if [ "$#" -eq 2 ]; then
    agenix-decrypt "$secret" "$2"
  else
    agenix-decrypt "$secret"
  fi
}

agenix-onboard() {
  if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    printf 'Usage: agenix-onboard HOST [HOST_PUBLIC_KEY]\n' >&2
    return 2
  fi

  local host="$1"
  local pubkey="${2:-/etc/ssh/ssh_host_ed25519_key.pub}"
  local root
  root=$(_agenix_repo_root) || return $?
  local secret_dir="$root/system/hosts/$host/secrets"
  local hash_secret="$secret_dir/$host-user-password-hash.age"

  if [ ! -f "$hash_secret" ]; then
    printf 'No password hash secret for host %s:\n%s\n' "$host" "$hash_secret" >&2
    return 1
  fi
  if [ ! -r "$pubkey" ]; then
    printf 'Host public key not readable: %s\n' "$pubkey" >&2
    return 1
  fi
  if ! ssh-keygen -l -f "$pubkey" >/dev/null 2>&1; then
    printf 'Invalid SSH public key: %s\n' "$pubkey" >&2
    return 1
  fi

  printf '\n1. Add this host public key to agenix-rules.nix:\n\n'
  printf '  %s = "%s";\n' "$host" "$(<"$pubkey")"
  printf '\n2. Add or replace the host rules with:\n\n'
  if [ -f "$secret_dir/$host-user-password.age" ]; then
    printf '  (mkHostSecrets "%s" [ admin ] [ "password" ])\n' "$host"
  fi
  printf '  (mkHostSecrets "%s" [ admin %s ] [ "password-hash" ])\n' "$host" "$host"
  printf '\n3. Re-encrypt the existing secrets from the repository root:\n\n'
  printf '  agenix-rekey\n'
  printf '\n4. Review and commit the changed rules and ciphertext.\n'
  printf '\n5. Ensure the matching private key is installed on the target as:\n\n'
  printf '  /etc/ssh/ssh_host_ed25519_key\n'
  printf '\n6. Activate the target configuration:\n\n'
  printf '  sudo nixos-rebuild switch --flake .#%s\n\n' "$host"
}

agenix-help() {
  cat <<'EOF'
Agenix helpers

Identity selection:
  1. Pass IDENTITY explicitly to agenix-decrypt, agenix-password, or agenix-rekey.
  2. Set AGENIX_IDENTITY to your private key path.
  3. Otherwise agenix uses its own default SSH identity search.

  Example: export AGENIX_IDENTITY="$HOME/.ssh/your-admin-key"

Commands:
  agenix-help
      Show this guide.

  agenix-password HOST [IDENTITY]
      Decrypt a host's default password into the clipboard.
      Example: agenix-password wsl

  agenix-decrypt SECRET [IDENTITY]
      Decrypt an arbitrary .age file into the clipboard.

  agenix-onboard HOST [HOST_PUBLIC_KEY]
      Print the rules and steps needed to authorize a host.
      HOST_PUBLIC_KEY defaults to /etc/ssh/ssh_host_ed25519_key.pub.
      This only prints guidance; it does not edit files or rekey.

  agenix-rekey [IDENTITY]
      Re-encrypt all secrets after changing agenix-rules.nix, then check them.

Typical host setup:
  1. agenix-onboard HOST /path/to/ssh_host_ed25519_key.pub
  2. Apply the printed rules in agenix-rules.nix.
  3. agenix-rekey
  4. Review, commit, and distribute the updated ciphertext.
  5. Provision /etc/ssh/ssh_host_ed25519_key on the target before activation.
  6. agenix-password HOST to retrieve the initial password on the admin machine.

Security reminders:
  - Never commit private keys or decrypted secrets.
  - Keep default plaintext password secrets admin-only.
  - Clear the clipboard and clipboard history after pasting secrets.
EOF
}
