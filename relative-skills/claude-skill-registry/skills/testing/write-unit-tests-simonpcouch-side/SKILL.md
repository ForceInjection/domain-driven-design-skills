---
name: write-unit-tests
description: Write minimal, concise testthat 3e unit tests for R package code
---

# Unit testing

Write minimal, concise testthat 3e unit tests for R package code. Given the contents of an R file, prefixed with the header "## Contents", and a selection that is a subset of those contents, prefixed with the header "## Selection", reply with a testthat unit test tests the functionality in the selection. Respond with *only* the testing code, no code comments and no backticks or newlines around the response, though feel free to intersperse newlines within the function call as needed, per tidy style.

For example, consider the following selection:

``` r
key_get <- function(name, error_call = caller_env()) {
  val <- Sys.getenv(name)
  if (!identical(val, "")) {
    val
  } else {
    cli::cli_abort("Can't find env var {.code {name}}.", call = error_call)
  }
}

key_exists <- function(name) {
  !identical(Sys.getenv(name), "")
}
```

In that case, return the following tests:

``` r
test_that("finds key if set", {
  withr::local_envvar(FOO = "abc123")
  expect_true(key_exists("FOO"))
  expect_equal(key_get("FOO"), "abc123")
})


test_that("informative error if no key", {
  withr::local_envvar(FOO = NULL, TESTTHAT = "false")
  expect_false(key_exists("FOO"))
  expect_snapshot(key_get("FOO"), error = TRUE)
})
```

In this case, we:

-   Set the value of an envvar temporarily with a `withr::local_*()` function. Another common temporary test fixtures might be temporary options with `withr::local_options()`.

-   Use `expect_true()` and `expect_false()` to test boolean outcomes.

-   Use `expect_equal()` to test that a function call returns an expected value.

-   Use `expect_snapshot()` with `error = TRUE` to test for an error message. Whenever you see erroring code with `stop()`, `stopifnot()`, `rlang::abort()`, or `cli::cli_abort()`, test it with a snapshot with `error = TRUE`.

The last example tested an error with `expect_snapshot(error = TRUE)`. If you see another condition, like a warning or message, test it with `expect_snapshot()` but assign the results to an intermediate value. For example, if your selection is:

``` r
warn_missing_argument <- function(arg) {
  cli::cli_warn("{.arg {arg}} is missing.")
}
```

Test it with:

``` r
test_that("warns informatively with missing argument", {
  expect_snapshot(.res <- warn_missing_argument("x")) 
})
```

To test conditional paths that are hard to get into, use mocking with `testthat::local_mocked_bindings()`. For example, provided the selection:

``` r
fail_on_macOS <- function() {
  if (identical(operating_system(), "macOS")) {
    cli::cli_abort("Not available on macOS.")
  }
  invisible(NULL)
}
```

You might write:

``` r
test_that("fails informatively on macOS", {
  testthat::local_mocked_bindings(operating_system = function() "macOS")
  expect_snapshot(fail_on_macOS())
})

test_that("does not fail on non-macOS", {
  testthat::local_mocked_bindings(operation_system = function() "Windows")
  expect_null(fail_on_macOS())
})
```

Some functions will have a `check_*()` function in their signature—in that case, do not test the functionality of the checking function unless the definition of the function is part of the selection. For example, provided:

``` r
has_package <- function(package, fail = FALSE) {
  check_bool(fail)
  has_package <- rlang::is_installed(package)
  
  if (!has_package && fail) {
    cli::cli_abort("{.pkg {pkg}} must be installed.")
  }
  
  has_package
}
```

Return:

``` r
test_that("returns is_installed when it ought to", {
  expect_false(has_package("somepackagethatdoesntexist"))
  
  local_mocked_bindings(is_installed = function(x) {TRUE}, .package = "rlang")
  expect_true(has_package("somepackage"))
  expect_true(has_package("somepackage", fail = TRUE))
})

test_that("fails informatively without package when `fail = TRUE`", {
  local_mocked_bindings(is_installed = function(x) {FALSE}, .package = "rlang")
  expect_snapshot(has_package("somepackage", fail = TRUE))
})
```

You will need to determine the number of `test_that()` blocks to use to test a given function thoughtfully. Balance these principles:

* In general, the fewer `test_that()` blocks to test a given function, the better.
* `local*()` settings and mocks should not have to be "reset" within a `test_that()` call.
* Function "successes" should be tested in a different block than failures. If you're specifically snapshotting messages/warnings/errors, those tests should live in a different `test_that()` block than the usual, "happy" control flow tests.

So, in the above, since there were two distinct `local_mocked_bindings()` calls needed, there were two distinct `test_that()` calls.

However, if the selection also includes the definition of the `check_*()` function, test it independently. If you had been provided:

``` r
has_package <- function(package, fail = FALSE) {
  check_bool(fail)
  has_package <- rlang::is_installed(package)
  
  if (!has_package && fail) {
    cli::cli_abort("{.pkg {pkg}} must be installed.")
  }
  
  has_package
}

check_bool <- function(x, arg = caller_arg(x)) {
  if (!(is.logical(x) && length(x) == 1L && !is.na(x))) {
    cli::cli_abort("{.arg {arg}} must be a single logical value.")
  }
  invisible(NULL)
}
```

You would *also* return the following tests:

``` r
test_that("check_bool accepts valid logical values", {
  expect_null(check_bool(TRUE))
  expect_null(check_bool(FALSE))
})

test_that("check_bool errors informatively with invalid input", {
  expect_snapshot(check_bool(1), error = TRUE)
  expect_snapshot(check_bool(NA), error = TRUE)
  expect_snapshot(check_bool(c(TRUE, FALSE)), error = TRUE)
  expect_snapshot(check_bool("TRUE"), error = TRUE)
  expect_snapshot(check_bool(1, arg = "my_arg"), error = TRUE)
})
```
