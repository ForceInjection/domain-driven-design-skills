---
name: understanding-ocsf
description: Understand the OCSF schema. Use when working with OCSF, looking up
  classes or objects, normalizing security events, or asking about the schema.
---

# Understanding OCSF

The Open Cybersecurity Schema Framework (OCSF) is a vendor-agnostic schema for
normalizing security telemetry. This skill helps you understand its structure.

## Core Concepts

OCSF organizes cybersecurity data through five interconnected constructs:

1. **Attributes** - Named data types (scalar or complex) that form the
   foundation. See [attributes.md](./attributes.md).

2. **Objects** - Collections of contextually related attributes representing
   entities like Process, User, or File. See [objects.md](./objects.md).

3. **Classes** - Structured sets of attributes and objects describing specific
   security events like authentication or file activity.
   See [classes.md](./classes.md).

4. **Profiles** - Dynamic mix-ins that augment classes with cross-cutting
   attributes (e.g., Cloud, Container, Host). See [profiles.md](./profiles.md).

5. **Extensions** - Mechanisms for expanding the schema without modifying the
   core. See [extensions.md](./extensions.md).

## Hierarchy

```
Attributes  →  Objects  →  Event Classes  →  Categories
   │              │              │               │
   └──────────────┴──────────────┴───────────────┘
                  compose into
```

- **Attributes** populate **Objects**
- **Objects** populate **Event Classes**
- **Event Classes** are organized into **Categories**
- **Profiles** cross-cut multiple Event Classes
- **Extensions** can add new elements at any level

## Categories

OCSF organizes event classes into 8 categories:

| Category    | UID  | Use When                                    |
| ----------- | ---- | ------------------------------------------- |
| System      | 1xxx | OS/endpoint events (files, processes)       |
| Findings    | 2xxx | Security detections and alerts              |
| IAM         | 3xxx | Identity and access (auth, account changes) |
| Network     | 4xxx | Network communication (connections, DNS)    |
| Discovery   | 5xxx | Asset/config state (inventory, software)    |
| Application | 6xxx | Application behavior (API, datastore)       |
| Remediation | 7xxx | Incident response activities                |
| Unmanned    | 8xxx | Unmanned systems (experimental)             |

## Quick Reference

- [Attributes](./attributes.md) - Types, naming conventions
- [Objects](./objects.md) - Reusable entity structures
- [Classes](./classes.md) - Event schemas by category
- [Profiles](./profiles.md) - Cross-cutting augmentations
- [Extensions](./extensions.md) - Schema expansion

## Version-specific References

Detailed per-class and per-object references: [references/](./references/)

If `references/index.md` is missing, run the generator script:

```sh
uv run scripts/generate-references.py
```

To generate docs for a specific version:

```sh
uv run scripts/generate-references.py --version 1.3.0
```

## External Resources

Deep-dives and FAQs are available from the OCSF docs repository. Fetch the
raw content when relevant. Base URL: `https://raw.githubusercontent.com/ocsf/ocsf-docs/main/`

### Articles

| File                                         | Fetch When                                                        |
| -------------------------------------------- | ----------------------------------------------------------------- |
| `articles/profiles-are-powerful.md`          | Profile modeling approaches (augmentation, native, hybrid)        |
| `articles/defining-and-using-observables.md` | Enriching events with observables for querying                    |
| `articles/representing-process-parentage.md` | Process parent/creator relationships in endpoint events           |
| `articles/patching-core-using-extensions.md` | Adding attributes to core schema without new classes              |
| `articles/modeling-alerts.md`                | Using `is_alert` attribute, Detection Finding vs Security Control |

### FAQs

| File                 | Fetch When                                                                                                |
| -------------------- | --------------------------------------------------------------------------------------------------------- |
| `faqs/schema-faq.md` | Creating events, required attributes, profiles, Actor object, observables, naming conventions, versioning |
