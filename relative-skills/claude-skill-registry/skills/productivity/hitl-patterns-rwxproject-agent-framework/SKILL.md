---
name: hitl-patterns
description: Human-in-the-Loop pattern library for CopilotKit. Use when implementing approval workflows, user input collection, option selection, or any human interaction patterns. Includes React components and hooks.
allowed-tools: Read, Write, Grep
---

# HITL (Human-in-the-Loop) Patterns

Comprehensive patterns for human-agent interaction using CopilotKit.

## Core Hook: useHumanInTheLoop

```tsx
import { useHumanInTheLoop } from "@copilotkit/react-core";

useHumanInTheLoop({
  name: "hookName",           // Unique identifier
  description: "...",         // LLM uses this to decide when to call
  parameters: [               // Input schema
    { name: "param", type: "string", description: "..." }
  ],
  render: ({ args, respond }) => (
    // React component for user interaction
    <Component onComplete={(result) => respond(result)} />
  )
});
```

## Pattern 1: Approval Workflow

Request user approval before executing sensitive actions.

### Hook Definition

```tsx
useHumanInTheLoop({
  name: "approveAction",
  description: "Request user approval before executing sensitive or irreversible actions",
  parameters: [
    { name: "action", type: "string", description: "Description of the action to approve" },
    { name: "risk_level", type: "string", description: "Risk assessment: low, medium, high" },
    { name: "details", type: "object", description: "Additional action details" }
  ],
  render: ({ args, respond }) => (
    <ApprovalDialog
      action={args.action}
      risk={args.risk_level}
      details={args.details}
      onApprove={() => respond({ approved: true, timestamp: new Date() })}
      onReject={(reason) => respond({ approved: false, reason })}
    />
  )
});
```

### Component Implementation

```tsx
interface ApprovalDialogProps {
  action: string;
  risk: 'low' | 'medium' | 'high';
  details?: Record<string, any>;
  onApprove: () => void;
  onReject: (reason?: string) => void;
}

function ApprovalDialog({ action, risk, details, onApprove, onReject }: ApprovalDialogProps) {
  const [reason, setReason] = useState('');

  const riskColors = {
    low: 'bg-green-100 border-green-500',
    medium: 'bg-yellow-100 border-yellow-500',
    high: 'bg-red-100 border-red-500'
  };

  return (
    <div className={`p-4 rounded-lg border-2 ${riskColors[risk]}`}>
      <h3 className="text-lg font-semibold mb-2">Approval Required</h3>
      <p className="mb-4">{action}</p>

      {details && (
        <pre className="bg-gray-100 p-2 rounded mb-4 text-sm">
          {JSON.stringify(details, null, 2)}
        </pre>
      )}

      <div className="flex gap-2">
        <button
          onClick={onApprove}
          className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700"
        >
          Approve
        </button>
        <button
          onClick={() => onReject(reason)}
          className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700"
        >
          Reject
        </button>
      </div>

      <input
        type="text"
        placeholder="Rejection reason (optional)"
        value={reason}
        onChange={(e) => setReason(e.target.value)}
        className="mt-2 w-full p-2 border rounded"
      />
    </div>
  );
}
```

## Pattern 2: User Input Collection

Collect structured data from the user.

### Hook Definition

```tsx
useHumanInTheLoop({
  name: "collectUserInput",
  description: "Collect structured information from the user via a form",
  parameters: [
    {
      name: "fields",
      type: "array",
      description: "Form fields to display",
      items: {
        type: "object",
        properties: {
          name: { type: "string" },
          label: { type: "string" },
          type: { type: "string", enum: ["text", "email", "number", "textarea", "select"] },
          required: { type: "boolean" },
          options: { type: "array", items: { type: "string" } }
        }
      }
    },
    { name: "title", type: "string", description: "Form title" }
  ],
  render: ({ args, respond }) => (
    <DynamicForm
      title={args.title}
      fields={args.fields}
      onSubmit={(data) => respond({ success: true, data })}
      onCancel={() => respond({ success: false, cancelled: true })}
    />
  )
});
```

### Component Implementation

