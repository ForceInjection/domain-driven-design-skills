---
name: triangle
description: Create triangle geometry figures with vertices, angles, special lines, and labels. Use when rendering triangles in mini-lessons or geometry questions.
---

# Triangle Figure Skill

This skill guides you through creating triangle visualizations using the `TriangleFigure` component.

## When to Use This Skill

Invoke this skill when:
- Creating geometry mini-lessons involving triangles
- Rendering triangles in practice questions
- Visualizing triangle properties (angles, special lines)
- Building interactive triangle explorations
- Demonstrating teorema de Pitágoras, área de triángulos, etc.

## Quick Start

### Forma más simple: Usando ángulos

```tsx
import { TriangleFigure } from '@/components/figures/TriangleFigure';

// Triángulo equilátero (60-60-60)
<TriangleFigure fromAngles={[60, 60, 60]} />

// Triángulo 30-60-90
<TriangleFigure fromAngles={[30, 60, 90]} showRightAngleMarker />

// Triángulo isósceles (45-45-90)
<TriangleFigure fromAngles={[45, 45, 90]} showGrid />
```

### Con tamaño personalizado

```tsx
// Triángulo más grande
<TriangleFigure
  fromAngles={{ angles: [30, 60, 90], size: 200 }}
  showGrid
/>
```

### Usando longitudes de lados

```tsx
// Triángulo 3-4-5 (rectángulo pitagórico)
<TriangleFigure fromSides={[3, 4, 5]} showRightAngleMarker />

// Triángulo equilátero (lados iguales)
<TriangleFigure fromSides={[5, 5, 5]} />

// Con tamaño personalizado
<TriangleFigure
  fromSides={{ sides: [5, 12, 13], size: 200 }}
  showRightAngleMarker
/>
```

### Triángulo rectángulo con labels

```tsx
<TriangleFigure
  fromAngles={[30, 60, 90]}
  showRightAngleMarker
  sides={[
    { label: 'c' },  // hipotenusa
    { label: 'a' },  // cateto opuesto
    { label: 'b' },  // cateto adyacente
  ]}
/>
```

### Con arcos de ángulos

```tsx
<TriangleFigure
  fromAngles={[60, 60, 60]}
  angles={[
    { showArc: true, showDegrees: true },
    { showArc: true, showDegrees: true },
    { showArc: true, showDegrees: true },
  ]}
/>
```

### Con altura (línea especial)

```tsx
<TriangleFigure
  fromAngles={[50, 60, 70]}
  specialLines={[
    {
      type: 'altura',
      fromVertex: 0,
      strokeStyle: 'dashed',
      showLabel: true,
      showRightAngleMarker: true,
    },
  ]}
/>
```

### Usando vértices (control total)

Cuando necesitas control preciso sobre las coordenadas:

```tsx
<TriangleFigure
  vertices={[
    { x: 200, y: 50, label: 'A' },
    { x: 100, y: 220, label: 'B' },
    { x: 300, y: 220, label: 'C' },
  ]}
  showGrid
/>
```

---

## Props Reference

### Construcción del triángulo (usar UNO de estos)

| Prop | Type | Description |
|------|------|-------------|
| `fromAngles` | `[number, number, number]` o `{ angles, size?, rotation? }` | **Recomendado.** Construir desde ángulos |
| `fromSides` | `[number, number, number]` o `{ sides, size?, rotation? }` | Construir desde longitudes de lados |
| `vertices` | `[LabeledPoint, LabeledPoint, LabeledPoint]` | Control total de coordenadas |

### fromAngles

```typescript
// Forma simple: array de 3 ángulos (deben sumar 180°)
fromAngles={[60, 60, 60]}

// Forma con opciones
fromAngles={{
  angles: [30, 60, 90],  // Los 3 ángulos interiores
  size: 200,             // Tamaño máximo (default: 150)
  rotation: 0,           // Rotación en grados (default: 0)
}}
```

### fromSides

```typescript
// Forma simple: array de 3 lados (deben cumplir desigualdad triangular)
fromSides={[3, 4, 5]}

// Forma con opciones
fromSides={{
  sides: [5, 12, 13],    // Las 3 longitudes de lados
  size: 200,             // Tamaño máximo (default: 150)
  rotation: 0,           // Rotación en grados (default: 0)
}}
```

> **Nota:** Los lados deben cumplir la desigualdad triangular: la suma de dos lados siempre debe ser mayor que el tercero.

### LabeledPoint

