# Sequencing workflow and safeguards

## Separation of concerns

Keep these actions separate:

1. **Discover:** search, inspect, rank, and present. No writes.
2. **Claim:** assign an unassigned company and only blank contact owners to the rep. Explicit confirmation and readback required.
3. **Enroll:** add selected contacts to a current HubSpot sequence. Explicit final confirmation and readback required.

Do not use sequence enrollment as a way to repair CRM ownership or account identity.

## Pre-enrollment checks

Immediately before action, re-read each selected contact, every associated company, ownership, activity, and sequence state. Apply the canonical suppression list in `hubspot-fields.md` and the readiness/ownership rules in `SKILL.md`. Skip any row that now fails a gate, has new outreach or sequence activity, or has an open sequence-generated task already allocated to a rep.

Do not retry an enrollment after a timeout or ambiguous response until live sequence status is checked.

## Sequence selection

Retrieve the current sequence catalog available to the rep through HubSpot. Historical `hs_latest_sequence_enrolled` property options include retired sequences and are not a safe catalog.

Use the canonical team sequences maintained in HubSpot. Do not clone or improvise a sequence inside this skill. If the canonical sequence for a segment is unclear, show the current options and route the selection question to the rep rather than guessing.

If the connected HubSpot tool cannot enumerate sequences, use the rep's authenticated HubSpot Sequences page. If neither a live sequence-listing tool nor authenticated browser view is available, ask the rep to provide the names currently visible in HubSpot. Never invent or reuse a sequence name from memory, a fixture, historical contact property options, or an earlier session.

Hard-exclude sequence names containing `NOT IN USE`, `DO NOT USE`, `OLD`, or `DEPRECATED`. Route the rep to the current canonical replacement or to the sequence owner; do not permit an override inside this skill.

Verify:

- the sequence is shared with the rep;
- the rep has a Sales or Service seat and sequence permissions;
- the sender email is the rep's connected personal inbox;
- personalization tokens and required fields are populated;
- the contact is not already in another active sequence.

Keep HubSpot `userId`, CRM `ownerId`, and connected sender email distinct. Use owner IDs for record assignment. Use the authenticated user/sender identity required by the live enrollment path; never substitute the configured owner ID for an API user ID.

HubSpot permits one active sequence per contact. A first sequence step may send immediately, so the final confirmation must say this plainly.

Official references:

- HubSpot Sequences API: <https://developers.hubspot.com/docs/api-reference/latest/automation/sequences/guide>
- Enroll contacts in a sequence: <https://knowledge.hubspot.com/sequences/enroll-contacts-in-a-sequence>
- Unenroll contacts from a sequence: <https://knowledge.hubspot.com/sequences/unenroll-from-sequence>

## Ownership claim

For claimable blank records, propose a compare-and-set claim:

- every blank owner being filled must still be blank;
- any already-populated company/contact owner must equal the invoking rep;
- no associated contact may have another rep's owner;
- no other company associated with the contact may belong to another rep or be a customer/open opportunity;
- set only blank company/contact owner fields to the invoking rep;
- re-read and verify both objects before enrollment.

If any precondition changes, stop that row and report the conflict. Never overwrite another rep's owner.

## Final preview

Show:

| Field | Required detail |
|---|---|
| Sequence | Current name and ID |
| Sender | Connected sender email |
| Start | Supported execution behavior; do not promise scheduling through a path that lacks it |
| First step | Type, delay/timing, and send window |
| Later steps | Calls/tasks/emails the enrollment will create |
| Scope | Contact count and account count |
| Contacts | Name, email, company, HubSpot link |
| Ownership | Exact proposed claims, if any |
| Warnings | First email timing, uncertain fields, personalization gaps |

Ask for an explicit yes/no confirmation. A prior “yes, show me sequences” is not approval to enroll.

## Batch behavior

Default to no more than 25 contacts per confirmed enrollment batch. Use the canonical per-account contact counts in `operating-motion.md` and expand only when the rep asks and the checks still pass.

Apply the operating motion:

- SMB may use small list-view batches into the canonical SMB sequence.
- Mid-Market should multi-thread the canonical persona set and personalize the first call and first email.
- Enterprise should not bulk enroll; use the canonical buyer map and personalized 1:1 sequences/manual calls.

After execution, report:

- enrolled and verified;
- skipped because live state changed;
- failed with a clear error;
- ambiguous and held for status reconciliation.

Include HubSpot links. Do not claim success based only on a request being sent.
