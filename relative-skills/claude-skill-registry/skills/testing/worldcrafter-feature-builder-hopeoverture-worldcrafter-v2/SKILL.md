---
name: worldcrafter-feature-builder
description: Build complete features with Server Actions, forms, Zod validation, database CRUD operations, and comprehensive tests. Use when user requests "add a feature", "build a [feature]", "create [feature] with forms", or needs end-to-end implementation with validation and testing. Scaffolds pages, actions, schemas, loading/error states, and unit/integration/E2E tests. Supports multi-step wizards, image uploads, markdown editing, custom JSON attributes, and relationship management. Do NOT use for simple static pages (use worldcrafter-route-creator), database-only changes (use worldcrafter-database-setup), testing existing code (use worldcrafter-test-generator), or auth-only additions (use worldcrafter-auth-guard).
---

# WorldCrafter Feature Builder

**Version:** 2.0.0
**Last Updated:** 2025-01-15

This skill provides a systematic approach to implementing new features in the WorldCrafter codebase following established architectural patterns, best practices, and testing standards.

## Skill Metadata

**Related Skills:**
- `worldcrafter-database-setup` - Use first if feature needs new database tables
- `worldcrafter-auth-guard` - Use to add authentication to generated features
- `worldcrafter-test-generator` - Alternative for adding tests to existing features
- `worldcrafter-route-creator` - Alternative for simple pages without forms

**Example Use Cases:**
- "I want to add a blog post feature with authentication" → Creates BlogPost model, form with validation, Server Actions, auth checks, and full test suite
- "Build a user settings page where users can update their profile" → Creates settings route, update form with Zod validation, Server Action, and tests
- "Create a commenting system for posts" → Creates Comment model, comment form, CRUD operations, and E2E tests

## When to Use This Skill

Use this skill when the user wants to:
- Add a new feature to the application
- Build a new form with validation and Server Actions
- Create CRUD operations for a new resource
- Implement authenticated workflows
- Add features that require database operations
- Build features with comprehensive testing (unit + integration + E2E)

## Feature Implementation Process

### Phase 1: Requirements Gathering

1. **Understand the feature requirements**
   - What is the feature's purpose?
   - What user interactions are needed?
   - Does it require authentication?
   - What data needs to be stored/retrieved?
   - What validations are required?

2. **Plan the database changes (if needed)**
   - What new tables or columns are needed?
   - What relationships exist with other tables?
   - What RLS policies should be applied?
   - Reference `references/feature-patterns.md` for database patterns

### Phase 2: Scaffold Feature Structure

Use the `scripts/scaffold_feature.py` script to generate the complete feature structure:

```bash
python .claude/skills/worldcrafter-feature-builder/scripts/scaffold_feature.py <feature-name>
```

This creates:
- `src/app/<feature-name>/page.tsx` - Client component with form
- `src/app/<feature-name>/actions.ts` - Server Actions
- `src/app/<feature-name>/loading.tsx` - Loading state
- `src/app/<feature-name>/error.tsx` - Error boundary
- `src/lib/schemas/<feature-name>.ts` - Zod validation schema
- `src/app/__tests__/<feature-name>.integration.test.ts` - Integration test
- `e2e/<feature-name>.spec.ts` - E2E test

Alternatively, manually copy templates from `assets/templates/` to customize the structure.

### Phase 3: Implement Database Layer (if needed)

1. **Update Prisma schema** (`prisma/schema.prisma`):
   - Add new models with proper field types
   - Define relationships with `@relation`
   - Use snake_case with `@@map` for table names

2. **Create migration**:
   ```bash
   npx prisma migrate dev --name add_<feature_name>
   ```

3. **Apply RLS policies**:
   - Create SQL migration in `prisma/migrations/<timestamp>_add_<feature_name>/`
   - Reference `references/feature-patterns.md` for RLS policy patterns
   - Run `npm run db:rls` to apply policies

4. **Update test database**:
   ```bash
   npm run db:test:sync
   ```

### Phase 4: Implement Validation Layer

1. **Create Zod schema** in `src/lib/schemas/<feature-name>.ts`:
   - Define validation rules for all form fields
   - Export TypeScript type: `export type FeatureFormValues = z.infer<typeof featureSchema>`
   - Reference `assets/templates/schema.ts` for examples