```typescript
interface LabeledPoint {
  x: number;          // Coordenada X
  y: number;          // Coordenada Y
  label?: string;     // Etiqueta del vértice (ej: 'A', 'B', 'C')
  labelOffset?: { x: number; y: number };  // Ajuste de posición del label
}
```

### Side Configuration

```typescript
interface SideConfig {
  label?: string;           // Etiqueta del lado (ej: 'a', 'b', 'c')
  measurement?: string;     // Medida con unidades (ej: '5 cm')
  color?: string;           // Color personalizado
  strokeStyle?: 'solid' | 'dashed' | 'dotted';
  showMeasurement?: boolean;
}
```

### Angle Configuration

```typescript
interface AngleConfig {
  label?: string;        // Etiqueta (grados o letra griega)
  showArc?: boolean;     // Mostrar arco del ángulo
  arcRadius?: number;    // Radio del arco (default: 25)
  color?: string;        // Color personalizado
  isExterior?: boolean;  // Si es ángulo exterior
  showDegrees?: boolean; // Mostrar valor en grados
}
```

### Special Lines

```typescript
interface SpecialLineConfig {
  type: 'altura' | 'mediana' | 'bisectriz' | 'mediatriz';
  fromVertex: 0 | 1 | 2;           // Vértice de origen
  color?: string;
  strokeStyle?: 'solid' | 'dashed' | 'dotted';
  showLabel?: boolean;             // Mostrar nombre de la línea
  showRightAngleMarker?: boolean;  // Marcador de ángulo recto
}
```

### Visual Options

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `fill` | `string` | `'rgba(59,130,246,0.15)'` | Color de relleno |
| `fillOpacity` | `number` | - | Opacidad del relleno |
| `stroke` | `string` | `'rgb(59,130,246)'` | Color del borde |
| `strokeWidth` | `number` | `2` | Ancho del borde |
| `showGrid` | `boolean` | `false` | Mostrar cuadrícula |
| `gridSize` | `number` | `20` | Tamaño de celda de la cuadrícula |
| `showVertices` | `boolean` | `true` | Mostrar puntos en los vértices |
| `vertexRadius` | `number` | `4` | Radio de los puntos de vértice |
| `showRightAngleMarker` | `boolean` | `false` | Mostrar marcador de ángulo recto |
| `rightAngleVertex` | `0 \| 1 \| 2` | auto | Vértice con ángulo recto |
| `rightAngleSize` | `number` | `12` | Tamaño del marcador |

### SVG Options

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `width` | `number` | auto | Ancho del SVG |
| `height` | `number` | auto | Alto del SVG |
| `viewBox` | `string` | auto | ViewBox personalizado |
| `padding` | `number` | `40` | Padding alrededor del triángulo |
| `className` | `string` | - | Clases CSS adicionales |

---

## Common Patterns

### Teorema de Pitágoras

```tsx
<TriangleFigure
  vertices={[
    { x: 50, y: 50, label: 'A' },
    { x: 50, y: 200, label: 'B' },
    { x: 200, y: 200, label: 'C' },
  ]}
  sides={[
    { label: 'c', measurement: '5 cm' },  // hipotenusa
    { label: 'a', measurement: '3 cm' },  // cateto opuesto
    { label: 'b', measurement: '4 cm' },  // cateto adyacente
  ]}
  showRightAngleMarker
  rightAngleVertex={1}
  showGrid
/>
```

### Suma de Ángulos Interiores

```tsx
<TriangleFigure
  vertices={[
    { x: 200, y: 50, label: 'A' },
    { x: 100, y: 220, label: 'B' },
    { x: 300, y: 220, label: 'C' },
  ]}
  angles={[
    { showArc: true, label: 'α' },
    { showArc: true, label: 'β' },
    { showArc: true, label: 'γ' },
  ]}
/>
// Los ángulos se calculan automáticamente: α + β + γ = 180°
```

### Altura y Área

```tsx
<TriangleFigure
  vertices={[
    { x: 200, y: 40, label: 'A' },
    { x: 80, y: 220, label: 'B' },
    { x: 320, y: 220, label: 'C' },
  ]}
  sides={[
    {},
    {},
    { label: 'base' },
  ]}
  specialLines={[
    {
      type: 'altura',
      fromVertex: 0,
      strokeStyle: 'dashed',
      showLabel: true,
      showRightAngleMarker: true,
    },
  ]}
/>
```

### Medianas y Centroide

