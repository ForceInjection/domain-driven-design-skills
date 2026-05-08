---
name: property-based-testing
description: How to make a good property-based test. Use when writing any property-based test.
---

# Property-based testing

* Generate correct test cases, don't filter down to correct test cases. Example: don't generate all lists and filter to non-empty ones; instead, generate an element and a list and concatenate them.
* When writing a test that has nontrivial requirements on the input distribution, add instrumentation to it and assert the actual observed distribution. Example: if the last line of the test is `someSet.Contains elt |> shouldEqual (referenceImplementation.Contains elt)`, we want to make sure we do hit the positive case sometimes; so additionally increment mutable variables `positiveCount` and `negativeCount`, and after the call to the testing framework to assert the property, check that the counts are in a reasonable ratio to each other.
* Fuzz over the distribution itself where appropriate. You can cheaply explore very different regimes by biasing the generator according to some parameters *and fuzzing over the bias parameters themselves*.
* The tests give more interpretable output if the property throws on failure, rather than merely failing an equality check. In FsCheck, use `b |> shouldEqual a` (a `unit`-returning property) rather than `a = b` (a `bool`-returning one).
