# Rep routing and persona order

## HubSpot owners

| Rep | Owner ID | User ID | Work email | Segment | Internal segment value |
|---|---:|---:|---|---|---|
| Octavio Pala | `85012029` | `85012029` | `octavio@adaptinsurance.com` | SMB | `smb` |
| Brandon Perez | `88178787` | `88178787` | `brandon.perez@adaptinsurance.com` | SMB | `smb` |
| Jacob Bolton | `300195503` | `72040909` | `jacob.bolton@adaptinsurance.com` | Mid Market | `mid_market` |
| Billy Huang | `93427243` | `93427243` | `billy@adaptinsurance.com` | ENT | `enterprise` |
| Greg DeJesus | `91896493` | `91896493` | `greg@adaptinsurance.com` | ENT | `enterprise` |
| Mike Petrosyan | `92430305` | `92430305` | `mike@adaptinsurance.com` | ENT | `enterprise` |

Use exact IDs or verified work emails. Owner IDs route CRM records; user IDs identify HubSpot users and may differ, as they do for Jacob. Never substitute one for the other.

At the start of each run, verify that the configured user still exists, is active, retains the expected owner ID/segment assignment, and has a connected email when sequencing is requested. If the live roster differs, stop using the stale rep mapping and report the routing change.

## Relevance lanes

A company is relevant when either condition holds:

1. The company is owned by the invoking rep. This lane is relevant even if the segment is outside the rep's normal assignment; label the discrepancy.
2. The company is unassigned, its segment matches the rep, and no associated contact is owned by another rep. This is the shared unassigned segment pool.

Use the effective sales segment defined by the canonical segment/size-band model in `hubspot-fields.md`.

Never treat `under_10` as SMB. It is a separate internal segment and is not assigned by this configuration. An explicit inbound/referral exception follows the live inbound/owner route; do not hash an unassigned under-10 record into an SMB pool.

The company owner is authoritative for routing. A contact with another rep's owner is not permission to take the account. Place mismatches in reconciliation; do not silently change either owner.

## Shared unassigned segment pool

Do not split unassigned accounts with a local hash, script, or model-invented allocation. Every rep may discover currently unassigned companies in their assigned segment. Rank rep-owned accounts first, then shared-pool accounts by target persona, readiness, and outreach state.

An unassigned account is not reserved merely because it appeared in a result. Follow the compare-and-set ownership claim in `sequencing.md`; if another rep claimed or began working it after discovery, skip it and continue.

This keeps coordination in HubSpot—the system of record—rather than in hidden skill state. A rep may ask to see all unassigned records in the segment, but sequencing still requires a successful live claim and readback.

## Segment target personas

Use the TAM Enrichment Plan's segment-specific hierarchy. These are priorities, not exact-title allowlists. Check the current job title and company context even when `mt_persona_role` is populated; use that field as a normalized aid, not unquestioned proof. Do not infer a persona solely from an email local part.

### SMB persona order

1. **Primary:** Owner, Principal, President, CEO, Founder, or Managing Partner.
2. **Secondary:** Operations Manager, Office Manager, Agency Manager, or Director/Manager of Agency Operations.
3. **Conditional line-of-business contact:** Personal Lines or Commercial Lines leader when the rep's request or sequence is line-specific.
4. **Conditional finance contact:** CFO, Controller, or Accounting Manager only for commission/accounting workflows.

### Mid Market persona order

1. **Primary pair:** one operations leader—COO, VP Operations, Director of Operations, or Agency Operations—plus one executive sponsor—President, CEO, Principal, or Managing Partner.
2. **Third contact:** Commercial Lines, Personal Lines, Product, Strategic Initiatives, or Service leader according to the play.
3. **Conditional IT contact:** CIO, CTO, Systems, Applications, Integrations, Innovation, or Implementation when AMS, workflow, or automation is central.
4. **Conditional finance contact:** CFO, Controller, or Accounting only for commission/accounting workflows.

### Enterprise persona order

1. **Primary:** COO, SVP Operations, VP Operations, Director of Business Operations, or Process/Governance leader.
2. **Second thread:** CIO, CTO, VP Systems, Applications, Integrations, Innovation, or Implementation.
3. **Executive sponsor:** CEO, President, Chief Customer Officer, Chief Strategy Officer, or Regional President.
4. **Functional champion:** Commercial Lines, Personal Lines, P&C Operations, Service/Support, or Project/Implementation leader.
5. **Conditional finance contact:** Finance/Accounting only for commission/accounting plays.

Rank contacts in that order unless the rep's stated play calls for one of the conditional roles. If an exact segment target persona is unavailable, expand deliberately to adjacent operational, executive, systems, line-of-business, service, and producer roles that could plausibly influence the purchase. Only then use other relevant business contacts. Label the fallback tier so the rep can distinguish an exact target persona from an adjacent or general contact.

Use contact-count targets from `operating-motion.md`. Do not pad a result with weak identities merely to reach a count, and do not suppress additional relevant validated contacts when the rep asks for broader coverage.