2. **Common validation patterns**:
   - Email: `z.string().email()`
   - Required string: `z.string().min(1, "Field is required")`
   - Optional: `z.string().optional()`
   - Enum: `z.enum(["option1", "option2"])`
   - Number: `z.number().min(0).max(100)`
   - Date: `z.date()` or `z.string().datetime()`

### Phase 5: Implement Server Actions

1. **Create Server Actions** in `src/app/<feature-name>/actions.ts`:
   - Mark file with `"use server"` directive
   - Import Zod schema for validation
   - Import Prisma client and Supabase server client
   - Reference `assets/templates/actions.ts` for the standard pattern

2. **Server Action pattern**:
   ```typescript
   "use server"

   import { revalidatePath } from "next/cache"
   import { prisma } from "@/lib/prisma"
   import { createClient } from "@/lib/supabase/server"
   import { featureSchema, type FeatureFormValues } from "@/lib/schemas/feature"

   export async function submitFeature(values: FeatureFormValues) {
     try {
       // 1. Validate
       const validated = featureSchema.parse(values)

       // 2. Authenticate (if needed)
       const supabase = await createClient()
       const { data: { user } } = await supabase.auth.getUser()
       if (!user) return { success: false, error: "Unauthorized" }

       // 3. Database operation
       const result = await prisma.feature.create({
         data: { ...validated, user_id: user.id }
       })

       // 4. Revalidate
       revalidatePath("/feature")

       // 5. Return
       return { success: true, data: result }
     } catch (error) {
       return { success: false, error: "Operation failed" }
     }
   }
   ```

3. **Security checklist**:
   - Always validate input with Zod schema
   - Check authentication for protected operations
   - Verify user owns resource before update/delete
   - Use parameterized queries (Prisma handles this)
   - Never expose sensitive data in responses

### Phase 6: Implement Client Components

1. **Create form component** in `src/app/<feature-name>/page.tsx`:
   - Use React Hook Form with `zodResolver`
   - Import shadcn/ui components from `@/components/ui`
   - Call Server Action on submit
   - Handle loading and error states
   - Reference `assets/templates/page.tsx` for examples

2. **Form handling pattern**:
   ```typescript
   "use client"

   import { useForm } from "react-hook-form"
   import { zodResolver } from "@hookform/resolvers/zod"
   import { featureSchema, type FeatureFormValues } from "@/lib/schemas/feature"
   import { submitFeature } from "./actions"

   export default function FeaturePage() {
     const form = useForm<FeatureFormValues>({
       resolver: zodResolver(featureSchema),
       defaultValues: { /* ... */ }
     })

     async function onSubmit(values: FeatureFormValues) {
       const result = await submitFeature(values)
       if (result.success) {
         // Handle success
       } else {
         // Handle error
       }
     }

     return <form onSubmit={form.handleSubmit(onSubmit)}>...</form>
   }
   ```

3. **Add shadcn/ui components** if needed:
   ```bash
   npx shadcn@latest add [component-name]
   ```

### Phase 7: Implement Loading and Error States

1. **Create loading state** (`loading.tsx`):
   - Use skeleton loaders matching the page layout
   - Reference `assets/templates/loading.tsx`

2. **Create error boundary** (`error.tsx`):
   - Must be a client component (`"use client"`)
   - Include reset functionality
   - Reference `assets/templates/error.tsx`

### Phase 8: Write Tests

Reference `references/testing-guide.md` for detailed testing patterns.

1. **Integration test** (`src/app/__tests__/<feature-name>.integration.test.ts`):
   - Test Server Actions with real test database
   - Use test data factories from `src/test/factories/`
   - Clean up data in `afterAll` hooks
   - Reference `assets/templates/integration.test.ts`

2. **E2E test** (`e2e/<feature-name>.spec.ts`):
   - Test complete user flows
   - Use Page Object Model pattern
   - Test across different browsers/viewports
   - Reference `assets/templates/e2e.spec.ts`

3. **Run tests**:
   ```bash
   npm test                  # Unit tests
   npm run test:coverage     # With coverage
   npm run test:e2e          # E2E tests
   npm run test:all          # All tests
   ```

### Phase 9: Final Checks

1. **Type checking**:
   ```bash
   npm run build
   ```

