---
name: unit-tests
description: Write pytest tests using Test-Driven Development (TDD). Use when implementing features, fixing bugs, or when the user mentions testing, TDD, or pytest. Tests should be written BEFORE implementation code.
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

# Test-Driven Development (TDD)

This Skill helps implement features and fix bugs using Test-Driven Development, following the Red-Green-Refactor cycle.

## TDD Philosophy

**Write tests BEFORE writing implementation code.**

TDD is not just about testing - it's a design and development methodology:
- Tests define the behavior you want
- Implementation fulfills that behavior
- Refactoring improves the design while keeping behavior intact

## The Red-Green-Refactor Cycle

### 1. RED - Write a Failing Test

Write the smallest possible test that fails because the functionality doesn't exist yet.

**Key principle**: The test MUST fail initially. If it passes without implementation, the test is wrong.

```python
import pytest
from student_management.models import Student

@pytest.mark.django_db
def test_student_full_name(mock_site_context):
    """Test that student has a full_name property."""
    student = Student.objects.create(
        first_name="Jane",
        last_name="Smith",
        email="jane@example.com"
    )
    # This will fail because full_name doesn't exist yet
    assert student.full_name == "Jane Smith"
```

**Run the test** and verify it fails:
```bash
pytest path/to/test_file.py::test_student_full_name -v
```

### 2. GREEN - Write Minimal Code to Pass

Write the SIMPLEST code that makes the test pass. Don't over-engineer.

```python
# In models.py
class Student(SiteAwareModel):
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    email = models.EmailField()

    @property
    def full_name(self):
        return f"{self.first_name} {self.last_name}"
```

**Run the test** and verify it passes, and make sure nothing else broke
```bash
pytest path/to/test_file.py::test_student_full_name -v
pytest
```


### 3. REFACTOR - Improve the Design

Now that tests are passing, refactor for clarity, performance, or design. Tests ensure you don't break anything.

```python
# Maybe you decide to add .strip() for safety
@property
def full_name(self):
    return f"{self.first_name.strip()} {self.last_name.strip()}"
```

**Run the test** again to ensure it still passes:
```bash
pytest path/to/test_file.py::test_student_full_name -v

pytest
```

### 4. REPEAT

Add the next test and repeat the cycle. Build functionality incrementally.

## TDD Workflow for New Features

### Step 1: Understand the Requirement

Read or clarify what needs to be built:
- What models/views/utilities are needed?
- What's the expected behavior?
- What are the edge cases?

### Step 2: Write One Failing Test

**CRITICAL**: Write ONE test at a time (project convention).

Create or open the test file:
- Location: `freedom_ls/<app_name>/tests/test_<module_name>.py`
- Naming: `test_<what_is_being_tested>.py`

Write a test that describes the desired behavior:

```python
import pytest
from content_engine.models import Course

@pytest.mark.django_db
def test_course_enrollment_count(mock_site_context):
    """Test that course can count enrolled students."""
    course = Course.objects.create(title="Python 101")
    # This will fail - enrollment_count doesn't exist
    assert course.enrollment_count == 0
```

### Step 3: Run the Test and Watch it Fail

```bash
pytest freedom_ls/content_engine/tests/test_course.py::test_course_enrollment_count -v
```

**Verify the failure is what you expect**:
- AttributeError: 'Course' object has no attribute 'enrollment_count' ✓
- Not some other error

### Step 4: Write Minimal Implementation

Add just enough code to make the test pass:

```python
# In models.py
class Course(TitledContent):
    # ... existing fields ...

    @property
    def enrollment_count(self):
        return 0  # Simplest implementation
```

### Step 5: Run the Test and Watch it Pass

```bash
pytest freedom_ls/content_engine/tests/test_course.py::test_course_enrollment_count -v
```

### Step 6: Refactor if Needed

The implementation is too simple. Add another test to drive the real behavior:

```python
@pytest.mark.django_db
def test_course_enrollment_count_with_students(mock_site_context):
    """Test that course counts enrolled students correctly."""
    course = Course.objects.create(title="Python 101")
    student1 = Student.objects.create(first_name="Jane", last_name="Doe", email="jane@example.com")
    student2 = Student.objects.create(first_name="John", last_name="Doe", email="john@example.com")

    StudentCourseRegistration.objects.create(student=student1, course=course)
    StudentCourseRegistration.objects.create(student=student2, course=course)

    assert course.enrollment_count == 2
```

Run it - it fails. Now implement properly:

```python
@property
def enrollment_count(self):
    return self.studentcourseregistration_set.count()
```

Run both tests - they both pass. ✓

### Step 7: Repeat

Add the next test for the next piece of functionality. Build incrementally.

## TDD Workflow for Bug Fixes

