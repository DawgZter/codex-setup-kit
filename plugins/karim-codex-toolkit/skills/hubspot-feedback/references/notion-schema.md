# Notion schema

## Destination

- Database URL: `https://app.notion.com/p/0a9e711bbdc346c59e98a7a8a2158af3`
- Data source: `collection://407307a6-da0e-454e-a9fc-fbaaaab6b8df`

Always fetch the database before the first write in a session. If the live schema differs from this reference, use the live schema and fail closed on any unclear property.

## Intake defaults

Use these values unless evidence supports something else:

- `Status`: `New`
- `Severity`: `P2 - Normal`
- `Account Source`: `Unknown`
- `Producing Provider`: `Unknown`
- `Evidence Sources`: `["Unknown"]`
- `Segment`: `Unknown`
- `ICP Fit`: `Unknown`
- `Pipeline Stage`: `Unknown`
- `Root Cause Layer`: `Unknown`
- `Potentially Systemic`: `__NO__`

## Required properties for every report

| Property | Value |
| --- | --- |
| `Report` | Short title, preferably `[Issue Type] Account or Contact` |
| `Status` | Default `New` |
| `Severity` | One allowed severity |
| `Issue Type` | One allowed issue type |
| `Affected Field` | The primary field or relationship that failed |
| `Object Type` | `Contact`, `Company`, `Contact + Company`, or `Other` |
| `Rep Description` | Faithful summary of the rep's observation |
| `Potentially Systemic` | `__YES__` or `__NO__` |
| `Occurrence Key` | Stable key for one concrete occurrence |

## Populate when known

- `HubSpot Record URL`
- `HubSpot Object ID`
- `Related HubSpot Record URLs`
- `Related HubSpot Object IDs`
- `Account`
- `Contact`
- `Domain`
- `Current Value`
- `Expected Value`
- `Evidence`
- `Occurred At` using `date:Occurred At:start` and `date:Occurred At:is_datetime`
- `Account Source`
- `Producing Provider`: the source that produced the disputed value
- `Evidence Sources`: sources used to corroborate or refute the report, as a JSON-array string for the current connector
- `Source Field / Property`
- `Pipeline Stage`
- `Script / Version`
- `Enrichment Run / Batch`
- `Segment`
- `ICP Fit`
- `Root Cause Layer`
- `Pattern / Cohort Key`
- `Suspected Impact Count` as a number: rep-reported or CRM-observed records sharing the suspicious pattern but not yet independently verified wrong
- `Confirmed Affected Count` as a number: records independently corroborated as wrong by authoritative evidence or direct outcome evidence
- `Cohort / Denominator Count` as a number: the full population to which a defensible rate could apply
- `Reporter`
- `Reporter Email`
- `HubSpot Owner`

Omit unknown URL, email, date, and number properties. Do not set `Ticket ID`, `Created`, or `Last Updated`; Notion generates them. Do not set resolution fields on intake.

## Lineage semantics

- `Producing Provider` answers: **which source put the disputed value into the data flow?** Use `Unknown` without evidence.
- `Evidence Sources` answers: **which sources were consulted while reporting or verifying the issue?** A first-party website can be evidence without being the producing provider.
- `Occurrence Key` deduplicates one event or one bad field on one record.
- `Pattern / Cohort Key` groups separate occurrences that plausibly share one provider, script, batch, or rule.
- `Suspected Impact Count` is not a confirmed error numerator. `Confirmed Affected Count / Cohort / Denominator Count` supports a defensible cohort error rate only after the affected rows are independently verified. The issue-row count alone is only a reported-issue numerator.

## Allowed values

### Status

- `New`
- `Triaged`
- `Investigating`
- `Fix ready`
- `Resolved`
- `Not an issue`
- `Duplicate`

### Severity

- `P0 - Blocking`
- `P1 - High`
- `P2 - Normal`
- `P3 - Low`

### Issue Type

