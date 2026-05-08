---
name: flutter-testing
description: Flutter testing patterns with mocktail. Covers unit testing, widget testing, and BLoC/Cubit testing. Use when writing tests or setting up test infrastructure.
---

# Flutter Testing

## Test Commands

```bash
flutter test                                    # Run all tests
flutter test test/features/auth/               # Run feature tests
flutter test --plain-name "returns empty"      # Run by name pattern
flutter test --coverage                        # With coverage
```

## Detailed Guides

| Topic | Guide | Use When |
|-------|-------|----------|
| Unit Testing | [unit-testing.md](references/unit-testing.md) | Testing business logic, repositories, use cases |
| Widget Testing | [widget-testing.md](references/widget-testing.md) | Testing UI components, interactions |
| BLoC Testing | [bloc-testing.md](references/bloc-testing.md) | Testing BLoC/Cubit state management |

## Feature-First Test Structure

```
test/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository_test.dart
│   │   │   └── auth_remote_source_test.dart
│   │   ├── domain/
│   │   │   └── login_usecase_test.dart
│   │   └── presentation/
│   │       ├── login_screen_test.dart
│   │       └── auth_bloc_test.dart
│   ├── home/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── profile/
│       └── ...
├── core/
│   ├── network/
│   │   └── api_client_test.dart
│   └── utils/
│       └── validators_test.dart
└── helpers/
    ├── pump_app.dart          # Test wrapper with providers
    ├── mocks.dart             # Shared mock classes
    └── fixtures.dart          # Test data factories
```

## Mocking with Mocktail

```dart
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  test('returns user on successful login', () async {
    // Arrange
    when(() => mockRepo.login(any(), any()))
        .thenAnswer((_) async => User(id: '1', name: 'Test'));

    // Act
    final result = await mockRepo.login('email', 'pass');

    // Assert
    expect(result.name, equals('Test'));
    verify(() => mockRepo.login('email', 'pass')).called(1);
  });
}
```

## Fakes vs Mocks

| Type | Use When | Example |
|------|----------|---------|
| **Mock** | Verify interactions | `verify(() => mock.save(any())).called(1)` |
| **Fake** | Need working implementation | `FakeAuthRepo` with in-memory `Map` |
| **Stub** | Fixed return values | `when(() => mock.get()).thenReturn(value)` |

## Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0
  bloc_test: ^9.1.0       # If using BLoC
```

## Test Naming

```dart
// ✅ Describe behavior
test('returns empty list when no todos exist', () {});
test('throws AuthException when credentials invalid', () {});

// ❌ Don't describe implementation
test('test getTodos', () {});
test('login test', () {});
```

## Arrange-Act-Assert

```dart
test('adds item to cart', () {
  // Arrange
  final cart = Cart();
  final item = Item(id: '1', price: 10.0);
  
  // Act
  cart.add(item);
  
  // Assert
  expect(cart.items, contains(item));
  expect(cart.total, equals(10.0));
});
```

## Group Related Tests

```dart
group('LoginUseCase', () {
  group('when credentials valid', () {
    test('returns user', () {});
    test('caches auth token', () {});
  });

  group('when credentials invalid', () {
    test('throws AuthException', () {});
    test('does not cache token', () {});
  });
});
```
