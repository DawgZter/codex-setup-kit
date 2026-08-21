#!/usr/bin/env node

import fs from "node:fs/promises";
import path from "node:path";

function parseArgs(argv) {
  const args = {};
  for (let i = 2; i < argv.length; i += 1) {
    const arg = argv[i];
    if (!arg.startsWith("--")) continue;
    const key = arg.slice(2);
    const next = argv[i + 1];
    if (!next || next.startsWith("--")) {
      args[key] = true;
    } else {
      args[key] = next;
      i += 1;
    }
  }
  return args;
}

function usage() {
  return `Usage:
node export-nooks-transcripts.mjs --url <nooks-call-library-url> --headers <headers.json> --out <output-prefix>

Options:
  --url       Nooks call-library URL containing /workspaces/{id}/call-library
  --headers   JSON file with x-nooks-auth-token and x-nooks-user-id
  --out       Output prefix or directory. Default: ./nooks-transcripts
  --max-date  Override maxDate ISO. Default: now
  --min-date  Override minDate ISO. Default: startDate URL param or 2000-01-01
`;
}

function cleanText(value) {
  return String(value ?? "").replace(/\s+/g, " ").trim();
}

function formatSeconds(seconds) {
  if (seconds == null || Number.isNaN(Number(seconds))) return "";
  const total = Math.max(0, Math.floor(Number(seconds)));
  const hours = Math.floor(total / 3600);
  const minutes = Math.floor((total % 3600) / 60);
  const secs = total % 60;
  return hours
    ? `${hours}:${String(minutes).padStart(2, "0")}:${String(secs).padStart(2, "0")}`
    : `${minutes}:${String(secs).padStart(2, "0")}`;
}

function parseWorkspaceId(url) {
  const match = url.pathname.match(/\/workspaces\/([^/]+)/);
  if (!match) throw new Error("Could not parse workspace id from URL");
  return match[1];
}

function parseDispositionIds(url) {
  const raw = url.searchParams.get("dispositions");
  if (!raw) return [];
  return raw.split(",").map((id) => id.trim()).filter(Boolean);
}

async function readHeaders(args) {
  if (args.headers) {
    return JSON.parse(await fs.readFile(args.headers, "utf8"));
  }
  if (process.env.NOOKS_AUTH_TOKEN && process.env.NOOKS_USER_ID) {
    return {
      "x-nooks-auth-token": process.env.NOOKS_AUTH_TOKEN,
      "x-nooks-user-id": process.env.NOOKS_USER_ID,
    };
  }
  throw new Error("Provide --headers or set NOOKS_AUTH_TOKEN and NOOKS_USER_ID");
}

async function requestJson(url, options) {
  const response = await fetch(url, options);
  const text = await response.text();
  let body;
  try {
    body = JSON.parse(text);
  } catch {
    body = { rawText: text.slice(0, 1000) };
  }
  if (!response.ok) {
    throw new Error(`Nooks request failed ${response.status}: ${JSON.stringify(body).slice(0, 500)}`);
  }
  return body?.data && typeof body.data === "object" ? body.data : body;
}

function callerName(call) {
  if (!call?.caller) return "Rep";
  if (typeof call.caller === "string") return call.caller;
  return call.caller.name || call.caller.email || "Rep";
}

function normalizeCall(call) {
  const rep = callerName(call);
  const prospect = call.prospectName || "Prospect";
  const segments = (Array.isArray(call.monologues) ? call.monologues : [])
    .slice()
    .sort((a, b) => Number(a.start ?? a.index ?? 0) - Number(b.start ?? b.index ?? 0))
    .map((monologue) => {
      const text = cleanText(monologue.textContent ?? monologue.text ?? monologue.content ?? monologue.transcript);
      return {
        speaker: monologue.isUser ? rep : prospect,
        isRep: Boolean(monologue.isUser),
        start: formatSeconds(monologue.start),
        startSeconds: monologue.start ?? null,
        end: formatSeconds(monologue.end),
        endSeconds: monologue.end ?? null,
        text,
      };
    })
    .filter((segment) => segment.text);

  return {
    id: call.id,
    time: call.time ?? null,
    duration: call.duration ?? null,
    prospectName: call.prospectName ?? null,
    prospectTitle: call.prospectTitle ?? null,
    companyName: call.companyName ?? null,
    caller: rep,
    callerEmail: typeof call.caller === "object" && call.caller ? call.caller.email ?? null : null,
    disposition: call.disposition?.name ?? call.dispositionName ?? null,
    sentiment: call.sentiment?.name ?? null,
    note: call.note ?? null,
    transcriptSegmentCount: segments.length,
    transcriptTextChars: segments.reduce((sum, segment) => sum + segment.text.length, 0),
    fullTranscript: segments.map((segment) => `[${segment.start}] ${segment.speaker}: ${segment.text}`).join("\n"),
    transcriptSegments: segments,
  };
}

