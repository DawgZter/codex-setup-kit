---
name: scrape-nooks-call-transcripts
description: Scrape and export authenticated Nooks call-library transcripts. Use when the user asks to scrape, download, analyze, summarize, benchmark, or model sales behavior from Nooks call transcripts, Nooks call-library URLs, booked calls, dispositions, call IDs, or full speaker-labeled Nooks transcripts.
---

# Scrape Nooks Call Transcripts

## Overview

Use the Nooks API directly instead of clicking through the Call Library UI. The historical call transcript is in each call object's `monologues` array.

Never store auth tokens in the skill. Capture fresh auth headers from the user's logged-in Chrome profile when needed, or accept them from user-provided environment variables/temp files.

## Workflow

1. Use Chrome control when the task depends on the user's logged-in Nooks session.
2. Open or claim the Nooks call-library URL in the correct Chrome profile.
3. Capture one `https://api.nooks.in/...` request and extract only the headers needed for API calls:
   - `x-nooks-auth-token`
   - `x-nooks-user-id`
4. Parse the workspace ID from `/workspaces/{workspaceId}/...`.
5. Query:

```text
POST https://api.nooks.in/calls/workspace/{workspaceId}/calls/find/v2
```

6. Export full transcripts from `calls[].monologues`. If a listed call lacks `monologues`, fetch:

```text
GET https://api.nooks.in/calls/workspace/{workspaceId}/call/{callId}
```

7. Save machine-readable JSON first. Add Markdown or CSV when the user wants readable review or spreadsheet import.

## List Request Notes

Common request body fields:

```json
{
  "includePersonas": true,
  "minDate": "2025-09-01T07:00:00.000Z",
  "maxDate": "2026-07-02T06:59:59.999Z",
  "minDuration": 60,
  "limit": 50,
  "dispositionIds": ["..."],
  "hasTranscript": true
}
```

Pagination is date-window based, not ordinary `offset`/`page`. To fetch the next batch, set `maxDate` to one millisecond before the oldest `calls[].time` returned so far. Continue until no new calls return or the expected `totalCount` is reached. The endpoint may report a smaller `totalCount` after `maxDate` moves; preserve the first total as the target.

For booked-call pages, use the exact disposition IDs from the URL query parameter `dispositions=...`. Split the comma- or `%2C`-separated values into `dispositionIds`.

## Script

Use `scripts/export-nooks-transcripts.mjs` for repeatable exports.

Example:

```zsh
cd <path-to-this-skill>
node scripts/export-nooks-transcripts.mjs \
  --url 'https://app.nooks.in/workspaces/w9P9s5i4KgiRtGTm/call-library?dispositions=id1%2Cid2&minDuration=60&startDate=2025-09-01T07%3A00%3A00.000Z' \
  --headers /tmp/nooks-headers.json \
  --out ./outputs/nooks-booked-calls
```

`--headers` must point to JSON like:

```json
{
  "x-nooks-auth-token": "...",
  "x-nooks-user-id": "..."
}
```

Alternatively set `NOOKS_AUTH_TOKEN` and `NOOKS_USER_ID`.

## Chrome Header Capture Pattern

After reading the Chrome control skill and initializing the Chrome runtime, use CDP to capture headers from a real Nooks API request. Keep tokens in memory or a temporary local file only.

```js
globalThis.cdp = await tab.capabilities.get("cdp");
await cdp.send("Network.enable", { maxPostDataSize: 65536 });
const before = await cdp.readEvents({ methods: ["Network.requestWillBeSent"], limit: 1, timeoutMs: 1000 }).catch(() => ({ cursor: 0 }));
await tab.reload();
await tab.playwright.waitForLoadState({ state: "networkidle", timeoutMs: 30000 }).catch(() => {});
await tab.playwright.waitForTimeout(3000);

let events = [];
let cursor = before.cursor;
for (let i = 0; i < 8; i++) {
  const batch = await cdp.readEvents({ afterSequence: cursor, methods: ["Network.requestWillBeSent"], limit: 1000, timeoutMs: 1000 }).catch(() => ({ cursor, events: [], hasMore: false }));
  events.push(...batch.events);
  cursor = batch.cursor;
  if (!batch.hasMore) break;
}

const req = events.map((e) => e.params?.request).find((r) =>
  r?.url?.includes("https://api.nooks.in/") &&
  r.headers &&
  (r.headers["x-nooks-auth-token"] || r.headers["X-Nooks-Auth-Token"])
);

globalThis.nooksHeaders = {
  "x-nooks-auth-token": req.headers["x-nooks-auth-token"] || req.headers["X-Nooks-Auth-Token"],
  "x-nooks-user-id": req.headers["x-nooks-user-id"] || req.headers["X-Nooks-User-Id"]
};
```

## Output Shape

Prefer this normalized record shape:

```json
{
  "id": "call-id",
  "time": "ISO timestamp",
  "duration": 513,
  "prospectName": "Name",
  "prospectTitle": "Title",
  "companyName": "Company",
  "caller": "Rep Name",
  "disposition": "Meeting",
  "transcriptSegmentCount": 55,
  "transcriptTextChars": 7723,
  "fullTranscript": "[0:03] Prospect: ...",
  "transcriptSegments": [
    { "speaker": "Rep Name", "isRep": true, "start": "0:10", "text": "..." }
  ]
}
```

## Safety

- Do not print raw auth tokens.
- Do not commit exported transcripts unless the user explicitly asks.
- Treat transcript contents as private business data. Summarize patterns unless the user asks for specific excerpts.
- Finalize Chrome tabs after scraping unless the page is a handoff.
