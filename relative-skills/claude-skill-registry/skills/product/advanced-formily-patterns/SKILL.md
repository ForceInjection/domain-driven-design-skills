---
name: Advanced Formily Patterns
description: This skill should be used when the user asks to "implement dynamic forms", "formily complex forms", "formily conditional fields", "formily nested forms", "formily async validation", "formily performance optimization", or "advanced formily patterns".
version: 1.0.0
---

# Advanced Formily Patterns

This skill provides advanced guidance for implementing complex form scenarios with Formily. Focus on dynamic forms, conditional fields, nested forms, async validation, performance optimization, and sophisticated form patterns in TypeScript.

## Dynamic Forms

### Conditional Field Visibility

```typescript
import { createForm, onFieldChange } from '@formily/core'

const form = createForm({
  effects() {
    // Show/hide fields based on other field values
    onFieldChange('userType', ['value'], (field) => {
      const userType = field.value

      form.setFieldState('companyName', state => {
        state.visible = userType === 'business'
        if (userType !== 'business') {
          state.value = ''
        }
      })

      form.setFieldState('studentId', state => {
        state.visible = userType === 'student'
        if (userType !== 'student') {
          state.value = ''
        }
      })
    })
  }
})
```

### Dynamic Field Options

```typescript
const form = createForm({
  effects() {
    onFieldChange('country', ['value'], (field) => {
      const country = field.value

      // Update city options based on selected country
      const cityOptions = country === 'us'
        ? [
            { label: 'New York', value: 'nyc' },
            { label: 'Los Angeles', value: 'la' },
            { label: 'Chicago', value: 'chi' }
          ]
        : country === 'uk'
        ? [
            { label: 'London', value: 'lon' },
            { label: 'Manchester', value: 'man' },
            { label: 'Birmingham', value: 'bir' }
          ]
        : []

      form.setFieldState('city', state => {
        state.dataSource = cityOptions
        state.value = cityOptions.length > 0 ? cityOptions[0].value : ''
      })
    })
  }
})
```

### Dynamic Form Schema

```typescript
import { createForm, Form } from '@formily/core'

interface DynamicFormConfig {
  fields: Array<{
    name: string
    type: 'string' | 'number' | 'boolean' | 'array' | 'object'
    label: string
    required?: boolean
    options?: Array<{ label: string; value: any }>
    validation?: any[]
  }>
}

const createDynamicForm = (config: DynamicFormConfig) => {
  const schema = {
    type: 'object',
    properties: config.fields.reduce((acc, field) => {
      acc[field.name] = {
        type: field.type,
        title: field.label,
        required: field.required,
        'x-validator': field.validation
      }

      if (field.type === 'boolean') {
        acc[field.name]['x-component'] = 'Checkbox'
      } else if (field.options) {
        acc[field.name]['x-component'] = 'Select'
        acc[field.name]['x-component-props'] = {
          options: field.options
        }
      } else {
        acc[field.name]['x-component'] = 'Input'
      }

      return acc
    }, {} as any)
  }

  return createForm({ schema })
}
```

## Array Field Patterns

### Dynamic Array Items

```typescript
import { createForm, isArrayField } from '@formily/core'
import { ArrayField } from '@formily/react'

const form = createForm({
  initialValues: {
    contacts: [
      { name: '', phone: '', relationship: '' }
    ]
  }
})

// Add new contact item
const addContact = () => {
  form.pushValues('contacts', {
    name: '',
    phone: '',
    relationship: ''
  })
}

// Remove contact item
const removeContact = (index: number) => {
  form.removeValues(`contacts.${index}`)
}

// Reorder contacts
const moveContact = (fromIndex: number, toIndex: number) => {
  const field = form.query('contacts')
  if (isArrayField(field)) {
    field.move(fromIndex, toIndex)
  }
}
```

### Nested Array Objects

```typescript
interface Contact {
  name: string
  emails: Array<{
    address: string
    type: 'work' | 'personal' | 'other'
  }>
}

const NestedArrayForm = () => {
  const form = createForm<Contact>({
    initialValues: {
      name: '',
      emails: []
    }
  })

  const addEmail = () => {
    form.pushValues('emails', {
      address: '',
      type: 'work'
    })
  }

  return (
    <FormProvider form={form}>
      <ArrayField name="emails">
        {(field) => (
          <div>
            {field.value?.map((email, index) => (
              <div key={index}>
                <Field name={`emails.${index}.address`}>
                  {/** Email input component */}
                </Field>
                <Field name={`emails.${index}.type`}>
                  {/** Email type select component */}
                </Field>
              </div>
            ))}
            <button onClick={addEmail}>Add Email</button>
          </div>
        )}
      </ArrayField>
    </FormProvider>
  )
}
```

