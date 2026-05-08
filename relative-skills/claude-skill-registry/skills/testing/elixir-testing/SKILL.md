---
name: elixir-testing
description: Guide for writing comprehensive tests in Elixir using ExUnit, property-based testing, mocks, and test organization best practices
---

# Elixir Testing with ExUnit

This skill activates when writing, organizing, or improving tests for Elixir applications using ExUnit and related testing tools.

## When to Use This Skill

Activate when:
- Writing unit, integration, or property-based tests
- Organizing test suites and test files
- Setting up test fixtures and factories
- Mocking external dependencies
- Testing concurrent or asynchronous code
- Improving test coverage or quality
- Troubleshooting failing tests

## ExUnit Basics

### Test Module Structure

```elixir
defmodule MyApp.MathTest do
  use ExUnit.Case, async: true

  describe "add/2" do
    test "adds two positive numbers" do
      assert Math.add(2, 3) == 5
    end

    test "adds negative numbers" do
      assert Math.add(-1, -1) == -2
    end

    test "adds zero" do
      assert Math.add(5, 0) == 5
    end
  end

  describe "divide/2" do
    test "divides two numbers" do
      assert Math.divide(10, 2) == 5.0
    end

    test "returns error for division by zero" do
      assert Math.divide(10, 0) == {:error, :division_by_zero}
    end
  end
end
```

### Assertions

Common assertion patterns:

```elixir
# Equality
assert actual == expected
refute actual == unexpected

# Boolean
assert is_binary(value)
assert is_integer(value)
refute is_nil(value)

# Pattern matching
assert {:ok, result} = function_call()
assert %User{name: "Alice"} = user

# Exceptions
assert_raise ArgumentError, fn ->
  String.to_integer("not a number")
end

assert_raise ArgumentError, "invalid argument", fn ->
  dangerous_function()
end

# Messages
send(self(), :hello)
assert_received :hello

assert_receive :message, 1000  # With timeout

refute_received :unwanted
refute_receive :unwanted, 100
```

### Test Organization

#### Using describe blocks

Group related tests:

```elixir
defmodule MyApp.UserTest do
  use ExUnit.Case

  describe "create_user/1" do
    test "creates user with valid attributes" do
      # ...
    end

    test "returns error with invalid email" do
      # ...
    end
  end

  describe "update_user/2" do
    test "updates user attributes" do
      # ...
    end
  end
end
```

#### Test tags

Categorize and filter tests:

```elixir
@moduletag :integration

@tag :slow
test "expensive operation" do
  # ...
end

@tag :external
test "calls external API" do
  # ...
end

# Run only tagged tests
# mix test --only slow
# mix test --exclude external
```

### Setup and Teardown

#### Test context

```elixir
defmodule MyApp.UserTest do
  use ExUnit.Case

  setup do
    user = %User{name: "Alice", email: "alice@example.com"}
    {:ok, user: user}
  end

  test "user has name", %{user: user} do
    assert user.name == "Alice"
  end

  test "user has email", %{user: user} do
    assert user.email == "alice@example.com"
  end
end
```

#### Setup with describe

```elixir
describe "authenticated user" do
  setup do
    user = insert(:user)
    token = generate_token(user)
    {:ok, user: user, token: token}
  end

  test "can access protected resource", %{token: token} do
    # ...
  end
end
```

#### Module setup

```elixir
setup_all do
  # Runs once before all tests in module
  start_supervised!(MyApp.Cache)
  :ok
end

setup do
  # Runs before each test
  :ok = Ecto.Adapters.SQL.Sandbox.checkout(MyApp.Repo)
end
```

#### Conditional setup

```elixir
setup context do
  if context[:integration] do
    start_external_service()
    on_exit(fn -> stop_external_service() end)
  end

  :ok
end

@tag :integration
test "integration test" do
  # ...
end
```

## Database Testing

### Sandbox Mode

Configure for concurrent tests:

```elixir
# config/test.exs
config :my_app, MyApp.Repo,
  pool: Ecto.Adapters.SQL.Sandbox

# test/test_helper.exs
Ecto.Adapters.SQL.Sandbox.mode(MyApp.Repo, :manual)

# test/support/data_case.ex
defmodule MyApp.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias MyApp.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import MyApp.DataCase
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(MyApp.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    :ok
  end
end
```

