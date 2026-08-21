# HubSpot field model

Use live property definitions when possible. The following internal names were verified in HubSpot account `23695809` and are the baseline for this skill.

## Company properties

| Property | Use |
|---|---|
| `hubspot_owner_id` | Authoritative routing owner |
| `segment` | Sales-routing classification. Values include `enterprise`, `mid_market`, `smb`, `under_10`. Standalone/parent records derive it from their own size band; verified children inherit the verified parent's segment. |
| `size_band` | The specific company record's own operating employee-size band; do not overwrite or reinterpret it to match an inherited parent segment. |
| `numberofemployees`, `hs_employee_range` | Employee evidence for that specific company record, not the parent's consolidated headcount unless the record itself is the parent. |
| `icp_fit` | Values include `yes`, `partial`, `no`, `unverifiable` |
| `icp_fit_reason`, `icp_fit_evidence` | Ranking and context |
| `notes_last_contacted` | Specific last-contact signal |
| `num_contacted_notes` | Count of actual contact activities |
| `notes_last_updated` | Broad activity/note signal; not sufficient alone |
| `hs_last_sales_activity_timestamp` | Broad engagement signal; inspect underlying activities when it is the only signal |
| `hs_last_logged_call_date` | Call/Nooks signal |
| `hs_last_logged_outgoing_email_date` | Outbound email signal |
| `hs_last_booked_meeting_date` | Booked-meeting signal |
| `engagements_last_meeting_booked` | Meeting signal |
| `lifecyclestage` | Exclude customer/opportunity/disqualified states |
| `hs_lead_status` | Values include `NEW`, `OPEN`, `IN_PROGRESS`, `OPEN_DEAL`, `UNQUALIFIED`, `ATTEMPTED_TO_CONTACT`, `CONNECTED`, `BAD_TIMING` |
| `hs_current_customer` | Values `yes`/`no`; exclude `yes` by default |
| `createdate`, `hs_object_source_label` | Net-new ranking context |
| `domain`, `name` | Identity and display |
| `hs_parent_company_id` and Parent Company association | Enterprise decision-level traversal; a bare association is not verification. Require current first-party relationship evidence, an explicit human-confirmed CRM signal, or current undisputed provenance before using it for routing. |

## Segment and size-band model

- Standalone company: its segment follows its own size band.
- Parent company: its segment follows its own size band.
- Verified child: its segment must equal the verified parent's segment, while its size band and employee evidence remain specific to the child.
- Do not derive a child's size band from its inherited segment and do not aggregate parent headcount into a child record.
- A verified child whose segment diverges from its parent's segment is a CRM data-quality hold, not a prospecting exception.

## Contact properties

| Property | Use |
|---|---|
| `hubspot_owner_id` | Must align with company owner or be blank/claimable |
| `email` | Required for sequence-ready state |
| `hs_email_bad_address` | Hard suppression when true |
| `hs_email_optout` | Hard suppression when true |
| `adapt_contact_validation_status` | Values `validated`, `review_required` |
| `adapt_contact_validation_source` | Validation provenance |
| `adapt_contact_validation_checked_at` | Identity-validation timestamp |
| `adapt_email_validation_status` | Values `deliverable`, `undeliverable`, `risky`, `unknown` |
| `adapt_email_validation_source` | Email-validation provenance |
| `adapt_email_validation_checked_at` | Determine freshness; treat older than 30 days as stale unless the rep asks otherwise |
| `mt_persona_role` | Values `owner`, `vp_ops`, `ops_leader`, `pl_leader`, `cl_leader`, `it_systems`, `producer_agent`, `finance_accounting`, `admin`, `unknown` |
| `notes_last_contacted` | Last logged call/chat/LinkedIn/postal/meeting/sales email/SMS/WhatsApp |
| `num_contacted_notes` | Count of the same actual contact activities |
| `notes_last_updated` | Broad activity signal; not sufficient alone |
| `num_notes` | Number of sales activities, including calls, meetings, notes, sales email, SMS, tasks, and related channels |
| `hs_last_sales_activity_timestamp` | Broad engagement timestamp |
| `hs_sequences_is_enrolled` | Current sequence enrollment |
| `hs_sequences_enrolled_count` | Historical sequence count |
| `hs_latest_sequence_enrolled` | Historical sequence identifier; not an active-sequence directory |
| `hs_latest_sequence_enrolled_date` | Historical enrollment evidence |
| `hs_latest_sequence_ended_date` | Historical sequence evidence |
| `lifecyclestage` | Contact lifecycle exclusion context |
| `hs_current_customer` | Values `yes`/`no`; exclude `yes` |
| `hs_lead_status` | Values include `NEW`, `UNQUALIFIED`, `CONNECTED`, `BAD_TIMING`, `WRONG_PERSON`, `Referral Partner` |
| `n1st_call` | `Yes`/`No`; call evidence |
| `createdate`, `hs_object_source_label` | Net-new ranking context |
| `firstname`, `lastname`, `jobtitle`, `phone` | Display and completeness |

