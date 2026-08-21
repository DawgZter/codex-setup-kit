---
name: select-adapt-chrome
description: Select the correct Google Chrome identity for every Chrome browser task, including logged-in dashboards, open tabs, account-specific sites, and public browsing. Use the recipient's configured Adapt work profile by default and their personal profile only when explicitly requested.
---

# Select Adapt Chrome

Use the account named by `CODEX_WORK_CHROME_EMAIL` as the persistent default identity for Chrome work. Treat the account named by `CODEX_PERSONAL_CHROME_EMAIL` as a one-task override, not a new default. If these identities have not been configured, ask the user to identify the work profile before account-specific access; never inherit Karim's identity from the source setup.

## Profile-selection rules

1. Follow the Chrome control skill for browser setup, safety, interaction, and cleanup.
2. Before reading or interacting with a Chrome page, ensure the selected Chrome binding belongs to the Adapt profile.
3. Verify identity from read-only, visible browser state such as an open-tab title or the signed-in account shown by a product UI. Never inspect cookies, local storage, passwords, Chrome profile directories, or session stores.
4. If the initially selected Chrome binding is clearly personal, do not use it. When multiple extension browser connections are available, use read-only browser discovery to select the connection whose visible state identifies the configured work account.
5. If the Adapt profile cannot be identified or connected safely, stop before accessing account-specific data and ask the user to open or focus that Chrome profile and enable the Codex Chrome extension. Never silently fall back to the personal profile.

## Personal-profile override

Use the configured personal account only when the user explicitly says `personal`, `personal Chrome profile`, or names that account for the current task. Do not infer personal-profile intent from the website being visited.

After the personal task ends, restore the configured work account as the default for subsequent Chrome work.

## Safety boundary

- Keep all authenticated reads and interactions inside the requested profile.
- Do not copy information between the Adapt and personal profiles unless the user explicitly requests that transfer.
- If profile identity is ambiguous, ask rather than risk using the personal account.
