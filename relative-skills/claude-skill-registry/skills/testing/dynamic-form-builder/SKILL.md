---
name: dynamic-form-builder
description: This skill enables Claude to dynamically generate form specifications within chat conversations based on the type of item or project the user wants to build. Instead of providing text responses, Claude will output structured JSON that the frontend can render as interactive form components.
---

## Core Concept
When a user indicates they want to build, quote, or configure an item, Claude should:
1. Identify the item type from the conversation
2. Generate a comprehensive form specification in JSON format
3. Include all necessary fields with proper validation
4. Group related fields logically
5. Provide helpful descriptions and placeholder text

## Available UI Components

The following components are available in the `@/components/ui` folder:

- **Input** - Text, number, email, etc.
- **Textarea** - Multi-line text input
- **Select** (Dropdown) - Single selection from options
- **Checkbox** - Boolean or multiple selections
- **RadioGroup** - Single selection from multiple options
- **Slider** - Numeric input with range
- **DatePicker** - Date selection
- **Switch** - Toggle on/off
- **Label** - Field labels
- **Button** - Form submission and actions

## Item Types and Their Forms

### 1. Custom Furniture/Cabinetry
**Typical fields:**
- Dimensions (length, width, height, depth)
- Material type (wood, metal, glass, composite)
- Finish/color
- Hardware specifications
- Quantity
- Installation requirements
- Special features (drawers, shelves, doors)

### 2. Signage
**Typical fields:**
- Sign type (outdoor, indoor, illuminated, monument)
- Dimensions (length, width, height)
- Material (aluminum, acrylic, wood, vinyl)
- Mounting type (wall, ground, hanging)
- Illumination (LED, backlit, non-illuminated)
- Text/graphics specifications
- Quantity
- Installation location

### 3. Architectural Elements
**Typical fields:**
- Element type (columns, railings, decorative panels)
- Dimensions
- Material specifications
- Load-bearing requirements
- Finish/coating
- Installation method
- Building code compliance needs

### 4. Manufacturing/CNC Parts
**Typical fields:**
- Part type
- Dimensions (with tight tolerances)
- Material specification
- Surface finish requirements
- Quantity
- Tolerance requirements
- 3D file/drawing availability

### 5. Web Development Projects
**Typical fields:**
- Project type (e-commerce, portfolio, SaaS, etc.)
- Number of pages
- Features required (authentication, payment, API integration)
- Design requirements
- Timeline
- Budget range
- Hosting preferences

### 6. Consulting Services
**Typical fields:**
- Service type
- Duration (hours, days, ongoing)
- Deliverables expected
- Industry/specialization
- Timeline
- Budget range

## Form Generation Rules

### When to Generate a Form

Generate a form specification when the user:
- Says they want to "build", "create", "quote", "configure", or "design" something
- Asks about pricing for a specific item type
- Mentions they need specifications for a project
- Indicates they want to start a new project/item

### Form JSON Structure

Always output forms using this exact JSON structure wrapped in a code block with `json-form` language identifier:

```json-form
{
  "formId": "unique-form-id",
  "itemType": "furniture|signage|architectural|manufacturing|web-development|consulting|custom",
  "title": "Human-readable form title",
  "description": "Brief description of what this form collects",
  "sections": [
    {
      "id": "section-1",
      "title": "Section Title",
      "description": "Optional section description",
      "fields": [
        {
          "id": "field-1",
          "name": "fieldName",
          "label": "Field Label",
          "type": "input|textarea|select|checkbox|radio|slider|date|switch",
          "inputType": "text|number|email|tel|url",
          "placeholder": "Placeholder text",
          "defaultValue": "",
          "required": true,
          "validation": {
            "min": 0,
            "max": 1000,
            "pattern": "regex-pattern",
            "message": "Validation error message"
          },
          "options": [
            { "value": "option1", "label": "Option 1" },
            { "value": "option2", "label": "Option 2" }
          ],
          "helperText": "Additional guidance for the user",
          "conditional": {
            "field": "other-field-id",
            "value": "required-value",
            "operator": "equals|notEquals|contains|greaterThan|lessThan"
          }
        }
      ]
    }
  ],
  "submitButton": {
    "text": "Generate Quote",
    "action": "generate-quote"
  }
}
```