### Test Factories

Use ExMachina for test data:

```elixir
# test/support/factory.ex
defmodule MyApp.Factory do
  use ExMachina.Ecto, repo: MyApp.Repo

  def user_factory do
    %MyApp.User{
      name: "Jane Smith",
      email: sequence(:email, &"email-#{&1}@example.com"),
      age: 25
    }
  end

  def admin_factory do
    struct!(
      user_factory(),
      %{role: :admin}
    )
  end

  def post_factory do
    %MyApp.Post{
      title: "A title",
      body: "Some content",
      author: build(:user)
    }
  end
end

# In tests
defmodule MyApp.UserTest do
  use MyApp.DataCase
  import MyApp.Factory

  test "creates user" do
    user = insert(:user)
    assert user.id
  end

  test "creates admin" do
    admin = insert(:admin)
    assert admin.role == :admin
  end

  test "builds without inserting" do
    user = build(:user, name: "Custom Name")
    assert user.name == "Custom Name"
    refute user.id
  end
end
```

### Testing Changesets

```elixir
defmodule MyApp.UserTest do
  use MyApp.DataCase

  describe "changeset/2" do
    test "valid changeset with valid attributes" do
      attrs = %{name: "Alice", email: "alice@example.com", age: 25}
      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid?
    end

    test "invalid without email" do
      attrs = %{name: "Alice", age: 25}
      changeset = User.changeset(%User{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).email
    end

    test "invalid with short password" do
      attrs = %{email: "test@example.com", password: "123"}
      changeset = User.changeset(%User{}, attrs)

      assert "should be at least 8 character(s)" in errors_on(changeset).password
    end
  end
end

# Helper function
def errors_on(changeset) do
  Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
    Regex.replace(~r"%{(\w+)}", message, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end)
end
```

## Phoenix Testing

### Controller Tests

```elixir
defmodule MyAppWeb.UserControllerTest do
  use MyAppWeb.ConnCase
  import MyApp.Factory

  describe "index" do
    test "lists all users", %{conn: conn} do
      user = insert(:user)

      conn = get(conn, ~p"/users")

      assert html_response(conn, 200) =~ "Listing Users"
      assert html_response(conn, 200) =~ user.name
    end
  end

  describe "create" do
    test "creates user with valid data", %{conn: conn} do
      attrs = %{name: "Alice", email: "alice@example.com"}

      conn = post(conn, ~p"/users", user: attrs)

      assert redirected_to(conn) =~ ~p"/users"

      conn = get(conn, redirected_to(conn))
      assert html_response(conn, 200) =~ "Alice"
    end

    test "renders errors with invalid data", %{conn: conn} do
      conn = post(conn, ~p"/users", user: %{})

      assert html_response(conn, 200) =~ "New User"
    end
  end
end
```

### LiveView Tests

```elixir
defmodule MyAppWeb.UserLiveTest do
  use MyAppWeb.ConnCase
  import Phoenix.LiveViewTest
  import MyApp.Factory

  describe "Index" do
    test "displays users", %{conn: conn} do
      user = insert(:user)

      {:ok, view, html} = live(conn, ~p"/users")

      assert html =~ "Listing Users"
      assert has_element?(view, "#user-#{user.id}")
      assert render(view) =~ user.name
    end

    test "creates new user", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/users/new")

      assert view
             |> form("#user-form", user: %{name: "Alice", email: "alice@example.com"})
             |> render_submit()

      assert_patch(view, ~p"/users")

      html = render(view)
      assert html =~ "Alice"
    end

    test "updates user", %{conn: conn} do
      user = insert(:user)

      {:ok, view, _html} = live(conn, ~p"/users/#{user.id}/edit")

      assert view
             |> form("#user-form", user: %{name: "Updated Name"})
             |> render_submit()

      assert_patch(view, ~p"/users/#{user.id}")

      html = render(view)
      assert html =~ "Updated Name"
    end

    test "deletes user", %{conn: conn} do
      user = insert(:user)

      {:ok, view, _html} = live(conn, ~p"/users")

      assert view
             |> element("#user-#{user.id} a", "Delete")
             |> render_click()

      refute has_element?(view, "#user-#{user.id}")
    end
  end

  describe "form validation" do
    test "validates on change", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/users/new")

      result =
        view
        |> form("#user-form", user: %{email: "invalid"})
        |> render_change()

      assert result =~ "must have the @ sign"
    end
  end

  describe "real-time updates" do
    test "receives updates from PubSub", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/users")

      user = insert(:user)

      # Trigger PubSub event
      Phoenix.PubSub.broadcast(MyApp.PubSub, "users", {:user_created, user})

      assert render(view) =~ user.name
    end
  end
end
```

