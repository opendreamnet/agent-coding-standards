# Nuxt Coding Conventions

These rules apply to Nuxt projects across the company.

Follow the installed Nuxt version, configured directory layout, and consuming
project's `AGENTS.md`. This profile does not implicitly select Vue or TypeScript.

## Reusable functions

- Use `composables/` for reusable Vue/Nuxt-context or reactive logic and `utils/` for ordinary application helpers. Reserve `useX` names for composables; do not turn every reusable function into one.
- Resolve these directories from the installed version and configuration: Nuxt 4 normally uses `app/composables/` and `app/utils/`, while Nuxt 3 normally uses them under `srcDir`.
- Use `server/utils/` only for Nitro server helpers, not for all helpers in an SSR application. Application code may execute on both server and client; keep server-only dependencies and secrets out of client-reachable modules, and browser-only APIs out of server execution paths.
- Keep reusable domain logic in focused domain modules. Nested composables are not auto-imported by default; use explicit imports or re-export them from a scanned file, unless the project already configures scanning for their directory.
- Do not keep mutable user- or request-specific state at module scope in server-executed code. Use request-scoped storage or Nuxt's SSR-safe state mechanisms to avoid sharing data across requests.
