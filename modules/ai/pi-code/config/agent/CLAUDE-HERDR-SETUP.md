# Claude-inspired Pi + Herdr subagents

Installed extensions:

- `~/.pi/agent/extensions/claude-style.ts`: compact header, input separators, two-line status footer (directory, Git branch, model, reasoning, context, working/ready, other extension statuses). Retains Pi's native editor, autocomplete and shortcuts. Uses your existing theme.
- `~/.pi/agent/extensions/herdr-subagents.ts`: `subagent` tool with scout, planner, reviewer and worker roles. Inherits the parent's model and reasoning level. Up to four concurrent tool executions.
- Existing Herdr-managed `herdr-agent-state.ts` is left unchanged.

## Activate

Run `/reload` in Pi, or restart it. For subagents, launch Pi **inside a Herdr-managed pane**:

```sh
herdr
# In a Herdr terminal:
cd /path/to/project
pi
```

Example prompts:

- "Use a scout subagent to map authentication and report relevant files."
- "Run two subagents in parallel: a reviewer for security and a scout for test coverage."
- "Use a planner first, then a worker to implement its plan."

The tool creates a sibling pane with `--no-focus`, starts an interactive Pi agent through `herdr agent start`, and submits work using `herdr agent prompt --wait`. Each worker explicitly loads Herdr's existing lifecycle integration. Workers stay open when finished so you can inspect their terminal and session. Close finished panes manually when no longer needed.

Results come from saved JSONL transcripts in `~/.pi/agent/subagent-sessions/`, not lossy terminal snapshots. The parent receives a capped final answer and the full session path. Those transcripts can contain source code and other sensitive data; they persist until you remove them.

## Boundaries

- Outside Herdr the tool refuses to start a worker; it never silently falls back to an invisible headless process.
- Visibility is implemented for workers launched through this `subagent` tool. Prompt instructions discourage bypassing it, but this is not an OS sandbox and cannot guarantee visibility for arbitrary subprocesses launched through bash or other future extensions.
- Workers cannot recursively call this tool: child extension discovery is disabled, and only the UI and Herdr integration are explicitly loaded. They are instructed not to spawn other agents through shell commands.
- Workers share the working tree and normal user permissions. Avoid overlapping parallel edits. Scout/reviewer include bash for exploration and testing; their no-edit rule is an instruction, not an enforced read-only sandbox. Planner omits mutation tools and bash.
- Project-local resources are not automatically trusted by workers (`--no-approve`). Personal context/skills remain available.
- Cancellation sends Escape to submitted work. Timeouts/errors retain the worker pane for inspection and never blindly retry a prompt. A timed-out worker may still be working. Blocked approvals are left to the user.
- Child usage/cost remains in each child's session; the custom footer does not aggregate child costs into the parent.
- The installed Herdr integration currently reports working/idle session state. Do not assume every possible custom dialog is detected as blocked.

## Validation

```sh
node --test ~/.pi/agent/tests/claude-herdr.test.mjs
```

Five mock-based tests cover outside-Herdr refusal, interactive worker launch and result extraction, blocked-state handling, cancellation/no-retry behavior, and basic UI rendering. Extensions also passed an actual Pi JSON-mode load check. Live Herdr pane detection and visual rendering still need testing from inside Herdr; the setup session was not Herdr-managed.

## Undo

Move the two custom `.ts` files out of `~/.pi/agent/extensions/` and run `/reload`. Leave `herdr-agent-state.ts` in place. No model, theme or Pi settings were changed.
