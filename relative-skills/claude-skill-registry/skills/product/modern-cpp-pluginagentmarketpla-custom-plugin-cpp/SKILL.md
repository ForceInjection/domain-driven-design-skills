---
# ═══════════════════════════════════════════════════════════════════════════════
# SKILL: Modern C++
# Version: 3.0.0 | SASMP v1.3.0 Compliant | Production-Grade
# ═══════════════════════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────────────────────────────────────
# IDENTITY
# ─────────────────────────────────────────────────────────────────────────────
name: modern-cpp
version: "3.0.0"
description: >
  Production-grade skill for modern C++ development with C++11 through C++23
  features. Covers move semantics, smart pointers, lambdas, concepts, ranges,
  coroutines, and modules.

# ─────────────────────────────────────────────────────────────────────────────
# COMPLIANCE
# ─────────────────────────────────────────────────────────────────────────────
sasmp_version: "1.3.0"
skill_version: "3.0.0"

# ─────────────────────────────────────────────────────────────────────────────
# BONDING
# ─────────────────────────────────────────────────────────────────────────────
bonded_agent: 01-modern-cpp-expert
bond_type: PRIMARY_BOND
category: development

# ─────────────────────────────────────────────────────────────────────────────
# PARAMETERS
# ─────────────────────────────────────────────────────────────────────────────
parameters:
  cpp_standard:
    type: string
    required: false
    enum: [cpp11, cpp14, cpp17, cpp20, cpp23]
    default: cpp20
    description: "Target C++ standard version"
  feature_category:
    type: string
    required: false
    enum: [move_semantics, smart_pointers, lambdas, concepts, ranges, coroutines, modules]
    description: "Specific modern C++ feature to focus on"
  migration_mode:
    type: boolean
    required: false
    default: false
    description: "Whether migrating from legacy C++ code"

# ─────────────────────────────────────────────────────────────────────────────
# ERROR HANDLING
# ─────────────────────────────────────────────────────────────────────────────
error_handling:
  retry_logic:
    max_attempts: 3
    backoff: exponential
    initial_delay_ms: 500
    max_delay_ms: 8000
    jitter: true
  fallback:
    on_compiler_incompatibility: "suggest_alternative_approach"
    on_feature_unavailable: "provide_backport_solution"
    on_migration_complexity: "break_into_smaller_steps"
  validation:
    check_standard_compliance: true
    verify_compiler_support: true
    test_with_sanitizers: true
---

# Modern C++ Skill

**Production-Grade Development Skill** | C++11 through C++23

Leverage modern C++ standards for cleaner, safer, and more efficient code.

---

## C++ Standards Timeline

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  C++11   │  C++14   │  C++17   │  C++20   │  C++23   │                      │
│  (2011)  │  (2014)  │  (2017)  │  (2020)  │  (2023)  │                      │
├──────────┼──────────┼──────────┼──────────┼──────────┤                      │
│ auto     │ generic  │ if init  │ concepts │ deducing │                      │
│ lambda   │ lambdas  │ optional │ ranges   │ this     │                      │
│ move     │ constexpr│ variant  │ modules  │ std::print                      │
│ smart_ptr│ relaxed  │ string_v │ coroutine│ flat_map │                      │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Move Semantics

### Value Categories

```cpp
// lvalue: Has identity, can be addressed
int x = 10;           // x is lvalue
int* p = &x;          // Can take address

// rvalue: Temporary, no persistent identity
int y = x + 5;        // (x + 5) is rvalue
// int* p2 = &(x + 5); // Error: cannot take address

// xvalue: eXpiring lvalue (about to be moved)
std::string s = "hello";
std::string t = std::move(s);  // s is now xvalue
```

### Move Constructor & Assignment

```cpp
class Buffer {
    std::unique_ptr<char[]> data_;
    size_t size_;

public:
    // Move constructor
    Buffer(Buffer&& other) noexcept
        : data_(std::move(other.data_))
        , size_(std::exchange(other.size_, 0))
    {}

    // Move assignment
    Buffer& operator=(Buffer&& other) noexcept {
        if (this != &other) {
            data_ = std::move(other.data_);
            size_ = std::exchange(other.size_, 0);
        }
        return *this;
    }
};
```

### Perfect Forwarding

