# Codebase Exploration Results

This file documents the results of exploring the ralph-tui codebase using subagents.

## Task 1: List all directories under src/

The following directories exist under `src/`:

- `src/` (root)
- `src/chat` - Chat functionality
- `src/commands` - CLI commands
- `src/config` - Configuration management
- `src/engine` - Core engine logic
- `src/interruption` - Interruption handling
- `src/logs` - Logging infrastructure
- `src/models-dev` - Development models
- `src/plugins` - Plugin system
  - `src/plugins/agents` - Agent plugins
    - `src/plugins/agents/builtin` - Built-in agents
    - `src/plugins/agents/droid` - Droid agent
    - `src/plugins/agents/tracing` - Tracing agents
  - `src/plugins/trackers` - Tracker plugins
    - `src/plugins/trackers/builtin` - Built-in trackers
      - `src/plugins/trackers/builtin/beads` - Beads tracker
      - `src/plugins/trackers/builtin/beads-bv` - Beads-bv tracker
      - `src/plugins/trackers/builtin/json` - JSON tracker
- `src/prd` - PRD handling
- `src/sandbox` - Sandbox functionality
- `src/session` - Session management
- `src/setup` - Setup/initialization
- `src/templates` - Templates
- `src/tui` - Terminal UI
  - `src/tui/components` - TUI components
- `src/utils` - Utility functions

## Task 2: Find files with "utility" in name

Files with "utility" in the name are primarily in dependencies:

1. `node_modules/undici-types/utility.d.ts` - TypeScript declarations from undici-types
2. `website/node_modules/lucide-react/dist/esm/icons/utility-pole.js` - Lucide React icon
3. `website/node_modules/doctrine/lib/utility.js` - Doctrine library utility
4. `website/node_modules/sharp/lib/utility.js` - Sharp library utility

**Note**: No custom utility files with "utility" in the name exist in the main source code. The project uses `src/utils/` for utility functions instead.

## Task 3: List examples directory

The examples directory contains the following TypeScript files:

| File | Description |
|------|-------------|
| `arrays.ts` | Array manipulation examples |
| `greeting.ts` | Greeting/hello world examples |
| `math.ts` | Mathematical operation examples |
| `strings.ts` | String manipulation examples |

**Note**: Several files were recently deleted from this directory: `dates.ts`, `objects.ts`, `slugs.ts`, `timers.ts`, `validation.ts`

---

*Generated via ralph-tui subagent exploration on 2026-01-18*
