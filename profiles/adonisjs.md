# AdonisJS Coding Conventions

These rules apply to AdonisJS backends across the company.

Follow the installed AdonisJS version and the consuming project's `AGENTS.md`,
directory conventions, and import aliases. This profile does not implicitly select
TypeScript or other profiles.

## Reusable functions

- Keep single-use helpers close to their callers. Place shared standalone functions in focused modules, using the project's existing casing and aliases, for example `app/utils/image.ts`; do not create a competing `app/Utils/` tree.
- Use descriptive operation names such as `resizeImage`. Preserve an established `use<Theme><Name>` convention when the project requires it, but do not introduce that prefix merely because a function is reusable.
- Keep project-coupled reusable logic in the owning domain or service layer rather than presenting it as a generic utility. Name each module for its responsibility.

## Domain workflows

- Keep controllers focused on request handling and delegate substantial workflows to the existing domain or service layer. Choose functions or classes based on shared state, lifecycle, and responsibility; accepting an ORM model does not by itself justify a class or manager.
- Use the framework's established dependency injection and lifecycle mechanisms when needed. Do not create a parallel container or new actions/managers hierarchy solely to apply this profile.
