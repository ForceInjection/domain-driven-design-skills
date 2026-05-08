---
name: ag-grid-patterns
description: AG-Grid v34 integration patterns for TMNL. Invoke when implementing data grids, custom cell renderers, themes, or grid-based UI. Provides canonical file locations and pattern precedents.
model_invoked: true
triggers:
  - "AG-Grid"
  - "ag-grid"
  - "data grid"
  - "DataGrid"
  - "TmnlDataGrid"
  - "cell renderer"
  - "column definition"
  - "rowData"
---

# AG-Grid Patterns for TMNL

## Critical: AG-Grid v34 Module Registration

**Without this, grid renders blank. No exceptions.**

```typescript
import { ModuleRegistry, AllCommunityModule } from 'ag-grid-community'
ModuleRegistry.registerModules([AllCommunityModule])
```

No CSS imports needed when using the `theme` prop.

## Canonical Sources

### TMNL Implementations
- **tldraw shape**: `src/components/tldraw/shapes/data-grid-shape.tsx`
- **Theme tokens**: `src/components/tldraw/shapes/data-grid-theme.ts`
- **Base component**: `src/components/data-grid/TmnlDataGrid.tsx`
- **Testbed**: `src/components/testbed/DataGridTestbed.tsx`
- **Architecture doc**: `assets/documents/AG_GRID_THEMING_ARCHITECTURE.md`

### AG-Grid Documentation
- Use `mcp__Ref__ref_search_documentation` with "AG-Grid" queries
- Official docs: https://www.ag-grid.com/react-data-grid/

## TMNL_TOKENS Design System

All grid styling derives from `TMNL_TOKENS` in `data-grid-theme.ts`:

```typescript
export const TMNL_TOKENS = {
  colors: {
    background: '#0a0a0a',
    surface: '#111111',
    surfaceAlt: '#1a1a1a',
    border: '#333333',
    borderSubtle: '#222222',
    text: {
      primary: '#c8e4d8',
      secondary: '#8ba89e',
      muted: '#5a7a6e',
      accent: '#00ffcc',
    },
    status: {
      success: '#00cc88',
      warning: '#ffaa00',
      error: '#ff4444',
      info: '#00aaff',
    },
  },
  typography: {
    fontFamily: "'JetBrains Mono', 'Fira Code', monospace",
    sizes: { xs: 11, sm: 12, base: 13, lg: 14 },
  },
  spacing: { base: 4, scales: [0.5, 1, 2, 3, 4, 6, 8] },
  dimensions: { rowHeight: 32, headerHeight: 36 },
  animation: { duration: { fast: 150, normal: 250 } },
}
```

## Core Patterns

### Pattern 1: Theme Creation via themeQuartz

```typescript
import { themeQuartz } from 'ag-grid-community'
import { TMNL_TOKENS } from './data-grid-theme'

export const tmnlDataGridTheme = themeQuartz.withParams({
  backgroundColor: TMNL_TOKENS.colors.background,
  foregroundColor: TMNL_TOKENS.colors.text.primary,
  borderColor: TMNL_TOKENS.colors.border,
  headerBackgroundColor: TMNL_TOKENS.colors.surface,
  headerTextColor: TMNL_TOKENS.colors.text.secondary,
  oddRowBackgroundColor: TMNL_TOKENS.colors.surface,
  rowHoverColor: TMNL_TOKENS.colors.surfaceAlt,
  selectedRowBackgroundColor: `${TMNL_TOKENS.colors.text.accent}15`,
  fontFamily: TMNL_TOKENS.typography.fontFamily,
  fontSize: TMNL_TOKENS.typography.sizes.base,
  headerFontSize: TMNL_TOKENS.typography.sizes.sm,
  spacing: TMNL_TOKENS.spacing.base,
  rowHeight: TMNL_TOKENS.dimensions.rowHeight,
  headerHeight: TMNL_TOKENS.dimensions.headerHeight,
})
```

**Canonical source**: `src/components/tldraw/shapes/data-grid-theme.ts`

### Pattern 2: Custom Cell Renderers

Cell renderers are React components receiving `ICellRendererParams`.