### Field Types Mapping

**Input (type: "input")**
```json
{
  "type": "input",
  "inputType": "text|number|email|tel|url",
  "placeholder": "Enter value...",
  "required": true
}
```

**Textarea (type: "textarea")**
```json
{
  "type": "textarea",
  "placeholder": "Enter detailed description...",
  "rows": 4,
  "required": false
}
```

**Select/Dropdown (type: "select")**
```json
{
  "type": "select",
  "options": [
    { "value": "oak", "label": "Oak Wood" },
    { "value": "maple", "label": "Maple Wood" }
  ],
  "required": true
}
```

**Checkbox (type: "checkbox")**
```json
{
  "type": "checkbox",
  "options": [
    { "value": "feature1", "label": "Include Feature 1" },
    { "value": "feature2", "label": "Include Feature 2" }
  ],
  "required": false
}
```

**Radio Group (type: "radio")**
```json
{
  "type": "radio",
  "options": [
    { "value": "indoor", "label": "Indoor Installation" },
    { "value": "outdoor", "label": "Outdoor Installation" }
  ],
  "required": true
}
```

**Slider (type: "slider")**
```json
{
  "type": "slider",
  "min": 0,
  "max": 100,
  "step": 1,
  "defaultValue": 50,
  "unit": "inches",
  "required": true
}
```

**Date Picker (type: "date")**
```json
{
  "type": "date",
  "minDate": "2024-01-01",
  "maxDate": "2025-12-31",
  "required": true
}
```

**Switch (type: "switch")**
```json
{
  "type": "switch",
  "label": "Enable this feature",
  "defaultValue": false,
  "required": false
}
```

## Example Form Generations

### Example 1: Custom Cabinet Quote

**User:** "I need a quote for a custom cabinet"

**Claude Response:**

I'll help you get a quote for a custom cabinet. Please fill out the specifications below:

```json-form
{
  "formId": "cabinet-quote-001",
  "itemType": "furniture",
  "title": "Custom Cabinet Specification",
  "description": "Provide the details for your custom cabinet to receive an accurate quote",
  "sections": [
    {
      "id": "dimensions",
      "title": "Dimensions",
      "description": "All measurements in inches",
      "fields": [
        {
          "id": "length",
          "name": "length",
          "label": "Length (Width)",
          "type": "input",
          "inputType": "number",
          "placeholder": "48",
          "required": true,
          "validation": {
            "min": 12,
            "max": 120,
            "message": "Length must be between 12 and 120 inches"
          },
          "helperText": "The width of the cabinet face"
        },
        {
          "id": "height",
          "name": "height",
          "label": "Height",
          "type": "input",
          "inputType": "number",
          "placeholder": "36",
          "required": true,
          "validation": {
            "min": 12,
            "max": 96,
            "message": "Height must be between 12 and 96 inches"
          }
        },
        {
          "id": "depth",
          "name": "depth",
          "label": "Depth",
          "type": "input",
          "inputType": "number",
          "placeholder": "24",
          "required": true,
          "validation": {
            "min": 6,
            "max": 48,
            "message": "Depth must be between 6 and 48 inches"
          }
        }
      ]
    },
    {
      "id": "materials",
      "title": "Materials & Finish",
      "fields": [
        {
          "id": "material",
          "name": "material",
          "label": "Cabinet Material",
          "type": "select",
          "required": true,
          "options": [
            { "value": "oak", "label": "Oak" },
            { "value": "maple", "label": "Maple" },
            { "value": "cherry", "label": "Cherry" },
            { "value": "walnut", "label": "Walnut" },
            { "value": "birch", "label": "Birch" },
            { "value": "mdf", "label": "MDF (Medium Density Fiberboard)" },
            { "value": "plywood", "label": "Plywood" }
          ]
        },
        {
          "id": "finish",
          "name": "finish",
          "label": "Finish Type",
          "type": "select",
          "required": true,
          "options": [
            { "value": "stain-natural", "label": "Natural Stain" },
            { "value": "stain-dark", "label": "Dark Stain" },
            { "value": "stain-medium", "label": "Medium Stain" },
            { "value": "paint-white", "label": "White Paint" },
            { "value": "paint-custom", "label": "Custom Paint Color" },
            { "value": "unfinished", "label": "Unfinished" }
          ]
        },
        {
          "id": "customColor",
          "name": "customColor",
          "label": "Custom Paint Color",
          "type": "input",
          "inputType": "text",
          "placeholder": "e.g., Sherwin Williams SW 7005",
          "required": false,
          "conditional": {
            "field": "finish",
            "value": "paint-custom",
            "operator": "equals"
          }
        }
      ]
    },
    {
      "id": "features",
      "title": "Cabinet Features",
      "fields": [
        {
          "id": "doorStyle",
          "name": "doorStyle",
          "label": "Door Style",
          "type": "radio",
          "required": true,
          "options": [
            { "value": "shaker", "label": "Shaker Style" },
            { "value": "flat-panel", "label": "Flat Panel" },
            { "value": "raised-panel", "label": "Raised Panel" },
            { "value": "glass", "label": "Glass Front" },
            { "value": "no-doors", "label": "Open Shelving (No Doors)" }
          ]
        },
        {
          "id": "shelves",
          "name": "shelves",
          "label": "Number of Shelves",
          "type": "slider",
          "min": 0,
          "max": 10,
          "step": 1,
          "defaultValue": 2,
          "required": true,
          "helperText": "Adjustable shelves inside the cabinet"
        },
        {
          "id": "drawers",
          "name": "drawers",
          "label": "Number of Drawers",
          "type": "slider",
          "min": 0,
          "max": 6,
          "step": 1,
          "defaultValue": 0,
          "required": true
        },
        {
          "id": "hardware",
          "name": "hardware",
          "label": "Hardware Finish",
          "type": "select",
          "required": true,
          "options": [
            { "value": "brushed-nickel", "label": "Brushed Nickel" },
            { "value": "oil-rubbed-bronze", "label": "Oil-Rubbed Bronze" },
            { "value": "chrome", "label": "Chrome" },
            { "value": "brass", "label": "Brass" },
            { "value": "black", "label": "Matte Black" }
          ]
        },
        {
          "id": "additionalFeatures",
          "name": "additionalFeatures",
          "label": "Additional Features",
          "type": "checkbox",
          "required": false,
          "options": [
            { "value": "soft-close", "label": "Soft-Close Hinges" },
            { "value": "lighting", "label": "Interior LED Lighting" },
            { "value": "pull-out-shelves", "label": "Pull-Out Shelves" },
            { "value": "lazy-susan", "label": "Lazy Susan (Corner Cabinets)" }
          ]
        }
      ]
    },
    {
      "id": "project-details",
      "title": "Project Details",
      "fields": [
        {
          "id": "quantity",
          "name": "quantity",
          "label": "Quantity Needed",
          "type": "input",
          "inputType": "number",
          "placeholder": "1",
          "defaultValue": "1",
          "required": true,
          "validation": {
            "min": 1,
            "max": 100,
            "message": "Quantity must be between 1 and 100"
          }
        },
        {
          "id": "installation",
          "name": "installation",
          "label": "Installation Required?",
          "type": "switch",
          "defaultValue": false,
          "required": false,
          "helperText": "Toggle on if you need professional installation"
        },
        {
          "id": "timeline",
          "name": "timeline",
          "label": "Desired Completion Date",
          "type": "date",
          "required": false,
          "helperText": "When do you need this completed?"
        },
        {
          "id": "additionalNotes",
          "name": "additionalNotes",
          "label": "Additional Requirements or Notes",
          "type": "textarea",
          "placeholder": "Any special requirements, matching existing furniture, etc.",
          "rows": 4,
          "required": false
        }
      ]
    }
  ],
  "submitButton": {
    "text": "Generate Cabinet Quote",
    "action": "generate-quote"
  }
}
```