2. **Linting and formatting**:
   ```bash
   npm run lint
   npm run format
   ```

3. **Test database sync** (if schema changed):
   ```bash
   npm run db:test:sync
   ```

4. **Verify tests pass**:
   ```bash
   npm run test:all
   ```

## Common Patterns

### Authentication-Required Features

For features requiring authentication:

1. Check auth in Server Action:
   ```typescript
   const supabase = await createClient()
   const { data: { user } } = await supabase.auth.getUser()
   if (!user) return { success: false, error: "Unauthorized" }
   ```

2. Optionally protect the route in middleware or layout

### Data Fetching Patterns

**In Server Components** (preferred):
- Fetch data directly with Prisma or Supabase
- No API route needed

**In Client Components**:
- Use TanStack Query (`useQuery`, `useMutation`)
- Call Server Actions or API routes

### Form with Multiple Steps

1. Use state management (useState) for current step
2. Validate each step independently
3. Combine all data in final submission
4. Show progress indicator

## Advanced Entity Features (v2.0)

WorldCrafter applications often need sophisticated entity creation and management workflows for worldbuilding. This section covers advanced patterns for character creators, location builders, item editors, and other complex entity forms.

### Multi-Step Form Wizard Pattern

For complex entity creation (e.g., character creator with Basics → Appearance → Personality → Backstory → Custom Attributes):

**State Management:**
```typescript
"use client"

import { useState } from "react"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"

type WizardStep = "basics" | "appearance" | "personality" | "backstory" | "attributes"

export default function CharacterWizard() {
  const [currentStep, setCurrentStep] = useState<WizardStep>("basics")
  const [formData, setFormData] = useState({})

  const form = useForm({
    resolver: zodResolver(stepSchemas[currentStep]),
    defaultValues: formData,
  })

  const steps: WizardStep[] = ["basics", "appearance", "personality", "backstory", "attributes"]
  const currentIndex = steps.indexOf(currentStep)
  const progress = ((currentIndex + 1) / steps.length) * 100

  async function handleNext(values: any) {
    // Merge values into accumulated form data
    setFormData(prev => ({ ...prev, ...values }))

    if (currentIndex < steps.length - 1) {
      setCurrentStep(steps[currentIndex + 1])
      form.reset() // Reset for next step
    } else {
      // Final step - submit all data
      const result = await submitCharacter({ ...formData, ...values })
      if (result.success) {
        // Handle success
      }
    }
  }

  function handleBack() {
    if (currentIndex > 0) {
      setCurrentStep(steps[currentIndex - 1])
    }
  }

  return (
    <div>
      {/* Progress indicator */}
      <div className="mb-8">
        <div className="flex justify-between mb-2">
          {steps.map((step, i) => (
            <div
              key={step}
              className={i <= currentIndex ? "text-primary" : "text-muted-foreground"}
            >
              {step}
            </div>
          ))}
        </div>
        <div className="h-2 bg-secondary rounded-full">
          <div
            className="h-full bg-primary rounded-full transition-all"
            style={{ width: `${progress}%` }}
          />
        </div>
      </div>

      {/* Step content */}
      <form onSubmit={form.handleSubmit(handleNext)}>
        {currentStep === "basics" && <BasicsStep form={form} />}
        {currentStep === "appearance" && <AppearanceStep form={form} />}
        {/* ... other steps ... */}

        <div className="flex justify-between mt-6">
          <Button
            type="button"
            variant="outline"
            onClick={handleBack}
            disabled={currentIndex === 0}
          >
            Back
          </Button>
          <Button type="submit">
            {currentIndex === steps.length - 1 ? "Save Character" : "Next"}
          </Button>
        </div>
      </form>
    </div>
  )
}
```

**Key Implementation Details:**
- Each step has its own Zod schema for incremental validation
- Form data accumulates in state across steps
- Progress bar shows completion percentage
- Navigation buttons enable Back/Next/Save
- Form resets between steps but preserves accumulated data
- Final step triggers Server Action with all combined data

**See template:** `assets/templates/multi-step-wizard.tsx`

### Image Upload with Supabase Storage

For entity images (character portraits, location maps, item icons):