When fixing bugs, use TDD to ensure the bug stays fixed.

### Step 1: Understand the Bug

- Read the code to understand what's happening
- Identify the specific buggy behavior
- Check for existing tests

### Step 2: Write a Test that Exposes the Bug

**The test should FAIL** because the bug exists:

```python
@pytest.mark.django_db
def test_student_registration_prevents_duplicates(mock_site_context):
    """Test that students cannot register for the same course twice."""
    course = Course.objects.create(title="Python 101")
    student = Student.objects.create(first_name="Jane", last_name="Doe", email="jane@example.com")

    StudentCourseRegistration.objects.create(student=student, course=course)

    # This should raise an error but currently doesn't (the bug)
    with pytest.raises(ValidationError):
        StudentCourseRegistration.objects.create(student=student, course=course)
```

### Step 3: Run the Test - It Should FAIL

```bash
pytest freedom_ls/student_management/tests/test_registration.py::test_student_registration_prevents_duplicates -v
```

**Expected failure**: The test fails because no ValidationError is raised (the bug).

**DO NOT CONTINUE** until you have a failing test. The failing test proves the bug exists.

### Step 4: Fix the Bug

Add the minimal code to fix the issue:

```python
# In models.py
class StudentCourseRegistration(SiteAwareModel):
    student = models.ForeignKey(Student, on_delete=models.CASCADE)
    course = models.ForeignKey(Course, on_delete=models.CASCADE)

    class Meta:
        unique_together = [['student', 'course', 'site']]  # Fix the bug
```

### Step 5: Run the Test - It Should PASS

```bash
pytest freedom_ls/student_management/tests/test_registration.py::test_student_registration_prevents_duplicates -v
```

### Step 6: Run ALL Tests

Ensure the fix didn't break anything:

```bash
pytest
```

## Project-Specific Testing Patterns

### Site-Aware Models Testing

All models in this project are site-aware. When testing models that require site context, always use the `mock_site_context` fixture:

```python
@pytest.mark.django_db
def test_student_creation(mock_site_context):
    student = Student.objects.create(
        first_name="John",
        last_name="Doe",
        email="john@example.com"
    )
    assert student.site is not None
```

**There is no need to explicitly set the site** if `mock_site_context` is being used.

**BAD** (unnecessary complexity):
```python
def test_student_creation(live_server_site):
    student = Student.objects.create(
        first_name="John",
        last_name="Doe",
        email="john@example.com",
        site=live_server_site.site  # Don't do this
    )
```

This is bad because it spins up a whole server to get access to a Site object that we don't need.

### Fixtures

Common fixtures are in `conftest.py`.

If you make new fixtures that are likely to be reused, put them in `conftest.py`.

### Import Pattern

Apps are inside the `freedom_ls/` directory but it's on the PATH. Leave out the `freedom_ls` part:

```python
# CORRECT
from content_engine.models import Course
from student_management.models import Student

# INCORRECT
from freedom_ls.content_engine.models import Course
from freedom_ls.student_management.models import Student
```

## Test Structure Templates

### Model Tests

```python
import pytest
from <app_name>.models import ModelName

@pytest.mark.django_db
def test_model_method(mock_site_context):
    """Test a specific model method."""
    instance = ModelName.objects.create(field1="value")
    result = instance.some_method()
    assert result == expected_value
```

### View/API Tests

```python
import pytest
from django.test import Client
from django.urls import reverse

@pytest.mark.django_db
def test_api_endpoint(client, user, mock_site_context):
    """Test API endpoint returns expected response."""
    client.force_login(user)
    response = client.get(reverse('app:endpoint-name'))
    assert response.status_code == 200
    result = response.json()
    assert result == expected_data  # Always be explicit
```

### Utility Function Tests

```python
import pytest
from <app_name>.utils import utility_function

def test_utility_function():
    """Test utility function with various inputs."""
    result = utility_function(input_value)
    assert result == expected_output
```

### Testing Edge Cases

```python
@pytest.mark.django_db
def test_full_name_with_empty_first_name(mock_site_context):
    """Test full_name when first_name is empty."""
    student = Student.objects.create(
        first_name="",
        last_name="Doe",
        email="doe@example.com"
    )
    assert student.full_name == " Doe"  # Be explicit about expected behavior
```

### Testing Error Cases

```python
@pytest.mark.django_db
def test_registration_requires_student(mock_site_context):
    """Test that registration cannot be created without a student."""
    course = Course.objects.create(title="Python 101")

    with pytest.raises(IntegrityError):
        StudentCourseRegistration.objects.create(
            student=None,  # Should fail
            course=course
        )
```

## Test Best Practices

### Writing Good Tests

