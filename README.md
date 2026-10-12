# Agent Coding Standards

Shared coding conventions for AI agents working across company repositories.

This repository contains only the rules; the CLI that installs and updates them
is maintained separately.

## Usage

Consumer repositories declare a pinned rules version and an ordered list of
profiles in the YAML front matter of their `CODING.md`. The separate CLI combines
only those profiles, in the declared order, into the generated document.

Project-specific context and exceptions belong in the consumer's `AGENTS.md`,
which should instruct agents to consult `CODING.md` before changing code.

## Versioning

Rules use SemVer tags such as `v1.0.0`, independently of the CLI version.
Published tags must not be moved or reused. Synchronizing keeps the pinned rules
version; adopting a newer release requires an explicit update.
