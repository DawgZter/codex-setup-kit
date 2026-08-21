---
name: research
description: 'Explicit-only primary-source research workflow. Invoke with `$research` to investigate a question against high-trust primary sources through a background agent and capture the findings as a Markdown file in the repository. Do not auto-trigger for ordinary research requests.'
disable-model-invocation: true
---

Spin up a **background agent** to do the research, so you keep working while it reads.

Its job:

1. Investigate the question against **primary sources** — official docs, source code, specs, first-party APIs — not a secondary write-up of them. Follow every claim back to the source that owns it.
2. Write the findings to a single Markdown file, citing each claim's source.
3. Save it where the repo already keeps such notes; match the existing convention, and if there is none, put it somewhere sensible and say where.
