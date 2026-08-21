#!/usr/bin/env zsh
set -euo pipefail
umask 077

for command_name in claude npx mktemp; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    print -u2 "Required command not found: $command_name"
    exit 69
  fi
done

state_dir="$(mktemp -d "${TMPDIR:-/tmp}/shared-claude-code-mcp.XXXXXX")"
export CLAUDE_CODE_MCP_STATE_DIR="$state_dir"
export CLAUDE_CODE_MCP_PATH="$(command -v claude)"

# The bridge should use the recipient's Claude subscription login, not ambient
# API-provider overrides from an unrelated shell.
unset ANTHROPIC_API_KEY ANTHROPIC_AUTH_TOKEN ANTHROPIC_BASE_URL
unset CLAUDE_CODE_USE_BEDROCK CLAUDE_CODE_USE_VERTEX
unset CLAUDE_CODE_USE_FOUNDRY CLAUDE_CODE_USE_MANTLE

exec npx -y @leo000001/claude-code-mcp@2.8.11
