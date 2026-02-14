#!/usr/bin/env bash
# Purpose: Bootstrap an Ubuntu machine for Orcheo by installing required packages
# (Docker, cloudflared, unzip), enabling Docker, installing cloudflared as a
# service, and configuring Bash history/search ergonomics.
# Requirement: Set CLOUDFLARED_TOKEN in the environment before running.

set -euo pipefail

readonly BASHRC="${HOME}/.bashrc"
readonly CLOUDFLARE_KEYRING="/usr/share/keyrings/cloudflare-public-v2.gpg"
readonly CLOUDFLARE_REPO="/etc/apt/sources.list.d/cloudflared.list"
readonly AGENT_SKILLS_ARCHIVE="agent-skills-main.zip"
readonly AGENT_SKILLS_MAIN_URL="https://github.com/ShaojieJiang/agent-skills/archive/refs/heads/main.zip"

install_dependencies() {
  sudo apt update
  sudo apt install -y docker.io docker-compose-v2 unzip

  # Enable and start the docker service
  sudo systemctl enable --now docker
}

install_cloudflared() {
  # Add cloudflare gpg key
  sudo mkdir -p --mode=0755 /usr/share/keyrings
  curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | sudo tee "$CLOUDFLARE_KEYRING" >/dev/null

  # Add cloudflared apt repository
  echo "deb [signed-by=${CLOUDFLARE_KEYRING}] https://pkg.cloudflare.com/cloudflared any main" | sudo tee "$CLOUDFLARE_REPO" >/dev/null

  # Refresh package metadata after adding the repository, then install cloudflared
  sudo apt update
  sudo apt install -y cloudflared

  # Install cloudflared as a service
  : "${CLOUDFLARED_TOKEN:?CLOUDFLARED_TOKEN is required}"
  sudo cloudflared service install "$CLOUDFLARED_TOKEN"
}

upsert_bashrc_setting() {
  local key="$1"
  local value="$2"

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
  curl -L -o "$AGENT_SKILLS_ARCHIVE" "$AGENT_SKILLS_MAIN_URL"
  unzip "$AGENT_SKILLS_ARCHIVE"
}

install_uv_and_orcheo_sdk() {
  curl -LsSf https://astral.sh/uv/install.sh | sh
  uv tool install -U orcheo-sdk
}

main() {
  install_dependencies
  install_cloudflared
  download_agent_skills_main
  install_uv_and_orcheo_sdk
  configure_bash_history
}

main "$@"
