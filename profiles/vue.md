# Vue Coding Conventions

These rules apply to Vue projects across the company.

Follow the installed Vue version and the consuming project's `AGENTS.md` and
configuration. This profile does not implicitly select TypeScript or other profiles.

## Reusable logic

- Use composables for reusable logic that relies on Vue reactivity, lifecycle, or component context; name them `useX`. Keep ordinary stateless helpers as plain functions in focused modules rather than wrapping them in composables or classes.
- Call composables that require component context during setup, respecting the installed Vue version's context-preservation rules. Clean up listeners, timers, and subscriptions through the appropriate lifecycle or scope disposal hooks.

## TypeScript scripts

- When the TypeScript profile is explicitly selected, its conventions also apply to TypeScript `<script>` blocks in `.vue` files. Do not convert JavaScript components solely to apply this profile.

## Template comments

Apply these rules to `<template>` blocks in `**/*.vue`.

- Use HTML comment syntax: `<!-- ... -->`.
- Write comments in English.
- Comment major sections and non-obvious intent only.
- Keep comments concise, usually single-line, and place them immediately before the section.
- Prefer clear section labels such as `Header`, `Filters`, `Results`, or `Footer actions`.
- Keep comments updated when the structure or behavior changes.

```html
<!-- Header: profile summary and quick actions -->
<section>
  ...
</section>
```
