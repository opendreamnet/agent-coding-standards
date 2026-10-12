# Shared Development Rules

This repository contains only the shared development conventions that company
repositories select to generate their `CODING.md`.
The CLI that installs and updates these rules lives in a separate repository.

## Scope

- Maintain modular rules in `rules/`, grouped by language or tool.
- Support independent profiles such as `typescript`, `vue`, and `python`.
- Compose only the profiles declared by each consumer, in their declared order,
  without implicitly including profiles or rules for other languages.
- Write clear, concrete, reusable rules without project-specific context.
  That context and its exceptions belong in the consumer's `AGENTS.md`.

## Versioning and Changes

- Publish identifiable versions using SemVer tags, such as `v1.0.0`.
- Do not move or reuse published tags: the same version must produce the same rules.
- Keep the rules version independent of the CLI version.
- Do not implement the CLI, automated propagation, or generated files for consumer
  repositories here.
- Do not create commits, tags, releases, pushes, or PRs without an explicit request.