## Async Validation Patterns

### Server-Side Validation

```typescript
import { createForm } from '@formily/core'

const form = createForm({
  effects() {
    // Async email uniqueness check
    onFieldChange('email', ['value'], async (field) => {
      if (!field.value) return

      field.validating = true

      try {
        const isUnique = await checkEmailUniqueness(field.value)

        if (!isUnique) {
          field.errors = ['Email already exists']
        } else {
          field.errors = []
        }
      } catch (error) {
        field.errors = ['Validation failed. Please try again.']
      } finally {
        field.validating = false
      }
    })

    // Debounced validation for performance
    onFieldChange('username', ['value'],
      debounce(async (field) => {
        if (!field.value || field.value.length < 3) return

        field.validating = true

        try {
          const exists = await checkUsernameExists(field.value)
          field.errors = exists ? ['Username already taken'] : []
        } catch (error) {
          field.errors = ['Unable to validate username']
        } finally {
          field.validating = false
        }
      }, 500)
    )
  }
})

// Helper function for debouncing
const debounce = <T extends (...args: any[]) => any>(
  func: T,
  wait: number
) => {
  let timeout: NodeJS.Timeout
  return (...args: Parameters<T>) => {
    clearTimeout(timeout)
    timeout = setTimeout(() => func(...args), wait)
  }
}
```

### Complex Validation Rules

```typescript
import { createForm, onFieldReact } from '@formily/core'

const form = createForm({
  effects() {
    // Password strength validation
    onFieldReact('password', (field) => {
      const password = field.value || ''
      const errors = []

      if (password.length < 8) {
        errors.push('Password must be at least 8 characters')
      }

      if (!/[A-Z]/.test(password)) {
        errors.push('Password must contain uppercase letter')
      }

      if (!/[a-z]/.test(password)) {
        errors.push('Password must contain lowercase letter')
      }

      if (!/\d/.test(password)) {
        errors.push('Password must contain number')
      }

      if (!/[!@#$%^&*]/.test(password)) {
        errors.push('Password must contain special character')
      }

      field.errors = errors
    })

    // Confirm password validation
    onFieldReact('confirmPassword', (field) => {
      const password = form.values.password
      const confirmPassword = field.value

      if (confirmPassword && password !== confirmPassword) {
        field.errors = ['Passwords do not match']
      } else {
        field.errors = []
      }
    })

    // Date range validation
    onFieldReact('endDate', (field) => {
      const startDate = form.values.startDate
      const endDate = field.value

      if (startDate && endDate && new Date(endDate) <= new Date(startDate)) {
        field.errors = ['End date must be after start date']
      } else {
        field.errors = []
      }
    })
  }
})
```

## Nested Form Patterns

### Multi-Step Forms

```typescript
import { createForm } from '@formily/core'
import { useState } from 'react'

interface MultiStepFormData {
  personal: {
    firstName: string
    lastName: string
    email: string
  }
  professional: {
    company: string
    position: string
    experience: number
  }
  preferences: {
    notifications: boolean
    theme: 'light' | 'dark'
    language: string
  }
}

const MultiStepForm = () => {
  const [currentStep, setCurrentStep] = useState(0)

  const form = createForm<MultiStepFormData>({
    initialValues: {
      personal: { firstName: '', lastName: '', email: '' },
      professional: { company: '', position: '', experience: 0 },
      preferences: { notifications: true, theme: 'light', language: 'en' }
    }
  })

  const steps = [
    { title: 'Personal Info', fields: ['personal'] },
    { title: 'Professional', fields: ['professional'] },
    { title: 'Preferences', fields: ['preferences'] }
  ]

  const handleNext = async () => {
    // Validate current step
    const currentFields = steps[currentStep].fields
    const isValid = await Promise.all(
      currentFields.map(field => form.validate(field))
    )

    if (isValid.every(result => result === null)) {
      if (currentStep < steps.length - 1) {
        setCurrentStep(currentStep + 1)
      }
    }
  }

  const handlePrevious = () => {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1)
    }
  }

  const handleSubmit = async () => {
    try {
      await form.validate()
      const values = form.values
      console.log('Form submitted:', values)
    } catch (errors) {
      console.error('Validation errors:', errors)
    }
  }

  return (
    <FormProvider form={form}>
      {/* Step content based on currentStep */}
      {/* Navigation buttons */}
    </FormProvider>
  )
}
```

