# Python Coding Conventions

These rules apply to Python projects across the company.

Apply them to Python code being changed, not as a reason to rewrite unrelated
code. Respect the consuming project's `AGENTS.md`, supported runtime, and tool
configuration. Other profiles apply only when explicitly selected.

## General Rules

- Use Python where the project uses it; do not migrate other languages as a side effect.
- Write comments, docstrings, and technical documentation in English.
- Avoid `Any` whenever possible; prefer specific types, protocols, dataclasses, typed collections, or validated models.
- Follow the project's formatting and linting configuration. Ruff with a line length of 100 is the default when establishing new configuration, not a reason to replace existing tools.
- Read the supported Python versions from project metadata and CI. Use only syntax and APIs available on the minimum supported version; do not raise it implicitly. For a new project, select a currently supported Python release.
- Prefer dependencies already declared in the relevant project manifest and lockfile.
- Add a dependency only when existing dependencies and standard-library APIs are insufficient. Check runtime compatibility, maintenance, and known security advisories using available evidence; a recent release alone does not establish safety. Explain the addition and any checks that could not be completed.
- Use the project's dependency manager and environment. Prefer `uv` for new projects; do not migrate an existing environment merely to apply this profile.
- Prefer standard-library modules when they provide suitable functionality without making the code less maintainable.

## Repository Analysis Workflow

- Prefer indexed or semantic discovery when available before broad file reading; ordinary file and text search is sufficient otherwise.
- Use this default workflow: discover files, search symbols and usages, then read only relevant sections.
- Use exact search when the identifier or string is already known.
- Before refactors, renames, or deletions, check affected usages, references, callers, and dependents.
- Ground architectural conclusions in concrete evidence such as file paths, symbols, and callers.
- When external information is needed, prefer official documentation and source code matching the installed version. Use available search or documentation tools; do not assume a specific tool or service exists.

## Validation Workflow

- Run the configured lint, formatting, and type checks for the affected package using its managed environment. Check project scripts and configuration before choosing commands.
- Use the following commands when the project is configured with `uv`, Ruff, and Pyright:

```bash
uv run ruff check
uv run ruff format --check
uv run pyright
```

- For complete project validation, use the project scripts when available.
- Do not use automatic formatting commands such as `ruff format` to modify files unless explicitly requested or necessary to complete the task.
- Prefer `ruff format --check` for verification.
- Avoid build commands unless a build is genuinely required, because they can take a significant amount of time.
- Do not rely on globally installed tools or silently download missing ones. Use project-managed versions and report checks not run and the reason.

## Naming Conventions

Use intent-based function names with `snake_case`:

- `set_x(value)`: set an explicit value from an argument.
- `update_x(value)`: update an existing internal value.
- `get_x()`: retrieve data from local state, a cache, a database, or another internal source.
- `fetch_x()`: retrieve data from an external service or API.
- `refresh_x(...)`: recompute or reload existing data rather than accept its replacement; identifiers or refresh options are allowed.
- `create_x(...)`: create a new entity or resource.
- `validate_x(...)`: validate input and return a validation result or raise an appropriate exception.
- `parse_x(...)`: parse external or serialized data into a known internal representation.

Examples:

```python
def set_config(value: Config) -> None:
    ...


def update_user_age(value: int) -> None:
    ...


def get_user_settings() -> UserSettings:
    ...


def fetch_api_data() -> ApiData:
    ...


def refresh_user_cache() -> None:
    ...
```

Use:

- `snake_case` for functions, methods, variables, and modules.
- `PascalCase` for classes and exceptions.
- `UPPER_SNAKE_CASE` for module-level constants.
- Descriptive names instead of abbreviations, except for well-established domain terms.

## Imports and Module Structure

- Keep imports at the top of the module.
- Avoid imports inside functions unless there is a clear technical reason, such as optional dependencies, circular-dependency avoidance, or expensive conditional loading.
- Use `import` and `from ... import ...` consistently with the surrounding code.
- Keep standard-library, third-party, and local imports organized according to the configured import sorter.
- Use `TYPE_CHECKING` for imports needed only by static analysis, with deferred or quoted annotations as appropriate for the supported Python version. Keep imports available at runtime when frameworks or `get_type_hints()` need to resolve them.
- Prefer explicit imports over wildcard imports.
- Keep modules focused on one coherent responsibility.
- Avoid module-level side effects during import unless they are required by the framework or application lifecycle.

Avoid:

```python
def load_parser():
    from .parser import parse

    return parse
```

Prefer:

```python
from .parser import parse


def load_parser():
    return parse
```

## Null and Guard Style

- Use explicit early returns when they make the successful path clearer.
- Distinguish between `None`, an empty collection, `False`, and another false-y value when the distinction matters.
- Do not hide important validation inside dense expressions or chained conditional expressions.

