# Git Hooks

Enforces security, formatting, compile-time correctness, and commit conventions.

## Hooks

| Hook       | Trigger     | What it checks                                          | Time   |
|------------|-------------|---------------------------------------------------------|--------|
| `pre-commit` | `git commit`  | Security scan · `moon fmt` · `moon info` · `moon check` | ~5s   |
| `commit-msg` | `git commit`  | Conventional Commits format                             | instant |
| `pre-push`   | `git push`    | `moon check` · `moon test` (tag pushes skipped)         | ~35s   |

## Setup

```bash
git config core.hooksPath .githooks
```

## Why `pre-push` instead of `pre-commit` for `moon test`?

`moon test` runs 772 tests in ~30s. Running it on every `git commit` makes iteration unbearably slow. Pre-push guarantees no broken code leaves the local repo without having been tested, while keeping the commit cycle snappy.

## Conventional Commits

```
feat(core): add Dijkstra algorithm
fix(storage): handle empty graph edge case
docs(readme): update installation instructions
ci: add deprecation warning gate
chore(githooks): optimize pre-commit hook
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.

Merge commits (`Merge branch ...`) are exempt.

## Bypassing hooks

```bash
git commit --no-verify   # skip pre-commit and commit-msg
git push --no-verify    # skip pre-push
```