Once you complete the form, I'll generate a detailed quote with pricing and timeline.

### Example 2: Outdoor Signage

**User:** "I need a sign for my business storefront"

**Claude Response:**

I'll help you design and quote an outdoor business sign. Please provide the following details:

```json-form
{
  "formId": "signage-quote-001",
  "itemType": "signage",
  "title": "Business Storefront Sign Specification",
  "description": "Provide details for your custom business sign",
  "sections": [
    {
      "id": "sign-type",
      "title": "Sign Type & Location",
      "fields": [
        {
          "id": "signType",
          "name": "signType",
          "label": "Type of Sign",
          "type": "radio",
          "required": true,
          "options": [
            { "value": "channel-letters", "label": "Channel Letters (Individual 3D Letters)" },
            { "value": "cabinet-sign", "label": "Cabinet Sign (Light Box)" },
            { "value": "monument", "label": "Monument Sign (Ground-Mounted)" },
            { "value": "panel", "label": "Flat Panel Sign" },
            { "value": "pylon", "label": "Pylon Sign (Tall Pole Sign)" }
          ]
        },
        {
          "id": "mounting",
          "name": "mounting",
          "label": "Mounting Location",
          "type": "select",
          "required": true,
          "options": [
            { "value": "wall", "label": "Wall-Mounted" },
            { "value": "ground", "label": "Ground/Monument" },
            { "value": "pole", "label": "Pole-Mounted" },
            { "value": "hanging", "label": "Hanging/Suspended" },
            { "value": "window", "label": "Window Display" }
          ]
        }
      ]
    },
    {
      "id": "dimensions",
      "title": "Sign Dimensions",
      "description": "All measurements in inches",
      "fields": [
        {
          "id": "width",
          "name": "width",
          "label": "Width",
          "type": "input",
          "inputType": "number",
          "placeholder": "96",
          "required": true,
          "validation": {
            "min": 12,
            "max": 480,
            "message": "Width must be between 12 and 480 inches"
          }
        },
        {
          "id": "height",
          "name": "height",
          "label": "Height",
          "type": "input",
          "inputType": "number",
          "placeholder": "24",
          "required": true,
          "validation": {
            "min": 6,
            "max": 240,
            "message": "Height must be between 6 and 240 inches"
          }
        },
        {
          "id": "depth",
          "name": "depth",
          "label": "Depth/Thickness",
          "type": "input",
          "inputType": "number",
          "placeholder": "4",
          "required": false,
          "helperText": "Relevant for 3D signs and channel letters"
        }
      ]
    },
    {
      "id": "materials-lighting",
      "title": "Materials & Lighting",
      "fields": [
        {
          "id": "material",
          "name": "material",
          "label": "Primary Material",
          "type": "select",
          "required": true,
          "options": [
            { "value": "aluminum", "label": "Aluminum" },
            { "value": "acrylic", "label": "Acrylic" },
            { "value": "pvc", "label": "PVC/Foam Board" },
            { "value": "wood", "label": "Wood" },
            { "value": "metal", "label": "Metal (Steel/Stainless)" },
            { "value": "vinyl", "label": "Vinyl Graphics" }
          ]
        },
        {
          "id": "illumination",
          "name": "illumination",
          "label": "Illumination Type",
          "type": "radio",
          "required": true,
          "options": [
            { "value": "led-front", "label": "Front-Lit LED" },
            { "value": "led-back", "label": "Back-Lit (Halo Effect)" },
            { "value": "internal", "label": "Internally Illuminated (Cabinet)" },
            { "value": "external-spot", "label": "External Spotlight" },
            { "value": "none", "label": "No Illumination" }
          ]
        },
        {
          "id": "colorScheme",
          "name": "colorScheme",
          "label": "Color Scheme",
          "type": "textarea",
          "placeholder": "Describe your brand colors or upload a logo reference",
          "rows": 3,
          "required": true
        }
      ]
    },
    {
      "id": "content",
      "title": "Sign Content",
      "fields": [
        {
          "id": "businessName",
          "name": "businessName",
          "label": "Business Name (Text on Sign)",
          "type": "input",
          "inputType": "text",
          "placeholder": "Your Business Name",
          "required": true
        },
        {
          "id": "includeGraphics",
          "name": "includeGraphics",
          "label": "Include Logo or Graphics?",
          "type": "switch",
          "defaultValue": false,
          "required": false
        },
        {
          "id": "additionalText",
          "name": "additionalText",
          "label": "Additional Text (Tagline, Phone, etc.)",
          "type": "textarea",
          "placeholder": "Optional tagline, phone number, website, etc.",
          "rows": 2,
          "required": false
        }
      ]
    },
    {
      "id": "installation",
      "title": "Installation & Permits",
      "fields": [
        {
          "id": "installationIncluded",
          "name": "installationIncluded",
          "label": "Installation Services Needed?",
          "type": "switch",
          "defaultValue": true,
          "required": false
        },
        {
          "id": "permitAssistance",
          "name": "permitAssistance",
          "label": "Need Help with Permits?",
          "type": "switch",
          "defaultValue": false,
          "required": false,
          "helperText": "We can assist with city permits and code compliance"
        },
        {
          "id": "timeline",
          "name": "timeline",
          "label": "Desired Installation Date",
          "type": "date",
          "required": false
        },
        {
          "id": "notes",
          "name": "notes",
          "label": "Additional Notes",
          "type": "textarea",
          "placeholder": "Site conditions, accessibility, special requirements...",
          "rows": 3,
          "required": false
        }
      ]
    }
  ],
  "submitButton": {
    "text": "Generate Sign Quote",
    "action": "generate-quote"
  }
}
```