```tsx
<TriangleFigure
  vertices={[
    { x: 200, y: 50, label: 'A' },
    { x: 100, y: 220, label: 'B' },
    { x: 300, y: 220, label: 'C' },
  ]}
  specialLines={[
    { type: 'mediana', fromVertex: 0, strokeStyle: 'dashed' },
    { type: 'mediana', fromVertex: 1, strokeStyle: 'dashed' },
    { type: 'mediana', fromVertex: 2, strokeStyle: 'dashed' },
  ]}
/>
```

---

## Color Palette

| Elemento | Light Mode | Dark Mode |
|----------|-----------|-----------|
| Triangle fill | `fill-blue-200` | `fill-blue-800/50` |
| Triangle stroke | `stroke-blue-600` | `stroke-blue-400` |
| Angle arc | `stroke-amber-500` | `stroke-amber-400` |
| Special lines | `stroke-purple-500` | `stroke-purple-400` |
| Right angle marker | `stroke-red-500` | `stroke-red-400` |
| Grid | `stroke-gray-200` | `stroke-gray-700` |

---

## Debug Page

Para experimentar interactivamente con todas las opciones:

**URL:** `/admin/figure-debug`

La página de debug permite:
- **Modo Vértices:** Ajustar posición de vértices con sliders
- **Modo Ángulos:** Construir triángulo especificando los 3 ángulos interiores
- Seleccionar presets (equilátero, rectángulo, isósceles, escaleno, 30-60-90, 45-45-90)
- Activar/desactivar opciones visuales
- Agregar líneas especiales (altura, mediana, bisectriz)
- Copiar el código generado

---

## Integration with Mini-Lessons

### In Step Components

```tsx
// En Step2Explore.tsx
import { TriangleFigure } from '@/components/figures/TriangleFigure';

export default function Step2Explore({ isActive }: LessonStepProps) {
  const [showAltura, setShowAltura] = useState(false);

  return (
    <div className="flex flex-col items-center">
      <TriangleFigure
        vertices={[...]}
        specialLines={showAltura ? [{ type: 'altura', fromVertex: 0 }] : []}
      />
      <button onClick={() => setShowAltura(!showAltura)}>
        {showAltura ? 'Ocultar' : 'Mostrar'} altura
      </button>
    </div>
  );
}
```

### With Animation

```tsx
import { motion } from 'framer-motion';

// Wrap TriangleFigure in motion.div for animations
<motion.div
  initial={{ opacity: 0 }}
  animate={{ opacity: 1 }}
  transition={{ duration: 0.5 }}
>
  <TriangleFigure vertices={[...]} />
</motion.div>
```

---

## Utility Functions

Las funciones matemáticas están disponibles en `@/lib/geometry/triangleUtils`:

```typescript
import {
  distance,           // Distancia entre puntos
  midpoint,           // Punto medio
  centroid,           // Centroide del triángulo
  angleAtVertex,      // Ángulo en un vértice (grados)
  altitudeFootPoint,  // Pie de la altura
  findRightAngleVertex, // Encuentra vértice con ángulo recto
  buildTriangleFromAngles,  // Construir triángulo desde ángulos
  validateTriangleAngles,   // Validar ángulos (suman 180°)
  buildTriangleFromSides,   // Construir triángulo desde longitudes de lados
  validateTriangleSides,    // Validar desigualdad triangular
} from '@/lib/geometry/triangleUtils';
```

### Build Triangle from Angles

Puedes construir un triángulo especificando los 3 ángulos interiores:

```typescript
import { buildTriangleFromAngles } from '@/lib/geometry/triangleUtils';

// Triángulo 30-60-90
const vertices = buildTriangleFromAngles(
  [30, 60, 90],  // Los 3 ángulos (deben sumar 180°)
  150,           // Longitud base (escala)
  200,           // Centro X
  150,           // Centro Y
  0              // Rotación (grados)
);

// Resultado: [LabeledPoint, LabeledPoint, LabeledPoint]
```

### Build Triangle from Sides

Puedes construir un triángulo especificando las 3 longitudes de lados:

```typescript
import { buildTriangleFromSides } from '@/lib/geometry/triangleUtils';

// Triángulo 3-4-5 (rectángulo pitagórico)
const vertices = buildTriangleFromSides(
  [3, 4, 5],     // Las 3 longitudes de lados
  150,           // Tamaño máximo (escala)
  200,           // Centro X
  150,           // Centro Y
  0              // Rotación (grados)
);

// Resultado: [LabeledPoint, LabeledPoint, LabeledPoint]
```

> **Importante:** Los lados deben cumplir la desigualdad triangular (a + b > c para todos los lados).