### Nested Object Management

```typescript
interface Address {
  street: string
  city: string
  state: string
  zip: string
  country: string
}

interface UserProfile {
  name: string
  email: string
  address: Address
  emergencyContact: {
    name: string
    relationship: string
    phone: string
  }
}

const NestedForm = () => {
  const form = createForm<UserProfile>({
    initialValues: {
      name: '',
      email: '',
      address: {
        street: '',
        city: '',
        state: '',
        zip: '',
        country: 'us'
      },
      emergencyContact: {
        name: '',
        relationship: '',
        phone: ''
      }
    }
  })

  // Update nested object efficiently
  const updateAddress = (field: keyof Address, value: string) => {
    form.setFieldState(`address.${field}`, state => {
      state.value = value
    })
  }

  // Batch update nested object
  const updateEntireAddress = (address: Partial<Address>) => {
    form.setValues({
      address: { ...form.values.address, ...address }
    })
  }

  return (
    <FormProvider form={form}>
      {/* Nested form fields */}
    </FormProvider>
  )
}
```

## Performance Optimization

### Memoized Field Components

```typescript
import React, { memo } from 'react'
import { observer } from '@formily/reactive-react'
import { useField } from '@formily/react'

interface OptimizedFieldProps {
  name: string
  component: React.ComponentType<any>
  [key: string]: any
}

const OptimizedField = observer(
  memo<OptimizedFieldProps>(({ name, component: Component, ...props }) => {
    const field = useField(name)

    return (
      <div>
        <Component {...props} value={field.value} onChange={field.onInput} />
        {field.errors && (
          <div className="error">{field.errors[0]}</div>
        )}
      </div>
    )
  })
)

// Usage
const MyForm = () => {
  return (
    <FormProvider form={form}>
      <OptimizedField name="firstName" component={Input} />
      <OptimizedField name="email" component={Input} />
    </FormProvider>
  )
}
```

### Virtualized Large Forms

```typescript
import { FixedSizeList as List } from 'react-window'

const VirtualizedForm = () => {
  const [items] = useState(() =>
    Array.from({ length: 1000 }, (_, i) => ({
      id: `field-${i}`,
      name: `Field ${i + 1}`,
      value: ''
    }))
  )

  const Row = ({ index, style }: { index: number; style: React.CSSProperties }) => (
    <div style={style}>
      <Field name={`items.${index}.value`}>
        {({ field, state }) => (
          <div>
            <label>{items[index].name}</label>
            <Input
              value={state.value}
              onChange={(e) => field.onInput(e.target.value)}
            />
          </div>
        )}
      </Field>
    </div>
  )

  return (
    <FormProvider form={form}>
      <List
        height={400}
        itemCount={items.length}
        itemSize={60}
        width="100%"
      >
        {Row}
      </List>
    </FormProvider>
  )
}
```

### Efficient Field Updates

```typescript
// Batch multiple field updates
const batchUpdateForm = () => {
  form.batch(() => {
    form.setValues({ name: 'John' })
    form.setValues({ email: 'john@example.com' })
    form.setValues({ age: 30 })
    form.setFieldState('name', state => {
      state.touched = true
    })
  })
}

// Selective re-rendering
const SelectiveForm = () => {
  const [shouldRenderExpensive, setShouldRenderExpensive] = useState(false)

  return (
    <FormProvider form={form}>
      {/* Always render essential fields */}
      <Field name="name">
        {/* Simple input */}
      </Field>

      {/* Conditionally render expensive fields */}
      {shouldRenderExpensive && (
        <Field name="complexField">
          {/* Expensive component */}
        </Field>
      )}

      <button onClick={() => setShouldRenderExpensive(!shouldRenderExpensive)}>
        Toggle Complex Field
      </button>
    </FormProvider>
  )
}
```

## Custom Field Patterns

### Address Field Component

