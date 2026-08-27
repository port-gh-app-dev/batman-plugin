---
name: mcp-setup
description: >
  Configure and verify the sample MCP servers bundled with this plugin.
  Use when the user wants to connect MCP tools, set plugin variables,
  or troubleshoot missing MCP servers.
---

# MCP setup

Guide the user through configuring and verifying the MCP servers declared in `mcp.json`.

## When to use

- User asks to set up or connect MCP servers from this plugin
- MCP tools are unavailable or not responding
- User needs help setting `POSTGRES_URL` or `SAMPLE_API_TOKEN`
- Authentication or connection errors occur while calling MCP tools

## Step 1 — Identify which servers to enable

This plugin ships four sample servers:

| Server | Transport | Ready out of the box? |
|--------|-----------|------------------------|
| `memory` | stdio (`npx`) | Yes — no config needed |
| `everything` | stdio (`npx`) | Yes — demo/test server |
| `postgres` | stdio (`npx`) | Needs `POSTGRES_URL` |
| `sample-remote` | HTTP | Needs a real URL + `SAMPLE_API_TOKEN` |

Recommend starting with `memory` or `everything` to confirm MCP loading works.

## Step 2 — Configure plugin variables

For servers that need secrets:

1. Open **Cursor Settings → Plugins → Batman → Configure**
2. Set `POSTGRES_URL` and/or `SAMPLE_API_TOKEN`
3. Do **not** commit secrets to the repository

`${VAR}` placeholders in `mcp.json` are substituted from these plugin variables.

## Step 3 — Verify connection

1. Confirm the servers appear under **Cursor Settings → MCP**
2. Call a simple tool from an enabled server (for example, create/read from `memory`)
3. If a server fails, check Node/`npx` availability, variable values, and network access for remote URLs

## Step 4 — Confirm to the user

Tell the user which servers are connected and suggest a quick smoke test:

- "Store a note in the memory MCP"
- "List tools from the everything demo server"
- "Query a table with the Postgres MCP" (after `POSTGRES_URL` is set)