Prefer:

```python
if value is None or not value.property:
    return

continue_with_value(value)
```

Avoid:

```python
if value and value.property:
    continue_with_value(value)
```

when `value` may legitimately be a false-y object that is not `None`.

## Type Annotations and Data Modeling

- Add type annotations to public functions, methods, class attributes, and important local boundaries.
- Prefer specific types over `Any`.
- Use `object` when a boundary accepts arbitrary values, then validate and narrow before use. Python has no standard `Unknown` annotation; annotations and `cast()` do not validate runtime data.
- Use built-in generic types such as `list[str]`, `dict[str, int]`, and `tuple[str, ...]` for Python 3.10 or newer.
- Use `TypedDict`, `dataclass`, `Protocol`, or a dedicated model when a data shape is known and reused.
- Use `Literal`, `TypeAlias`, and `TypeGuard` when they clarify a meaningful contract.
- Do not create a type abstraction merely to avoid a small annotation.
- Keep small local type aliases and protocols near their usage.
- Extract shared contracts into focused modules when they have independent consumers or make the implementation difficult to navigate. Use names such as `users/contracts.py` rather than a top-level module that shadows the standard library.
- Avoid mutable default arguments. Use `None` or `default_factory` where appropriate.

Example:

```python
from dataclasses import dataclass


@dataclass(frozen=True)
class TranslatorOptions:
    source_language: str


class Translator:
    def __init__(self, options: TranslatorOptions) -> None:
        self._source_language = options.source_language
```

## Modularization and Dependency Flow

- Do not implement major features directly in a single orchestrator, command handler, route, or entry-point module.
- Keep orchestrators thin; delegate responsibilities to dedicated modules, services, or classes.
- Wire long-lived dependencies at the application entry point or through the framework's lifecycle mechanisms. Pass dependencies explicitly; do not introduce a container or class hierarchy for a simple function.
- Store orchestrator-owned module instances as private attributes when applicable.
- Do not use ad-hoc getter callbacks such as `get_x=lambda: x` as the default dependency flow.
- If data is lifecycle-stable, pass the value directly and avoid unnecessary mutation.
- If data is dynamic, inject a narrow service interface or protocol. A callback is appropriate when deferred evaluation is part of the contract.

Keep the root focused on wiring and coordination:

```python
class FeatureOrchestrator:
    def __init__(self) -> None:
        self._feature_module = FeatureModule()

        self._secondary_module = SecondaryModule(
            feature_module=self._feature_module,
        )
```

The modules should contain their own responsibilities rather than moving feature implementation into `FeatureOrchestrator`.

For a stable value, pass it directly rather than introducing a getter callback:

```python
class Translator:
    def __init__(self, source_language: str) -> None:
        self._source_language = source_language
```

Avoid replacing that value with an ad-hoc callback:

```python
from collections.abc import Callable


class Translator:
    def __init__(self, get_source_language: Callable[[], str]) -> None:
        self._get_source_language = get_source_language
```

If the value is dynamic, inject the responsible module or a narrow protocol,
unless an established provider contract requires a callback. An underscore-prefixed
attribute is an implementation convention, not an enforcement of immutability.

## Reuse and Duplication

- Extract repeated logic when it represents the same responsibility and should change together. Do not create helpers for hypothetical reuse or merge similar-looking code with different domain rules.
- Keep helpers near their callers, as module-level functions or private methods according to who owns the behavior.
- Do not extract domain-specific logic into a generic utility merely to shorten a class.
- Before adding a helper, determine whether it is an independent function or part of a project-specific domain workflow.

### Function Location

- Keep single-use helpers in their owning module. Place shared standalone functions in focused modules following the project's structure.
- Keep business workflows in domain modules or services, whether implemented as functions or classes.
- Move only reusable standalone logic to utilities.
- Group independent functions by one theme per module instead of creating catch-all utility modules.
- Use descriptive module names and avoid shadowing standard-library or installed packages, for example with a top-level `types.py` or `string.py`.
- Use the project's established package structure. Do not introduce framework-specific conventions that do not belong to the project.

## Independent Functions

