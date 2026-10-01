# Agent rules

## Workspace standards

- Comments: follow the code-comment-writer skill (<https://skills.rest/skill/code-comment-writer>). Why over what, minimal, no commented-out code.
- UI/design work: use design-taste-frontend, gpt-taste, impeccable (<https://www.tasteskill.dev/>).
- Always use graphify for codebase questions (`graphify query "<q>"` before raw browsing when `graphify-out/graph.json` exists; `graphify path` / `graphify explain` for relationships and concepts; `graphify update .` after code changes).
- Long-form docs live in the Obsidian vault (`~/Documents/Obsidian Vault/<project-folder>/`); code keeps a one-line pointer. Extend an existing related note; group docs by feature, never a doc per issue.
- Never place files directly in `~/developer` or `~/developer/Code`; everything goes inside a project folder.

## Delegation

- Offload simple, self-contained work (searches, file lookups, mechanical edits, single-file checks) to subagents; keep the hard reasoning in the main thread.
- Run independent work in parallel: batch independent tool calls in one block, and spawn multiple subagents at once instead of sequentially.
