# Optional Codex add-ons

These are deliberately outside the main installer. They can add real value, but they either change provider routing or inspect additional local/provider state. Review and install each one explicitly.

## OpenCodex

[OpenCodex](https://github.com/lidge-jun/opencodex) is a third-party local proxy and provider-management layer for Codex. This repository records the upstream link and a pinned npm package snapshot; it does not vendor the source.

Install the package without activating it:

```zsh
./addons.zsh info opencodex
./addons.zsh install opencodex
```

The installer runs only `npm install --global @bitkyc08/opencodex@2.28.0`. It never runs `ocx init`, `ocx start`, background-service installation, or the Codex shim. Those operations can change Codex routing or configuration and require separate, explicit authorization. Review each provider's terms before routing an account through a proxy.

OpenCodex also asks users about starring its repository. An agent must never star it or answer that prompt affirmatively without the user's explicit consent.

## CodexBar

[CodexBar](https://github.com/steipete/CodexBar) is an optional macOS menu-bar app and CLI for monitoring coding-provider usage limits and status.

```zsh
./addons.zsh info codexbar
./addons.zsh install codexbar
```

Its Homebrew install is opt-in. Before enabling provider integrations, review which local files, Keychain items, browser cookies, or provider endpoints the selected features may access.

At audit time, Homebrew's cask was `0.53.0` while the upstream GitHub release was `0.54.0`. The manifest records both so recipients can see package-manager lag instead of assuming the cask is the newest upstream build.

## Official additions

The full setup now includes the official Codex Security plugin. It is a better fit than another overlapping agent framework because it contributes a distinct, authorization-gated code-scanning capability.

The canonical Codex source and install instructions remain at [openai/codex](https://github.com/openai/codex). This kit references upstream rather than vendoring Codex itself; `codex` is already a required dependency.

## Considered, not installed

| Project | Decision |
|---|---|
| [oh-my-codex](https://github.com/Yeachan-Heo/oh-my-codex) | Not included by default. Its agents, hooks, workflows, and config merging overlap the 63 bundled skills and Compound Engineering, increasing collision risk. |
| [codex-hud](https://github.com/fwyc0573/codex-hud) | Not included by default. It is mainly a terminal status wrapper, while current Codex releases provide native status-line customization. |
| [OpenCode](https://github.com/anomalyco/opencode) | Not included. It is a separate coding-agent product, not the OpenCodex routing companion. |

List the maintained add-on inventory at any time with:

```zsh
./addons.zsh list
```