- Prefer a module-level function for straightforward stateless logic. Introduce a class when shared state, lifecycle, or a domain contract justifies it.
- Use classes when the logic is sufficiently complex or stateful to justify them. A class is appropriate when several operations depend on the same evolving or lifecycle-bound value, such as a user, session, database connection, transaction, or configured client.
- Functions may depend on project-specific classes, such as `User`, when the function's logic is abstract enough that it does not feel naturally owned by that class, or when the function is reused across multiple parts of the project and placing or referencing the logic through the class would add unnecessary complexity.
- Do not force logic into a class merely because its parameters include an instance of that class. Ownership of the data and ownership of the behavior are separate decisions.
- Prefer a class when the behavior primarily represents an operation or workflow owned by the entity, or when several operations share the same complex state or lifecycle.
- Name functions by their operation, such as `resize_image`, or `resize` when called as `image.resize`. Follow established public names; do not mechanically prefix every function with its module name.
- Expose reusable functions at module level; prefix internal helpers with `_` rather than treating all helpers as public API.
- Prefer optional parameters with sensible defaults when the operation has a meaningful default.
- Keep parameters required when the operation cannot be correct without them.
- When an independent function interacts with an external library, use the library's exported types whenever available.
- Independent functions may use native platform classes such as `pathlib.Path`, `io.BytesIO`, and `datetime`, or external libraries such as Pillow and SQLAlchemy.
- Independent functions should not depend on an entire application lifecycle, framework container, global mutable state, or unnecessary project-specific setup.
- Before creating a class, determine whether the behavior can be expressed as a group of independent functions with explicit parameters.
- The goal is not to avoid classes completely. The goal is to keep simple or abstract behavior as explicit functions and introduce classes only when shared state, lifecycle management, or domain complexity provides a concrete justification.

Prefer an independent function when the logic is abstract, reusable, and does not clearly belong to `User`:

```python
# authorization/subjects.py


def get_subject_attributes(user: User) -> dict[str, str]:
    """Build the attributes required by an authorization policy."""
    ...


def get_resource_scope(user: User) -> str:
    """Resolve the access scope used by authorization rules."""
    ...
```

Prefer a class when the operations form a complex workflow around shared state:

```python
class UserService:
    def __init__(self, user: User, repository: UserRepository) -> None:
        self._user = user
        self._repository = repository

    def display_name(self) -> str:
        """Return the display name for the configured user."""
        ...

    async def save(self) -> None:
        """Persist the configured user."""
        ...
```

The decision should be based on cohesion, complexity, reuse, and shared state, not only on whether a function receives an instance of a project-specific class.

### Project-Coupled Reusable Functions

- If reusable logic depends on a project-specific class or system, keep it in a domain subpackage.
- Use domain-oriented modules such as `users/utils.py`, `billing/services.py`, or `orders/use_cases.py`.
- Choose a function or class based on ownership, shared state, and lifecycle, not merely on the presence of an ORM model parameter.
- Extract a utility only when independent reuse provides real value.

## Class Design

- Use underscore-prefixed attributes and methods for implementation details.
- Do not rely on name mangling with double underscores unless there is a concrete need.
- Use `@property` for derived values or controlled read access, not as a replacement for ordinary methods.
- Use `Final` to tell a type checker that a name must not be reassigned; it does not prevent mutation or enforce restrictions at runtime.
- Use immutable data structures when contents must not change. `@dataclass(frozen=True)` prevents normal field assignment but does not freeze mutable objects stored in its fields.
- Keep public workflows stable and expose the smallest practical API.
- Prefer composition or strategy objects when only one behavior varies.
- Do not expose mutable internal state to subclasses or callers unless there is a clear, documented need.
- Prefer protocols or composition over inheritance when extension does not require shared implementation.

Example:

```python
from typing import Protocol


class BaseTask:
    def __init__(self) -> None:
        self._is_running = False

    async def run(self) -> None:
        if self._is_running:
            raise RuntimeError("Task is already running")

        self._is_running = True

        try:
            await self.before_run()
        finally:
            self._is_running = False

    async def before_run(self) -> None:
        """Allow subclasses to prepare the task without changing the workflow."""
        return


class Formatter(Protocol):
    def format(self, value: str) -> str:
        ...
```

Use inheritance only when the subtype genuinely satisfies the parent contract. Prefer a strategy or injected protocol when only one behavior varies.

## Declarations and Expressions

- Avoid unnecessary mutation and reassignment, but use ordinary local variables when they make the algorithm clearer. Python has no `const` or `let` declaration modes.
- Prefer direct expressions and small helpers over deeply nested temporary variables.
- Give external data a named shape when its structure is known.
- Keep object and collection literals readable.
- Put nested data on separate lines when it improves scanning.
- Let Ruff determine continuation indentation and formatting.
- For long method chains, place each meaningful call on its own continuation line.
- Do not manually align whitespace or compress nested payloads to reduce line count.

## Control Flow

- Use explicit blocks for conditional and loop bodies.
- Keep one logical action per conditional branch.
- When several branches perform the same kind of operation, make the distinction between them visible.
- Avoid deeply nested conditionals. Prefer guards, early returns, or small named helpers.
- Await asynchronous operations or schedule them with explicit ownership so completion and failure are observed. Do not block the event loop with synchronous I/O inside async code.
- Use `asyncio.create_task()` for intentional concurrency, retaining task references and managing completion, errors, and cancellation. Detached tasks still need lifecycle ownership and error handling; prefer structured concurrency such as `TaskGroup` when supported by the project's Python version.
- Validate and narrow external or persisted data at the boundary.
- Raise specific exceptions and preserve useful context.
- Do not catch `Exception` broadly unless the code re-raises, translates, logs, or otherwise handles the failure intentionally.

