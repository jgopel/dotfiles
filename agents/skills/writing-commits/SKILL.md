---
name: writing-commits
description: Writes git commit messages following the project template. Use when committing changes, writing commit messages, or asked to commit.
---

# Writing Commit Messages

Write commit messages following the format defined in `COMMIT_MESSAGE_TEMPLATE`
at the repo root. Read that file before writing a commit message — it is the
source of truth and may have changed since this skill was written.

## Subject Line

Format: `:emoji_code: [subsystem] Imperative verb phrase`

- Aim for 50 chars, hard limit 72 (excluding emoji markup)
- Capitalize the first word after the subsystem tag
- Do not end with a period
- Use imperative mood — the subject should complete the sentence: "If
  applied, this commit will *your subject line here*"
  - Good: "Add depth-of-book snapshots"
  - Bad: "Added depth-of-book snapshots", "Adding snapshots",
    "More snapshot stuff"
- If summarizing is hard, the commit may contain too many changes.
  Strive for atomic commits — one logical change per commit. Split into
  separate commits when changes address distinct problems or touch
  unrelated subsystems.

### Choosing a subsystem

The subsystem tag identifies the logical area of the change. Check
`git log --oneline` for subsystems already in use and prefer those over
inventing new ones. When no existing subsystem fits, use the closest
owning crate, package, or component name. Keep it short and lowercase.

### Choosing an emoji code

Pick the single emoji code that best matches the *primary intent* of the
change. Do not stack multiple emoji codes. When a commit spans
categories (e.g., a refactor that also fixes a bug), choose the one most
visible to users of the code.

## Body

Separate subject from body with a blank line. Wrap all body text at 72
characters.

### Problem section

Explain *why* the change is needed. Describe how things worked before
and what was wrong with that. Focus on motivation and context that a
future reader will need to understand the commit.

- Use `-` for bullets
- Continuation lines align with the first letter, not the bullet

### Solution section

Explain *what* you changed and *why you chose this approach*. Do not
explain *how* the code works — the diff shows that. If the code is
complex enough to need prose explanation, that belongs in source
comments, not the commit message.

Call out non-obvious consequences, side effects, or trade-offs of the
change.

Same formatting rules as Problem.

### What not to include

- Conversational filler ("as discussed", "per review", "quick fix")
- Unsubstantiated claims ("massively faster") — include measurements or
  omit
- Secrets, credentials, or internal URLs
- Implementation details that the diff already shows

## Emoji Codes

**Always use the text code (`:sparkles:`) — never the Unicode emoji
character (✨).** GitHub and other tools render the codes automatically.

Pick the code that best describes the *nature* of the change. Common
codes are listed in `COMMIT_MESSAGE_TEMPLATE`. The full set is at
https://gitmoji.dev.

## Examples

### New feature

```
:sparkles: [orderbook] Add depth-of-book snapshot support

Problem:
- Consumers need periodic full snapshots to rebuild state after
  reconnection
- Currently only incremental updates are published, forcing consumers
  to re-subscribe from scratch

Solution:
- Add DepthSnapshot message type to the orderbook publisher
- Publish full snapshots every 60 seconds on a dedicated channel
- Include sequence numbers so consumers can detect gaps
```

### Bug fix

```
:bug: [gateway] Fix sequence number wrap-around at 2^31

Problem:
- Sequence numbers overflow and wrap to negative values after extended
  uptime, causing downstream decoders to reject messages

Solution:
- Switch sequence counter from i32 to u64
- Add unit test covering the wrap-around boundary
```

### Refactor

```
:recycle: [risk] Extract margin calculation into dedicated module

Problem:
- Margin logic is scattered across three files, making it hard to
  reason about and test in isolation

Solution:
- Move all margin calculation into risk::margin module
- Expose a single MarginCalculator trait for consumers
- Update existing call sites to use the new interface
```
