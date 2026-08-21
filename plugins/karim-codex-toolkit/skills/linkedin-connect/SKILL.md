---
name: linkedin-connect
description: Connect the user's LinkedIn account for LinkedIn automation. Use when the user asks to connect LinkedIn, set up LinkedIn automation, reconnect LinkedIn, or check whether LinkedIn is connected.
---

# LinkedIn Connect

Use the `linkedin-automation` MCP connector.

1. Load `linkedin_connection_status` from the connector.
2. Complete the connector's authorization flow using the user's work Google account.
3. Call `linkedin_connection_status`.
4. When it returns `status: "connected"`, reply with: `LinkedIn's connected.`
