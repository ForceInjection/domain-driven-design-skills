---
name: mochi-creator
description: Create evidence-based spaced repetition flashcards using cognitive science principles from Andy Matuschak's research. Use when user wants to create Mochi cards, flashcards, study materials, or mentions learning, memorization, spaced repetition, SRS, Anki-style cards, or knowledge retention. Applies the 5 properties of effective prompts (focused, precise, consistent, tractable, effortful) to ensure cards actually work for long-term retention.
---

# Mochi Creator

## Overview

This skill enables creation and management of flashcards, decks, and templates in Mochi.cards, a spaced repetition learning system. **Critically, this skill applies evidence-based cognitive science principles** to ensure flashcards actually work for long-term retention.

**Core Philosophy**: Writing prompts for spaced repetition is task design. You're creating recurring retrieval tasks for your future self. Effective prompts leverage *retrieval practice* - actively recalling information strengthens memory far more than passive review.

Use this skill to transform content into study materials, organize learning resources into deck hierarchies, and create cards that are focused, precise, consistent, tractable, and effortful.

## Quick Start

### Setup

Before using this skill, set the Mochi API key as an environment variable:

```bash
export MOCHI_API_KEY="your_api_key_here"
```

To obtain an API key:
1. Open the Mochi.cards application
2. Navigate to Account Settings
3. Locate the API Keys section
4. Generate a new API key

### Using the Python Script

The `scripts/mochi_api.py` script provides a complete Python interface to the Mochi API. Import and use it in Python code:

```python
from scripts.mochi_api import MochiAPI

# Initialize the client (reads MOCHI_API_KEY from environment)
api = MochiAPI()

# Create a deck
deck = api.create_deck(name="Python Programming")

# Create a card in that deck
card = api.create_card(
    content="# What is a list comprehension?\n---\nA concise way to create lists in Python",
    deck_id=deck["id"],
    manual_tags=["python", "syntax"]
)
```

Or execute it directly from command line for testing:

```bash
python scripts/mochi_api.py list-decks
python scripts/mochi_api.py create-deck "My Study Deck"
python scripts/mochi_api.py list-cards <deck-id>
```

## The Science of Effective Prompts

**CRITICAL**: Before creating any flashcard, understand what makes prompts effective. Bad prompts waste time and fail to build lasting memory. Great prompts compound learning over years.

### The Five Properties of Effective Prompts