function csvEscape(value) {
  if (value == null) return "";
  const text = String(value);
  return /[",\n\r]/.test(text) ? `"${text.replace(/"/g, '""')}"` : text;
}

async function main() {
  const args = parseArgs(process.argv);
  if (!args.url || args.help) {
    console.error(usage());
    process.exit(args.help ? 0 : 1);
  }

  const callLibraryUrl = new URL(args.url);
  const workspaceId = parseWorkspaceId(callLibraryUrl);
  const headers = await readHeaders(args);
  const dispositionIds = parseDispositionIds(callLibraryUrl);
  const minDuration = Number(callLibraryUrl.searchParams.get("minDuration") || 0);
  const minDate = args["min-date"] || callLibraryUrl.searchParams.get("startDate") || "2000-01-01T00:00:00.000Z";
  let maxDate = args["max-date"] || new Date().toISOString();
  const out = args.out || "./nooks-transcripts";
  const listEndpoint = `https://api.nooks.in/calls/workspace/${workspaceId}/calls/find/v2`;
  const listHeaders = {
    ...headers,
    accept: "application/json, text/plain, */*",
    "content-type": "application/json",
  };

  const calls = [];
  const seen = new Set();
  let expectedTotal = null;
  const pages = [];

  for (let page = 0; page < 50; page += 1) {
    const requestBody = {
      includePersonas: true,
      minDate,
      maxDate,
      minDuration,
      limit: 50,
      hasTranscript: true,
    };
    if (dispositionIds.length) requestBody.dispositionIds = dispositionIds;

    const body = await requestJson(listEndpoint, {
      method: "POST",
      headers: listHeaders,
      body: JSON.stringify(requestBody),
    });

    const pageCalls = Array.isArray(body.calls) ? body.calls : [];
    if (expectedTotal == null) expectedTotal = body.totalCount ?? null;
    pages.push({ page, maxDate, returned: pageCalls.length, totalCount: body.totalCount ?? null });

    for (const call of pageCalls) {
      if (call.id && !seen.has(call.id)) {
        calls.push(call);
        seen.add(call.id);
      }
    }

    if (!pageCalls.length || (expectedTotal != null && calls.length >= expectedTotal)) break;
    const oldest = pageCalls.map((call) => Date.parse(call.time)).filter(Number.isFinite).sort((a, b) => a - b)[0];
    if (!oldest) break;
    maxDate = new Date(oldest - 1).toISOString();
  }

  const detailed = [];
  for (const call of calls) {
    if (Array.isArray(call.monologues) && call.monologues.length) {
      detailed.push(call);
      continue;
    }
    const detail = await requestJson(`https://api.nooks.in/calls/workspace/${workspaceId}/call/${encodeURIComponent(call.id)}`, {
      headers: { ...headers, accept: "application/json, text/plain, */*" },
    });
    detailed.push(detail);
  }

  const records = detailed.map(normalizeCall);
  const totals = {
    calls: records.length,
    expectedTotal,
    callsWithTranscript: records.filter((record) => record.transcriptSegmentCount > 0).length,
    transcriptSegments: records.reduce((sum, record) => sum + record.transcriptSegmentCount, 0),
    transcriptTextChars: records.reduce((sum, record) => sum + record.transcriptTextChars, 0),
  };

  const payload = {
    scrapedAt: new Date().toISOString(),
    request: { workspaceId, sourceUrl: args.url, listEndpoint, minDate, minDuration, dispositionIds },
    pages,
    totals,
    calls: records,
  };

  const outPath = path.resolve(out);
  const base = outPath.endsWith(".json") ? outPath.slice(0, -5) : outPath;
  await fs.mkdir(path.dirname(base), { recursive: true });

  const jsonPath = `${base}.json`;
  const csvPath = `${base}.csv`;
  const mdPath = `${base}.md`;

  await fs.writeFile(jsonPath, JSON.stringify(payload, null, 2), "utf8");

  const csvFields = ["id", "time", "duration", "prospectName", "prospectTitle", "companyName", "caller", "disposition", "transcriptSegmentCount", "transcriptTextChars", "fullTranscript"];
  const csv = [csvFields.join(","), ...records.map((record) => csvFields.map((field) => csvEscape(record[field])).join(","))].join("\n") + "\n";
  await fs.writeFile(csvPath, csv, "utf8");

  const md = [
    "# Nooks Call Transcripts",
    "",
    `Calls: ${totals.calls}`,
    `Transcript segments: ${totals.transcriptSegments}`,
    `Transcript text chars: ${totals.transcriptTextChars}`,
    "",
    ...records.map((record, index) => [
      `## ${index + 1}. ${[record.prospectName, record.companyName].filter(Boolean).join(" - ") || record.id}`,
      "",
      `- Call ID: ${record.id}`,
      `- Time: ${record.time || ""}`,
      `- Duration: ${record.duration ?? ""} seconds`,
      `- Caller: ${record.caller || ""}`,
      `- Disposition: ${record.disposition || ""}`,
      "",
      "```text",
      record.fullTranscript,
      "```",
      "",
    ].join("\n")),
  ].join("\n");
  await fs.writeFile(mdPath, md, "utf8");

  console.log(JSON.stringify({ jsonPath, csvPath, mdPath, totals }, null, 2));
}

main().catch((error) => {
  console.error(error.message || error);
  process.exit(1);
});
