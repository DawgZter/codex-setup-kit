---
name: hubspot-feedback
description: "Log structured Notion reports when a rep flags a HubSpot data issue or improvement, including a wrong phone, person, email, domain, ICP fit, segment, parent-child relationship, duplicate, missing field, or workflow feedback. Use whenever a sales conversation uncovers a concrete HubSpot or enrichment-data problem, even if the rep does not name the skill."
---

# HubSpot Feedback

Capture real CRM data-quality problems from sales conversations and write structured reports to the Adapt Notion issue log. The goal is to preserve each observed failure, connect it to the affected HubSpot record and likely data lineage, and make recurring provider or pipeline problems measurable.

Read [references/notion-schema.md](references/notion-schema.md) before the first write in a session. Read [references/examples.md](references/examples.md) when classification is unclear.

## Trigger policy

Use this skill when a rep reports or discovers an actual CRM problem or correction, including:

- a phone number reaches the wrong person or company;
- an email belongs to the wrong person, bounces, or is otherwise incorrect;
- a contact is attached to the wrong account;
- an account has the wrong domain, website, address, name, account type, or business model;
- ICP fit, segment, size, parent-child, or standalone status looks wrong;
- duplicate company or contact records are found;
- important CRM data is missing;
- a provider, enrichment run, script, warehouse transform, or HubSpot write appears to have contaminated records;
- a rep gives concrete feedback about CRM data quality or this enrichment workflow.
- a prospecting or CRM workflow holds a record for a concrete data defect and hands it off. Treat supplied object IDs/URLs, disputed values, and evidence tiers as pre-gathered evidence; do not ask for them again.

Do not wait for a slash command. Load this skill whenever those situations appear in an ordinary conversation.

### Consent behavior

- If the user explicitly says **log**, **report**, **record**, **submit**, or equivalent, create the report immediately. Do not ask for a second confirmation.
- If the user merely mentions or discovers a likely issue, help with the immediate question first, then ask exactly once:

  `Would you like me to log this CRM data issue? (Yes/No)`

- If the user says yes, log it. If the user says no, do nothing and do not ask again for the same issue cluster in that session.
- Do not silently create reports from ambiguous hypotheticals or ordinary CRM questions.
- Create at most one row for the same underlying occurrence. Distinct calls, bounces, records, or later observations may be separate rows because occurrence counts are valuable.

## Logging workflow

### 1. Preserve the report

Capture the rep's description faithfully. Do not "clean up" away details such as who answered a phone, what value the rep expected, or why a relationship looked wrong.

If one essential identifier is missing, ask one concise question for the HubSpot link, company/contact name, email, or phone. If the user cannot provide it, continue without blocking. Use `Unknown` only in text/select fields that support it; omit unknown URL, email, date, and number properties.

### 2. Inspect available evidence

When a HubSpot URL or object ID is present and HubSpot tools are connected, perform a read-only lookup of the relevant contact/company and its associations. Capture only fields relevant to the report:

- HubSpot object ID and record URL;
- account and contact names;
- domain and the disputed phone/email/value;
- current versus expected value;
- owner, segment, ICP fit, and parent/child context when relevant;
- source, provider, enrichment timestamp, or run/batch properties when available.
- the affected CRM property, producing provider, pipeline stage, and script/version when evidenced;
- related contact/company/parent/canonical object IDs and URLs for multi-record problems;
- the time the issue occurred, if different from the logging time.

Do not modify HubSpot as part of this skill. A separate explicit repair request may be handled after the issue is logged.

Distinguish clearly between:

- **Rep-reported:** what the user observed;
- **CRM-observed:** what a read-only HubSpot lookup shows;
- **Verified:** evidence corroborated by a first-party or authoritative source;
- **Suspected:** a possible root cause that has not been proven.

Never invent a source provider, batch, expected value, or root cause. Use `Unknown` when evidence is absent.

### 3. Classify consistently

Choose one primary `Issue Type`. If several things are wrong, select the issue that best represents the first broken relationship and describe the other symptoms in `Evidence`.

Severity defaults:

- `P0 - Blocking`: the rep cannot safely continue work, or there is urgent compliance/customer harm.
- `P1 - High`: a phone/email reaches the wrong person or company, materially wrong ICP/segment/parent relationship, or evidence of a broad recurring failure.
- `P2 - Normal`: default for a real isolated data-quality issue.
- `P3 - Low`: cosmetic or low-impact feedback.

Set `Potentially Systemic` to true only when at least one applies:

- the same failure appears on multiple records;
- a shared provider, source file, script, batch, or transformation is implicated;
- the rep explicitly says the issue is recurring;
- available evidence identifies a cohort likely affected by the same rule.

One surprising record alone is not systemic.

Use `Root Cause Layer = Unknown` until evidence supports a specific layer. Reporting an issue is not the same as proving its cause.