## Response Guidelines

1. **Always introduce the form** - Tell the user what information you need and why
2. **Use clear field names** - Make labels and descriptions user-friendly
3. **Provide helper text** - Guide users on what to enter
4. **Set appropriate validation** - Prevent invalid data entry
5. **Group related fields** - Use sections to organize the form logically
6. **Make smart defaults** - Pre-fill common values when appropriate
7. **Use conditional fields** - Show/hide fields based on other selections
8. **Keep forms focused** - Only ask for information necessary for the quote/item

## After Form Submission

Once the user submits the form, Claude should:
1. Acknowledge receipt of the information
2. Summarize the key specifications
3. Ask any clarifying questions if needed
4. Generate the markdown documentation with all collected data
5. Provide next steps (quote generation, timeline, etc.)

## Important Notes

- **Always use the `json-form` code block identifier** for the frontend to recognize and render the form
- **Validate that all required fields are marked correctly**
- **Use appropriate field types** for the data being collected (don't use text input for dates, etc.)
- **Consider mobile users** - keep forms scannable and not too long
- **Test conditional logic** - ensure dependent fields reference the correct parent field IDs
- **Provide units** - always specify measurement units (inches, feet, meters, etc.)

## Custom Item Types

If the user requests a quote for an item type not listed above, use your best judgment to:
1. Identify the key dimensions and specifications needed
2. Determine appropriate material options
3. Consider installation/delivery requirements
4. Include quantity and timeline fields
5. Add a notes field for special requirements

Always err on the side of collecting more information rather than less - it's easier to ignore extra data than to follow up for missing information.
