# Classification examples

## Wrong phone after a call

Rep says: “I called John’s number and reached a dentist’s office.”

- Issue Type: `Wrong phone`
- Object Type: `Contact`
- Severity: `P1 - High` because the stored number creates wrong-person outreach risk
- Current Value: stored phone
- Expected Value: correct number for John, or `Unknown`
- Root Cause Layer: `Unknown` unless provider lineage proves more
- Potentially Systemic: false for one isolated call
- Occurrence Key: the contact ID plus normalized phone
- Pattern / Cohort Key: blank unless a shared source/batch failure is evidenced

Ask to log once if the rep did not explicitly request logging.

## Wrong ICP fit

Rep says: “This is a carrier, not an independent agency, but ICP Fit says Yes.”

- Issue Type: `Wrong ICP fit`
- Object Type: `Company`
- Current Value: `ICP Fit = Yes; account type = independent agency`
- Expected Value: `ICP Fit = No; carrier`
- Evidence: rep observation plus first-party or CRM evidence if available
- Severity: usually `P1 - High`
- Potentially Systemic: true only if the same rule/source appears to affect more accounts

## Parent-child relationship

Rep says: “This local office is attached as a child of an unrelated parent.”

- Issue Type: `Wrong parent-child`
- Object Type: `Company`
- Current Value: current parent ID/name
- Expected Value: expected parent or standalone
- Root Cause Layer: `Entity resolution` only if evidence supports it; otherwise `Unknown`
- Include both company IDs and preserve whether the claim is rep-reported or independently verified
- Put the parent/counterpart IDs and URLs in the related-object fields, not only in prose

If Prospecting Assistant hands this off as `parent disputed — account review`, retain that wording in the evidence/triage note, reuse its pre-gathered IDs and evidence tiers, and return the logged ticket ID so the prospecting row can display it.

## Bulk or cohort issue

Rep identifies 15 companies with the same suspected segment or parent defect from one enrichment run.

- Create one representative report using the clearest company as the occurrence-key object.
- Put all 15 IDs/URLs in the related-record fields.
- Set `Suspected Impact Count = 15`, populate the shared pattern key, and mark `Potentially Systemic` true.
- Populate `Confirmed Affected Count` only for independently verified rows.
- Do not create 15 separate reports unless the rep asks or the records require independent tracking.

## Duplicate records

Rep supplies two HubSpot company URLs for the same operating business.

- Issue Type: `Duplicate record`
- Object Type: `Company`
- Current Value: both object IDs/URLs
- Expected Value: one canonical company, details unknown unless already established
- Severity: `P1 - High` if contacts/activity are split; otherwise `P2 - Normal`
- Do not merge records from this skill
- Store both IDs/URLs in the related-object fields and use one occurrence key for the reported duplicate pair

## Data-quality suggestion, not a current error

Rep says: “It would help if we showed when a phone was last validated.”

- Issue Type: `Other feedback`
- Object Type: `Other` or `Contact`
- Severity: `P3 - Low`
- Record the requested behavior and the workflow pain it addresses
- Do not pretend an existing record is wrong

## Do not log

- “What does ICP Fit mean?” with no claimed issue
- “Could this account be a child?” as a hypothetical with no evidence or correction
- routine CRM navigation help
- repeated mentions of the same issue after the user already declined logging in this session