- `Wrong phone`
- `Wrong email`
- `Wrong person/contact`
- `Wrong domain/website`
- `Wrong address`
- `Wrong ICP fit`
- `Wrong account type`
- `Wrong segment/size`
- `Wrong parent-child`
- `Duplicate record`
- `Wrong association`
- `Missing data`
- `Source/provider contamination`
- `Other feedback`

### Affected Field

- `Phone`
- `Email`
- `Person identity`
- `Job title`
- `Domain/website`
- `Company name`
- `Address`
- `ICP fit`
- `Account type`
- `Segment`
- `Size band`
- `Parent company`
- `Association`
- `Duplicate identity`
- `Missing field`
- `Other`

### Account Source

- `Pre-existing CRM`
- `TAM enrichment`
- `Rep-created`
- `Import/other`
- `Unknown`

### Producing Provider

- `HubSpot existing`
- `TAM enrichment`
- `Blitz`
- `Moltsets`
- `ZoomInfo`
- `Apollo`
- `DeepLine`
- `SBS Data`
- `AdvizorPro`
- `Crustdata`
- `LinkedIn`
- `Rep-created/manual`
- `Unknown`

### Evidence Sources

The producing-provider values plus `First-party website`, `Rep research`, and `Unknown` are available. This is a multi-select field.

### Pipeline Stage

- `Source import`
- `Provider enrichment`
- `Entity resolution`
- `Warehouse transform`
- `HubSpot payload/write`
- `Manual CRM edit`
- `Unknown`

### Segment

- `Enterprise`
- `Mid-Market`
- `SMB`
- `Under 10`
- `Unknown`

### ICP Fit

- `Yes`
- `Partial`
- `No`
- `Unknown`

### Root Cause Layer

- `Source data`
- `Entity resolution`
- `Enrichment logic`
- `Warehouse transform`
- `HubSpot payload/write`
- `Manual CRM edit`
- `Unknown`

## Suggested create-page payload

```json
{
  "parent": {"data_source_id": "407307a6-da0e-454e-a9fc-fbaaaab6b8df"},
  "pages": [
    {
      "properties": {
        "Report": "[Wrong phone] Acme Insurance / Jane Smith",
        "Status": "New",
        "Severity": "P1 - High",
        "Issue Type": "Wrong phone",
        "Affected Field": "Phone",
        "Object Type": "Contact",
        "HubSpot Record URL": "https://app.hubspot.com/...",
        "HubSpot Object ID": "123456",
        "Related HubSpot Object IDs": "company:987654",
        "Account": "Acme Insurance",
        "Contact": "Jane Smith",
        "Domain": "acmeinsurance.com",
        "Current Value": "+1 415 555 0100",
        "Expected Value": "Correct number for Jane Smith; exact value unknown",
        "Rep Description": "Rep called the CRM number and a different person answered.",
        "Evidence": "Rep-reported call outcome. CRM lookup confirmed the stored number.",
        "date:Occurred At:start": "2026-07-13T10:30:00-07:00",
        "date:Occurred At:is_datetime": 1,
        "Account Source": "TAM enrichment",
        "Producing Provider": "ZoomInfo",
        "Evidence Sources": "[\"HubSpot existing\",\"Rep research\"]",
        "Source Field / Property": "phone",
        "Pipeline Stage": "Provider enrichment",
        "Segment": "SMB",
        "ICP Fit": "Yes",
        "Root Cause Layer": "Unknown",
        "Potentially Systemic": "__NO__",
        "Occurrence Key": "contact:123456|wrong phone|+14155550100",
        "Reporter": "Rep Name",
        "Reporter Email": "rep@example.com"
      },
      "content": "## Reported issue\n\nRep called the CRM number and a different person answered.\n\n## Observed vs expected\n\n**Observed:** The stored number reached a different person.\n\n**Expected:** A working number for Jane Smith.\n\n## Evidence captured\n\nRep-reported call outcome; HubSpot value read back.\n\n## Triage notes\n\nProducing provider is CRM-observed; root cause not yet verified."
    }
  ]
}
```
