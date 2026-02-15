#!/usr/bin/env bash
# Purpose: Bootstrap an Ubuntu machine for Orcheo by installing required packages
# (Docker, cloudflared, unzip), enabling Docker, installing cloudflared as a
# service, and configuring Bash history/search ergonomics.
# Usage:
#   export CLOUDFLARED_TOKEN="<your-token>"
#   ./ubuntu-setup.sh
#
# Prerequisites:
#   - Ubuntu with sudo access
#   - Internet access
#   - CLOUDFLARED_TOKEN environment variable

set -euo pipefail

readonly BASHRC="${HOME}/.bashrc"
readonly CLOUDFLARE_KEYRING="/usr/share/keyrings/cloudflare-public-v2.gpg"
readonly CLOUDFLARE_REPO="/etc/apt/sources.list.d/cloudflared.list"
readonly CLOUDFLARE_GPG_FINGERPRINT="C0F8B3B770A8C70E1E84121984A4C8D3DDAAAE6A"
readonly AGENT_SKILLS_ARCHIVE="agent-skills-main.zip"
readonly AGENT_SKILLS_MAIN_URL="https://github.com/ShaojieJiang/agent-skills/archive/refs/heads/main.zip"

validate_prerequisites() {
  : "${CLOUDFLARED_TOKEN:?CLOUDFLARED_TOKEN is required}"
}

install_dependencies() {
  sudo apt update
  sudo apt install -y docker.io docker-compose-v2 gnupg python3-pip unzip

  # Enable and start the docker service
  sudo systemctl enable --now docker

  if id -nG "$USER" | tr ' ' '\n' | grep -Fxq docker; then
    echo "User '$USER' is already in the docker group"
  else
    sudo usermod -aG docker "$USER"
    echo "Added '$USER' to the docker group (log out/in to apply)"
  fi
}

install_cloudflared() {
  if sudo systemctl is-active --quiet cloudflared; then
    echo "cloudflared service is already active, skipping install"
    return 0
  fi

  # Add cloudflare gpg key
  sudo mkdir -p --mode=0755 /usr/share/keyrings
  curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | sudo tee "$CLOUDFLARE_KEYRING" >/dev/null

  local actual_fingerprint
  actual_fingerprint="$(gpg --show-keys --with-colons "$CLOUDFLARE_KEYRING" | awk -F: '/^fpr:/ {print $10; exit}')"
  if [[ "$actual_fingerprint" != "$CLOUDFLARE_GPG_FINGERPRINT" ]]; then
    echo "ERROR: Cloudflare GPG fingerprint mismatch"
    echo "Expected: $CLOUDFLARE_GPG_FINGERPRINT"
    echo "Actual:   $actual_fingerprint"
    sudo rm -f "$CLOUDFLARE_KEYRING"
    exit 1
  fi

  # Add cloudflared apt repository
  echo "deb [signed-by=${CLOUDFLARE_KEYRING}] https://pkg.cloudflare.com/cloudflared any main" | sudo tee "$CLOUDFLARE_REPO" >/dev/null

  # Refresh package metadata after adding the repository, then install cloudflared
  sudo apt update
  sudo apt install -y cloudflared

  sudo cloudflared service install "$CLOUDFLARED_TOKEN"
}

upsert_bashrc_setting() {
  local key="$1"
  local value="$2"

  if ! [[ "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
    echo "ERROR: invalid shell variable name '$key'"
    exit 1
  fi

  if grep -Eq "^[[:space:]]*(export[[:space:]]+)?${key}=" "$BASHRC"; then
    sed -i -E "s|^[[:space:]]*(export[[:space:]]+)?${key}=.*$|${key}=${value}|" "$BASHRC"
  else
    echo "${key}=${value}" >> "$BASHRC"
  fi
}

configure_bash_history() {
  touch "$BASHRC"

  upsert_bashrc_setting "HISTSIZE" "10000"
  upsert_bashrc_setting "HISTFILESIZE" "20000"

  # Add key bindings to ~/.bashrc once
  if ! grep -Fq '# >>> orcheo-history-bindings >>>' "$BASHRC"; then
    cat >> "$BASHRC" <<'EOF'

# >>> orcheo-history-bindings >>>
# Enable history search by prefix with Up/Down arrows
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Also bind Ctrl-P / Ctrl-N (like zsh)
bind '"\C-p": history-search-backward'
bind '"\C-n": history-search-forward'
# <<< orcheo-history-bindings <<<
EOF
  fi
}

download_agent_skills_main() {
  if [[ -d agent-skills-main ]]; then
    echo "agent-skills-main directory already exists, skipping download"
    return 0
  fi

  curl -L -o "$AGENT_SKILLS_ARCHIVE" "$AGENT_SKILLS_MAIN_URL"
  unzip -q "$AGENT_SKILLS_ARCHIVE"
  rm -f "$AGENT_SKILLS_ARCHIVE"
}

install_uv_and_orcheo_sdk() {
  if command -v uv >/dev/null 2>&1; then
    echo "uv is already installed"
  else
    python3 -m pip install --user --upgrade uv
  fi

  local uv_bin
  if [[ -x "${HOME}/.local/bin/uv" ]]; then
    uv_bin="${HOME}/.local/bin/uv"
  elif command -v uv >/dev/null 2>&1; then
    uv_bin="$(command -v uv)"
  else
    echo "ERROR: uv installation failed or uv is not in PATH"
    echo "Tried: ${HOME}/.local/bin/uv and PATH"
    exit 1
  fi

  "$uv_bin" tool install -U orcheo-sdk
}

main() {
  echo "=== Starting Orcheo Ubuntu bootstrap ==="
  validate_prerequisites

  echo "[1/5] Installing base dependencies"
  install_dependencies

  echo "[2/5] Installing cloudflared"
  install_cloudflared

  echo "[3/5] Downloading agent-skills main archive"
  download_agent_skills_main

  echo "[4/5] Installing uv and orcheo-sdk"
  install_uv_and_orcheo_sdk

  echo "[5/5] Configuring bash history"
  configure_bash_history

  echo "=== Orcheo Ubuntu bootstrap complete ==="
}

main "$@"
