#!/usr/bin/env zsh
set -euo pipefail

repo_root=${0:A:h:h}
required=(codex git node npm npx python3 jq rg curl)
recommended=(gh claude uv ffmpeg ffprobe docker pnpm bun agent-browser scrapecreators letsfg mlxfast)
missing_required=()
missing_recommended=()

print 'Required commands:'
for command_name in $required; do
  if command -v "$command_name" >/dev/null 2>&1; then
    print "  ok       $command_name"
  else
    print "  missing  $command_name"
    missing_required+=("$command_name")
  fi
done

print 'Recommended commands:'
for command_name in $recommended; do
  if command -v "$command_name" >/dev/null 2>&1; then
    print "  ok       $command_name"
  else
    print "  optional $command_name"
    missing_recommended+=("$command_name")
  fi
done

print 'Static-key MCP environment:'
for variable_name in AGENTENRICH_API_KEY BLAND_API_KEY CONTEXT_DEV_API_KEY HEROUI_PERSONAL_TOKEN INSTANTLY_API_KEY; do
  if (( ${+parameters[$variable_name]} )) && [[ -n "${(P)variable_name}" ]]; then
    print "  present  $variable_name"
  else
    print "  unset    $variable_name"
  fi
done

if (( ${#missing_required} > 0 )); then
  print -u2 "Missing required commands: ${(j:, :)missing_required}"
  exit 69
fi

plugin_skill_count="$(find "$repo_root/plugins/karim-codex-toolkit/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
explicit_skill_count="$(find "$repo_root/skills/explicit-only" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
print "Bundled skills: $(( plugin_skill_count + explicit_skill_count )) ($plugin_skill_count plugin, $explicit_skill_count explicit-only)"
print "Recommended commands not found: ${#missing_recommended}"
