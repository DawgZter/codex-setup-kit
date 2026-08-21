# Validation record

Validated on 2026-08-21 with `codex-cli 0.146.0`.

## Source runtime audit

- 21 user-configured MCP entries inspected without copying credentials.
- 12 of those entries initialized with one or more tools in a fresh app-server process.
- 9 returned zero tools because they were disabled, logged out, lacked static authentication, or failed to initialize.
- Webflow was absent from the live MCP configuration and active user skill roots.

## Repository validation

- Official `plugin-creator` validation: passed.
- JSON manifests: passed.
- Zsh syntax: passed.
- Skill inventory: 45 plugin-compatible plus 18 explicit-only, 63 total.
- Duplicate skill names: resolved to one copy.
- Webflow MCP and named Webflow skill scan: passed absent.
- Source-machine absolute path and personal-email scan: passed absent.
- High-confidence secret-pattern scan: passed absent.

The generic Agent Skills validator also ran. All plugin skills passed except `reui`, which intentionally retains Codex's supported `user-invocable: false` extension. The current Codex plugin validator accepts that field. The 18 explicit-only skills intentionally retain `disable-model-invocation: true` and are therefore validated and installed as local Codex skills rather than plugin skills.

## Isolated install test

Using a fresh temporary `CODEX_HOME`:

- Marketplace registration: passed.
- Plugin installation: passed.
- Explicit-only skill installation: 18 of 18.
- Fresh app-server recognition: all 17 exported MCP definitions were listed.
- MCPs exposing tools before recipient-specific authentication: Claude Code, Context7, Context.dev, Exa, Fathom, Fibbler, LetsFG, and OpenAI developer docs.
- Expected unauthenticated/static-key services returned zero tools or `notLoggedIn` without breaking the plugin.
- External Compound Engineering marketplace installation: passed.

App-bundled and OpenAI-curated plugins are not exposed inside an empty CLI-only temporary `CODEX_HOME`; the full installer reports them as unavailable and continues. They are available in a normal Codex Desktop profile, which was the source environment used for the inventory.

## Remaining recipient checks

Authenticated correctness cannot be transferred. After the recipient signs in, verify `tools/list` and one harmless read-only call per service in a fresh task.
