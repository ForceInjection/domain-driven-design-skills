---
name: supertester-otp-testing
description: This skill should be used when teams need to adopt Supertester to build deterministic Elixir OTP tests with isolation, synchronization, and supervision coverage.
license: Complete terms in LICENSE
---

# Supertester OTP Testing

## When To Trigger
- Activate whenever writing or reviewing new OTP-heavy tests so Supertester foundations are considered before adding bespoke helpers.
- Activate when eliminating flaky OTP tests, `Process.sleep/1` calls, or race conditions in Elixir suites.
- Activate when installing or upgrading Supertester and clarifying how OTP helpers should shape new or existing tests.
- Activate when validating supervision restarts, chaos scenarios, or performance contracts with Supertester-provided tooling.

## Core Goals
- Establish isolation with `Supertester.UnifiedTestFoundation` and run OTP tests safely with `async: true`.
- Retrofit GenServers and supervisors to use deterministic synchronization via Supertester helpers.
- Replace bespoke OTP utilities with the official helpers and assertions in `lib/supertester`.
- Surface reusable diagnostics that make failures obvious and repeatable.

## Quick Orientation
- Review `README.md` for feature highlights and before/after examples.
- Use `MANUAL.md` for full API coverage; jump to the “OTP Testing Helpers” section for signatures.
- Keep `docs/QUICK_START.md` on hand for migration recipes and example code.
- Inspect source modules directly (`lib/supertester/otp_helpers.ex`, `lib/supertester/genserver_helpers.ex`, `lib/supertester/unified_test_foundation.ex`, `lib/supertester/testable_genserver.ex`, `lib/supertester/assertions.ex`) whenever implementation details matter.

## Setup Workflow
1. Add `{:supertester, "~> 0.2.1", only: :test}` to `mix.exs` and run `mix deps.get` to install.
2. Use `Supertester.UnifiedTestFoundation` in each OTP-heavy test module, defaulting to `isolation: :full_isolation` unless constraints require lighter modes.
3. Import helper namespaces explicitly:
   ```elixir
   import Supertester.OTPHelpers
   import Supertester.GenServerHelpers
   import Supertester.Assertions
   ```
4. Mark eligible cases `async: true` (automatically supplied by the isolation macro) and rely on helper-driven cleanup instead of manual teardown.

## GenServer Workflow
- Start isolated servers via `setup_isolated_genserver/3`, passing custom `:init_args` or explicit names through opts.
- Apply `use Supertester.TestableGenServer` inside target modules to expose the `__supertester_sync__` handler without redefining `handle_call/3`.
- Replace bare casts with `cast_and_sync/3` followed by `assert_genserver_state/2` or `assert_genserver_responsive/1`.
- Leverage `call_with_timeout/3`, `get_server_state_safely/1`, `monitor_process_lifecycle/1`, and `cleanup_on_exit/1` to observe asynchronous behavior deterministically.

### Example Pattern
```elixir
defmodule MyApp.CounterTest do
  use ExUnit.Case
  use Supertester.UnifiedTestFoundation, isolation: :full_isolation

  import Supertester.OTPHelpers
  import Supertester.GenServerHelpers
  import Supertester.Assertions

  test "increments without race conditions" do
    {:ok, counter} = setup_isolated_genserver(MyApp.Counter)

    :ok = cast_and_sync(counter, :increment)
    assert_genserver_state(counter, fn state -> state.count == 1 end)
  end
end
```

## Supervisor & Restart Testing
- Start trees with `setup_isolated_supervisor/3` and confirm readiness through `wait_for_supervisor_restart/2` or `wait_for_supervisor_stabilization/2`.
- Probe restart semantics using `test_restart_strategy/3`, then assert outcomes with helpers such as `assert_process_restarted/2` and `assert_all_children_alive/1`.
- Trace living supervision events via `trace_supervision_events/2` to capture restarts without manual logging.
- Enable `isolation: :contamination_detection` when diagnosing leaks; review warnings emitted by `Supertester.UnifiedTestFoundation`.

## Chaos And Performance Hooks
- Exercise resilience with `Supertester.ChaosHelpers`, following scenario setups in `README.md` and option references in `MANUAL.md`.
- Guard service-level objectives using `Supertester.PerformanceHelpers`, pairing `assert_performance/2` or `assert_no_memory_leak/2` with isolated fixtures.

## Assertions & Diagnostics
- Favor OTP-aware checks from `lib/supertester/assertions.ex` (`assert_genserver_handles_message/3`, `assert_process_dead/1`, `assert_no_process_leaks/1`) instead of bespoke assertions.
- Run `verify_test_isolation/1` when isolations feel suspect to confirm all tracked processes remain sandboxed.
- Capture process exits intentionally with `wait_for_process_death/2` and translate restarts to deterministic expectations.

## Reference Bundle
- Load `MANUAL.md#otp-testing-helpers` for signature verification mid-task.
- Consult `docs/API_GUIDE.md` for extended examples and edge-case notes.
- Check `CHANGELOG.md` before depending on newer APIs or behavior changes.

## Reuse Checklist
- Confirm each GenServer under test `use Supertester.TestableGenServer`.
- Ensure every asynchronous assertion flows through `cast_and_sync/3`, `wait_for_genserver_sync/2`, or equivalent helpers.
- Replace any remaining `Process.sleep/1` usage with Supertester synchronization.
- Remove redundant in-house OTP helpers once the Supertester equivalents are adopted.