**Component Pattern:**
```typescript
"use client"

import { useState } from "react"
import { createClient } from "@/lib/supabase/client"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import Image from "next/image"

export function ImageUpload({
  value,
  onChange,
  bucket = "entity-images",
  folder = "characters"
}: {
  value?: string
  onChange: (url: string) => void
  bucket?: string
  folder?: string
}) {
  const [uploading, setUploading] = useState(false)
  const [preview, setPreview] = useState<string | null>(value || null)

  async function handleImageUpload(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0]
    if (!file) return

    setUploading(true)
    try {
      const supabase = createClient()

      // Generate unique filename
      const fileExt = file.name.split('.').pop()
      const fileName = `${folder}/${Date.now()}-${Math.random().toString(36).substring(7)}.${fileExt}`

      // Upload to Supabase Storage
      const { data, error } = await supabase.storage
        .from(bucket)
        .upload(fileName, file, {
          cacheControl: '3600',
          upsert: false
        })

      if (error) throw error

      // Get public URL
      const { data: { publicUrl } } = supabase.storage
        .from(bucket)
        .getPublicUrl(fileName)

      setPreview(publicUrl)
      onChange(publicUrl) // Update form field
    } catch (error) {
      console.error('Upload error:', error)
      alert('Failed to upload image')
    } finally {
      setUploading(false)
    }
  }

  return (
    <div className="space-y-4">
      <Label htmlFor="image-upload">Image</Label>

      {preview && (
        <div className="relative w-48 h-48 border rounded-lg overflow-hidden">
          <Image
            src={preview}
            alt="Preview"
            fill
            className="object-cover"
          />
        </div>
      )}

      <Input
        id="image-upload"
        type="file"
        accept="image/*"
        onChange={handleImageUpload}
        disabled={uploading}
      />

      {uploading && <p className="text-sm text-muted-foreground">Uploading...</p>}
    </div>
  )
}
```

**Integration with Form:**
```typescript
<FormField
  control={form.control}
  name="imageUrl"
  render={({ field }) => (
    <FormItem>
      <ImageUpload
        value={field.value}
        onChange={field.onChange}
        folder="characters"
      />
      <FormMessage />
    </FormItem>
  )}
/>
```

**Schema:**
```typescript
export const characterSchema = z.object({
  name: z.string().min(1),
  imageUrl: z.string().url().optional(),
  // ... other fields
})
```

**Storage Setup:**
1. Create bucket in Supabase Dashboard: Storage → New Bucket → "entity-images"
2. Set bucket to public or configure RLS policies
3. Configure CORS if needed for direct uploads

**See template:** `assets/templates/image-upload.tsx`

### Custom JSON Attributes Pattern

For genre-specific or dynamic fields stored in a JSON column (e.g., Fantasy characters have "Mana Points", Sci-Fi characters have "Tech Level"):

**Database Schema:**
```prisma
model Character {
  id         String   @id @default(uuid())
  name       String
  worldId    String
  world      World    @relation(fields: [worldId], references: [id])
  attributes Json?    // Custom fields based on world genre

  @@map("characters")
}

model World {
  id     String @id @default(uuid())
  name   String
  genre  String // "fantasy", "scifi", "modern", etc.

  @@map("worlds")
}
```

**Zod Schema:**
```typescript
export const characterSchema = z.object({
  name: z.string().min(1),
  worldId: z.string().uuid(),
  // Flexible attributes - validated at runtime based on genre
  attributes: z.record(z.any()).optional(),
})

// Genre-specific schemas
export const fantasyAttributesSchema = z.object({
  manaPoints: z.number().min(0).max(100),
  magicSchool: z.enum(["fire", "water", "earth", "air"]),
  spellSlots: z.number().min(0),
})

export const scifiAttributesSchema = z.object({
  techLevel: z.number().min(1).max(10),
  cybernetics: z.array(z.string()),
  faction: z.string(),
})
```

