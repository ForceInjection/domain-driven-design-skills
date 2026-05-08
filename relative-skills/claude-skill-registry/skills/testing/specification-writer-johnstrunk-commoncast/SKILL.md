---
name: specification-writer
description: Use this skill proactively to write and revise feature specifications
---

# Specification writing

Work interactively with the user to create the specification for a feature. A
feature specification has the following components:

- **Title:** Brief title for the feature
- **Summary:** A 1-2 sentence description of the feature
- **Description:** A longer description that contains:
  - The trigger or situation for when this feature would be used
  - The ability or artifact that is desired
  - The value or outcome that is expected

## Steps

Use the todo tool to track each of the following steps in creating the feature
specification:

- [ ] Engage in a dialog with the user to develop answers to the above items.
- [ ] Scan through the [design/](../../design/) directory and determine the
  next sequential 4-digit ID number to use.
- [ ] Create a markdown file in the design directory of the form
  `NNNN-a-short-name.md`.
- [ ] Fill the new file with the information about the feature, using the
  template below.
- [ ] Based on the description, decompose it into a series of requirements,
  each of which are specific and testable. Add those requirements as a
  numbered list under "Requirements", replacing the placeholder text.
- [ ] Based on the feature description and requirements, decompose it into a
  series of simple development tasks suitable for an AI agent to complete. Add
  those steps as a checklist under "Development tasks", replacing the
  placeholder text.
- [ ] Use the description, requirements, and development tasks to create an
  automated test plan for this feature. Automated tests are very important to
  ensure that features continue to work as the codebase and repository
  evolves. Ensure that every requirement is covered by at least one test,
  referencing the requirement by number.

## Template

```markdown
# {feature title}

{short summary of the feature (1-2 sentences)}

## Description

{detailed description of the feature}

## Requirements

1. {First specific, testable requirement}
2. {Second specific, testable requirement}
3. {Etc.}

## Development tasks

- [ ] {First development task}
- [ ] {Second development task}
- [ ] {Etc.}

## Test plan

- {Description of automated test for requirement 1}
- {Description of automated test for requirement 2}
- {Etc.}
```
