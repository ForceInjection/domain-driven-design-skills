---
name: Implement SCM Features
description: Build features in the SCM (School Coaching Manager) section. Use for creating pages, hooks, and visualizations for podsie tracking, roadmaps, velocity, and assessment data.
---

# Implement SCM Features

Build features in the SCM (School Coaching Manager) section of the app. This includes pages under `/src/app/scm/` for podsie tracking, roadmaps, velocity, and assessment data.

## When to Use This Skill

Use when the user asks to:
- Create new SCM pages or features
- Add data fetching to SCM pages
- Build visualizations for velocity, roadmaps, or assessments
- Work with section/class data

## Architecture

### File Structure
```
src/app/scm/
├── podsie/           # Velocity tracking, progress, weekly reports
│   ├── velocity/     # Class velocity tracker
│   ├── progress/     # Student progress tracking
│   ├── weekly/       # Weekly summary reports
│   ├── pace/         # Pacing analysis
│   └── hooks/        # Shared podsie hooks
├── roadmaps/         # Skills mastery and curriculum
│   ├── history/      # Assessment history
│   ├── progress/     # Roadmap completions
│   ├── mastery-grid/ # Student mastery visualization
│   ├── skills/       # Skill browser
│   ├── units/        # Unit browser
│   └── hooks/        # Shared roadmaps hooks
└── ...
```

### Centralized Hooks Location
All SCM React Query hooks are available at:
```typescript
import { ... } from "@/hooks/scm";
```

## Available Hooks

### Section & Class Hooks
```typescript
// Get all section configs with colors
const { sectionOptions, sectionColors, loading } = useSectionOptions();

// Get unique sections from students
const { sections, loading } = useSections();

// Get days off for a school year
const { daysOff, loading } = useDaysOff(schoolYear);

// Get current units for all sections
const { currentUnits, loading } = useCurrentUnits(schoolYear);
```

### Velocity Hooks
```typescript
// Get velocity data for selected sections
const { velocityData, detailData, unitScheduleData, loadingSectionIds } =
  useVelocityData(selectedSections, sectionOptions, schoolYear, includeNotTracked);

// Get weekly velocity aggregates
const { sectionData, loading, error } =
  useWeeklyVelocity(sections, startDate, endDate);
```

### Roadmap Hooks
```typescript
// Get all roadmap units
const { units, loading, error } = useRoadmapUnits();

// Get roadmap completion data for sections
const { roadmapData, loadingSectionIds } = useRoadmapData(selectedSections);

// Get all skills (for filter dropdowns)
const { allSkills, loading } = useAllSkills();

// Get filtered skills by grade/unit
const { skills, loading, error } = useFilteredSkills(selectedGrade, selectedUnit);
```

### Assessment Hooks
```typescript
// Get student assessment data
const { data, loading, error } = useAssessmentData();

// Get Zearn completion data (with refetch for imports)
const { data, loading, error, refetch } = useZearnCompletions();

// Get Podsie completion data
const { data, loading, error } = usePodsieCompletions();

// Get students grouped by section
const { studentsBySection, loading } = useStudentsBySection();
```

## Patterns

### Creating a New SCM Page

1. **Use existing hooks** from `@/hooks/scm` or page-specific hooks
2. **Use `useMemo`** for derived/filtered data
3. **Use `useEffect`** only for side effects (e.g., clearing selection on filter change)

```typescript
"use client";

import { useState, useMemo, useEffect } from "react";
import { useSectionOptions, useRoadmapUnits } from "@/hooks/scm";

export default function MyPage() {
  const [selectedGrade, setSelectedGrade] = useState("");

  // Data fetching with React Query hooks
  const { sectionOptions, loading } = useSectionOptions();
  const { units } = useRoadmapUnits();

  // Derived data with useMemo
  const filteredUnits = useMemo(() => {
    if (!selectedGrade) return [];
    return units.filter(u => u.grade === selectedGrade);
  }, [selectedGrade, units]);

  // Side effects with useEffect
  useEffect(() => {
    // Clear selection when filter changes
  }, [selectedGrade]);

  // ... render
}
```

### Creating a New Hook

Place hooks in the appropriate location:
- **Page-specific**: `src/app/scm/{area}/{page}/hooks/`
- **Shared within area**: `src/app/scm/{area}/hooks/`
- **Shared across SCM**: Export from `src/hooks/scm/index.ts`

```typescript
import { useQuery } from "@tanstack/react-query";

export const myDataKeys = {
  all: ["my-data"] as const,
  byId: (id: string) => [...myDataKeys.all, id] as const,
};

export function useMyData(id: string) {
  const { data, isLoading, error } = useQuery({
    queryKey: myDataKeys.byId(id),
    queryFn: async () => {
      const result = await fetchMyData(id);
      if (!result.success) {
        throw new Error(result.error);
      }
      return result.data;
    },
    staleTime: 60_000, // Cache for 1 minute
    enabled: !!id, // Only fetch when id exists
  });

  return {
    data: data || [],
    loading: isLoading,
    error: error?.message || null,
  };
}
```

