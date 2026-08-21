---
name: prospecting-assistant
description: Build rep-relevant HubSpot prospecting queues; surface due work and untouched accounts or contacts by owner, segment, and persona; detect prior outreach from Nooks calls, emails, meetings, tasks, and sequences; and guide safe enrollment into a current HubSpot sequence. Use when a sales rep asks what to work or call next, wants relevant accounts or contacts, asks for untouched or unworked prospects, wants a call or sequence list, or wants to sequence surfaced HubSpot contacts.
---

# Prospecting assistant

Build a current, rep-specific prospecting queue from HubSpot. Keep discovery read-only. Treat sequence enrollment and ownership changes as separate, confirmed actions.

Read the supporting references when needed:

- Read [references/rep-routing.md](references/rep-routing.md) before resolving the rep, segment, ownership lane, or shared unassigned pool.
- Read [references/hubspot-fields.md](references/hubspot-fields.md) before searching HubSpot or classifying outreach and validation state.
- Read [references/operating-motion.md](references/operating-motion.md) before choosing how many contacts to surface or how to treat HubSpot tasks and Nooks calls for a segment.
- Read [references/sequencing.md](references/sequencing.md) before proposing or performing any ownership change or sequence enrollment.

## 1. Resolve the rep

1. Call the HubSpot user-details tool first and verify read/write availability. If no HubSpot connector is available, stop and ask the rep to connect HubSpot; do not substitute Apollo or stale exports.
2. Preserve the authenticated HubSpot `userId`, `ownerId`, and work email separately. Match the invoking user by exact values. Never infer a rep from a fuzzy name match or substitute an owner ID where a sequence actor user ID is required.
3. If the authenticated user is not one of the configured reps, ask whose queue to build.
4. Apply every extra constraint in the prompt—geography, persona, named accounts, count, date, product interest, or other context—as a ranking or filter after the hard routing and suppression rules.

If the rep asks to inspect another rep's queue, keep that view read-only. Ownership claims and sequence enrollment may act only as the authenticated rep, never on behalf of the viewed rep.

Interpret the request before searching:

- If the rep asks what to call or work **today**, show their own due and overdue HubSpot tasks first, including sequence-generated call tasks expected to sync to Nooks. This is the current committed queue.
- If the rep asks for **net-new**, **untouched**, **new accounts**, or new contacts to sequence, run the discovery workflow below.
- If the request is ambiguous, show a short current-task summary followed by net-new capacity; do not hide already committed work.

## 2. Build the candidate company set

Search HubSpot companies in two lanes:

- **Owned:** `hubspot_owner_id` is the rep. Include even when the company is outside the rep's usual segment, but label it `owner-owned / outside segment`.
- **Shared unassigned segment pool:** company owner is blank, `segment` matches the rep's configured segment, and no associated contact is owned by another rep. Do not invent a hidden per-rep partition. Treat every unassigned result as discovery-only until the company is claimed because the live HubSpot guardrail permits sequencing only from rep-owned accounts.

Apply the segment/size-band model in `hubspot-fields.md`: segment routes, size band describes the record itself, verified children inherit the parent's segment, and divergence is a hold rather than an exception.

Default to `icp_fit=yes`. Keep `partial`, `no`, and `unverifiable` out of the sequence-ready queue. A `partial` row may appear as a concise held/research result when it is relevant to the search; expand it into a full research section only when the rep asks for broader discovery. Do not map `under_10` to SMB.

Exclude a company from sequence-ready results when it is a current customer, active opportunity/open deal, disqualified, owned by another rep, or on a live identity/duplicate hold. Do not repair account identity, segment, parent-child, or duplicate problems inside this skill.

Use company-level activity fields only to narrow the search. They are not sufficient proof that an account is untouched.

Inspect candidates in ranked batches of 10–15 companies until the requested account count is met or the candidate pool is exhausted. Report how many candidates were inspected, matched, and held; label the result complete or sampled.

## 3. Inspect every associated contact

For each candidate company, retrieve all associated contacts—not only the newest or highest-ranked contact—and inspect:

- contact owner and company owner consistency;
- email, validation, bad-address, and opt-out state;
- contact validation status and persona role;
- last contacted, sales activity, call, meeting, task, and Nooks evidence;
- current and historical HubSpot sequence enrollment;
- lead status and lifecycle exclusions;
- duplicate email, person, company, and same-domain account collisions.