- **Use descriptive test names** that explain what is being tested
- **Include docstrings** explaining the test's purpose
- **Use `@pytest.mark.django_db`** for tests that touch the database
- **Use fixtures from `conftest.py`** when available
- **Always use `mock_site_context`** for site-aware models
- **Keep tests focused** - one assertion concept per test
- **Write one test at a time** (project convention)
- **DO NOT** include conditionals and branching logic in tests. Test one execution path at a time

### Making Assertions

- **Be explicit**: `assert result == []` NOT `assert type(result) is list`
- **No if statements in tests**: The code under test is deterministic
- **Use pytest.raises** for testing exceptions
- **Assert on exact values** when possible, not just types or truthiness

### Test Organization

```python
"""Tests for Student model."""
import pytest
from student_management.models import Student, Cohort


@pytest.mark.django_db
class TestStudentModel:
    """Test suite for Student model."""

    def test_student_creation(self, mock_site_context):
        """Test that students can be created with required fields."""
        student = Student.objects.create(
            first_name="Jane",
            last_name="Smith",
            email="jane@example.com"
        )
        assert student.first_name == "Jane"
        assert student.last_name == "Smith"
        assert student.email == "jane@example.com"
        assert student.site is not None

    def test_student_str_method(self, mock_site_context):
        """Test string representation of Student."""
        student = Student.objects.create(
            first_name="Jane",
            last_name="Smith",
            email="jane@example.com"
        )
        assert str(student) == "Jane Smith"

    def test_student_cohort_relationship(self, mock_site_context):
        """Test that students can be added to cohorts."""
        cohort = Cohort.objects.create(name="2024 Cohort")
        student = Student.objects.create(
            first_name="Jane",
            last_name="Smith",
            email="jane@example.com"
        )
        student.cohorts.add(cohort)
        assert student.cohorts.count() == 1
        assert cohort in student.cohorts.all()
```

## Running Tests

### Run Specific Test

```bash
pytest path/to/test_file.py::test_name -v
```

### Run Test File

```bash
pytest freedom_ls/student_management/tests/test_models.py -v
```

### Run All Tests

```bash
pytest
```

### Run Tests with Output

```bash
pytest -v  # verbose
pytest -s  # show print statements
pytest -vv  # very verbose
```

### Run Tests Matching Pattern

```bash
pytest -k "student" -v  # runs all tests with "student" in the name
```

## Test Coverage Checklist

For each feature, write tests covering:

- **Happy path**: Normal expected usage
- **Edge cases**: Empty values, None, boundary conditions
- **Error cases**: Invalid inputs, missing required fields
- **Business logic**: Custom methods, calculated properties
- **Relationships**: Foreign keys, M2M relationships (for site-aware models)
- **Permissions**: Access control if applicable

**TDD approach**: Write these tests BEFORE implementing. Each test drives the next piece of implementation.

## When to Use This Skill

Use this Skill when:
- **Implementing new features** - Write tests first, then implement
- **Fixing bugs** - Write failing test, then fix
- **User mentions "TDD", "test", "pytest"**
- **Adding functionality** - Use TDD to design it
- **Refactoring code** - Ensure tests pass throughout

## TDD Benefits

- **Better design**: Tests force you to think about interfaces first
- **Confidence**: Comprehensive test coverage from the start
- **Documentation**: Tests show how code should be used
- **Regression prevention**: Bugs can't resurface
- **Faster debugging**: Failures are caught immediately

## Legacy Code (Testing Existing Code)

Sometimes you need to add tests to existing code that wasn't built with TDD.

### Workflow

1. **Read the code** to understand what it does
2. **Check existing tests** to follow established patterns
3. **Create test file** if it doesn't exist: `freedom_ls/<app_name>/tests/test_<module_name>.py`
4. **Write tests one at a time** for existing behavior
5. **Run each test** to verify it works
6. **Continue** until coverage is sufficient

### Example

```python
# Existing code in models.py (already written)
class Student(SiteAwareModel):
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)

    def get_full_name(self):
        return f"{self.first_name} {self.last_name}"

# Write test for existing method
@pytest.mark.django_db
def test_get_full_name(mock_site_context):
    """Test existing get_full_name method."""
    student = Student.objects.create(
        first_name="Jane",
        last_name="Smith",
        email="jane@example.com"
    )
    assert student.get_full_name() == "Jane Smith"
```

This is acceptable for legacy code, but **prefer TDD for all new work**.

## Quick TDD Reference

1. ❌ **RED**: Write failing test
2. ✅ **GREEN**: Make it pass with minimal code, make sure all the other tests pass too!
3. ♻️ **REFACTOR**: Improve design while keeping tests green
4. 🔁 **REPEAT**: Next test, next feature

**Remember**: Tests come FIRST. Implementation comes SECOND.
