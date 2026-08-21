# Current sales operating motion

This reference reflects the active July 2026 Prospecting SOP plus live Slack confirmation. HubSpot has replaced Apollo for rep prospecting.

## Tool responsibilities

| Tool | Current role |
|---|---|
| HubSpot | System of record for contacts, companies, ownership, sequences, tasks, activity, and reporting |
| Nooks | Dialer; consumes HubSpot call tasks and writes dispositions/recordings back to the HubSpot contact |
| HubSpot Sales Chrome extension | Logs Gmail activity into HubSpot |
| Apollo | No longer used for sequencing; do not push records back into Apollo |

A contact must exist in HubSpot before it is dialed in Nooks so the call, disposition, and recording map to the correct record.

## Task and activity semantics

- HubSpot sequences create call tasks that sync to Nooks.
- An open future call task is not a completed outreach attempt, but the contact is already queued and must not be offered as new work to another rep. When the rep asks what to call today, show these due/overdue tasks first.
- A completed Nooks call and disposition write back to HubSpot and count as worked.
- A completed HubSpot task without a call disposition, outbound email, meeting, or other specific activity is `activity uncertain`, not proof of outreach.
- Count all logged outreach regardless of source. Historical Apollo-generated calls may still appear in HubSpot.
- On a reply, meeting, or phone connect, verify sequence unenrollment; do not assume every channel auto-unenrolls correctly.

## Segment motions

### SMB (`smb`, 10–49)

- Use a volume motion and the canonical SMB HubSpot sequence.
- Start from HubSpot tasks due today and launch synced call tasks in Nooks.
- Target 2–3 contacts per account: one strongest contact, one backup, and a conditional line-of-business or workflow-specific contact when relevant.
- Prefer Owner/Principal, then Operations, then PL/CL or producer roles.
- Small batch enrollment is acceptable after owner and suppression checks.

### Mid-Market (`mid_market`, 50–99)

- Use a hybrid, call-heavy motion.
- Target 3 personas per account: Operations + Owner/Principal/executive sponsor + PL/CL, product, strategic-initiatives, or service leader where available.
- Operations is the fastest-converting cold persona and should rank first when evidence is otherwise equal.
- Personalize the first call and first email using account context such as AMS, carriers, and ICP evidence.
- Check parent/platform context before sequencing; coordinate with the Enterprise owner when the account is acquired.

### Enterprise (`enterprise`, 100+)

- Use an account-based motion at the parent/decision level.
- Target a 4–5 person buyer map spanning Operations, IT/Systems, executive sponsorship, and a functional champion; include Finance only for a finance/accounting play.
- Do not bulk sequence. Use personalized 1:1 HubSpot sequences and manual calls.
- Inspect parent/child and owner context before outreach. Escalate ambiguity instead of sequencing blind.

### Under 10 (`under_10`)

- Do not prospect by default. This band is covered by automated long-tail cycling.
- Allow only explicit inbound or referral exceptions.

## Operational sources

- Active Notion SOP: <https://app.notion.com/p/39a7433b636a81d9a05be3424d1bbf8b>
- Scaled Outreach initiative: <https://app.notion.com/p/38c7433b636a81fe836fd3647589a31c>
- HubSpot portal: `23695809`

Slack history confirms why the checks matter: reps previously reported overlapping call lists and asked that accounts be checked before enrollment. The post-Apollo process starts from fresh HubSpot-owned queues to prevent cross-calling.
