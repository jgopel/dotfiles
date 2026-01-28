---
name: ralph
description: Autonomous task loop that picks ready tasks, implements them in new threads, commits, and repeats. Use when asked to "ralph", "use a ralph loop", or "ralph this".
arguments: topic
---

# Ralph Loop

Autonomous task execution loop for this repository.

## Arguments

- `topic` (optional): Only work on tasks whose title or description contains
  this keyword (case-insensitive). Examples: "observable", "auth", "migration"
  Craft a concise commit message (max 50‑char title + 1–3 bullet body) that
  summarises the change and references the user story / issue ⟨ID⟩ below (only
  if provided include it).Craft a concise commit message (max 50‑char title +
  1–3 bullet body) that summarises the change and references the user story /
  issue ⟨ID⟩ below (only if provided include it).Craft a concise commit message
  (max 50‑char title + 1–3 bullet body) that summarises the change and
  references the user story / issue ⟨ID⟩ below (only if provided include it).

## Workflow

1. **Review previous work** (if continuing a ralph loop):
   - If you just completed work in a previous thread, review what was done
   - Check if AGENTS.md should be updated with learnings (common patterns,
     gotchas, useful commands discovered)
   - Make the update if warranted, then continue
1. **Check for ready tasks**
   ```
   task_list action: "list", repoURL: "<repo-url>", ready: true
   ```
1. **Filter by topic** (if provided):
   - Only consider tasks where title or description contains the topic keyword
     (case-insensitive match)
   - Ignore tasks that don't match
1. **If no matching ready tasks**:
   - With topic: Stop and report "Ralph complete - no ready tasks matching
     '[topic]'."
   - Without topic: Stop and report "Ralph complete - no ready tasks remaining."
1. **If ready tasks exist**:
   - Pick the task most relevant to what was just completed (prefer related
     functionality, same module/area, or dependent work over unrelated tasks)
   - If no prior context or unclear relevance, pick the first matching ready
     task
   - Use the `handoff` tool with goal: "Implement and verify task \[task-id\]:
     [task-title]. [task-description]. If any test case or edge case fails and
     you can't fix it quickly, create a task for it (with exact input,
     expected/actual behavior, hypothesis) before simplifying or moving on. When
     complete, commit with the commit-messages skill (only add the relevant
     files, not add -A), mark the task completed, and invoke the ralph skill
     \[WITH TOPIC '[topic]' IF PROVIDED\] to continue the loop."

## Task Discovery

While working, **liberally create new tasks** when you discover:

- Failing tests or test gaps
- Code that needs refactoring
- Missing error handling
- Documentation gaps
- TODOs or FIXMEs in the code
- Build/lint warnings
- Performance issues
- Any other issues worth addressing Use `task_list action: "create"` to add
  these immediately. Set appropriate `dependsOn` relationships. Don't
  wait—capture issues as you find them.

## Important

- Always pass `ready: true` when listing tasks to only get tasks with satisfied
  dependencies
- The handoff goal must include instructions to commit and re-invoke ralph
- Each iteration runs in a fresh thread to maintain clean context
- Prefer tasks in the same area/module as the just-completed work for better
  context continuity