**Dynamic Form Component:**
```typescript
"use client"

import { useEffect, useState } from "react"
import { useForm } from "react-hook-form"

export default function CharacterForm({ worldId }: { worldId: string }) {
  const [world, setWorld] = useState<any>(null)
  const form = useForm()

  useEffect(() => {
    // Fetch world to get genre
    fetch(`/api/worlds/${worldId}`)
      .then(res => res.json())
      .then(data => setWorld(data))
  }, [worldId])

  function renderAttributeFields() {
    if (!world) return null

    switch (world.genre) {
      case "fantasy":
        return (
          <>
            <FormField
              control={form.control}
              name="attributes.manaPoints"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Mana Points</FormLabel>
                  <FormControl>
                    <Input type="number" {...field} />
                  </FormControl>
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="attributes.magicSchool"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Magic School</FormLabel>
                  <Select onValueChange={field.onChange} defaultValue={field.value}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="fire">Fire</SelectItem>
                      <SelectItem value="water">Water</SelectItem>
                      <SelectItem value="earth">Earth</SelectItem>
                      <SelectItem value="air">Air</SelectItem>
                    </SelectContent>
                  </Select>
                </FormItem>
              )}
            />
          </>
        )

      case "scifi":
        return (
          <>
            <FormField
              control={form.control}
              name="attributes.techLevel"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Tech Level (1-10)</FormLabel>
                  <FormControl>
                    <Input type="number" min="1" max="10" {...field} />
                  </FormControl>
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="attributes.faction"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Faction</FormLabel>
                  <FormControl>
                    <Input {...field} />
                  </FormControl>
                </FormItem>
              )}
            />
          </>
        )

      default:
        return null
    }
  }

  return (
    <form>
      {/* Standard fields */}
      <FormField name="name" ... />

      {/* Dynamic genre-specific fields */}
      {renderAttributeFields()}
    </form>
  )
}
```

**Server Action Validation:**
```typescript
export async function createCharacter(values: any) {
  // Validate base schema
  const validated = characterSchema.parse(values)

  // Fetch world to validate attributes
  const world = await prisma.world.findUnique({ where: { id: validated.worldId } })
  if (!world) throw new Error("World not found")

  // Validate genre-specific attributes
  if (world.genre === "fantasy" && validated.attributes) {
    fantasyAttributesSchema.parse(validated.attributes)
  } else if (world.genre === "scifi" && validated.attributes) {
    scifiAttributesSchema.parse(validated.attributes)
  }

  // Create character
  const character = await prisma.character.create({ data: validated })
  return { success: true, data: character }
}
```

**See template:** `assets/templates/custom-attributes.tsx`

### Markdown Editor Integration

For long-form text fields (backstories, descriptions, lore):

**Installation:**
```bash
npm install @uiw/react-md-editor
```

**Component:**
```typescript
"use client"

import dynamic from "next/dynamic"
import { useState } from "react"
import "@uiw/react-md-editor/markdown-editor.css"
import "@uiw/react-markdown-preview/markdown.css"

// Import dynamically to avoid SSR issues
const MDEditor = dynamic(
  () => import("@uiw/react-md-editor"),
  { ssr: false }
)

export function MarkdownField({
  value,
  onChange,
  label,
  height = 300,
}: {
  value?: string
  onChange: (value: string) => void
  label: string
  height?: number
}) {
  return (
    <div className="space-y-2">
      <label className="text-sm font-medium">{label}</label>
      <MDEditor
        value={value}
        onChange={(val) => onChange(val || "")}
        height={height}
        preview="edit" // "edit" | "live" | "preview"
      />
    </div>
  )
}
```

**Integration with React Hook Form:**
```typescript
<FormField
  control={form.control}
  name="backstory"
  render={({ field }) => (
    <FormItem>
      <MarkdownField
        value={field.value}
        onChange={field.onChange}
        label="Backstory"
        height={400}
      />
      <FormDescription>
        Use Markdown formatting for rich text
      </FormDescription>
      <FormMessage />
    </FormItem>
  )}
/>
```

**Schema:**
```typescript
export const characterSchema = z.object({
  name: z.string().min(1),
  backstory: z.string().optional(),
  // Markdown is stored as plain text in database
})
```

**Display Markdown:**
```typescript
import ReactMarkdown from "react-markdown"

export function CharacterDetail({ character }) {
  return (
    <div>
      <h1>{character.name}</h1>
      <div className="prose dark:prose-invert">
        <ReactMarkdown>{character.backstory}</ReactMarkdown>
      </div>
    </div>
  )
}
```

**See template:** `assets/templates/markdown-editor.tsx`

### Relationship Management

