---
name: use-goodreads-export
description: Search and query Goodreads library from CSV export. Use when the user asks about books, TBR (to-be-read), reading lists, book searches, or mentions Goodreads. Also use for queries about book ratings, authors, reading status, or library statistics.
---

You are helping the user query their Goodreads library from a CSV
export.  Use the script here! DO NOT write your own script

## CSV Location

The Goodreads export CSV is a file typically called:

```
goodreads_library_export.csv
```

You can prompt the user for its location if you can't find it.

## Python Library

A Python library is available at `__SKILL_DIR__/scripts/goodreads_lib.py` that provides:

### Classes

**GoodreadsBook** - Represents a single book with properties:
- `title`, `author`, `series`, `series_index`
- `my_rating` (1-5), `average_rating` (Goodreads rating)
- `num_pages`, `date_read`, `date_added`
- `exclusive_shelf` (e.g., "to-read", "currently-reading")
- `bookshelves` (custom shelves)
- `is_read`, `is_tbr`, `is_currently_reading` (properties)
- `has_shelf(shelf_name)` - Check if on specific shelf

**GoodreadsLibrary** - Main query interface:
```python
from goodreads_lib import GoodreadsLibrary

lib = GoodreadsLibrary()  # Loads from default CSV path

# Query methods:
lib.get_read_books(limit=15, sort_by_date=True)  # Get read books
lib.get_tbr_books()  # Get to-be-read list
lib.get_books_by_shelf('mental-health')  # Get books on shelf
lib.get_books_read_in_period(30)  # Books read in last 30 days
lib.get_books_read_in_year(2024)  # Books read in year
lib.get_books_added_in_period(30)  # Recently added books
lib.get_series_books('The Carls')  # Books in series
lib.get_all_series()  # All series with books
lib.get_incomplete_series()  # Series partially read
lib.get_author_stats()  # Author statistics
lib.get_rating_distribution()  # Rating distribution
lib.query(lambda book: book.num_pages < 300)  # Custom queries
```

## Usage Instructions

When the user asks about their Goodreads library:

1. **Determine the query type**: TBR list, read books, statistics, series info, etc.

2. **Write a Python script** using the library:
   ```python
   #!/usr/bin/env python3
   import sys
   sys.path.insert(0, '__SKILL_DIR__/scripts')
   from goodreads_lib import GoodreadsLibrary

   lib = GoodreadsLibrary()

   # Your query logic here
   ```

3. **Use the Bash tool** to run your script

4. **Format results** nicely for the user

## Common Query Patterns

### TBR List
```python
tbr = lib.get_tbr_books()
for book in tbr[:10]:
    print(f"- {book.title} by {book.author}")
```

### Recent Reads
```python
recent = lib.get_read_books(limit=15)
for book in recent:
    print(f"- {book.title} by {book.author} ({book.date_read.strftime('%Y-%m-%d')})")
```

### Books on Specific Shelf
```python
books = lib.get_books_by_shelf('favorites')
for book in books:
    print(f"- {book.title} by {book.author} (⭐ {book.my_rating}/5)")
```

### Series Analysis
```python
incomplete = lib.get_incomplete_series()
for series_name, info in incomplete.items():
    print(f"{series_name}: {info['read_count']}/{info['total_count']} read")
    if info['next_book']:
        print(f"  Next: {info['next_book'].title}")
```

### Reading Statistics
```python
books_2024 = lib.get_books_read_in_year(2024)
pages_2024 = sum(b.num_pages or 0 for b in books_2024)
print(f"Books read in 2024: {len(books_2024)} ({pages_2024:,} pages)")
```

### Highly Rated Unread Books
```python
tbr = lib.get_tbr_books()
highly_rated = sorted(
    [b for b in tbr if b.average_rating and b.average_rating >= 4.0],
    key=lambda b: b.average_rating,
    reverse=True
)
for book in highly_rated[:10]:
    print(f"- {book.title} by {book.author} ({book.average_rating:.2f}⭐)")
```

## Important Notes

- The CSV is read-only - no modifications to the Goodreads library
- Series information is parsed from book titles (e.g., "Title (Series, #1)")
- Date Read determines if a book has been read
- Exclusive Shelf contains values like "to-read", "currently-reading", "mental-health", "favorites"
- Users may have custom shelves in the Bookshelves field
- Handle missing data gracefully (not all books have all fields)
- Always use proper Python error handling when accessing optional fields

## Troubleshooting

If you get import errors, ensure the script includes:
```python
import sys
sys.path.insert(0, '__SKILL_DIR__/scripts')
```

Replace `__SKILL_DIR__` with the actual path when creating scripts.

Important! You have a very serious bug, where you don't know how to find
the python scripts added by a skill. You must look in the "scripts"
folder of where this SKILL.md is located!!