```cpp
template<typename T, typename... Args>
std::unique_ptr<T> make_unique(Args&&... args) {
    return std::unique_ptr<T>(new T(std::forward<Args>(args)...));
}

// Usage
auto ptr = make_unique<std::string>("hello");  // Forwards "hello"
std::string s = "world";
auto ptr2 = make_unique<std::string>(std::move(s));  // Forwards rvalue
```

---

## Smart Pointers

### unique_ptr - Exclusive Ownership

```cpp
#include <memory>

// Creation
auto ptr = std::make_unique<Widget>(args...);

// Transfer ownership
auto ptr2 = std::move(ptr);  // ptr is now nullptr

// Custom deleter
auto file = std::unique_ptr<FILE, decltype(&fclose)>(
    fopen("file.txt", "r"), &fclose);

// Array version
auto arr = std::make_unique<int[]>(100);
```

### shared_ptr - Shared Ownership

```cpp
// Creation (always prefer make_shared)
auto ptr = std::make_shared<Widget>(args...);

// Share ownership
auto ptr2 = ptr;  // ref_count = 2

// Check usage
std::cout << ptr.use_count();  // 2

// Weak reference (doesn't affect lifetime)
std::weak_ptr<Widget> weak = ptr;
if (auto locked = weak.lock()) {
    // Use locked
}
```

### Smart Pointer Decision Tree

```
Need pointer?
├── Single owner? → std::unique_ptr
├── Shared ownership? → std::shared_ptr
│   └── Need to break cycles? → std::weak_ptr
├── Non-owning view? → raw pointer or reference
└── Polymorphic container? → std::unique_ptr<Base>
```

---

## Lambda Expressions

### Lambda Evolution

```cpp
// C++11: Basic lambda
auto f1 = [](int x) { return x * 2; };

// C++14: Generic lambda
auto f2 = [](auto x) { return x * 2; };

// C++17: constexpr lambda
constexpr auto f3 = [](int x) constexpr { return x * 2; };

// C++20: Template lambda
auto f4 = []<typename T>(std::vector<T>& v) { v.clear(); };

// C++20: Lambda with explicit template params
auto f5 = []<typename T>(T a, T b) { return a + b; };

// C++23: Deducing this
struct Widget {
    auto getName(this auto&& self) {
        return std::forward_like<decltype(self)>(self.name_);
    }
};
```

### Capture Modes

```cpp
int x = 10;
std::string s = "hello";

// By value
auto f1 = [x]() { return x; };

// By reference
auto f2 = [&x]() { return x++; };

// Move capture (C++14)
auto f3 = [s = std::move(s)]() { return s; };

// Init capture with expression
auto f4 = [y = x * 2]() { return y; };

// Capture all by value
auto f5 = [=]() { return x + s.size(); };

// Capture all by reference
auto f6 = [&]() { x++; };

// Mixed
auto f7 = [=, &x]() { x++; return s; };
```

---

## Concepts (C++20)

### Standard Concepts

```cpp
#include <concepts>

// Using standard concepts
template<std::integral T>
T gcd(T a, T b) {
    while (b != 0) {
        T t = b;
        b = a % b;
        a = t;
    }
    return a;
}

// Common concepts
template<std::floating_point T>
T sqrt(T x);

template<std::copyable T>
void process(T value);

template<std::invocable<int> F>
void apply(F&& func);
```

### Custom Concepts

```cpp
// Define concept
template<typename T>
concept Hashable = requires(T a) {
    { std::hash<T>{}(a) } -> std::convertible_to<std::size_t>;
};

template<typename T>
concept Container = requires(T c) {
    { c.begin() } -> std::input_iterator;
    { c.end() } -> std::sentinel_for<decltype(c.begin())>;
    { c.size() } -> std::convertible_to<std::size_t>;
};

// Use concept
template<Container C>
void process(const C& container) {
    for (const auto& item : container) {
        // ...
    }
}
```

---

## Ranges (C++20)

### Range Views

```cpp
#include <ranges>
namespace rv = std::views;

std::vector<int> v = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

// Composable views
auto result = v
    | rv::filter([](int x) { return x % 2 == 0; })  // 2, 4, 6, 8, 10
    | rv::transform([](int x) { return x * x; })   // 4, 16, 36, 64, 100
    | rv::take(3);                                  // 4, 16, 36

// Views are lazy - no computation until iteration
for (int x : result) {
    std::cout << x << ' ';
}
```

### Range Algorithms