```typescript
import type { ICellRendererParams } from 'ag-grid-community'

// ID Cell - muted, small tracking
const IdCellRenderer = (params: ICellRendererParams) => (
  <span
    style={{
      color: TMNL_TOKENS.colors.text.muted,
      fontSize: TMNL_TOKENS.typography.sizes.xs,
      fontFamily: TMNL_TOKENS.typography.fontFamily,
      letterSpacing: '0.05em',
    }}
  >
    {params.value}
  </span>
)

// Value Cell - number with progress bar
const ValueCellRenderer = (params: ICellRendererParams) => {
  const value = params.value as number
  const percentage = Math.min(100, Math.max(0, value))
  return (
    <div style={{ position: 'relative', width: '100%', height: '100%' }}>
      <div
        style={{
          position: 'absolute',
          left: 0,
          top: 0,
          height: '100%',
          width: `${percentage}%`,
          backgroundColor: `${TMNL_TOKENS.colors.text.accent}20`,
        }}
      />
      <span style={{ position: 'relative', zIndex: 1 }}>
        {value.toFixed(1)}
      </span>
    </div>
  )
}

// Status Cell - glowing indicator
const StatusCellRenderer = (params: ICellRendererParams) => {
  const status = params.value as string
  const color = STATUS_COLORS[status] ?? TMNL_TOKENS.colors.text.muted
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
      <div
        style={{
          width: 8,
          height: 8,
          borderRadius: '50%',
          backgroundColor: color,
          boxShadow: `0 0 6px ${color}`,
        }}
      />
      <span style={{ color, textTransform: 'uppercase', fontSize: 11 }}>
        {status}
      </span>
    </div>
  )
}
```

**Canonical source**: `src/components/tldraw/shapes/data-grid-shape.tsx`

### Pattern 3: Column Definitions

Type-safe column definitions with cell renderers.

```typescript
import type { ColDef } from 'ag-grid-community'

const columnDefs: ColDef[] = [
  {
    field: 'id',
    headerName: 'ID',
    width: 80,
    cellRenderer: IdCellRenderer,
    sortable: true,
  },
  {
    field: 'name',
    headerName: 'Name',
    flex: 1,
    minWidth: 120,
    filter: true,
  },
  {
    field: 'value',
    headerName: 'Value',
    width: 120,
    cellRenderer: ValueCellRenderer,
    sortable: true,
    comparator: (a, b) => a - b,
  },
  {
    field: 'status',
    headerName: 'Status',
    width: 100,
    cellRenderer: StatusCellRenderer,
  },
]
```

### Pattern 4: tldraw Shape Integration

AG-Grid as a tldraw custom shape.

```typescript
import { BaseBoxShapeUtil, TLBaseShape } from 'tldraw'
import { AgGridReact } from 'ag-grid-react'

type DataGridWidgetShape = TLBaseShape<
  'data-grid-widget',
  {
    w: number
    h: number
    rowData: unknown[]
    columnDefs: ColDef[]
  }
>

export class DataGridWidgetShapeUtil extends BaseBoxShapeUtil<DataGridWidgetShape> {
  static override type = 'data-grid-widget' as const

  override getDefaultProps(): DataGridWidgetShape['props'] {
    return {
      w: 600,
      h: 400,
      rowData: [],
      columnDefs: defaultColumnDefs,
    }
  }

  override component(shape: DataGridWidgetShape) {
    return (
      <HTMLContainer>
        <div style={{ width: shape.props.w, height: shape.props.h }}>
          <AgGridReact
            theme={tmnlDataGridTheme}
            rowData={shape.props.rowData}
            columnDefs={shape.props.columnDefs}
            animateRows={false}
            suppressCellFocus={true}
          />
        </div>
      </HTMLContainer>
    )
  }
}
```

**Canonical source**: `src/components/tldraw/shapes/data-grid-shape.tsx`

### Pattern 5: effect-atom Integration

Grid rowData from atoms (Atom-as-State pattern).

