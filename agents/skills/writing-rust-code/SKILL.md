---
name: writing-rust-code
description: Rust coding conventions for this workspace. Use when writing, reviewing, or modifying any Rust code in the rust/ directory.
---

# Writing Rust Code

These are the conventions that differ from standard Rust practice. If something
is not listed here, follow standard idioms.

## Workspace Constraints

- All 9 clippy lint groups enabled as warnings (including `restriction`). Do not
  add crate-level lint attributes.
- Use `#[expect(...)]` for lint suppression, not `#[allow(...)]`. There are rare
  cases where `#[allow]` is required (e.g., macro hygiene). If you think you
  need `#[allow]`, stop and ask the user for guidance.
- No `dyn` trait objects — no `Box<dyn Error>`, no `Box<dyn Trait>`, no
  `&dyn Trait`. Use enums or generic type parameters instead. This also means no
  `anyhow` in library code (it uses `dyn Error` internally). Use `thiserror`.
- No `serde_json` — use `sonic_rs` for all JSON operations. Do not use
  `serde_json::Value`, `serde_json::json!()`, or `serde_json::RawValue`.

## Imports

Fully qualified paths by default. `use` statements only for:

1. Trait method imports: `use futures::SinkExt as _;`
1. Paths exceeding 120 characters.

No `super::super` — prefer `crate::` paths. Test modules may use `use super::*`.

## Error Handling

- `#[from]` only for unique 1:1 error mappings. When the same source type maps
  to multiple variants, use `#[source]` and `map_err(Variant)` (pass the
  constructor directly, no closures).
- On deserialization failures, capture the raw payload in the error variant.
  Only log raw JSON at `tracing::trace!` level.
- In production code, never `.unwrap()`. Use `.expect()` only for compile-time
  provable invariants.
- In test code, prefer `.unwrap()` over `.expect()` for brevity.

## Domain Types

### String newtypes — `std_ext::string!`

Never use raw `String` for identifiers, credentials, or codes:

```rust
std_ext::string!(pub ClientOrderId, {
    derives: [serde::Serialize],
    owned_type_derives: [serde::Deserialize]
});
```

Generates a borrowed/owned pair (`ClientOrderId` / `ClientOrderIdOwned`).

### Financial numerics

- `fixnum_ext::ExactFixedPoint<I, P>` — rejects values that can't be represented
  exactly. Preferred for API clients.
- `nxyz::Price<T>` / `nxyz::Quantity<T>` / `nxyz::Position<T>` — semantic
  wrappers with domain constraints.
- Each exchange crate defines type aliases with appropriate precision.
- Never use `f64` for financial data unless the upstream protocol requires it.
- Never introduce `rust_decimal::Decimal` in new code.

### Derives

Always use fully qualified derive paths (`serde::Serialize`, not `Serialize`).
Use `derive_more` for mechanical impls. Use
`#[cfg_attr(test, derive(PartialEq))]` when equality is only needed in tests.

### Enums

ClickHouse-bound enums: `#[repr(i8)]`, discriminants start at 1. Always use
exhaustive `match` on upstream types — no wildcard arms.

## Serialization

- Use `serde_ext::empty_string_is_none` for APIs that send `""` instead of
  `null`.
- Use `chrono_ext::serde::*` and `clickhouse::serde::chrono::*` for timestamp
  formats.
- Response-only types: `#[cfg_attr(test, derive(serde::Serialize))]`.

### Protobuf

Inner `mod proto` with `tonic::include_proto!`, re-export via
`pub use proto::*`. Type aliases for client/server/trait names. Hand-written
`From`/`TryFrom` conversions — numeric fields are strings in proto, parsed to
`ExactFixedPoint`.

## Testing

- Inline `#[cfg(test)] mod tests` with nested submodules per function under
  test.
- `pretty_assertions::assert_eq` imported **per-submodule**, not at `mod tests`
  level.
- No `test_` prefix on test names.
- No `mockall` — hand-write mock structs implementing traits, record calls with
  `Arc<Mutex<Vec<...>>>`.
- Fixtures: `pub mod fixtures` (plural), not behind `#[cfg(test)]`.
- Use `rstest` with named `#[case::name]` for parameterized tests.
- Tests never return `Result`.

## Async and Concurrency

- **Graceful shutdown:** `wind-down` crate, only when a task needs final actions
  or must be fully halted (not just aborted). Use `biased` `tokio::select!` with
  shutdown as the first branch.
- **Task RAII:** `tokio_ext::SafeHandle` (aborts on drop). Store as `_`-prefixed
  fields. `SafeHandle` handles abort-on-drop only, not graceful shutdown.
- **No `JoinSet`** — manage tasks individually with `JoinHandle` + `select!`.
- **Rate limiting:** `rate_limit::RateLimiter` (token-bucket on `Semaphore`).
- **WebSockets:** split via `futures::StreamExt::split()`, shared sink via
  `Arc<tokio::sync::Mutex<SplitSink<...>>>`, generic over transport for
  testability.

## Logging

- Fully qualified: `tracing::info!(...)`, never import macros.
- Prefer format-string style: `tracing::debug!("Placing order for {symbol:?}")`.
- Do not log inside functions that return `Result` — return the error and let
  the caller decide severity.
- Binary init:
  `tracing_preset::setup_tracing(level, tracing_preset::get_format_from_env())`.