### Channel Tests

```elixir
defmodule MyAppWeb.RoomChannelTest do
  use MyAppWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      MyAppWeb.UserSocket
      |> socket("user_id", %{user_id: 42})
      |> subscribe_and_join(MyAppWeb.RoomChannel, "room:lobby")

    %{socket: socket}
  end

  test "ping replies with pong", %{socket: socket} do
    ref = push(socket, "ping", %{"hello" => "there"})
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "shout broadcasts to room:lobby", %{socket: socket} do
    push(socket, "shout", %{"hello" => "all"})
    assert_broadcast "shout", %{"hello" => "all"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end
end
```

## Mocking and Stubbing

### Using Mox

Define behaviors and mocks:

```elixir
# Define behaviour
defmodule MyApp.HTTPClient do
  @callback get(String.t()) :: {:ok, map()} | {:error, term()}
end

# In config/test.exs
config :my_app, :http_client, MyApp.HTTPClientMock

# In test/test_helper.exs
Mox.defmock(MyApp.HTTPClientMock, for: MyApp.HTTPClient)

# In application code
defmodule MyApp.UserFetcher do
  @http_client Application.compile_env(:my_app, :http_client)

  def fetch_user(id) do
    @http_client.get("/users/#{id}")
  end
end

# In tests
defmodule MyApp.UserFetcherTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  test "fetches user successfully" do
    expect(MyApp.HTTPClientMock, :get, fn "/users/1" ->
      {:ok, %{"name" => "Alice"}}
    end)

    assert {:ok, %{"name" => "Alice"}} = MyApp.UserFetcher.fetch_user(1)
  end

  test "handles error" do
    expect(MyApp.HTTPClientMock, :get, fn _ ->
      {:error, :network_error}
    end)

    assert {:error, :network_error} = MyApp.UserFetcher.fetch_user(1)
  end
end
```

### Stubbing Multiple Calls

```elixir
test "calls API multiple times" do
  MyApp.HTTPClientMock
  |> expect(:get, 3, fn url ->
    {:ok, %{"url" => url}}
  end)

  MyApp.batch_fetch([1, 2, 3])
end
```

### Global Stubs

```elixir
setup do
  stub(MyApp.HTTPClientMock, :get, fn _ -> {:ok, %{}} end)
  :ok
end

test "can override stub" do
  expect(MyApp.HTTPClientMock, :get, fn _ ->
    {:error, :timeout}
  end)

  # ...
end
```

## Property-Based Testing

Use StreamData for property-based tests:

```elixir
defmodule MyApp.MathPropertyTest do
  use ExUnit.Case
  use ExUnitProperties

  property "addition is commutative" do
    check all a <- integer(),
              b <- integer() do
      assert Math.add(a, b) == Math.add(b, a)
    end
  end

  property "list reversal is involutive" do
    check all list <- list_of(integer()) do
      assert Enum.reverse(Enum.reverse(list)) == list
    end
  end

  property "concatenation length" do
    check all list1 <- list_of(term()),
              list2 <- list_of(term()) do
      concatenated = list1 ++ list2
      assert length(concatenated) == length(list1) + length(list2)
    end
  end
end
```

### Custom Generators

```elixir
defmodule MyApp.Generators do
  use ExUnitProperties

  def email do
    gen all username <- string(:alphanumeric, min_length: 1),
            domain <- string(:alphanumeric, min_length: 1),
            tld <- member_of(["com", "org", "net"]) do
      "#{username}@#{domain}.#{tld}"
    end
  end

  def user do
    gen all name <- string(:alphanumeric, min_length: 1),
            email <- email(),
            age <- integer(18..100) do
      %User{name: name, email: email, age: age}
    end
  end
end

# Use in tests
property "validates email format" do
  check all email <- MyApp.Generators.email() do
    assert User.valid_email?(email)
  end
end
```