```typescript
interface AddressFieldProps {
  name: string
  label?: string
  required?: boolean
}

const AddressField: React.FC<AddressFieldProps> = ({ name, label, required }) => {
  const form = useForm()

  const handleCountryChange = (country: string) => {
    // Reset dependent fields when country changes
    form.setValues({
      [`${name}.state`]: '',
      [`${name}.city`]: ''
    })
  }

  return (
    <div>
      <h3>{label || 'Address'}</h3>

      <Row gutter={16}>
        <Col span={24}>
          <Field name={`${name}.street`}>
            <FormItem label="Street Address" required={required}>
              <Input placeholder="123 Main St" />
            </FormItem>
          </Field>
        </Col>
      </Row>

      <Row gutter={16}>
        <Col span={8}>
          <Field name={`${name}.city`}>
            <FormItem label="City" required={required}>
              <Input placeholder="City" />
            </FormItem>
          </Field>
        </Col>

        <Col span={8}>
          <Field name={`${name}.state`}>
            <FormItem label="State/Province">
              <Input placeholder="State" />
            </FormItem>
          </Field>
        </Col>

        <Col span={8}>
          <Field name={`${name}.zip`}>
            <FormItem label="ZIP/Postal Code">
              <Input placeholder="ZIP" />
            </FormItem>
          </Field>
        </Col>
      </Row>

      <Row gutter={16}>
        <Col span={24}>
          <Field name={`${name}.country`}>
            <FormItem label="Country" required={required}>
              <Select
                placeholder="Select country"
                onChange={handleCountryChange}
              >
                <Select.Option value="us">United States</Select.Option>
                <Select.Option value="ca">Canada</Select.Option>
                <Select.Option value="uk">United Kingdom</Select.Option>
              </Select>
            </FormItem>
          </Field>
        </Col>
      </Row>
    </div>
  )
}
```

### File Upload with Progress

```typescript
import { Upload, Button, Progress } from 'antd'

interface FileUploadFieldProps {
  name: string
  maxSize?: number
  accept?: string
  multiple?: boolean
}

const FileUploadField: React.FC<FileUploadFieldProps> = ({
  name,
  maxSize = 5 * 1024 * 1024, // 5MB
  accept,
  multiple = false
}) => {
  const [uploadProgress, setUploadProgress] = useState<Record<string, number>>({})

  const handleUpload = async (file: File) => {
    const formData = new FormData()
    formData.append('file', file)

    try {
      // Simulate upload progress
      let progress = 0
      const interval = setInterval(() => {
        progress += 10
        setUploadProgress(prev => ({ ...prev, [file.name]: progress }))

        if (progress >= 100) {
          clearInterval(interval)
        }
      }, 200)

      const response = await uploadFile(formData)

      // Update form field with upload result
      form.setValues({
        [name]: response.url
      })

      return response
    } catch (error) {
      console.error('Upload failed:', error)
      throw error
    }
  }

  return (
    <Field name={name}>
      {({ field, state }) => (
        <div>
          <Upload
            customRequest={({ file }) => handleUpload(file as File)}
            beforeUpload={(file) => {
              if (file.size > maxSize) {
                alert(`File size must be less than ${maxSize / 1024 / 1024}MB`)
                return false
              }
              return true
            }}
            accept={accept}
            multiple={multiple}
          >
            <Button icon={<UploadOutlined />}>
              Select {multiple ? 'Files' : 'File'}
            </Button>
          </Upload>

          {Object.entries(uploadProgress).map(([filename, progress]) => (
            <div key={filename}>
              <span>{filename}</span>
              <Progress percent={progress} size="small" />
            </div>
          ))}

          {state.value && (
            <div>Uploaded: {state.value}</div>
          )}
        </div>
      )}
    </Field>
  )
}
```

## Additional Resources

### Example Files
- **`examples/dynamic-form.tsx`** - Complete dynamic form implementation
- **`examples/performance-optimization.tsx`** - Performance optimization techniques
- **`examples/complex-validation.tsx`** - Advanced validation patterns

### Reference Files
- **`references/performance-checklist.md`** - Performance optimization checklist
- **`references/validation-patterns.md`** - Complex validation pattern reference
- **`references/nested-form-patterns.md`** - Nested form architecture guide

### Common Advanced Patterns
- Dynamic field visibility and options
- Async validation with debouncing
- Nested object and array management
- Multi-step form workflows
- Performance optimization strategies
- Custom field component creation

## Best Practices

1. **Use debouncing for async validation** to prevent excessive API calls
2. **Batch field updates** using form.batch() for better performance
3. **Memoize expensive components** to prevent unnecessary re-renders
4. **Virtualize large forms** with hundreds of fields
5. **Use TypeScript generics** for type-safe nested forms
6. **Implement proper error boundaries** for complex form scenarios
7. **Optimize field dependencies** to minimize validation triggers
8. **Use form effects** for reactive field behavior instead of manual listeners