```tsx
interface Field {
  name: string;
  label: string;
  type: 'text' | 'email' | 'number' | 'textarea' | 'select';
  required?: boolean;
  options?: string[];
  placeholder?: string;
}

interface DynamicFormProps {
  title: string;
  fields: Field[];
  onSubmit: (data: Record<string, any>) => void;
  onCancel: () => void;
}

function DynamicForm({ title, fields, onSubmit, onCancel }: DynamicFormProps) {
  const [formData, setFormData] = useState<Record<string, any>>({});
  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    // Validate required fields
    const newErrors: Record<string, string> = {};
    fields.forEach(field => {
      if (field.required && !formData[field.name]) {
        newErrors[field.name] = `${field.label} is required`;
      }
    });

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }

    onSubmit(formData);
  };

  const renderField = (field: Field) => {
    const commonProps = {
      id: field.name,
      name: field.name,
      value: formData[field.name] || '',
      onChange: (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) =>
        setFormData({ ...formData, [field.name]: e.target.value }),
      className: `w-full p-2 border rounded ${errors[field.name] ? 'border-red-500' : ''}`,
      placeholder: field.placeholder
    };

    switch (field.type) {
      case 'textarea':
        return <textarea {...commonProps} rows={4} />;
      case 'select':
        return (
          <select {...commonProps}>
            <option value="">Select...</option>
            {field.options?.map(opt => (
              <option key={opt} value={opt}>{opt}</option>
            ))}
          </select>
        );
      default:
        return <input type={field.type} {...commonProps} />;
    }
  };

  return (
    <form onSubmit={handleSubmit} className="p-4 bg-white rounded-lg shadow">
      <h3 className="text-lg font-semibold mb-4">{title}</h3>

      {fields.map(field => (
        <div key={field.name} className="mb-4">
          <label htmlFor={field.name} className="block mb-1 font-medium">
            {field.label} {field.required && <span className="text-red-500">*</span>}
          </label>
          {renderField(field)}
          {errors[field.name] && (
            <p className="text-red-500 text-sm mt-1">{errors[field.name]}</p>
          )}
        </div>
      ))}

      <div className="flex gap-2">
        <button type="submit" className="px-4 py-2 bg-blue-600 text-white rounded">
          Submit
        </button>
        <button type="button" onClick={onCancel} className="px-4 py-2 bg-gray-300 rounded">
          Cancel
        </button>
      </div>
    </form>
  );
}
```

## Pattern 3: Option Selection

Present options for user to choose from.

### Hook Definition

```tsx
useHumanInTheLoop({
  name: "selectOption",
  description: "Present multiple options for the user to choose from",
  parameters: [
    { name: "question", type: "string", description: "Question or prompt" },
    {
      name: "options",
      type: "array",
      description: "Available options",
      items: {
        type: "object",
        properties: {
          id: { type: "string" },
          label: { type: "string" },
          description: { type: "string" },
          icon: { type: "string" }
        }
      }
    },
    { name: "multiSelect", type: "boolean", description: "Allow multiple selections" }
  ],
  render: ({ args, respond }) => (
    <OptionSelector
      question={args.question}
      options={args.options}
      multiSelect={args.multiSelect}
      onSelect={(selected) => respond({ selected })}
    />
  )
});
```

### Component Implementation

```tsx
interface Option {
  id: string;
  label: string;
  description?: string;
  icon?: string;
}

interface OptionSelectorProps {
  question: string;
  options: Option[];
  multiSelect?: boolean;
  onSelect: (selected: string | string[]) => void;
}

function OptionSelector({ question, options, multiSelect, onSelect }: OptionSelectorProps) {
  const [selected, setSelected] = useState<string[]>([]);

  const toggleOption = (id: string) => {
    if (multiSelect) {
      setSelected(prev =>
        prev.includes(id)
          ? prev.filter(x => x !== id)
          : [...prev, id]
      );
    } else {
      setSelected([id]);
    }
  };

  const handleConfirm = () => {
    onSelect(multiSelect ? selected : selected[0]);
  };

  return (
    <div className="p-4 bg-white rounded-lg shadow">
      <h3 className="text-lg font-semibold mb-4">{question}</h3>

      <div className="space-y-2">
        {options.map(option => (
          <button
            key={option.id}
            onClick={() => toggleOption(option.id)}
            className={`w-full p-3 text-left rounded border-2 transition-colors ${
              selected.includes(option.id)
                ? 'border-blue-500 bg-blue-50'
                : 'border-gray-200 hover:border-gray-300'
            }`}
          >
            <div className="flex items-center gap-3">
              {option.icon && <span className="text-2xl">{option.icon}</span>}
              <div>
                <div className="font-medium">{option.label}</div>
                {option.description && (
                  <div className="text-sm text-gray-500">{option.description}</div>
                )}
              </div>
            </div>
          </button>
        ))}
      </div>

      <button
        onClick={handleConfirm}
        disabled={selected.length === 0}
        className="mt-4 px-4 py-2 bg-blue-600 text-white rounded disabled:opacity-50"
      >
        Confirm Selection
      </button>
    </div>
  );
}
```

## Pattern 4: Progress Confirmation

Confirm progress at key workflow steps.

```tsx
useHumanInTheLoop({
  name: "confirmProgress",
  description: "Show progress and confirm continuation",
  parameters: [
    { name: "currentStep", type: "number" },
    { name: "totalSteps", type: "number" },
    { name: "completedItems", type: "array" },
    { name: "nextAction", type: "string" }
  ],
  render: ({ args, respond }) => (
    <ProgressConfirmation
      current={args.currentStep}
      total={args.totalSteps}
      completed={args.completedItems}
      next={args.nextAction}
      onContinue={() => respond({ continue: true })}
      onPause={() => respond({ continue: false, paused: true })}
      onCancel={() => respond({ continue: false, cancelled: true })}
    />
  )
});
```

## Usage in Agent Instructions

```python
orchestrator = LlmAgent(
    name="orchestrator",
    instruction="""
    When performing sensitive actions, use the approveAction tool first.
    When you need user input, use collectUserInput with appropriate fields.
    When presenting choices, use selectOption with clear descriptions.
    Always confirm before irreversible operations.
    """
)
```
