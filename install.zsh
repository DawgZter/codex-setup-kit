#!/usr/bin/env zsh
set -euo pipefail

repo_root=${0:A:h}
mode=check
full=false

usage() {
  print 'Usage: ./install.zsh [--check | --apply] [--full]'
  print '  --check  Read-only dependency and installation report (default).'
  print '  --apply  Add this marketplace and install its plugin.'
  print '  --full   With --apply, also install supported official plugins.'
}

while (( $# > 0 )); do
  case "$1" in
    --check) mode=check ;;
    --apply) mode=apply ;;
    --full) full=true ;;
    -h|--help) usage; exit 0 ;;
    *) print -u2 "Unknown option: $1"; usage >&2; exit 64 ;;
  esac
  shift
done

print "Setup repository: $repo_root"
"$repo_root/scripts/preflight.zsh"

if [[ "$mode" == check ]]; then
  print ''
  print 'Read-only check complete. Planned install:'
  print '  1. Add this repository as marketplace karim-codex-setup.'
  print '  2. Install karim-codex-toolkit@karim-codex-setup.'
  print '  3. Install 18 explicit-only skills without replacing conflicts.'
  if $full; then
    print '  4. Install missing plugins from config/plugin-manifest.json.'
  else
    print '  4. Leave official plugins unchanged (pass --full to include them).'
  fi
  print 'No files or configuration were changed.'
  exit 0
fi

marketplaces_json="$(codex plugin marketplace list --json)"
existing_root="$(print -r -- "$marketplaces_json" | jq -r '.marketplaces[] | select(.name == "karim-codex-setup") | .root' | head -1)"

if [[ -n "$existing_root" ]]; then
  if [[ "${existing_root:A}" != "${repo_root:A}" ]]; then
    print -u2 'Marketplace name karim-codex-setup already points elsewhere:'
    print -u2 "  $existing_root"
    print -u2 'Remove or rename that marketplace explicitly before retrying.'
    exit 73
  fi
  print 'Marketplace already registered at this repository.'
else
  codex plugin marketplace add "$repo_root" --json >/dev/null
  print 'Registered marketplace karim-codex-setup.'
fi

plugins_json="$(codex plugin list --available --json)"
if print -r -- "$plugins_json" | jq -e '.installed[] | select(.pluginId == "karim-codex-toolkit@karim-codex-setup")' >/dev/null; then
  print 'Plugin karim-codex-toolkit is already installed.'
else
  codex plugin add karim-codex-toolkit@karim-codex-setup --json >/dev/null
  print 'Installed karim-codex-toolkit.'
fi

codex_home=${CODEX_HOME:-$HOME/.codex}
explicit_destination="$codex_home/skills"
mkdir -p "$explicit_destination"
explicit_conflicts=0
while IFS= read -r skill_name; do
  source_dir="$repo_root/skills/explicit-only/$skill_name"
  destination_dir="$explicit_destination/$skill_name"
  if [[ ! -e "$destination_dir" ]]; then
    cp -R "$source_dir" "$destination_dir"
    print "Installed explicit-only skill: $skill_name"
  elif diff -qr "$source_dir" "$destination_dir" >/dev/null 2>&1; then
    print "Explicit-only skill already current: $skill_name"
  else
    print -u2 "Skipped conflicting existing skill: $destination_dir"
    explicit_conflicts=$(( explicit_conflicts + 1 ))
  fi
done < "$repo_root/config/explicit-skills.txt"

if $full; then
  while IFS=$'\t' read -r marketplace_name marketplace_source; do
    marketplaces_json="$(codex plugin marketplace list --json)"
    if print -r -- "$marketplaces_json" | jq -e --arg name "$marketplace_name" '.marketplaces[] | select(.name == $name)' >/dev/null; then
      print "Marketplace already available: $marketplace_name"
      continue
    fi
    if codex plugin marketplace add "$marketplace_source" --json >/dev/null; then
      print "Added marketplace: $marketplace_name"
    else
      print -u2 "Could not add marketplace: $marketplace_name"
    fi
  done < <(jq -r '.external[] | [.name, .source] | @tsv' "$repo_root/config/marketplace-manifest.json")

  while IFS= read -r plugin_id; do
    plugins_json="$(codex plugin list --available --json)"
    if print -r -- "$plugins_json" | jq -e --arg id "$plugin_id" '.installed[] | select(.pluginId == $id)' >/dev/null; then
      print "Already installed: $plugin_id"
      continue
    fi
    if ! print -r -- "$plugins_json" | jq -e --arg id "$plugin_id" '.available[] | select(.pluginId == $id)' >/dev/null; then
      print -u2 "Not available in this Codex installation: $plugin_id"
      continue
    fi
    if codex plugin add "$plugin_id" --json >/dev/null; then
      print "Installed: $plugin_id"
    else
      print -u2 "Could not install: $plugin_id"
    fi
  done < <(jq -r '.install[].id' "$repo_root/config/plugin-manifest.json")
fi

print ''
print 'Installation complete. No credentials were written.'
if (( explicit_conflicts > 0 )); then
  print -u2 "$explicit_conflicts explicit-only skill conflict(s) were left unchanged."
fi
print 'Restart Codex, open a fresh task, and authenticate services on first use.'
print 'Static-key variable names are listed in config/env.example.'