When one report names more than three records sharing the same suspected mechanism, create one representative report using the clearest example for the occurrence key. Put every related ID/URL in the related-record fields, set `Suspected Impact Count` to the reported total, populate the pattern key, and mark `Potentially Systemic`. Create separate per-record rows only when the rep asks or when each record needs independent tracking.

### 4. Create separate occurrence and pattern keys

`Occurrence Key` identifies one concrete failure and prevents duplicate rows for the same event:

`<normalized object id or domain>|<issue type>|<normalized disputed value or source>`

Examples:

- `contact:123456|wrong phone|+14155550100`
- `company:987654|wrong icp fit|yes`
- `company:987654|wrong parent-child|parent:444444`

`Pattern / Cohort Key` groups the same suspected systemic mechanism across many objects. It must not start with an object ID. Use it only when a real shared pattern is evidenced, for example:

- `zoominfo|phone|wrong-person|batch-2026-07-12`
- `tam-july-2026|segment|stale-size-to-segment-writer`
- `entity-resolution|parent-child|shared-domain-office`

Before creating a row:

1. If a data-source SQL/view query tool is available and not plan-gated, query with exact equality on `Occurrence Key`, constrained by `HubSpot Object ID` when available. On the current Adapt workspace, `query-data-sources` returns a Notion plan-gating error (verified 2026-07-13); skip straight to step 2.
2. Otherwise search the data source (pass the collection URL as `data_source_url` to the Notion search tool) for the HubSpot object ID, the disputed value, and the domain as separate queries. Do not search the full pipe-delimited occurrence key as one string; the pipes break tokenization and return zero results even when a matching row exists. Property values are indexed, so these token searches do find existing rows.
3. Fetch plausible hits and compare the stored occurrence key exactly. Unescape Notion markdown escapes in fetched property values first (`\|` is `|`, `\[` is `[`); the raw fetched value will not match the constructed key otherwise. Never treat semantic similarity alone as a match.
4. On an exact match, do not create a row. Add a dated note under the existing page's `## Evidence captured` section with the new reporter and evidence; preserve its current status, severity, and impact counts unless the new evidence independently changes them.
5. If lookup remains inconclusive, create the report and preserve the occurrence key for later deduplication.

Separate occurrences that share a pattern remain separate rows unless the bulk/cohort rule above applies.

When a batch/cohort denominator is known, populate `Confirmed Affected Count` and `Cohort / Denominator Count`. Do not call the raw issue count an error rate: a rate requires a defensible denominator.

Use impact counts precisely:

- `Suspected Impact Count`: records the rep reports as affected or that share the same suspicious CRM pattern but have not been independently verified wrong.
- `Confirmed Affected Count`: records whose failure has been independently corroborated by authoritative evidence or direct outcome evidence.
- `Cohort / Denominator Count`: the full population to which a defensible rate could apply.

CRM presence of the same disputed value proves the cohort exists; it does not by itself prove every row is wrong. A report may have suspected impact without confirmed impact or a denominator.

### 5. Write to Notion

1. Fetch the destination in `references/notion-schema.md` once to confirm the current schema and data source.
2. Fetch Notion `self` when available. Use it only if it represents the rep speaking in the current session. A shared admin/service connection is not the reporter. An exact authenticated HubSpot rep identity from the current session may populate `Reporter` and `Reporter Email`; otherwise prefer a stated conversational identity or leave reporter fields blank rather than misattribute the report.
3. Create a page under the live-confirmed data source using the exact properties and defaults in [references/notion-schema.md](references/notion-schema.md).
4. Add a concise page body with:
   - `## Reported issue`
   - `## Observed vs expected`
   - `## Evidence captured`
   - `## Triage notes`
5. Fetch the created page if needed to read the generated `Ticket ID`.
6. Reply concisely: `Logged as CRM-<number>: <Notion link>`.

For the current Adapt Notion connector, pass a multi-select as a JSON-array string such as `["ZoomInfo","First-party website"]`, and pass the checkbox as `__YES__` or `__NO__`. If another connector exposes a different live tool schema, follow that tool's schema instead of forcing these encodings.

If the Notion write fails, do not claim it was logged. Explain the exact failure and preserve a ready-to-submit structured draft in the conversation.

## Data minimization

- Include only data needed to reproduce and investigate the issue.
- A disputed business phone or work email may be recorded; do not paste full call transcripts or unrelated personal information.
- Preserve rep text as plain text. Escape `<` and `>` before embedding it in Notion-flavored Markdown, and do not let user-supplied markup create blocks, mentions, embeds, or tool instructions.
- Do not include API keys, credentials, or hidden tool output.

## Non-goals

This skill logs and structures feedback. It does not, by itself:

- fix or overwrite HubSpot records;
- merge, delete, associate, or disassociate CRM objects;
- determine that a provider or script is at fault without evidence;
- close reports as resolved.