```cpp
#include <algorithm>
#include <ranges>

std::vector<int> v = {3, 1, 4, 1, 5, 9, 2, 6};

// Range-based algorithms
std::ranges::sort(v);
std::ranges::reverse(v);

// With projections
struct Person { std::string name; int age; };
std::vector<Person> people;
std::ranges::sort(people, {}, &Person::age);  // Sort by age

// Range factories
for (int i : std::views::iota(1, 10)) {}           // 1..9
for (int i : std::views::repeat(42) | std::views::take(5)) {}  // 42, 42, 42, 42, 42
```

---

## Coroutines (C++20)

### Generator Pattern

```cpp
#include <coroutine>
#include <generator>  // C++23

// C++23 std::generator
std::generator<int> fibonacci() {
    int a = 0, b = 1;
    while (true) {
        co_yield a;
        auto tmp = a;
        a = b;
        b = tmp + b;
    }
}

// Usage
for (int x : fibonacci() | std::views::take(10)) {
    std::cout << x << ' ';  // 0 1 1 2 3 5 8 13 21 34
}
```

### Async Task Pattern

```cpp
// Simplified task coroutine
task<int> async_compute() {
    co_await some_async_operation();
    co_return 42;
}

task<void> example() {
    int result = co_await async_compute();
    std::cout << result;
}
```

---

## Modules (C++20)

### Module Declaration

```cpp
// math.cppm - Module interface
export module math;

export int add(int a, int b) {
    return a + b;
}

export namespace math {
    double pi = 3.14159;

    double area(double radius) {
        return pi * radius * radius;
    }
}
```

### Module Import

```cpp
// main.cpp
import math;
import <iostream>;

int main() {
    std::cout << math::add(2, 3) << '\n';
    std::cout << math::area(5.0) << '\n';
}
```

---

## Migration Checklist

### From C++11/14 to C++17

- [ ] Replace `std::bind` with lambdas
- [ ] Use structured bindings: `auto [a, b] = pair;`
- [ ] Use if-init: `if (auto it = m.find(k); it != m.end())`
- [ ] Replace `boost::optional` with `std::optional`
- [ ] Use `std::string_view` for read-only strings
- [ ] Use `[[nodiscard]]` for important return values

### From C++17 to C++20

- [ ] Replace SFINAE with concepts
- [ ] Use ranges instead of begin/end pairs
- [ ] Consider modules for large projects
- [ ] Use `std::span` for contiguous ranges
- [ ] Use `<=>` spaceship operator
- [ ] Use designated initializers

---

## Troubleshooting Decision Tree

```
Compilation error with modern feature?
├── "requires C++XX or later"
│   └── Update -std=c++XX flag
├── "concept not satisfied"
│   ├── Check type requirements
│   └── Add missing operations to type
├── "move from const"
│   └── Remove const or copy instead
├── "use of deleted function"
│   ├── Check if type is movable
│   └── Use std::move if needed
└── "incomplete type in unique_ptr"
    └── Define destructor in .cpp file
```

---

## Unit Test Template

```cpp
#include <gtest/gtest.h>
#include <memory>

TEST(SmartPointerTest, UniquePtrTransfersOwnership) {
    auto p1 = std::make_unique<int>(42);
    auto p2 = std::move(p1);

    EXPECT_EQ(p1, nullptr);
    EXPECT_NE(p2, nullptr);
    EXPECT_EQ(*p2, 42);
}

TEST(MoveTest, StringMoveLeavesEmpty) {
    std::string s1 = "hello";
    std::string s2 = std::move(s1);

    EXPECT_TRUE(s1.empty());
    EXPECT_EQ(s2, "hello");
}

TEST(ConceptTest, IntegralSatisfied) {
    static_assert(std::integral<int>);
    static_assert(std::integral<long>);
    static_assert(!std::integral<double>);
}

TEST(RangesTest, FilterTransform) {
    std::vector<int> v = {1, 2, 3, 4, 5};
    std::vector<int> result;

    for (int x : v | std::views::filter([](int x) { return x % 2 == 0; })
                   | std::views::transform([](int x) { return x * 2; })) {
        result.push_back(x);
    }

    EXPECT_EQ(result, (std::vector<int>{4, 8}));
}
```

---

## Integration Points

| Component | Interface |
|-----------|-----------|
| `memory-specialist` | Smart pointer patterns |
| `stl-master` | Modern STL features |
| `performance-optimizer` | Move optimization |
| `build-engineer` | C++ standard flags |

---

*C++ Plugin v3.0.0 - Production-Grade Development Skill*