## Visual Density and Blank Lines

- Keep code visually compact while prioritizing first-read legibility.
- Separate logical phases with one blank line; do not split cohesive code solely to satisfy a line count.
- Treat a multiline expression, call, declaration, or collection literal as one logical unit.
- Add spacing around multiline logical units when they separate distinct phases, not automatically around every multiline expression.
- Put two blank lines between top-level functions and classes, following standard Python formatting.
- Let the configured formatter determine spacing after imports and between declarations.
- Do not add padding immediately after an opening block or immediately before a closing block.
- In a method with several guards, group related checks together and separate groups with one blank line.
- Add a short phase comment only when it explains intent not already clear from the code. Blocks such as `if`, `for`, and `with` do not introduce a separate local scope; do not add them to isolate variables.

Example:

```python
validation = validate_payroll_input(input_data)
errors = list(validation.errors)
warnings = list(validation.warnings)

salary_resolution = resolve_salary_history(
    input_data.salary_history,
    input_data.employee.id,
    input_data.period.starts_on,
    input_data.period.ends_on,
)

incident = input_data.incidents[0] if input_data.incidents else None
paid_days = incident.paid_days if incident else input_data.period.days
scale = max(4, input_data.rounding.scale)
salary = salary_resolution.record

line: PayrollLineResult | None = None
```

## Comments and Docstrings

### Python Comments

- Keep comments high-signal and maintenance-friendly.
- Every public function, method, class, and important private function must have an English docstring.
- Use docstrings to describe purpose, behavior, important arguments, return values, raised exceptions, side effects, or non-obvious assumptions.
- Do not write docstrings that merely restate the function name.
- Add documentation comments to public class attributes when their meaning is not obvious.
- Keep comments updated with code changes and remove stale comments.
- Prefer short `#` section comments inside functions when they make logical sections easier to locate.
- Keep section comments immediately above the section they describe.
- Use section comments for real conceptual groups, not for individual obvious statements.
- Keep inline comments near non-obvious algorithms, compatibility constraints, external service behavior, or coupled logic.
- Do not add empty docstrings or comments that only restate syntax.

Use a docstring to explain a contract that is not apparent from the signature:

```python
def enhance_prompt(prompt: str) -> str:
    """Enhance a prompt after validation, propagating generation failures."""

    request = prepare_prompt_request(prompt)

    response = generate_prompt(request)

    return response.prompt
```

Avoid:

```python
def enhance_prompt(prompt: str) -> str:
    """Enhance prompt."""

    request = prepare_prompt_request(prompt)

    return request.prompt
```

For simple private functions, keep the docstring concise but meaningful:

```python
def _normalize_name(value: str) -> str:
    """Return a normalized name suitable for comparison."""
    return " ".join(value.split()).casefold()
```

## Exceptions and Resource Management

- Raise exceptions that describe the actual failure.
- Define project-specific exception classes when callers need to distinguish domain failures.
- Preserve the original exception context with `raise ... from error` when translating exceptions.
- Do not use exceptions for ordinary control flow when a direct conditional is clearer.
- Use context managers for files, locks, transactions, sessions, and other managed resources.
- Ensure cleanup occurs through `with`, `async with`, `try/finally`, or the lifecycle mechanism provided by the framework.
- Do not silently suppress errors.

Example:

```python
try:
    response = client.fetch_data()
except ClientError as error:
    raise DataFetchError("Unable to fetch remote data") from error
```

## Testing

- Add or update tests for behavior changed by the implementation.
- Keep tests deterministic and independent from execution order.
- Prefer focused unit tests for pure functions and domain rules.
- Use integration tests for database, filesystem, network, queue, and framework behavior.
- Do not weaken production types or validation merely to make tests pass.
- Name tests according to the behavior they verify.
- Keep fixtures small, explicit, and reusable.
- Avoid excessive mocking. Mock external boundaries, not internal implementation details.
- Run the relevant test suite, including failure paths, together with the configured static checks when changing behavior.

## Conflict Resolution and Execution

When rules conflict, apply this order:

1. Runtime correctness and the existing architecture.
2. Formatting, linting, and type-checking compliance.
3. Naming, documentation, and other style preferences.

- Prefer minimal, targeted edits.
- Do not change runtime behavior unless required by the task.
- If intent is unclear and logic changes are risky, keep behavior unchanged and state the assumption in the response.
- Preserve compatibility with the project's supported Python version.
- Follow framework-specific conventions only when they are required by the framework or explicitly documented by the project.