## Activity decision rules

Treat these as specific outreach evidence:

- current or historical sequence enrollment;
- `notes_last_contacted`;
- `n1st_call=Yes`;
- company `hs_last_logged_call_date`;
- associated outbound email, call/Nooks disposition, or meeting; task completion alone is insufficient;
- a lead status that clearly indicates attempted contact, connection, or disqualification.

Treat `notes_last_updated`, `num_notes`, and `hs_last_sales_activity_timestamp` as broad signals. When they conflict with specific fields, discover the available activity object types from HubSpot user details, then search the returned CALL, EMAIL, MEETING_EVENT, and TASK types. An open sequence-generated task means `already queued`, not a completed touch. Label unresolved cases `activity uncertain`.

Do not use `hs_is_unworked` as proof of no outreach. It is owner-relative. In a live audit, 2,430 contacts marked unworked had contact activity and 474 had prior sequence enrollment.

Account-level rollups can lag or omit contact activity. Always inspect all associated contacts before declaring an account untouched.

For final sequence-ready output, query contacts and activities per company when needed. Multi-company association searches do not always make the originating company unambiguous.

## Task properties

Use these live `TASK` properties to distinguish today's queue from net-new discovery:

| Property | Use |
|---|---|
| `hubspot_owner_id` | Rep assigned to the task |
| `hs_task_status` | `COMPLETED`, `DEFERRED`, `IN_PROGRESS`, `NOT_STARTED`, `WAITING` |
| `hs_task_type` | `CALL`, `EMAIL`, `LINKED_IN`, `MEETING`, `TODO`, and Sales Navigator variants |
| `hs_timestamp` | Due date |
| `hs_task_is_open` | Whether the task remains open |
| `hs_task_is_overdue` | Whether the due date passed while open |
| `hs_task_sequence_id` | Sequence that created the task; blank means not sequence-created |
| `hs_task_sequence_step_number` | Position in the sequence |
| `hs_task_sequence_enrollment_active` | Whether the related enrollment is active |
| `hs_task_completion_date` | Completion timestamp; not proof of completed outreach by itself |
| `hs_task_last_contact_outreach` | Last specific contact activity context |
| `hs_object_source_label`, `hs_object_source_detail_1/2/3` | Creation provenance |

Classify an open `CALL` task with nonblank `hs_task_sequence_id` as a sequence-generated HubSpot call task allocated to its `hubspot_owner_id`. It is expected to sync into Nooks under the active HubSpot↔Nooks integration, but do not claim Nooks sync is confirmed without Nooks-visible evidence.

## Suppression details

Hard-suppress a contact when any of these are present:

- `hs_email_bad_address=true`;
- `hs_email_optout=true`;
- `adapt_email_validation_status=undeliverable`;
- any `hs_email_quarantined_reason`, `hs_email_customer_quarantined_reason`, or `hs_quarantined_emails` value;
- `lifecyclestage` customer or disqualified;
- `hs_current_customer=yes`;
- lead status `UNQUALIFIED` or `WRONG_PERSON`;
- current sequence enrollment.

Treat `risky`, `unknown`, blank, or stale email validation as `Validate email`, not as deliverable. Treat `BAD_TIMING` as a recycle hold unless the rep explicitly requests re-engagement.

## Email revalidation behavior

`Validate email` is a hold label, not a promise that an email-validation provider is connected. If the current environment exposes an approved validation workflow, run it only when the rep requests revalidation, then re-read the HubSpot validation fields. If no validation workflow is available, return a separate revalidation queue with HubSpot links and do not enroll those contacts. Never set `deliverable` manually or infer it from email format/domain alone.

## Live counterexamples that motivated the checks

- A Billy-owned company had newly created validated contacts owned by Jake Stone. Company ownership alone would have routed those contacts incorrectly.
- A Greg-owned company passed a company-level untouched filter, while its associated contact already had `notes_last_contacted` and two recorded sales activities.
- An Octavio-owned company had aligned validated contacts with no contact-level activity and therefore represented the intended ready state.

These examples are patterns, not allowlists.