## Testing Async and Concurrent Code

### Testing Processes

```elixir
test "GenServer handles messages" do
  {:ok, pid} = MyApp.Worker.start_link()

  MyApp.Worker.process(pid, :work)

  assert_receive {:done, :work}, 1000
end
```

### Testing Tasks

```elixir
test "async task completes" do
  parent = self()

  Task.start(fn ->
    result = expensive_computation()
    send(parent, {:result, result})
  end)

  assert_receive {:result, value}, 5000
  assert value == expected
end
```

### Testing Race Conditions

```elixir
test "concurrent updates are handled correctly" do
  {:ok, counter} = Counter.start_link(0)

  tasks = for _ <- 1..100 do
    Task.async(fn -> Counter.increment(counter) end)
  end

  Task.await_many(tasks)

  assert Counter.get(counter) == 100
end
```

## Test Coverage

### Generate Coverage Reports

```bash
mix test --cover

# Detailed coverage
MIX_ENV=test mix coveralls
MIX_ENV=test mix coveralls.html
```

### Coverage Configuration

```elixir
# mix.exs
def project do
  [
    # ...
    test_coverage: [tool: ExCoveralls],
    preferred_cli_env: [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.html": :test
    ]
  ]
end
```

## Best Practices

### Test Organization

- One test file per module: `lib/my_app/user.ex` → `test/my_app/user_test.exs`
- Use `describe` blocks to group related tests
- Use `test/support` for shared test helpers
- Keep tests focused on one behavior per test

### Naming

- Use descriptive test names that explain what is being tested
- Start with the action being tested
- Include the expected outcome

```elixir
# Good
test "create_user/1 returns error with invalid email"
test "add/2 returns sum of two positive integers"

# Avoid
test "it works"
test "test1"
```

### Setup

- Use `setup` for common test data
- Keep setup focused - don't create unnecessary data
- Use context to pass data between setup and tests
- Use factories for complex data structures

### Assertions

- Prefer pattern matching over multiple assertions
- Use specific assertions (`assert_receive` vs `assert Process.info(...)`)
- Test one logical assertion per test when possible

### Async Tests

```elixir
# Mark tests as async when they don't share state
use ExUnit.Case, async: true

# Don't use async when tests:
# - Modify global state
# - Use database without sandbox
# - Access shared resources
```

### Test Data

- Use factories (ExMachina) for consistent test data
- Avoid hardcoded IDs - use factories and references
- Keep test data minimal - only what's needed for the test
- Use descriptive data that makes tests readable

### External Dependencies

- Mock external APIs and services
- Use Mox for behavior-based mocking
- Stub at the boundary - don't mock internal modules
- Tag tests that require external services

## Debugging Tests

### Running Specific Tests

```bash
# Run single test file
mix test test/my_app/user_test.exs

# Run specific line
mix test test/my_app/user_test.exs:42

# Run tests matching pattern
mix test --only integration

# Run tests excluding pattern
mix test --exclude slow
```

### Test Output

```elixir
# Add IEx.pry breakpoint
import IEx
test "debugging" do
  user = build(:user)
  IEx.pry()  # Stops here
  # ...
end

# Print during tests
IO.inspect(value, label: "DEBUG")
```

### Failed Test Debugging

```bash
# Re-run only failed tests
mix test --failed

# Show detailed error traces
mix test --trace

# Run tests one at a time
mix test --max-cases 1
```

## Key Principles

- **Test behavior, not implementation**: Test what the code does, not how it does it
- **Keep tests fast**: Use async tests, avoid unnecessary setup, mock slow dependencies
- **Make tests readable**: Use descriptive names, clear assertions, minimal setup
- **Test at the right level**: Unit tests for logic, integration tests for interactions
- **Use factories**: Consistent, reusable test data with ExMachina
- **Mock at boundaries**: Mock external services, not internal modules
- **Property-based testing**: Use StreamData for algorithmic code
- **Embrace the database**: Use Ecto sandbox for fast, isolated database tests
