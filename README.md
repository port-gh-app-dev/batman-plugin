# Batman Plugin for Cursor

A full-featured **Cursor plugin** starter with sample MCP servers, skills, rules, agents, commands, and hooks. Use it as a template for building and publishing your own plugin to the Cursor Marketplace or a team marketplace.

---

## What's included

| Component | Path | Purpose |
|-----------|------|---------|
| Manifest | `.cursor-plugin/plugin.json` | Plugin metadata and variable schema |
| MCP servers | `mcp.json` | Sample stdio and remote MCP configs |
| Skills | `skills/` | Agent workflows (`code-reviewer`, `mcp-setup`) |
| Rules | `rules/` | Always-on and on-demand coding guidance |
| Agents | `agents/` | Custom subagent (`security-reviewer`) |
| Commands | `commands/` | Slash commands (`/deploy-staging`) |
| Hooks | `hooks/hooks.json` | Lifecycle hooks + `scripts/` |
| Assets | `assets/logo.svg` | Plugin logo |

### Sample MCP servers

| Server | Transport | Notes |
|--------|-----------|-------|
| `memory` | stdio (`npx @modelcontextprotocol/server-memory`) | Works with no config |
| `everything` | stdio (`npx @modelcontextprotocol/server-everything`) | Demo/test MCP |
| `postgres` | stdio (`npx @modelcontextprotocol/server-postgres`) | Needs `POSTGRES_URL` |
| `sample-remote` | HTTP | Placeholder URL; needs `SAMPLE_API_TOKEN` |

Replace `sample-remote` with your real remote MCP endpoint (for example Port, GitHub, or an internal API).

---

## Requirements

- [Cursor](https://cursor.com) v2.6.0 or later
- Node.js / `npx` on `PATH` (for the stdio sample servers)

---

## Installation

### Local development

Symlink or copy this repo into Cursor's local plugins directory:

```bash
ln -s "$(pwd)" ~/.cursor/plugins/local/batman
```

Then reload Cursor (**Developer: Reload Window**) and confirm the plugin under **Settings → Plugins**.

On Teams/Enterprise, enable **Allow Local Plugin Imports** if local plugins are blocked.

### From the Cursor Marketplace

1. Open Cursor Settings → **Plugins**
2. Search for **Batman**
3. Click **Install**

*(Publish first at [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish).)*

---

## Configuration

Servers that need secrets use plugin variables declared in `.cursor-plugin/plugin.json`:

| Variable | Used by |
|----------|---------|
| `POSTGRES_URL` | `postgres` MCP |
| `SAMPLE_API_TOKEN` | `sample-remote` MCP |

Set them in **Cursor Settings → Plugins → Batman → Configure**. Do not commit secrets.

Ask the agent to run the **mcp-setup** skill if you need guided configuration.

---

## Usage

Once installed, try:

```
Store a note about our deploy process in the memory MCP
List tools from the everything demo server
Review this PR for security issues
/deploy-staging
```

### Local validation

Run the same checks used by CI before publishing or sharing a local plugin:

```bash
./scripts/validate-plugin.sh
./scripts/format-code.sh
```

The validator checks JSON syntax, required manifest metadata, MCP server
definitions, hook references, executable permissions, and required
documentation. It exits non-zero when a required check fails.

The lifecycle hooks are intentionally conservative:

- `format-code.sh` verifies that hook scripts are executable and consistently
  newline-terminated.
- `validate-shell.sh` blocks destructive commands and suspicious download
  pipelines before they run.
- `audit.sh` checks that the plugin's core files exist at session end and warns
  when a sample endpoint is still configured.

Hook scripts receive their command input from Cursor. When run manually,
`validate-shell.sh` also accepts the command as its first argument.

---

## Repository structure

```
batman-plugin/
├── .cursor-plugin/
│   └── plugin.json          # Cursor plugin manifest
├── agents/
│   └── security-reviewer.md
├── assets/
│   └── logo.svg
├── commands/
│   └── deploy-staging.md
├── hooks/
│   └── hooks.json
├── rules/
│   ├── coding-standards.mdc
│   └── review-checklist.mdc
├── scripts/
│   ├── audit.sh
│   ├── format-code.sh
│   └── validate-shell.sh
├── skills/
│   ├── code-reviewer/
│   │   └── SKILL.md
│   └── mcp-setup/
│       └── SKILL.md
├── mcp.json                 # MCP server configuration
├── CHANGELOG.md
├── LICENSE
└── README.md
```

---

## Customizing

1. Update `name`, `displayName`, `description`, and `author` in `.cursor-plugin/plugin.json`
2. Replace sample MCP entries in `mcp.json` with your real servers
3. Add or edit skills under `skills/<name>/SKILL.md`
4. Replace hook script placeholders in `scripts/`
5. Update `assets/logo.svg` and bump `version`

For multi-plugin repos, see the official [cursor/plugin-template](https://github.com/cursor/plugin-template).

---

## Support

- [Cursor Plugins docs](https://cursor.com/docs/plugins)
- [Cursor MCP docs](https://cursor.com/docs/mcp)
- [Port Documentation](https://docs.port.io)

## License

MIT — see [LICENSE](./LICENSE) for details.
