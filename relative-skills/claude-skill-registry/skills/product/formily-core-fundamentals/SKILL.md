---
name: Formily Core Fundamentals
description: This skill should be used when the user asks to "learn formily basics", "setup formily", "formily core concepts", "formily getting started", "formily fundamentals", "how to use formily", "formily installation", or "formily form state management".
version: 1.0.0
---

# Formily Core Fundamentals

This skill provides essential guidance for using Formily as a React form solution. Focus on understanding core concepts, setting up Formily projects, and implementing basic forms with TypeScript.

## Core Concepts Overview

Formily is a performant, flexible, and extensible form solution for React. It provides:

- **Schema-driven forms** - Define forms through JSON schema
- **Path-based value management** - Access nested form values via path strings
- **Powerful validation** - Built-in validation with custom rules
- **Fine-grained reactivity** - Efficient updates and minimal re-renders
- **TypeScript support** - Full type safety for forms and validation

## Installation and Setup

Install core Formily packages:

```bash
npm install @formily/core @formily/react @formily/validate
```

For TypeScript support, install types:

```bash
npm install -D @types/react @types/react-dom
```

## Basic Form Implementation

Create a simple contact form to understand Formily fundamentals:

### 1. Define Form Schema

```typescript
import { createForm } from '@formily/core'

const form = createForm({
  initialValues: {
    name: '',
    email: '',
    message: ''
  }
})
```

### 2. Connect Form to React

```typescript
import { FormProvider, createField } from '@formily/react'

// In your component
const MyForm = () => {
  return (
    <FormProvider form={form}>
      {/* Form fields go here */}
    </FormProvider>
  )
}
```

### 3. Create Form Fields

```typescript
import { Field } from '@formily/react'

const NameField = () => (
  <Field name="name">
    {(field, state) => (
      <div>
        <label>Name:</label>
        <input
          value={state.value || ''}
          onChange={e => field.onInput(e.target.value)}
        />
        {state.errors && <span>{state.errors}</span>}
      </div>
    )}
  </Field>
)
```

## Form State Management

Formily manages form state through the `form` instance:

### Accessing Form Values

```typescript
// Get all form values
const values = form.values

// Get specific field value
const name = form.values.name

// Get nested values
const address = form.values.contact.address
```

### Setting Form Values

```typescript
// Set single field
form.setValues({
  name: 'John Doe'
})

// Set multiple fields
form.setValues({
  name: 'John Doe',
  email: 'john@example.com'
})

// Set nested values
form.setValues({
  'user.profile.name': 'John Doe'
})
```

### Field State Management

```typescript
// Access field state
const field = form.query('name')
const fieldValue = field.value
const fieldErrors = field.errors
const fieldTouched = field.touched

// Modify field state
form.setFieldState('name', state => {
  state.value = 'New value'
  state.errors = ['Error message']
})
```

## Validation Basics

Formily provides built-in validation capabilities:

### Schema Validation

```typescript
import { createForm } from '@formily/core'

const form = createForm({
  schema: {
    type: 'object',
    properties: {
      name: {
        type: 'string',
        title: 'Name',
        required: true,
        'x-validator': [
          { required: true, message: 'Name is required' },
          { min: 2, message: 'Name must be at least 2 characters' }
        ]
      },
      email: {
        type: 'string',
        title: 'Email',
        format: 'email',
        'x-validator': [
          { format: 'email', message: 'Invalid email format' }
        ]
      }
    }
  }
})
```

### Custom Validation Rules

```typescript
import { createForm } from '@formily/core'

const form = createForm({
  validateFirst: true,
  effects() {
    onFieldChange('confirmPassword', ['value'], (field) => {
      const password = form.values.password
      const confirmPassword = field.value

      if (password !== confirmPassword) {
        field.errors = ['Passwords do not match']
      } else {
        field.errors = []
      }
    })
  }
})
```

## Form Submission

Handle form submission with proper validation:

```typescript
const handleSubmit = async () => {
  try {
    // Validate entire form
    await form.validate()

    // Get form values
    const values = form.values
    console.log('Form submitted:', values)

    // Reset form if needed
    form.reset()
  } catch (errors) {
    console.error('Validation errors:', errors)
  }
}
```

## TypeScript Integration

Formily provides full TypeScript support:

### Define Form Types

```typescript
interface ContactForm {
  name: string
  email: string
  message: string
}

// Create typed form
const form = createForm<ContactForm>({
  initialValues: {
    name: '',
    email: '',
    message: ''
  }
})

// Access typed values
const name: string = form.values.name
```

### Type-Safe Field Components

```typescript
import { Field } from '@formily/react'

interface StringFieldProps {
  name: string
  label: string
  placeholder?: string
}

const StringField: React.FC<StringFieldProps> = ({ name, label, placeholder }) => (
  <Field name={name}>
    {(field, state) => (
      <div>
        <label>{label}:</label>
        <input
          value={state.value || ''}
          onChange={e => field.onInput(e.target.value)}
          placeholder={placeholder}
        />
        {state.errors && <span className="error">{state.errors[0]}</span>}
      </div>
    )}
  </Field>
)
```

## Common Patterns

### Conditional Fields

```typescript
const form = createForm({
  effects() {
    onFieldChange('hasAccount', ['value'], (field) => {
      const hasAccount = field.value
      form.setFieldState('password', state => {
        state.visible = hasAccount
        if (!hasAccount) {
          state.value = ''
        }
      })
    })
  }
})
```

### Dynamic Field Arrays

```typescript
// Add item to array
form.pushValues('emails', '')

// Remove item from array
form.removeValues('emails.0')

// Insert item at specific position
form.insertValues('emails.1', 'new@email.com')
```

## Performance Optimization

### Minimize Re-renders

```typescript
import { observer } from '@formily/reactive-react'

const OptimizedField = observer(({ name }: { name: string }) => (
  <Field name={name}>
    {(field, state) => (
      <input
        value={state.value || ''}
        onChange={e => field.onInput(e.target.value)}
      />
    )}
  </Field>
))
```

### Batch Updates

```typescript
// Batch multiple updates for better performance
form.batch(() => {
  form.setValues({ field1: 'value1' })
  form.setValues({ field2: 'value2' })
  form.setValues({ field3: 'value3' })
})
```

## Error Handling

### Global Error Handler

```typescript
const form = createForm({
  effects() {
    onError((error) => {
      console.error('Form error:', error)
      // Handle global form errors
    })
  }
})
```

### Field-Specific Error Handling

```typescript
const form = createForm({
  effects() {
    onFieldError('email', (field, errors) => {
      if (errors.includes('Invalid format')) {
        // Show custom error UI
      }
    })
  }
})
```

## Additional Resources

### Reference Files
- **`references/types-cheatsheet.md`** - Common TypeScript types and interfaces
- **`references/validation-rules.md`** - Built-in validation rules reference

### Example Files
- **`examples/simple-contact-form.tsx`** - Complete working contact form example
- **`examples/field-components.tsx`** - Reusable field component patterns

### Common Formily Patterns
- Use `form.submit()` for form submission with validation
- Leverage `form.reset()` for clearing form state
- Use `form.setFieldState()` for granular field control
- Implement custom validators with `x-validator` or effects

## Best Practices

1. **Always define TypeScript interfaces** for your form schemas
2. **Use schema validation** instead of manual validation when possible
3. **Leverage observer** for performance-critical components
4. **Handle errors gracefully** at both form and field levels
5. **Use batch operations** for multiple state updates
6. **Create reusable field components** to reduce code duplication
7. **Test validation thoroughly** with edge cases and error scenarios