For every shortlisted contact, also retrieve **all companies associated with that contact**. Exclude or hold the contact if any association belongs to another rep, is a customer/open opportunity, or creates unresolved parent/child or duplicate-account routing ambiguity.

Rank eligible contacts using the segment target-persona hierarchy in `rep-routing.md`: exact target persona first, then the closest adjacent buyer or influencer, then other relevant business contacts. Apply any persona or play constraint in the rep's prompt before falling back. Show the persona tier and title in the result so the rep can see why each person was selected.

For Enterprise, resolve the decision-level company before selecting contacts. Treat a child/parent relationship as verified only when the live HubSpot association is supported by at least one authoritative relationship signal: a first-party acquisition/location page, an explicit human-confirmed CRM note or field, or a provenance field whose evidence is current and not contradicted. A matching name, shared domain, or bare parent association alone is not verification. Use a brief first-party web check when CRM evidence is insufficient; check the company's own site or the parent's acquisition/location pages, then move on if ambiguity remains. If the company is a verified child, use the parent's inherited segment and persona motion, traverse to its verified parent, check the parent owner/activity/lifecycle, and build the buyer map from the parent decision level. Do not substitute local-office contacts for the parent map or reinterpret the child's own size band as its sales segment.

If the parent relationship is disputed or unverified, keep the account out of sequence-ready results, show it as `parent disputed — account review`, and continue building the rest of the rep's queue. It may be described provisionally at the standalone operating-company level for research, but do not claim it is standalone, remove the parent, derive a parent buyer map, or sequence it until adjudication. When the evidence later verifies standalone status or a corrected parent, re-run routing against the live repaired state.

When discovery exposes a concrete CRM data defect—such as a wrong association, duplicate, suspect parent, bad domain, or contradictory segment—keep the affected row out of Ready, continue the usable prospecting queue, and offer once to log the issue through `$hubspot-feedback`. Pass the affected object IDs and URLs, disputed value, observed-versus-expected framing, and whether each fact is rep-reported, CRM-observed, verified, or suspected. After logging, show the returned `CRM-<number>` on the held row. Treat that report as the default account-review route unless another destination is configured. Do not silently log a merely possible issue or let the logging offer derail unaffected results.

Classify ownership:

- **Aligned:** company and contact are owned by the rep.
- **Claimable blank:** both are blank, the company is owned by the rep and contact is blank, or the contact is owned by the rep and company is blank. Require fresh compare-and-set before sequencing.
- **Reconciliation needed:** nonblank owners disagree, a relevant association has another owner, or parent/duplicate routing is ambiguous.
- **Other-rep owned:** any relevant nonblank owner belongs to another rep.

Only `Aligned` and `Claimable blank` may become sequence-ready. Surface `Reconciliation needed` separately. Exclude `Other-rep owned`. Never overwrite an owner or silently reassign a record.

## 4. Classify outreach state

Use three states:

- **Untouched account:** no associated contact has specific outbound evidence and the company has no call, meeting, sequence, or last-contacted evidence.
- **New person at worked account:** the selected contact has no outbound evidence, but another contact or the company has been worked.
- **Worked:** the contact has a call/Nooks disposition, outbound email, meeting, current or past sequence enrollment, or a clear contacted/connected lead status. Do not use task completion alone as proof.

Also mark **Already queued** when a contact is in an active sequence or has an open sequence-generated HubSpot call task assigned to a rep. A pending task is not proof a call happened and HubSpot alone does not prove it appeared in Nooks, but it means the contact is already allocated to a rep workflow and must not be surfaced as available net-new work.

A completed task alone is not proof of outreach; it may have been skipped or manually closed. Require a call disposition, outbound email, meeting, or other specific activity to classify `Worked`. Otherwise label `task completed / activity uncertain`.

If only broad timestamps such as `hs_last_sales_activity_timestamp` or `notes_last_updated` are populated, inspect the underlying activities. If the source cannot be resolved, label the row `activity uncertain` instead of `untouched`.

Contact-level unresolved activity uncertainty makes that contact `Review`. Account-level uncertainty caused only by a different associated contact demotes the selected contact's ranking and prevents labeling the whole account untouched, but does not by itself make an otherwise clean selected contact non-ready.

Default results to `Untouched account`. Show `New person at worked account` secondarily. Exclude `Worked` unless the rep explicitly asks for re-engagement.

## 5. Determine contact readiness