For managing connections between entities (character-to-character relationships, location hierarchies):

**Database Schema (from worldcrafter-database-setup):**
```prisma
model CharacterRelationship {
  id             String   @id @default(uuid())
  fromCharacterId String
  toCharacterId   String
  relationshipType String  // "friend", "enemy", "family", "ally", etc.
  description    String?

  fromCharacter  Character @relation("RelationshipsFrom", fields: [fromCharacterId], references: [id], onDelete: Cascade)
  toCharacter    Character @relation("RelationshipsTo", fields: [toCharacterId], references: [id], onDelete: Cascade)

  @@map("character_relationships")
}

model Character {
  id         String   @id @default(uuid())
  name       String

  relationshipsFrom CharacterRelationship[] @relation("RelationshipsFrom")
  relationshipsTo   CharacterRelationship[] @relation("RelationshipsTo")

  @@map("characters")
}
```

**Relationships Panel Component:**
```typescript
"use client"

import { useState } from "react"
import { Plus, X } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Select } from "@/components/ui/select"
import { addRelationship, removeRelationship } from "./actions"

export function RelationshipsPanel({
  characterId,
  relationships
}: {
  characterId: string
  relationships: any[]
}) {
  const [isAddingRelationship, setIsAddingRelationship] = useState(false)

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold">Relationships</h3>
        <Button
          size="sm"
          onClick={() => setIsAddingRelationship(true)}
        >
          <Plus className="w-4 h-4 mr-1" />
          Add Relationship
        </Button>
      </div>

      {/* List existing relationships */}
      <div className="space-y-2">
        {relationships.map((rel) => (
          <div
            key={rel.id}
            className="flex items-center justify-between p-3 border rounded-lg"
          >
            <div>
              <p className="font-medium">{rel.toCharacter.name}</p>
              <p className="text-sm text-muted-foreground">
                {rel.relationshipType}
              </p>
              {rel.description && (
                <p className="text-sm mt-1">{rel.description}</p>
              )}
            </div>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => removeRelationship(rel.id)}
            >
              <X className="w-4 h-4" />
            </Button>
          </div>
        ))}

        {relationships.length === 0 && (
          <p className="text-muted-foreground text-sm">
            No relationships yet
          </p>
        )}
      </div>

      {/* Add relationship modal */}
      <AddRelationshipModal
        open={isAddingRelationship}
        onClose={() => setIsAddingRelationship(false)}
        characterId={characterId}
      />
    </div>
  )
}
```

**Add Relationship Modal:**
```typescript
function AddRelationshipModal({
  open,
  onClose,
  characterId
}: {
  open: boolean
  onClose: () => void
  characterId: string
}) {
  const form = useForm({
    resolver: zodResolver(relationshipSchema),
    defaultValues: {
      fromCharacterId: characterId,
      toCharacterId: "",
      relationshipType: "",
      description: "",
    }
  })

  async function onSubmit(values: any) {
    const result = await addRelationship(values)
    if (result.success) {
      onClose()
      form.reset()
    }
  }

  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Add Relationship</DialogTitle>
        </DialogHeader>

        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
          <FormField
            control={form.control}
            name="toCharacterId"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Character</FormLabel>
                <CharacterSelect
                  value={field.value}
                  onChange={field.onChange}
                  excludeId={characterId}
                />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="relationshipType"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Relationship Type</FormLabel>
                <Select onValueChange={field.onChange}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="friend">Friend</SelectItem>
                    <SelectItem value="enemy">Enemy</SelectItem>
                    <SelectItem value="family">Family</SelectItem>
                    <SelectItem value="ally">Ally</SelectItem>
                    <SelectItem value="rival">Rival</SelectItem>
                  </SelectContent>
                </Select>
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="description"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Description (Optional)</FormLabel>
                <Textarea {...field} />
              </FormItem>
            )}
          />

          <div className="flex justify-end gap-2">
            <Button type="button" variant="outline" onClick={onClose}>
              Cancel
            </Button>
            <Button type="submit">Add Relationship</Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  )
}
```

