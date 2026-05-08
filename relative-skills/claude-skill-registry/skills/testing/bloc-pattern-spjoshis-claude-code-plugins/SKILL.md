---
name: bloc-pattern
description: Master BLoC (Business Logic Component) pattern for Flutter with flutter_bloc. Learn events, states, testing, and advanced patterns for scalable apps.
---

# BLoC Pattern in Flutter

Comprehensive guide to implementing the BLoC (Business Logic Component) pattern in Flutter for scalable, testable, and maintainable applications.

## When to Use This Skill

- Building scalable Flutter applications
- Separating business logic from UI
- Implementing testable architecture
- Managing complex state
- Handling async operations
- Stream-based state management

## Core BLoC Concepts

### Events
User interactions or system events that trigger state changes

### States
Representations of the app's state at any given moment

### Transitions
The change from one state to another in response to an event

### BLoC
The component that receives events and emits states

## Implementation Patterns

### 1. Basic BLoC Setup

```dart
// Install dependencies in pubspec.yaml
// dependencies:
//   flutter_bloc: ^8.1.0
//   equatable: ^2.0.0

// Events
abstract class CounterEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class Increment extends CounterEvent {}
class Decrement extends CounterEvent {}

// States
class CounterState extends Equatable {
  final int count;

  const CounterState(this.count);

  @override
  List<Object?> get props => [count];
}

// BLoC
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState(0)) {
    on<Increment>((event, emit) => emit(CounterState(state.count + 1)));
    on<Decrement>((event, emit) => emit(CounterState(state.count - 1)));
  }
}
```

### 2. BLoC with API Integration

```dart
// Sealed classes for states (Dart 3+)
sealed class UserState extends Equatable {}

class UserInitial extends UserState {
  @override
  List<Object?> get props => [];
}

class UserLoading extends UserState {
  @override
  List<Object?> get props => [];
}

class UserLoaded extends UserState {
  final List<User> users;

  UserLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class UserError extends UserState {
  final String message;

  UserError(this.message);

  @override
  List<Object?> get props => [message];
}

// Events
sealed class UserEvent extends Equatable {}

class LoadUsers extends UserEvent {
  @override
  List<Object?> get props => [];
}

class RefreshUsers extends UserEvent {
  @override
  List<Object?> get props => [];
}

// BLoC with repository
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  UserBloc({required this.repository}) : super(UserInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<RefreshUsers>(_onRefreshUsers);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final users = await repository.fetchUsers();
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onRefreshUsers(RefreshUsers event, Emitter<UserState> emit) async {
    try {
      final users = await repository.fetchUsers();
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
```

### 3. BLoC Testing

```dart
// Install dev dependency
// dev_dependencies:
//   bloc_test: ^9.1.0

void main() {
  group('CounterBloc', () {
    late CounterBloc bloc;

    setUp(() {
      bloc = CounterBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is CounterState(0)', () {
      expect(bloc.state, const CounterState(0));
    });

    blocTest<CounterBloc, CounterState>(
      'emits [CounterState(1)] when Increment is added',
      build: () => CounterBloc(),
      act: (bloc) => bloc.add(Increment()),
      expect: () => [const CounterState(1)],
    );

    blocTest<CounterBloc, CounterState>(
      'emits [CounterState(-1)] when Decrement is added',
      build: () => CounterBloc(),
      act: (bloc) => bloc.add(Decrement()),
      expect: () => [const CounterState(-1)],
    );
  });

  group('UserBloc', () {
    late UserRepository mockRepository;
    late UserBloc bloc;

    setUp(() {
      mockRepository = MockUserRepository();
      bloc = UserBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLoaded] when LoadUsers succeeds',
      build: () {
        when(() => mockRepository.fetchUsers()).thenAnswer(
          (_) async => [User(id: '1', name: 'Test')],
        );
        return bloc;
      },
      act: (bloc) => bloc.add(LoadUsers()),
      expect: () => [
        UserLoading(),
        UserLoaded([User(id: '1', name: 'Test')]),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when LoadUsers fails',
      build: () {
        when(() => mockRepository.fetchUsers()).thenThrow(Exception('Failed'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadUsers()),
      expect: () => [
        UserLoading(),
        isA<UserError>(),
      ],
    );
  });
}
```

## Best Practices

1. **Use sealed classes** for states and events (Dart 3+)
2. **Implement Equatable** for proper state comparison
3. **Keep BLoC pure** - no UI logic in BLoC
4. **Use repositories** for data access
5. **Test thoroughly** with bloc_test
6. **Handle errors** gracefully with error states
7. **Dispose BLoCs** properly
8. **Use MultiBlocProvider** for multiple BLoCs
9. **Emit states** based on business logic only
10. **Document complex logic** in BLoC

## Resources

- https://bloclibrary.dev
- https://github.com/felangel/bloc
