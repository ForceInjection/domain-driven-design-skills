---
name: numpy-api-compatibility
description: use when adding API to this project that exists in numpy, especially if the user mentions a stream in the numpy-api-parity plan.
---

When implementing functionality in this project that already exists in numpy  we can go through a few phases:

## Phase 1: Research and Design

We can look at how numpy implements a feature.  For simple functions we can look at the source code in ../numpy-src or by running simple scripts.

For more complex systems we can search the internet for NEPs.

We can also look through our own design files for internal systems in our codebase that we might use.  Often we find that `designs/adding-operations.md`, `designs/iteration-performance.md`, `designs/kernel-dispatch.md` are quite useful.

Check dtype behavior early. NumPy often preserves input dtypes - for example a float32 input often produces float32 output.

## Phase 2: Testing

We want simple and fast tests comparing execution against numpy.  Read `designs/testing.md`

## Phase 3: Implementation

Here we implement our new functionality, testing against our simple tests from earlier to gauge correctness.

Avoid dtype-specific implementations, especially code that routes through f64.
Instead, try to build dtype generic implementations.  We've managed this for
ufuncs and reductions while also making them fast, such that the Rust compiler
can identify loops as SIMD friendly.

Instead dispatch on types and use macros if necessary.  Consider using typed
pointer access.

Avoid using get_element if possible. (it's slow.)

## Phase 4: Simplification and Cleanup

Review our work so far and see if there is anything we should clean up or
simplify.  Then perform the work there that you think is best.

## Phase 5: Performance testing

Compare our performance against numpy.  If we're slower, we don't want to build fast-paths for specific dtypes (like float64) but instead want to build good dtype-generic solutions that compile down to something fast, often using SIMD operations.  We've managed this for other operations (even complex operations like reductions and norms), and numpy manages to do so, so we should have confidence that we can too.

If our operations don't require speed (if they just manage metadata) then this isn't a big deal.

**Always benchmark in release mode:**
```bash
PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1 uv tool run maturin develop --release
```

**Benchmark across dtypes.** A common anti-pattern is code that's fast for float64 but slow for float32 or int due to hidden conversions:

If float32 is significantly slower than float64 (relative to numpy), suspect dtype conversion in the implementation.

## Phase 6: Cleanup again

Review again for simplicity and cleanliness.  Also check that our functions
handle the depth that numpy does, including keyword arguments and other dtypes
that numpy might support.


## Phase 7: Final review and commit

Present results about both what we've accomplished and performance if necessary.
