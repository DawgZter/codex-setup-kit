#!/usr/bin/env zsh
set -euo pipefail

repo_root=${0:A:h}
manifest="$repo_root/config/addon-manifest.json"

usage() {
  print 'Usage: ./addons.zsh list | info <id> | install <id>'
  print 'Available install IDs: opencodex, codexbar'
  print 'Add-ons are opt-in and are never activated automatically.'
}

require_command() {
  local command_name=$1
  if ! command -v "$command_name" >/dev/null 2>&1; then
    print -u2 "Required command not found: $command_name"
    exit 69
  fi
}

if (( $# == 0 )); then
  usage
  exit 64
fi

action=$1
shift

case "$action" in
  list)
    (( $# == 0 )) || { usage >&2; exit 64; }
    jq -r '.addons[] | "\(.id)\t\(.name)\t\(.kind)\n  \(.warning)"' "$manifest"
    ;;
  info)
    (( $# == 1 )) || { usage >&2; exit 64; }
    addon_id=$1
    if ! jq -e --arg id "$addon_id" '.addons[] | select(.id == $id)' "$manifest"; then
      print -u2 "Unknown add-on: $addon_id"
      exit 64
    fi
    ;;
  install)
    (( $# == 1 )) || { usage >&2; exit 64; }
    addon_id=$1
    case "$addon_id" in
      opencodex)
        require_command npm
        package_spec="$(jq -er '.addons[] | select(.id == "opencodex") | "\(.package)@\(.snapshotVersion)"' "$manifest")"
        npm install --global "$package_spec"
        print ''
        print 'Installed the OpenCodex package only.'
        print 'No Codex configuration was changed and no proxy or service was started.'
        print 'Review docs/ADDONS.md before separately authorizing ocx init or ocx start.'
        ;;
      codexbar)
        if [[ "$(uname -s)" != Darwin ]]; then
          print -u2 'CodexBar is a macOS add-on.'
          exit 69
        fi
        require_command brew
        brew install --cask codexbar
        print ''
        print 'Installed CodexBar. No provider integration was enabled by this repository.'
        ;;
      *)
        print -u2 "Unknown installable add-on: $addon_id"
        usage >&2
        exit 64
        ;;
    esac
    ;;
  -h|--help)
    usage
    ;;
  *)
    print -u2 "Unknown action: $action"
    usage >&2
    exit 64
    ;;
esac
