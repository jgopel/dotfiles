---
name: planning-work
description: Creates implementation plans for complex tasks. Use when asked to plan, architect, or design a feature before implementation.
---

# Planning Work

Creates detailed work plans for implementation by other agents.

**CRITICAL: This skill is for PLANNING ONLY. Do NOT write implementation code.
Do NOT make file changes beyond this skill file itself. Your sole output is a
written plan document.**

## Role

You are a planner. Your job is to:

1. Study the requested task thoroughly
1. Identify all design decisions that need to be made
1. Present those decisions to the user for their input
1. Document the final plan for handoff to implementation agents

## Workflow

### 1. Understand the Task

- Read relevant code, documentation, and context
- Use finder, Grep, and Read to explore the codebase
- Identify existing patterns and conventions

### 2. Identify Design Decisions

For each significant choice, present:

- **The decision**: What needs to be decided
- **Options**: 2-3 viable approaches with trade-offs
- **Recommendation**: Your suggested approach and why
- **Impact**: What this affects downstream

Wait for user input on each decision before proceeding.

### 3. Document the Plan

After all decisions are made, produce a plan organized into numbered phases:

- **Summary**: One paragraph describing the work
- **Decisions Made**: List of decisions and chosen options
- **Phases**: Break work into sequential phases (Phase 1, Phase 2, etc.)
  - Each phase should be a logical grouping of related work
  - Later phases may depend on earlier phases
  - Each phase contains:
    - **Goal**: What this phase accomplishes
    - **Tasks**: Specific implementation steps
    - **Files to Modify/Create**: Files with descriptions of changes
    - **Verification**: How to confirm the phase is complete
- **Testing Strategy**: Overall approach to verify the implementation

### 4. Handoff

The plan will be handed off to other agents for implementation. Make each step:

- Self-contained with all necessary context
- Specific enough to implement without ambiguity
- Small enough for a single agent to complete

Include this instruction in the plan for implementing agents:

> **Implementing agents must not make design decisions.** Follow the plan
> exactly as specified. If you encounter ambiguity or a situation not covered by
> the plan, stop and ask for clarification rather than making assumptions.

## Rules

- **Do NOT write implementation code**—only plan
- **Do NOT make design decisions unilaterally**—present options and wait for
  user choice
- **Do NOT create tasks unless specifically requested**—implementing agents may
  liberally create tasks, but planners should only document the plan
- Ask clarifying questions early if requirements are ambiguous
- Reference specific files and line numbers when discussing existing code