Every prompt you create must satisfy these five properties (based on Andy Matuschak's research):

1. **Focused**: One detail at a time
   - ❌ "What are Python decorators, what syntax do they use, and when would you use them?"
   - ✅ "What is the primary purpose of Python decorators?" (separate cards for syntax and usage)

2. **Precise**: Specific questions demand specific answers
   - ❌ "What's interesting about decorators?"
   - ✅ "What Python feature allows decorators to modify function behavior?"

3. **Consistent**: Should produce the same answer each time
   - ❌ "Give an example of a decorator" (produces different answers, creates interference)
   - ✅ "What is the most common built-in Python decorator?" (consistent: @property or @staticmethod)
   - Note: Creative prompts asking for novel answers are advanced and experimental

4. **Tractable**: You should answer correctly ~90% of the time
   - If struggling, break down further or add cues
   - Too easy? Increase effortfulness (next property)
   - Add mnemonic cues in parentheses when helpful

5. **Effortful**: Must require actual memory retrieval, not trivial inference
   - ❌ "Is Python a programming language?" (too trivial)
   - ✅ "What problem does the @lru_cache decorator solve?" (requires retrieval)

### The "More Than You Think" Rule

**Write 3-5 focused prompts instead of 1 comprehensive prompt.**

This feels unnatural initially. You'll want to economize. Resist this urge.

- Each focused prompt takes only 10-30 seconds across an entire year of review
- Prompts are cheaper than you think
- Coarser prompts don't reduce work - they make learning harder and less reliable

**Example transformation:**

❌ One unfocused prompt:
```
Q: What are the ingredients in chicken stock?
A: Chicken bones, onions, carrots, celery, bay leaves, water
```

✅ Six focused prompts:
```
Q: What protein source forms the base of chicken stock?
A: Chicken bones

Q: What three vegetables form the aromatic base of chicken stock?
A: Onions, carrots, celery (mirepoix)

Q: What herb is traditionally added to chicken stock?
A: Bay leaves

Q: What liquid comprises the majority of chicken stock?
A: Water

Q: What is the French term for the onion-carrot-celery base?
A: Mirepoix

Q: What ratio of vegetables to liquid is typical in stock?
A: Roughly 1:4 (vegetables to water)
```

Notice: Each prompt lights a specific "bulb" in your understanding. The unfocused version leaves bulbs unlit.

### Emotional Connection is Primary

**Only create prompts about material that genuinely matters to you.**

- If creating cards "because you should," stop and reassess
- Connect prompts to your actual creative work and goals
- During review sessions, notice internal "sighs" - flag those cards for revision or deletion
- Delete liberally when emotional connection fades
- Boredom leads to abandonment of the entire system

**Ask yourself**: "Do I actually care about remembering this in six months? Why?"

### Common Anti-Patterns to Avoid

1. **Binary prompts** (yes/no questions)
   - ❌ "Is encapsulation important in OOP?"
   - ✅ "What benefit does encapsulation provide in object-oriented design?"

2. **Pattern-matching prompts** (answerable by syntax recognition)
   - ❌ "In the context of RESTful APIs using HTTP methods with proper authentication headers, what method creates resources?"
   - ✅ "What HTTP method creates resources?"

3. **Unfocused prompts** (multiple details)
   - ❌ "What are the features, benefits, and drawbacks of Redis?"
   - ✅ Create separate prompts for each feature, benefit, and drawback

4. **Vague prompts** (imprecise questions)
   - ❌ "Tell me about async/await"
   - ✅ "What problem does async/await solve in JavaScript?"

5. **Trivial prompts** (no retrieval required)
   - ❌ "What does URL stand for?"
   - ✅ "Why do URLs encode spaces as %20 instead of using literal spaces?"

### Quality Validation Checklist

Before creating each card, verify:

- [ ] **Focused**: Tests exactly one detail?
- [ ] **Precise**: Question is specific, answer is unambiguous?
- [ ] **Consistent**: Will produce the same answer each time?
- [ ] **Tractable**: I can answer correctly ~90% of the time?
- [ ] **Effortful**: Requires actual memory retrieval?
- [ ] **Emotional**: I genuinely care about remembering this?

If any checkbox fails, revise before creating the card.

## Core Tasks

### Creating Simple Flashcards

For basic question-and-answer flashcards, create cards with markdown content using `---` to separate card sides.

**Example user requests:**
- "Create a Mochi card about Python decorators"
- "Add a flashcard to my Python deck explaining lambda functions"
- "Make flashcards from these notes"

**Implementation approach:**

1. List existing decks to get deck IDs or create a new deck if needed:
```python
decks = api.list_decks()
# Or create new deck
deck = api.create_deck(name="Python Programming")
deck_id = deck["id"]
```

2. Format content with markdown and side separators:
```python
content = """# What are Python decorators?
---
Functions that modify the behavior of other functions or methods.
They use the @decorator syntax above function definitions.

Example:
@staticmethod
def my_function():
    pass
"""
```

3. Create the card with optional tags:
```python
card = api.create_card(
    content=content,
    deck_id=deck_id,
    manual_tags=["python", "functions", "decorators"]
)
```

**Multi-card creation from text:**

When creating multiple cards from a document or conversation:
1. Parse or chunk the content into logical learning units
2. Format each as question/answer or concept/explanation
3. Create cards in a loop, handling each API response
4. Report success/failure for each card created

### Creating Template-Based Cards

For structured, repeatable card formats (vocabulary, definitions, examples), use templates with fields.

**Example user requests:**
- "Create vocabulary flashcards with word, definition, and example"
- "Make a template for programming concepts with name, description, and code example"
- "Use the Basic Flashcard template to create cards"

**Implementation approach:**

1. Create or retrieve a template:
```python
# Create a new template
template = api.create_template(
    name="Vocabulary Card",
    content="# << Word >>\n\n**Definition:** << Definition >>\n\n**Example:** << Example >>",
    fields={
        "word": {
            "id": "word",
            "name": "Word",
            "type": "text",
            "pos": "a"
        },
        "definition": {
            "id": "definition",
            "name": "Definition",
            "type": "text",
            "pos": "b",
            "options": {"multi-line?": True}
        },
        "example": {
            "id": "example",
            "name": "Example",
            "type": "text",
            "pos": "c",
            "options": {"multi-line?": True}
        }
    }
)
```

2. Create cards using the template:
```python
card = api.create_card(
    content="",  # Content can be empty when using fields
    deck_id=deck_id,
    template_id=template["id"],
    fields={
        "word": {
            "id": "word",
            "value": "ephemeral"
        },
        "definition": {
            "id": "definition",
            "value": "Lasting for a very short time; temporary"
        },
        "example": {
            "id": "example",
            "value": "The beauty of cherry blossoms is ephemeral, lasting only a few weeks."
        }
    }
)
```

**Reusing existing templates:**

1. List available templates:
```python
templates = api.list_templates()
for template in templates["docs"]:
    print(f"{template['name']}: {template['id']}")
```

2. Retrieve template details to see field structure:
```python
template = api.get_template(template_id)
field_ids = list(template["fields"].keys())
```

3. Create cards matching the template's field structure

### Managing Decks

Organize cards into hierarchical deck structures for better content organization.

**Example user requests:**
- "Create a deck for studying Spanish"
- "Organize these cards into a Python → Data Structures subdeck"
- "List my existing Mochi decks"

**Implementation approach:**

**Creating decks:**
```python
# Top-level deck
deck = api.create_deck(
    name="Programming",
    sort=1
)

# Nested subdeck
subdeck = api.create_deck(
    name="Python",
    parent_id=deck["id"],
    sort=1
)
```

**Listing decks:**
```python
result = api.list_decks()
for deck in result["docs"]:
    parent = f" (under {deck.get('parent-id', 'root')})" if deck.get("parent-id") else ""
    print(f"{deck['name']}: {deck['id']}{parent}")

# Handle pagination if needed
if result.get("bookmark"):
    next_page = api.list_decks(bookmark=result["bookmark"])
```

**Updating deck properties:**
```python
# Archive a deck
api.update_deck(deck_id, archived=True)

# Change deck display settings
api.update_deck(
    deck_id,
    cards_view="grid",
    sort_by="updated-at",
    show_sides=True
)

# Reorganize deck hierarchy
api.update_deck(deck_id, parent_id=new_parent_id)
```

**Deck organization strategies:**
- Use hierarchical structures: Subject → Topic → Subtopic
- Set `sort` field numerically to control deck ordering
- Archive completed decks instead of deleting them
- Use `archived?` to hide decks from active review

### Batch Operations

Create multiple cards efficiently from source materials like notes, documents, or conversations.

**Example user requests:**
- "Turn this conversation into Mochi flashcards"
- "Create cards from these 20 definitions"
- "Import my study notes into Mochi"

**Implementation approach:**

1. Parse source content into individual card items
2. Identify or create target deck
3. Determine if template-based or simple cards are appropriate
4. Create cards in sequence with error handling:

```python
def create_cards_from_list(items, deck_id, template_id=None):
    """Create multiple cards with error handling."""
    results = {"success": [], "failed": []}

    for item in items:
        try:
            if template_id:
                card = api.create_card(
                    content="",
                    deck_id=deck_id,
                    template_id=template_id,
                    fields=item["fields"]
                )
            else:
                card = api.create_card(
                    content=item["content"],
                    deck_id=deck_id,
                    manual_tags=item.get("tags", [])
                )
            results["success"].append(card["id"])
        except Exception as e:
            results["failed"].append({"item": item, "error": str(e)})

    return results
```

5. Report results to user with success count and any errors

**Content extraction strategies:**
- Split text by headers or numbered lists for question/answer pairs
- Extract key terms and definitions from formatted documents
- Parse conversation history for teaching moments or explanations
- Identify code examples and create cards with syntax and explanation

## Knowledge-Type Specific Workflows

Different types of knowledge require different prompt strategies. Always apply the 5 properties, but adapt your approach based on what you're learning.

### Factual Knowledge (Simple Facts)

**Characteristics**: Names, dates, definitions, ingredients, components

**Strategy**: Break into atomic units, write more prompts than feels natural

**Example - Learning Recipe Components:**

❌ Poor approach:
```python
api.create_card(
    content="# What ingredients are in chocolate chip cookies?\n---\nFlour, butter, sugar, brown sugar, eggs, vanilla, baking soda, salt, chocolate chips",
    deck_id=deck_id
)
```

✅ Better approach - Create 5-8 focused cards:
```python
facts = [
    ("What is the primary dry ingredient in chocolate chip cookies?", "Flour"),
    ("What fat is used in chocolate chip cookies?", "Butter"),
    ("What two sweeteners are used in chocolate chip cookies?", "White sugar and brown sugar"),
    ("What provides structure in chocolate chip cookies?", "Eggs"),
    ("What flavoring extract is used in chocolate chip cookies?", "Vanilla"),
    ("What leavening agent makes cookies rise?", "Baking soda"),
    ("What balances sweetness in cookies?", "Salt"),
]

for question, answer in facts:
    api.create_card(
        content=f"# {question}\n---\n{answer}",
        deck_id=deck_id,
        manual_tags=["baking", "cookies", "recipes"]
    )
```

**Key principle**: Each card lights one specific "bulb" of understanding

### Lists (Closed vs Open)

**Closed lists** (fixed members like "7 continents"):
- Use cloze deletion - one card per missing element
- Keep order consistent across cards to build visual memory
- Example: "Africa, Antarctica, Asia, Australia, Europe, North America, __?" → "South America"

**Open lists** (evolving categories like "design patterns"):
- Don't memorize the whole list
- Create prompts linking instances to the category
- Write prompts about patterns within the category
- Example: "What design pattern does the Observer pattern belong to?" → "Behavioral patterns"

**Implementation:**
```python
# Closed list - continents
continents = ["Africa", "Antarctica", "Asia", "Australia", "Europe", "North America", "South America"]
for i, continent in enumerate(continents):
    others = ", ".join([c for j, c in enumerate(continents) if j != i])
    api.create_card(
        content=f"# Name all 7 continents\n---\n{others}, __{continent}__ (fill in the blank)",
        deck_id=deck_id,
        pos=chr(97 + i)  # 'a', 'b', 'c', etc. for ordering
    )

# Open list - design patterns
patterns = [
    ("Observer", "Behavioral"),
    ("Factory", "Creational"),
    ("Adapter", "Structural"),
]
for pattern, category in patterns:
    api.create_card(
        content=f"# What category does the {pattern} pattern belong to?\n---\n{category} patterns",
        deck_id=deck_id,
        manual_tags=["design-patterns", category.lower()]
    )
```

### Conceptual Knowledge (Understanding Ideas)

**Characteristics**: Principles, theories, mental models, frameworks

**Strategy**: Use multiple "lenses" to trace the edges of a concept

**The Five Conceptual Lenses:**

1. **Attributes and tendencies**: What's always/sometimes/never true?
2. **Similarities and differences**: How does it relate to adjacent concepts?
3. **Parts and wholes**: Examples, sub-concepts, categories
4. **Causes and effects**: What does it do? When is it used?
5. **Significance and implications**: Why does it matter personally?

**Example - Learning "Dependency Injection":**

```python
concept = "dependency injection"
deck_id = get_or_create_deck("Software Design Patterns")

# Lens 1: Attributes
api.create_card(
    content="# What is the core attribute of dependency injection?\n---\nDependencies are provided from outside rather than created internally",
    deck_id=deck_id,
    manual_tags=["dependency-injection", "attributes"]
)

# Lens 2: Similarities/Differences
api.create_card(
    content="# How does dependency injection differ from service locator?\n---\nDI pushes dependencies in, service locator pulls them out",
    deck_id=deck_id,
    manual_tags=["dependency-injection", "comparison"]
)

# Lens 3: Parts/Wholes
api.create_card(
    content="# Give one concrete example of dependency injection\n---\nPassing a database connection to a class constructor instead of creating it inside the class",
    deck_id=deck_id,
    manual_tags=["dependency-injection", "examples"]
)

# Lens 4: Causes/Effects
api.create_card(
    content="# What problem does dependency injection solve?\n---\nMakes code testable by allowing mock dependencies to be injected",
    deck_id=deck_id,
    manual_tags=["dependency-injection", "benefits"]
)

# Lens 5: Significance
api.create_card(
    content="# When would you use dependency injection in your work?\n---\nWhen writing testable APIs that need to swap database implementations or mock external services",
    deck_id=deck_id,
    manual_tags=["dependency-injection", "application"]
)
```

**Key principle**: Multiple angles create robust understanding resistant to forgetting

### Procedural Knowledge (How to Do Things)

**Characteristics**: Processes, workflows, algorithms, techniques

**Strategy**: Focus on transitions, timing, and rationale (not rote steps)

**Anti-pattern**: Don't create "step 1, step 2, step 3" cards - this encourages rote memorization

**Better approach**: Focus on:
- **Keywords**: Verbs, conditions, heuristics
- **Transitions**: When do you move from step X to Y?
- **Timing**: How long do things take? ("heads-up" information)
- **Rationale**: Why does each step matter?

**Example - Learning "How to Make Sourdough Bread":**

❌ Poor approach (rote steps):
```python
# Don't do this!
api.create_card(
    content="# What is step 1 in making sourdough?\n---\nMix flour and water",
    deck_id=deck_id
)
api.create_card(
    content="# What is step 2 in making sourdough?\n---\nLet it autolyse for 30 minutes",
    deck_id=deck_id
)
# ... etc - encourages mindless recitation
```

✅ Better approach (transitions and rationale):
```python
# Focus on transitions
api.create_card(
    content="# When do you know the autolyse phase is complete?\n---\nAfter 30-60 minutes when flour is fully hydrated",
    deck_id=deck_id,
    manual_tags=["sourdough", "transitions"]
)

# Focus on rationale
api.create_card(
    content="# Why do you autolyse before adding salt?\n---\nSalt inhibits gluten development; autolyse allows gluten to form first",
    deck_id=deck_id,
    manual_tags=["sourdough", "rationale"]
)

# Focus on timing/heads-up
api.create_card(
    content="# How long does bulk fermentation take for sourdough?\n---\n4-6 hours at room temperature (temperature-dependent)",
    deck_id=deck_id,
    manual_tags=["sourdough", "timing"]
)

# Focus on conditions
api.create_card(
    content="# What indicates sourdough is ready for shaping?\n---\n50-100% volume increase, jiggly texture, small bubbles on surface",
    deck_id=deck_id,
    manual_tags=["sourdough", "conditions"]
)
```

**Key principle**: Understand the *why* and *when*, not just the *what*

### Salience Prompts (Behavioral Change)

**Purpose**: Keep ideas "top of mind" to drive actual application, not just retention

**Use when**: You want to change behavior or apply knowledge, not just remember facts

**Strategy**: Create prompts around contexts where ideas might be meaningful

**Example - Applying "First Principles Thinking":**

```python
# Context-based application
api.create_card(
    content="# What's one situation this week where you could apply first principles thinking?\n---\n(Give an answer specific to your current work context - answer may vary)",
    deck_id=deck_id,
    manual_tags=["first-principles", "application"],
    review_reverse=False  # Don't review in reverse
)

# Implication-focused
api.create_card(
    content="# What's one assumption you're making in your current project that could be questioned?\n---\n(Identify a specific assumption - answer will vary)",
    deck_id=deck_id,
    manual_tags=["first-principles", "reflection"]
)

# Creative application
api.create_card(
    content="# Describe a way to apply first principles thinking you haven't mentioned before\n---\n(Novel answer each time - leverages generation effect)",
    deck_id=deck_id,
    manual_tags=["first-principles", "creative"]
)
```

**Key principle**: Extend the "Baader-Meinhof effect" where new knowledge feels salient and you notice it everywhere

**Warning**: Salience prompts are experimental. Standard retrieval prompts have stronger research backing.

### Interactive Card Creation

Guide users through card creation with clarifying questions when details are ambiguous. **Critically, always validate quality before creating cards.**

**Example user requests:**
- "Help me create some flashcards"
- "I want to study biology with Mochi"

**Implementation approach:**

1. **First, establish emotional connection:**
   - "What specifically do you want to remember from this material?"
   - "How does this connect to your work or goals?"
   - "What would success look like in 6 months?"
   - If user seems unmotivated or creating cards "because they should," push back gently

2. **Determine information needed:**
   - Which deck to add to (list existing or create new)
   - What type of knowledge (factual, conceptual, procedural, salience)
   - Card format (simple or template-based)
   - Content source (manual input, existing notes, conversation)
   - Tags and organization preferences

3. **Before creating ANY card, apply quality validation:**
   - Check against 5 properties (focused, precise, consistent, tractable, effortful)
   - Suggest breaking unfocused prompts into multiple cards
   - Identify and fix anti-patterns (binary questions, vague prompts, etc.)
   - Ask: "This prompt tests multiple details - should we break it into 3 separate cards?"

4. **Suggest knowledge-type appropriate patterns:**
   - For concepts: "I can create cards using the 5 conceptual lenses to give you robust understanding"
   - For procedures: "Instead of step-by-step cards, I'll focus on transitions and rationale"
   - For facts: "I'll break this into atomic prompts - expect 5-8 cards instead of 1"

5. **Create cards with quality commentary:**
   ```python
   # Show your reasoning
   print("Creating focused card: Tests ONE detail (what problem DI solves)")
   print("Precise: Asks specifically about testability benefit")
   print("Tractable: You should get this right ~90% of the time")

   api.create_card(
       content="# What problem does dependency injection solve?\n---\nMakes code testable by allowing mock dependencies",
       deck_id=deck_id,
       manual_tags=["design-patterns", "dependency-injection"]
   )
   ```

6. **Offer iteration and refinement:**
   - "I've created 5 cards covering attributes, examples, and significance. Would you like me to add more lenses?"
   - "This card might be too difficult - should I add a mnemonic cue?"
   - "Should I create salience prompts to help you apply this in your work?"

7. **Flag quality issues proactively:**
   - "I notice this prompt is unfocused - it asks about features AND drawbacks. Let me split it."
   - "This question is binary (yes/no). Let me rephrase as an open-ended question."
   - "This might be too trivial. Let me make it more effortful."

**Quality-First Workflow:**

```python
def create_card_with_validation(question: str, answer: str, deck_id: str) -> None:
    """Always validate before creating."""

    # Check 1: Focused?
    if " and " in question or len(answer.split(",")) > 2:
        print("⚠️  This prompt seems unfocused. Consider breaking into separate cards.")
        return

    # Check 2: Precise?
    vague_words = ["interesting", "important", "good", "tell me about"]
    if any(word in question.lower() for word in vague_words):
        print("⚠️  Question is vague. Be more specific about what you're asking.")
        return

    # Check 3: Binary?
    if question.strip().startswith(("Is ", "Does ", "Can ", "Will ")):
        print("⚠️  Binary question detected. Rephrase as open-ended.")
        return

    # Check 4: Pattern-matchable?
    if len(question) > 200:
        print("⚠️  Question is very long - might be answerable by pattern matching.")
        return

    # Validation passed - create the card
    api.create_card(
        content=f"# {question}\n---\n{answer}",
        deck_id=deck_id
    )
    print("✅ Card created (passed quality checks)")
```

**Remember**: Your job is to help create cards that *work* - not just cards that exist. Push back on poor quality prompts.

## Advanced Features

### Card Positioning

Control card order within decks using the `pos` field with lexicographic sorting:

```python
# Cards sort lexicographically by pos field
card1 = api.create_card(content="First card", deck_id=deck_id, pos="a")
card2 = api.create_card(content="Third card", deck_id=deck_id, pos="c")

# Insert between existing cards
card_between = api.create_card(content="Second card", deck_id=deck_id, pos="b")
```

### Tagging Strategies

Tags can be added inline in content or via `manual_tags`:

```python
# Inline tags in content
content = "# What is Python?\n---\nA programming language #python #programming"

# Manual tags (preferred for programmatic creation)
card = api.create_card(
    content="# What is Python?\n---\nA programming language",
    deck_id=deck_id,
    manual_tags=["python", "programming", "basics"]
)
```

Use manual tags when:
- Creating cards programmatically
- Tags don't fit naturally in content
- Maintaining clean card appearance
- Need to update tags separately from content

### Soft Delete vs Hard Delete

Prefer soft deletion for safety:

```python
# Soft delete (reversible)
from datetime import datetime
api.update_card(card_id, trashed=datetime.utcnow().isoformat())

# Undelete
api.update_card(card_id, trashed=None)

# Hard delete (permanent)
api.delete_card(card_id)  # Cannot be undone
```

### Pagination Handling

Handle pagination for large collections:

```python
def get_all_cards(deck_id):
    """Retrieve all cards from a deck, handling pagination."""
    all_cards = []
    bookmark = None

    while True:
        result = api.list_cards(deck_id=deck_id, limit=100, bookmark=bookmark)
        all_cards.extend(result["docs"])

        bookmark = result.get("bookmark")
        if not bookmark or not result["docs"]:
            break

    return all_cards
```

## Common Patterns

### Pattern: Topic Extraction

Extract topics from a document and create organized flashcards:

1. Identify main topics/sections
2. Create a deck for the subject
3. Create subdeck for each major topic
4. Generate cards from content within each topic
5. Tag cards with relevant concepts

### Pattern: Vocabulary Lists

Transform vocabulary lists into flashcards:

1. Create or reuse vocabulary template
2. Parse vocabulary source (spreadsheet, document, etc.)
3. Create cards using template fields
4. Group into appropriate decks by category/difficulty
5. Tag with language and proficiency level

### Pattern: Conversation Capture

Turn teaching moments from conversations into cards:

1. Review conversation history for explanations
2. Identify distinct concepts explained
3. Format as question/answer pairs
4. Create cards in relevant topic deck
5. Tag with context from conversation

## Error Handling

Handle API errors gracefully:

```python
from scripts.mochi_api import MochiAPIError

try:
    card = api.create_card(content=content, deck_id=deck_id)
except MochiAPIError as e:
    # Report specific error to user
    print(f"Failed to create card: {e}")
    # Possibly retry or ask for corrected input
```

Common errors:
- Missing required fields (content, deck-id)
- Invalid deck or template IDs
- Validation failures on field values
- Network connectivity issues

## Resources

### scripts/mochi_api.py

Complete Python client for the Mochi API. Provides classes and functions for:
- `MochiAPI`: Main client class with methods for all operations
- `create_card()`, `update_card()`, `delete_card()`: Card operations
- `create_deck()`, `update_deck()`, `delete_deck()`: Deck operations
- `create_template()`, `get_template()`, `list_templates()`: Template operations
- `list_cards()`, `list_decks()`: Listing with pagination support

Execute directly for command-line testing or import as a module for programmatic use.

### references/mochi_api_reference.md

Detailed API reference documentation including:
- Complete field type reference for templates
- Deck sort and view options
- Card content markdown syntax
- Positioning and tagging strategies
- Pagination details
- Error handling patterns
- Best practices for API usage

Consult this reference when:
- Creating complex templates with specialized field types
- Implementing advanced sorting or display options
- Handling edge cases or errors
- Optimizing API usage patterns
