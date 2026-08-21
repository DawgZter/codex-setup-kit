#!/usr/bin/env zsh
set -euo pipefail

repo_root=${0:A:h:h}
plugin_root="$repo_root/plugins/karim-codex-toolkit"
failures=0

check() {
  local label=$1
  shift
  if "$@" >/dev/null; then
    print "ok  $label"
  else
    print -u2 "FAIL  $label"
    failures=$(( failures + 1 ))
  fi
}

check 'plugin manifest JSON' jq -e . "$plugin_root/.codex-plugin/plugin.json"
check 'MCP manifest JSON' jq -e . "$plugin_root/.mcp.json"
check 'marketplace JSON' jq -e . "$repo_root/.agents/plugins/marketplace.json"
check 'CLI manifest JSON' jq -e . "$repo_root/config/cli-manifest.json"
check 'plugin inventory JSON' jq -e . "$repo_root/config/plugin-manifest.json"
check 'marketplace inventory JSON' jq -e . "$repo_root/config/marketplace-manifest.json"
check 'skill inventory JSON' jq -e . "$repo_root/config/skill-manifest.json"

plugin_skill_count="$(find "$plugin_root/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
explicit_skill_count="$(find "$repo_root/skills/explicit-only" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
skill_count=$(( plugin_skill_count + explicit_skill_count ))
if [[ "$plugin_skill_count" == 45 && "$explicit_skill_count" == 18 && "$skill_count" == 63 ]]; then
  print 'ok  63 deduplicated skills (45 plugin, 18 explicit-only)'
else
  print -u2 "FAIL  expected 45 plugin and 18 explicit-only skills; found $plugin_skill_count and $explicit_skill_count"
  failures=$(( failures + 1 ))
fi

manifest_plugin_count="$(jq '.pluginSkills | length' "$repo_root/config/skill-manifest.json")"
manifest_explicit_count="$(jq '.explicitOnlySkills | length' "$repo_root/config/skill-manifest.json")"
if [[ "$manifest_plugin_count" == 45 && "$manifest_explicit_count" == 18 ]]; then
  print 'ok  skill manifest counts'
else
  print -u2 'FAIL  skill manifest counts do not match the repository'
  failures=$(( failures + 1 ))
fi

repo_plugin_names="$(find "$plugin_root/skills" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)"
manifest_plugin_names="$(jq -r '.pluginSkills[]' "$repo_root/config/skill-manifest.json" | sort)"
repo_explicit_names="$(find "$repo_root/skills/explicit-only" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)"
manifest_explicit_names="$(jq -r '.explicitOnlySkills[]' "$repo_root/config/skill-manifest.json" | sort)"
if [[ "$repo_plugin_names" == "$manifest_plugin_names" && "$repo_explicit_names" == "$manifest_explicit_names" ]]; then
  print 'ok  skill manifest names'
else
  print -u2 'FAIL  skill manifest names do not match the repository'
  failures=$(( failures + 1 ))
fi

missing_skill_files="$(find "$plugin_root/skills" "$repo_root/skills/explicit-only" -mindepth 1 -maxdepth 1 -type d ! -exec test -f '{}/SKILL.md' \; -print)"
if [[ -z "$missing_skill_files" ]]; then
  print 'ok  every skill has SKILL.md'
else
  print -u2 'FAIL  skills missing SKILL.md:'
  print -u2 -- "$missing_skill_files"
  failures=$(( failures + 1 ))
fi

if find "$plugin_root/skills" "$repo_root/skills/explicit-only" -mindepth 1 -maxdepth 1 -iname '*webflow*' | grep -q . || jq -e '.mcpServers | has("webflow")' "$plugin_root/.mcp.json" >/dev/null; then
  print -u2 'FAIL  a Webflow integration was found'
  failures=$(( failures + 1 ))
else
  print 'ok  no Webflow MCP or Webflow skill'
fi

if rg -n --hidden --glob '!docs/INTERFACE-AUDIT.md' --glob '!scripts/audit-repo.zsh' '/Users/karimyahia|karimyahia1@gmail\.com|karim@adaptinsurance\.com' "$repo_root"; then
  print -u2 'FAIL  source-machine path or personal identity found'
  failures=$(( failures + 1 ))
else
  print 'ok  no source-machine paths or personal email identities'
fi

secret_pattern='BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{24,}|[?&](token|api[_-]?key|access[_-]?token)=[A-Za-z0-9._~-]{16,}'
if rg -n --hidden --glob '!scripts/audit-repo.zsh' "$secret_pattern" "$repo_root"; then
  print -u2 'FAIL  possible committed secret found'
  failures=$(( failures + 1 ))
else
  print 'ok  no high-confidence secret pattern found'
fi

for script_path in "$repo_root"/**/*.zsh(N); do
  if ! zsh -n "$script_path"; then
    print -u2 "FAIL  zsh syntax: $script_path"
    failures=$(( failures + 1 ))
  fi
done
if (( failures == 0 )); then
  print 'ok  zsh syntax'
fi

validator="${CODEX_HOME:-$HOME/.codex}/skills/.system/plugin-creator/scripts/validate_plugin.py"
if [[ -f "$validator" ]]; then
  if python3 -c 'import yaml' >/dev/null 2>&1; then
    validator_command=(python3 "$validator" "$plugin_root")
  elif command -v uv >/dev/null 2>&1; then
    validator_command=(uv run --quiet --with pyyaml python "$validator" "$plugin_root")
  else
    print -u2 'FAIL  plugin validator requires PyYAML or uv'
    failures=$(( failures + 1 ))
    validator_command=()
  fi
  if (( ${#validator_command} > 0 )) && "${validator_command[@]}"; then
    print 'ok  official plugin validation'
  elif (( ${#validator_command} > 0 )); then
    failures=$(( failures + 1 ))
  fi
else
  print 'skip  official plugin validator is not installed locally'
fi

if (( failures > 0 )); then
  print -u2 "Repository audit failed with $failures issue(s)."
  exit 1
fi
print 'Repository audit passed.'
