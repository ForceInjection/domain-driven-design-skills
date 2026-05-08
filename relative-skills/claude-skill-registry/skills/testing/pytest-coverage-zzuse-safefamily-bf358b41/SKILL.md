---
name: pytest-coverage
description: Generate or extend pytest suites to reach at least 80% total coverage for the repository while excluding src/safe_family/templates/miscellaneous/. Use when asked to add tests, raise coverage, or set up CI coverage gates.
---

# Pytest Coverage Skill

## Checklist before writing tests
- Map critical modules: auth/session, todo CRUD/long-term goals, scheduler jobs, URL analyzers/blocker, notifications, CLI entrypoints. Note DB/network touchpoints to mock.
- Confirm coverage config or add it (see **Config**). Always exclude `src/safe_family/templates/miscellaneous/`.
- Identify fast, deterministic seams (pure functions like `generate_time_slots`, `infer_tag`, `get_time_range`, etc.) for unit coverage; avoid real DB/network/FS.

## Config
- Prefer pyproject with coverage + pytest options:
  ```toml
  [tool.coverage.run]
  branch = true
  source = ["src"]
  omit = ["src/safe_family/templates/miscellaneous/*"]

  [tool.coverage.report]
  show_missing = true
  skip_covered = true
  fail_under = 80

  [tool.pytest.ini_options]
  addopts = "-q --disable-warnings --cov --cov-report=term-missing"
  ```
- If pyproject cannot be changed, pass flags: `python -m pytest --cov=src --cov-report=term-missing --cov-fail-under=80 --cov-config=pyproject.toml`.

## Test-writing patterns
- **Pure helpers**: Assert exact outputs and boundary errors; freeze `now` via parameters or monkeypatch.
- **DB-backed functions**: Prefer patching `get_db_connection`/SQLAlchemy with fakes; avoid hitting real DB. Validate SQL parameters via mocks/spies.
- **Scheduler/commands**: Patch APScheduler, subprocess, requests, and timeouts. Assert functions called with expected args; do not perform network/router calls.
- **Blueprint routes**: Use Flask test client and `app.test_client()`; seed JWT/session via fixtures; patch external services (mail, requests.post).
- **Notifications**: Mock `requests.post` and `mail.send`; assert payload structure, no real HTTP.
- **Long-term goals/time tracking**: Use fixed datetimes; patch `local_tz` or inject `today`.

## Workflow
1) Select targets that maximize uncovered lines while avoiding excluded templates. Start with pure utilities, then branchy routes/CLI, then scheduler logic.
2) Add/extend fixtures in `tests/conftest.py` for app factory, test client, and mock DB/requests/mail.
3) Write small, focused tests (arrange/act/assert) with descriptive names; cover success and error branches.
4) Run `python -m pytest`; iterate until coverage ≥ 80% and no flakiness. Use `--maxfail=1` during iteration for speed.

## CI
- Ensure workflow installs deps and runs `python -m pytest` with coverage flags or pyproject config. Keep runtime minimal (no services). Use `PYTHONPATH=${{ github.workspace }}`.
