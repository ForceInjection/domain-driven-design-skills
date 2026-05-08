---
name: lesson-plan-generator
description: This skill should be used when educators, trainers, curriculum designers, or instructional designers need to create comprehensive lesson plans from a topic. The skill generates structured educational content with learning objectives aligned to Bloom's taxonomy, content outlines, interactive exercises, assessment quizzes, and instructor notes. It can read existing .docx and .pptx files for context and exports final lesson plans as .docx files. Triggers include requests to create lesson plans, generate curriculum, build training materials, or develop educational content.
---

# Lesson Plan Generator

This skill generates comprehensive, professionally structured lesson plans from any topic. It produces ready-to-publish educational content including learning objectives, content structure, interactive exercises, assessment quizzes, and instructor guidance. The skill integrates with the docx skill to create Word documents and can read existing .docx and .pptx files for context.

## When to Use This Skill

This skill should be activated when:
- Creating a complete lesson plan for a new topic
- Developing corporate training materials
- Designing curriculum with standardized structures
- Prototyping course content for instructional designers
- Scaffolding lessons from existing presentations or documents
- Professional development content requiring consistent formatting

Typical trigger phrases:
- "Create a lesson plan for..."
- "Generate curriculum on..."
- "Build training materials about..."
- "Design a lesson on..."
- "Help me plan a class on..."

## Skill Workflow

### Phase 1: Input Gathering

To generate an effective lesson plan, collect or infer the following information:

**Required Information**:
- **Topic**: The subject matter to be taught
- **Target Audience**: Grade level, skill level, or audience description
- **Duration**: Total lesson time (e.g., "45 minutes", "2 hours")

**Optional Information** (make reasonable assumptions if not provided):
- **Prerequisite Knowledge**: What students should already know
- **Learning Environment**: Classroom, online, hybrid, corporate training room
- **Special Considerations**: Accessibility needs, diverse backgrounds, constraints
- **Standards Alignment**: Educational standards to reference (Common Core, NGSS, etc.)

**Reading Existing Materials**:
When existing .docx or .pptx files are provided for context:
1. Use the docx skill to read Word documents
2. Use the pptx skill to read PowerPoint presentations
3. Extract relevant content, structure, and learning goals
4. Integrate insights into the lesson plan generation

### Phase 2: Learning Objectives Generation

Create 5-8 SMART learning objectives using Bloom's taxonomy. Reference `references/blooms_taxonomy.md` for action verbs and `references/smart_objectives.md` for objective structure.

**Objective Structure**:
"By the end of this lesson, students will be able to [action verb] [specific content] [measurable criteria]."

**Distribution Guidelines**:
- 2-3 objectives at Remember/Understand level (foundational knowledge)
- 2-3 objectives at Apply/Analyze level (skill development)
- 1-2 objectives at Evaluate/Create level (advanced application)

**Quality Checks**:
- Each objective uses a specific action verb from Bloom's taxonomy
- Objectives are measurable and observable
- Progressive complexity from lower to higher cognitive levels
- Aligned with lesson duration and audience capabilities

### Phase 3: Content Structure

Organize instructional content into 3-5 main segments. Reference `references/lesson_structure.md` for complete structural guidance.

**For Each Segment Include**:
- **Segment Title**: Clear, descriptive heading
- **Duration**: Estimated time allocation
- **Key Concepts**: 3-5 main ideas to cover
- **Teaching Approach**: Instructional method (lecture, discussion, demonstration, etc.)
- **Student Activities**: What learners do during this segment
- **Transition**: How this connects to the next segment

**Content Progression Principles**:
- Logical flow from foundational to complex concepts
- Each segment builds on previous knowledge
- Balance teacher-led instruction with student activity
- Include check-for-understanding moments

### Phase 4: Lesson Procedure Timeline

Create a detailed timeline with specific durations:

1. **Opening/Hook** (5-10 minutes)
   - Attention-grabbing activity or question
   - Connection to prior knowledge
   - Clear statement of learning objectives
   - Preview of lesson structure

2. **Direct Instruction** (15-25 minutes)
   - Teacher-led concept explanation
   - Modeling of skills or processes
   - Visual aids and concrete examples
   - Strategic questioning for engagement

3. **Guided Practice** (10-20 minutes)
   - Structured practice with scaffolding
   - Teacher circulation and feedback
   - Step-by-step problem solving
   - Gradual release of responsibility

4. **Independent Practice** (10-20 minutes)
   - Student-led application of skills
   - Individual or small group work
   - Real-world problem contexts
   - Differentiated challenge levels

5. **Closure** (5-10 minutes)
   - Summary of key learning points
   - Student reflection opportunities
   - Formative assessment (exit ticket)
   - Preview of next lesson

### Phase 5: Interactive Exercises

Design 3-5 hands-on activities that reinforce learning objectives.

**Exercise Components**:
- **Title**: Descriptive activity name
- **Duration**: Time allocation
- **Objective Alignment**: Which specific objectives addressed
- **Instructions**: Clear, step-by-step directions
- **Materials**: Complete list of required items
- **Expected Outcomes**: What students produce or demonstrate
- **Facilitation Tips**: How to manage the activity
- **Differentiation**: Modifications for various learner levels

**Activity Variety**:
- Individual work for personal mastery
- Pair activities for collaborative learning
- Group discussions for multiple perspectives
- Problem-solving scenarios for application
- Creative projects for synthesis
- Simulations or role-play for engagement