Apply the hard suppression list in `hubspot-fields.md`. A sequence-ready contact must also have a person-specific business email, validated contact identity, no unresolved owner/identity conflict, and an untouched or explicitly requested re-engagement state.

Reject generic inboxes such as `info@`, `support@`, `sales@`, `contact@`, `office@`, `admin@`, `hello@`, `service@`, `claims@`, and `billing@` from sequence-ready results.

Use these readiness labels:

- **Ready:** hard gates pass and email validation is deliverable/current.
- **Validate email:** otherwise eligible, but email validation is missing, unknown, risky, or stale.
- **Review:** ownership, identity, activity, ICP, lifecycle, or suppression uncertainty remains.

Do not hide useful research rows; place them in the appropriate non-ready section.

## 6. Rank and present

Rank in this order, allowing the rep's prompt to refine ties:

1. exact segment target persona before adjacent and general fallback tiers;
2. rep-owned before shared-pool unassigned within the same persona tier;
3. untouched account before new person at worked account;
4. `Ready` before `Validate email` before `Review`;
5. newer net-new CRM records before older equally qualified records;
6. better contact completeness and stronger ICP evidence.

Default to 10 accounts. Use the canonical per-segment contact counts in `operating-motion.md`. Do not exceed 25 contacts in one action batch without the rep asking to expand.

Present a compact table with:

- index;
- company and HubSpot link;
- segment and ICP fit;
- relevance lane (`owned` or `shared unassigned segment pool`);
- contact, title, persona, email, and contact link;
- owner state;
- outreach state;
- readiness;
- one-line reason it ranked.

State the filters, total candidates inspected, total eligible, and whether the results are complete or sampled.

When the rep wants the queue as a file, or the result is too large for a readable table, write a CSV with the same columns as the table. Always output CSV—never .xlsx or any other spreadsheet format, even if a spreadsheet skill is available—unless the rep explicitly asks for a different format in the current request.

Then ask: **“Would you like to sequence any of the Ready contacts in HubSpot? I can list Validate email contacts separately for revalidation.”**

## 7. Sequence only after selection

If the rep says yes:

1. In one interaction, confirm which `Ready` rows to use, which live-confirmed sequence to use, and the connected sender identity. Never enroll `Review`. If the rep selects `Validate email`, keep it held and follow the revalidation behavior in `hubspot-fields.md`; continue only after a live re-read shows current `deliverable`.
2. Retrieve the current sequences available to that rep from a live HubSpot source. Do not infer active sequences from historical property options. If the connected HubSpot tools cannot enumerate sequences, use the authenticated HubSpot Sequences page; if that is unavailable, ask the rep to provide the currently visible sequence names. Never propose a sequence name that was not confirmed by a live source or the rep. Hard-exclude names containing `NOT IN USE`, `DO NOT USE`, `OLD`, or `DEPRECATED` and route to the current canonical replacement.
3. Re-read every selected company, contact, owner, suppression, activity, and sequence-enrollment field immediately before action. For unassigned records, follow the compare-and-set claim in `sequencing.md`.
4. Show one final enrollment preview: sequence, sender, supported start behavior, first step type, first-step delay, send window, later task/email chain, contact count, contact emails, account count, ownership changes, and warnings. Say plainly when an email can send immediately.
5. Get explicit confirmation for the enrollment action.
6. Enroll in small batches, verify each enrollment, and report successes, skips, and failures. Never retry an ambiguous result without checking live enrollment status first.

If connected tools cannot enroll, produce a manual HubSpot enrollment checklist containing the exact contacts and links, confirmed sequence, sender, and warnings. After the rep says they completed it, re-read `hs_sequences_is_enrolled` for every contact and report verified or missing. Do not claim enrollment succeeded without live readback.

## Hard boundaries

- Keep discovery read-only.
- Do not silently claim ownership, repair account data, merge records, disassociate contacts, or overwrite rep-entered fields.
- Do not sequence a contact merely because the email domain matches an account.
- Do not use Apollo for sequencing or push contacts back into Apollo. HubSpot is the system of record; Nooks consumes HubSpot call tasks.
- Do not treat a historical sequence list property as the list of usable sequences.
- Do not bypass the suppression list or enroll anything without current `deliverable` email validation.
- Do not let extra prompt context override hard suppression and ownership gates.
- File outputs are CSV only; do not produce .xlsx unless the rep explicitly requests it.