### Shared Layout Components

Use existing layout components for consistent UI:
```typescript
import {
  SectionVisualizationLayout,
  SectionAccordion,
  type SectionOption,
  type AccordionItemConfig,
} from "@/components/composed/section-visualization";
```

## Server Actions

Server actions for SCM data are located at:
- `src/app/actions/scm/` - Student, section, velocity, roadmap actions
- `src/app/actions/calendar/` - Calendar and scheduling actions

Key action files:
```
src/app/actions/scm/
├── students.ts           # CRUD for students collection
├── student-data.ts       # Student dashboard data aggregation
├── section-config.ts     # Section configuration management
├── velocity/velocity.ts  # Velocity calculations
├── podsie-sync/          # Podsie API integration
├── podsie-completion.ts  # Podsie completion queries
├── roadmaps-units.ts     # Roadmap units CRUD
├── roadmaps-skills.ts    # Roadmap skills CRUD
├── roadmaps-lessons.ts   # Scope and sequence lessons
├── scope-and-sequence.ts # Curriculum sequence data
├── zearn-import.ts       # Zearn data import
└── analytics.ts          # Analytics aggregations
```

## Zod Schemas

All SCM schemas are in `src/lib/schema/zod-schema/scm/`:

### Student Schema (`scm/student/student.ts`)
```typescript
import { StudentZodSchema, type Student } from "@zod-schema/scm/student/student";

// Student document structure
interface Student {
  studentID: number;           // Unique identifier
  firstName: string;
  lastName: string;
  school: "IS313" | "PS19" | "X644";
  section: string;             // Class section (e.g., "802")
  gradeLevel?: string;
  email: string;
  active: boolean;

  // Progress tracking
  masteredSkills: string[];              // Skill numbers mastered
  skillPerformances: SkillPerformance[]; // Assessment attempts
  zearnLessons: ZearnLessonCompletion[]; // Zearn completions
  podsieProgress: PodsieProgress[];      // Podsie assignment progress
  classActivities: StudentActivity[];    // Logged activities
}
```

### Section Config Schema (`scm/podsie/section-config.ts`)
```typescript
import { SectionConfigZodSchema, type SectionConfig } from "@zod-schema/scm/podsie/section-config";

// Section configuration for a class
interface SectionConfig {
  school: string;
  classSection: string;        // e.g., "802"
  teacher?: string;
  gradeLevel: string;
  scopeSequenceTag?: string;   // e.g., "Grade 8"
  groupId?: string;            // Podsie group ID
  specialPopulations: string[];
  bellSchedule?: BellSchedule;

  // Assignment configurations linking to scope-and-sequence
  assignmentContent: AssignmentContent[];

  // Smartboard YouTube links
  youtubeLinks: YoutubeLink[];
  activeYoutubeUrl?: string;
}
```

### Curriculum Schemas (`scm/curriculum/`)
```typescript
// Roadmap Units - skill groupings by unit
import { RoadmapUnitZodSchema, type RoadmapUnit } from "@zod-schema/scm/roadmaps/roadmap-unit";

interface RoadmapUnit {
  grade: string;               // e.g., "Illustrative Math NY - 7th Grade"
  unitTitle: string;           // e.g., "01 - Area and Surface Area"
  unitNumber?: number;
  targetSkills: string[];      // Primary skill numbers
  additionalSupportSkills: string[];
  extensionSkills: string[];
}

// Roadmap Skills - individual skill definitions
import { RoadmapSkillZodSchema, type RoadmapSkill } from "@zod-schema/scm/roadmaps/roadmap-skill";

// Scope and Sequence - curriculum lesson sequence
import { ScopeAndSequenceZodSchema, type ScopeAndSequence } from "@zod-schema/scm/scope-and-sequence/scope-and-sequence";
```

### Podsie Schemas (`scm/podsie/`)
```typescript
// Podsie completion tracking
import { PodsieCompletionZodSchema } from "@zod-schema/scm/podsie/podsie-completion";

// Learning content (worked examples, etc.)
import { LearningContentZodSchema } from "@zod-schema/scm/podsie/learning-content";

// Question mappings
import { PodsieQuestionMapZodSchema } from "@zod-schema/scm/podsie/podsie-question-map";
```

## Key Types

```typescript
// From @/components/composed/section-visualization
interface SectionOption {
  id: string;
  school: string;
  classSection: string;
  teacher?: string;
  gradeLevel?: string;
  displayName: string;
  scopeSequenceTag?: string;
  specialPopulations?: string[];
}

// From hooks
interface SectionWeeklyData {
  section: string;
  school: string;
  totalMasteryChecks: number;
  totalStudents: number;
  masteryChecksPerStudent: number;
  attendance: {
    present: number;
    late: number;
    absent: number;
    total: number;
  };
}
```