**Server Actions:**
```typescript
"use server"

export async function addRelationship(values: any) {
  const validated = relationshipSchema.parse(values)

  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return { success: false, error: "Unauthorized" }

  // Verify user owns the character
  const character = await prisma.character.findUnique({
    where: { id: validated.fromCharacterId },
    select: { userId: true }
  })

  if (!character || character.userId !== user.id) {
    return { success: false, error: "Forbidden" }
  }

  const relationship = await prisma.characterRelationship.create({
    data: validated
  })

  revalidatePath(`/characters/${validated.fromCharacterId}`)
  return { success: true, data: relationship }
}

export async function removeRelationship(id: string) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return { success: false, error: "Unauthorized" }

  // Verify ownership
  const relationship = await prisma.characterRelationship.findUnique({
    where: { id },
    include: { fromCharacter: { select: { userId: true } } }
  })

  if (!relationship || relationship.fromCharacter.userId !== user.id) {
    return { success: false, error: "Forbidden" }
  }

  await prisma.characterRelationship.delete({ where: { id } })

  revalidatePath(`/characters/${relationship.fromCharacterId}`)
  return { success: true }
}
```

**See template:** `assets/templates/relationships-panel.tsx`

## Reference Files

- `references/feature-patterns.md` - Detailed architectural patterns
- `references/testing-guide.md` - Testing conventions and examples
- `references/advanced-features-guide.md` - **NEW v2.0**: Multi-step wizards, image uploads, custom attributes, markdown, relationships
- `references/related-skills.md` - How this skill works with other WorldCrafter skills
- `assets/templates/` - Complete template files for quick scaffolding
  - `multi-step-wizard.tsx` - **NEW v2.0**: Character creation wizard example
  - `image-upload.tsx` - **NEW v2.0**: Supabase Storage image upload component
  - `custom-attributes.tsx` - **NEW v2.0**: Dynamic genre-specific attributes form
  - `markdown-editor.tsx` - **NEW v2.0**: Rich text editing with @uiw/react-md-editor
  - `relationships-panel.tsx` - **NEW v2.0**: Entity relationship management UI

## Skill Orchestration

This skill works seamlessly with other WorldCrafter skills to provide complete feature implementation.

### Common Workflows

**Complete Feature with Authentication:**
1. **worldcrafter-database-setup** - Create database tables and RLS policies first
2. **worldcrafter-feature-builder** (this skill) - Build feature UI, forms, and Server Actions
3. **worldcrafter-auth-guard** - Add authentication checks to routes and actions
4. **worldcrafter-test-generator** - Add additional test coverage if needed (basic tests included)

**Quick Feature (No Database):**
1. **worldcrafter-feature-builder** (this skill) - Creates feature with form and validation
2. **worldcrafter-auth-guard** - Protect feature if needed

**Database-First Approach:**
1. **worldcrafter-database-setup** - Design and create database schema
2. **worldcrafter-feature-builder** (this skill) - Build UI and forms for the data model

### When Claude Should Use Multiple Skills

Claude will naturally orchestrate multiple skills when:
- User request spans multiple capabilities (e.g., "add blog with auth and database")
- One skill creates prerequisites for another (database before UI)
- Task requires complementary expertise (feature + security)

**Example orchestration:**
```
User: "Add a comments feature for blog posts with user authentication"

Claude's workflow:
1. worldcrafter-database-setup: Create Comment model with RLS policies
2. worldcrafter-feature-builder: Create comment form, Server Actions, UI
3. worldcrafter-auth-guard: Add auth checks to ensure only logged-in users can comment
4. Tests are automatically included by feature-builder
```

### Skill Selection Guidance

**Choose this skill when:**
- Building a complete feature from scratch
- Need forms, validation, Server Actions, and tests together
- User wants end-to-end implementation

**Choose worldcrafter-route-creator when:**
- User only needs a simple page without forms
- Static content or read-only pages
- No validation or Server Actions needed

**Choose worldcrafter-database-setup when:**
- User only wants to modify database schema
- Adding tables without immediate UI
- Setting up data models for later

## Success Criteria

A complete feature implementation includes:
- ✅ Database schema with RLS policies (if applicable)
- ✅ Zod validation schema
- ✅ Server Actions with proper error handling
- ✅ Client components with forms and UI
- ✅ Loading and error states
- ✅ Integration tests with test database
- ✅ E2E tests for critical user flows
- ✅ Type checking passes (`npm run build`)
- ✅ All tests pass (`npm run test:all`)