```typescript
import { Atom } from '@effect-rx/rx-react'

// State atoms
const rowDataAtom = Atom.make<RowData[]>([])
const columnDefsAtom = Atom.make<ColDef[]>(defaultColumnDefs)

// Service updates atoms directly
const dataService = {
  loadData: () => Effect.gen(function* () {
    const data = yield* fetchData()
    Atom.set(rowDataAtom, data)
  }),
  addRow: (row: RowData) => Effect.gen(function* () {
    const current = Atom.get(rowDataAtom)
    Atom.set(rowDataAtom, [...current, row])
  }),
}

// React component subscribes
function DataGrid() {
  const rowData = useAtomValue(rowDataAtom)
  const columnDefs = useAtomValue(columnDefsAtom)

  return (
    <AgGridReact
      theme={tmnlDataGridTheme}
      rowData={rowData}
      columnDefs={columnDefs}
    />
  )
}
```

**Canonical source**: `src/components/testbed/DataManagerTestbed.tsx`

### Pattern 6: Dynamic Column Generation

Generate columns from data schema.

```typescript
import { Schema } from 'effect'

const generateColumnDefs = <A extends Schema.Struct.Fields>(
  schema: Schema.Struct<A>
): ColDef[] => {
  return Object.entries(schema.fields).map(([field, fieldSchema]) => ({
    field,
    headerName: field.charAt(0).toUpperCase() + field.slice(1),
    // Infer renderer from schema type
    cellRenderer: inferRenderer(fieldSchema),
  }))
}

const inferRenderer = (schema: Schema.Schema.Any) => {
  // Match on schema type annotations
  if (Schema.is(Schema.Number)(schema)) return ValueCellRenderer
  if (hasTag(schema, 'Status')) return StatusCellRenderer
  return undefined // default text
}
```

### Pattern 7: Grid Performance Optimization

For large datasets in tldraw shapes.

```typescript
<AgGridReact
  theme={tmnlDataGridTheme}
  rowData={rowData}
  columnDefs={columnDefs}
  // Performance settings
  animateRows={false}           // Disable row animation in canvas
  suppressCellFocus={true}      // Prevent focus stealing
  suppressRowClickSelection     // Manual selection control
  rowBuffer={10}                // Virtualization buffer
  // Immutable data optimization
  immutableData={true}
  getRowId={(params) => params.data.id}
/>
```

## Theme Variants

### Compact Theme
```typescript
const tmnlCompactTheme = tmnlDataGridTheme.withParams({
  rowHeight: 24,
  headerHeight: 28,
  fontSize: 11,
})
```

### High Contrast Theme
```typescript
const tmnlHighContrastTheme = tmnlDataGridTheme.withParams({
  foregroundColor: '#ffffff',
  borderColor: '#666666',
  selectedRowBackgroundColor: `${TMNL_TOKENS.colors.text.accent}30`,
})
```

## Filing New Patterns

When you create a new AG-Grid pattern:

1. **Implement in TMNL first** - Working code in `src/components/data-grid/`
2. **Add to theme tokens** - Extend `TMNL_TOKENS` if needed
3. **Update architecture doc** - Add to `assets/documents/AG_GRID_THEMING_ARCHITECTURE.md`
4. **Update this skill** - Add pattern with canonical source
5. **Create bead** - Track with `bd create --type=task --title="Document X grid pattern"`

## Anti-Patterns (BANNED)

### Importing CSS Files
```typescript
// BANNED - No CSS imports with v34
import 'ag-grid-community/styles/ag-grid.css'
import 'ag-grid-community/styles/ag-theme-quartz.css'
// Use theme prop instead
```

### Missing Module Registration
```typescript
// BANNED - Grid will render blank
<AgGridReact rowData={data} columnDefs={cols} />
// Must register modules first
```

### useState for Grid Data
```typescript
// BANNED when data crosses boundaries
const [rowData, setRowData] = useState([])
// Use Atom.make + service methods instead
```

## Related Ecosystem

- **Agent**: `.claude/agents/ag-grid-specialist.md` (TODO)
- **Command**: `.claude/commands/grid.md` (TODO)
- **Hook**: `.claude/hooks/ag-grid-patterns.json` (TODO)