### Phase 6: Assessment Quiz Development

Create an assessment with 8-12 questions that measure objective achievement.

**Question Type Distribution**:
- **Multiple Choice** (4-6 questions): Quick knowledge verification
- **Short Answer** (2-3 questions): Conceptual understanding demonstration
- **Application Questions** (1-2 questions): Skill transfer assessment
- **Analysis Questions** (1-2 questions): Higher-order thinking evaluation

**For Each Question Provide**:
- Question text (clear, unambiguous)
- Answer options (for multiple choice: 4-5 options, 1 correct)
- Correct answer identification
- Explanation of why the answer is correct
- Which learning objective the question assesses

**Question Quality Standards**:
- Directly tied to learning objectives
- Appropriate difficulty progression
- No trick questions or ambiguous wording
- Variety of cognitive levels assessed
- Adequate discrimination between understanding levels

### Phase 7: Instructor Notes

Generate practical teaching guidance:

**Preparation Section**:
- Materials to prepare before class
- Room setup requirements
- Technology checks needed
- Handouts to print/distribute

**Teaching Strategies**:
- Opening engagement techniques
- Common student misconceptions with corrections
- Pacing and time management checkpoints
- Discussion facilitation strategies
- Classroom management tips

**Troubleshooting**:
- Backup plans if technology fails
- Adjustments if activities run long/short
- Reteaching strategies for difficult concepts
- Extension activities for fast finishers

**Differentiation Guidance**:
- Modifications for advanced learners
- Scaffolding for struggling students
- ELL support strategies
- Accommodation implementation

### Phase 8: Export to .docx

Use the docx skill to create a professional Word document:

1. **Read the Template**: Load `assets/lesson_plan_template.md` as structural guide
2. **Format Document**:
   - Professional fonts (Arial, Calibri, or Times New Roman)
   - 11-12 point body text
   - Consistent heading hierarchy (Heading 1, 2, 3 styles)
   - 1-inch margins
   - Page numbers in footer
   - Header with lesson title and date
3. **Organize Content**:
   - Clear section breaks between major components
   - Tables for structured information (header metadata, materials)
   - Bulleted and numbered lists for readability
   - Adequate white space for visual clarity
4. **Save as .docx**: Use descriptive filename (e.g., "Lesson_Plan_[Topic]_[Date].docx")

**Invoke docx skill** with the generated content structured according to the template. The docx skill handles the actual file creation with proper Office Open XML formatting.

## Bundled Resources

### References (Load as needed)

- **`references/blooms_taxonomy.md`**: Complete Bloom's taxonomy hierarchy with action verbs for each cognitive level. Use when crafting learning objectives.

- **`references/smart_objectives.md`**: Guide for writing Specific, Measurable, Achievable, Relevant, Time-bound objectives. Use when structuring objective statements.

- **`references/lesson_structure.md`**: Comprehensive lesson plan components and formatting standards. Use when organizing the complete lesson plan structure.

### Assets (Use in output)

- **`assets/lesson_plan_template.md`**: Master template with placeholders for all lesson plan components. Use as structural foundation when generating lesson plans.

## Integration with Other Skills

### Reading Input Files

**For .docx files** (Word documents):
- Invoke the docx skill to extract text content
- Identify existing learning objectives, content structure, or assessments
- Use extracted information to inform lesson plan generation

**For .pptx files** (PowerPoint presentations):
- Invoke the pptx skill to read slide content
- Extract key concepts from slide titles and body text
- Identify existing visual structure and content flow
- Adapt presentation content into lesson plan format

### Creating Output Files

**For .docx export**:
- Invoke the docx skill after content generation
- Pass structured lesson plan content
- Specify formatting requirements (fonts, margins, styles)
- Request professional document creation

## Best Practices

1. **Objective Alignment**: Every activity and assessment item directly supports a learning objective
2. **Specificity**: Provide explicit instructions, not vague guidance
3. **Engagement Variety**: Multiple instructional methods and activity types
4. **Realistic Constraints**: Account for actual classroom time, resources, and diverse learners
5. **Actionable Guidance**: Specific facilitation tips, not generic advice
6. **Inclusive Design**: Built-in differentiation and accommodation options
7. **Evidence-Based Assessment**: Quiz and exercises measure actual learning
8. **Professional Quality**: Ready for immediate use or sharing

## Customization Support

When users request modifications:

- **Different Duration**: Adjust content depth, exercise count, and segment lengths proportionally
- **Alternative Audience**: Modify vocabulary, examples, and cognitive complexity
- **Specific Standards**: Align objectives to requested frameworks (Common Core, NGSS, state standards)
- **Pedagogical Approaches**: Apply requested methods (project-based learning, Socratic questioning, flipped classroom, direct instruction)
- **Subject-Specific Needs**: Adapt structure for lab sciences, performance arts, language learning, etc.

## Error Handling

If essential information is missing:
1. Make explicit, reasonable assumptions based on topic and context
2. Note assumptions clearly in the lesson plan
3. Suggest where user input could improve accuracy
4. Provide alternatives if multiple valid approaches exist

If output exceeds scope:
1. Prioritize core components (objectives, content, assessment)
2. Offer to generate additional sections separately
3. Suggest breaking into multiple lesson plans if topic is too broad
