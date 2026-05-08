---
name: family-menu
description: Creates beautiful, protein-focused weekly dinner menus for families with research capabilities. Generates printer-ready PDFs (8.5x11) with random design styles, identifies leftover opportunities, suggests local restaurants, emphasizes seasonal ingredients, and includes Homemade Pizza Fridays. Use when users want to plan family dinners, create refrigerator menus, or need meal planning assistance.
---

# Family Menu Generator

This skill creates beautiful, research-backed weekly dinner menus designed for families, with a focus on high-protein meals, seasonal ingredients, and practical leftover planning.

## Key Features

- **Protein-focused meals**: Every meal emphasizes protein sources
- **Leftover detection**: Automatically identifies opportunities to use leftovers
- **Local restaurant suggestions**: Searches for restaurants within 25 miles of user's location
- **Homemade Pizza Fridays**: Periodically includes fun pizza nights
- **Seasonal ingredients**: Researches and incorporates seasonal produce
- **Random beautiful designs**: 5 different design styles (fun & colorful, clean & modern, rustic, elegant, bold & playful)
- **Print-ready PDFs**: Optimized for 8.5x11 paper to post on refrigerator

## Workflow

### 1. Gather Information

When a user requests a menu, first determine what ingredients or preferences they have:

**Ask the user:**
- "Do you have any ingredients on hand that you'd like me to incorporate into this week's menu?"
- "Any dietary restrictions or preferences I should know about?"
- "Any meals you're craving this week?"

**If the user doesn't provide specific ingredients:** Assume all ingredients will be purchased from the grocery store and proceed with planning.

### 2. Research Phase

Use web search to gather information:

**Seasonal Ingredients:**
- Search for current seasonal produce and proteins (consider the current month)
- Example: "seasonal vegetables October" or "fall produce in season"

**Recipe Ideas:**
- Search for high-protein recipes incorporating seasonal ingredients
- Example: "high protein chicken recipes with butternut squash"
- Look for recipes with prep times and protein content

**Restaurant Options:**
- Search for restaurants near the user's zip code (20136 for this user)
- Use local search: "restaurants near 20136" or "best dinner restaurants Centreville VA"
- Select one interesting option within 25 miles for restaurant night

**Leftover Assessment:**
- When planning, identify meals that will likely produce leftovers based on:
  - Large batch recipes (roasts, casseroles, soups)
  - Recipes that serve 4-6+ people
  - Meals that reheat well
- Schedule a "leftovers" meal 1-2 days after these large meals

### 3. Menu Planning

Create a 7-day dinner menu following these guidelines:

**Monday-Thursday:**
- Focus on variety of proteins (chicken, beef, fish, pork, turkey)
- Include prep times
- Note the primary protein source
- Consider cooking methods variety

**Friday:**
- Every 2-3 weeks: "Homemade Pizza Friday 🍕"
- Other Fridays: Regular protein-focused meals

**Saturday:**
- Restaurant night approximately once per week
- Include the restaurant name and a brief note
- Example: "Restaurant Night - Try the new Thai place on Main Street"

**Sunday:**
- Often a good day for slow-cooker meals or batch cooking
- Meals that can provide leftovers for the week ahead

**Leftover Days:**
- Explicitly mark 1-2 days as using leftovers from specific previous meals
- Example: "Monday Leftovers - Use remaining pot roast and vegetables"

### 4. Generate the PDF

Use the `scripts/generate_menu.py` script to create the PDF:

```python
from scripts.generate_menu import create_menu_pdf
import datetime

menu_data = {
    'title': 'Family Dinner Menu',
    'subtitle': f'Week of {datetime.datetime.now().strftime("%B %d, %Y")}',
    'meals': [
        {
            'day': 'Monday',
            'name': 'Grilled Salmon with Roasted Brussels Sprouts',
            'protein': 'Salmon fillet (6oz)',
            'prep_time': '30 min',
            'notes': 'Seasonal fall vegetables'
        },
        {
            'day': 'Tuesday',
            'name': 'Monday Leftovers',
            'notes': 'Use remaining salmon and veggies'
        },
        # ... continue for all 7 days
    ]
}

# The function will randomly select a design style
design_used = create_menu_pdf(menu_data, output_path)
```

**Menu Data Structure:**
- `title`: Menu title (usually "Family Dinner Menu" or similar)
- `subtitle`: Date range for the week
- `meals`: List of meal objects with:
  - `day`: Day of the week (required)
  - `name`: Meal name (required)
  - `protein`: Primary protein source (optional but recommended)
  - `prep_time`: Estimated cooking time (optional)
  - `notes`: Special notes like "leftover", "seasonal", "restaurant info" (optional)

### 5. Present to User

After generating the menu:

1. Show the user a text summary of the week's meals
2. Provide the PDF link for download
3. Mention which design style was randomly selected
4. Offer to regenerate if they want a different design style

## Tips for Great Menus

- **Balance cooking complexity**: Mix quick meals with more involved ones
- **Protein variety**: Try to avoid repeating the same protein more than twice
- **Leftover strategic placement**: Place leftover days 1-2 days after big meals
- **Seasonal excitement**: Highlight when you're using seasonal ingredients
- **Restaurant selection**: Choose restaurants with good reviews and variety
- **Pizza frequency**: Aim for 1-2 pizza nights per month
- **Batch cooking**: Sunday is often ideal for slow cooker or big batch meals

## Available Design Styles

The script randomly selects from these designs:
1. **Fun and Colorful**: Bright, playful colors perfect for families with kids
2. **Clean and Modern**: Minimalist with bold typography
3. **Rustic**: Warm earth tones with serif fonts
4. **Elegant**: Sophisticated with gold accents
5. **Bold and Playful**: Vibrant colors with fun fonts

All designs are optimized for 8.5x11 inch paper and include the meal details in an easy-to-read format.

## Resources

### scripts/generate_menu.py
The main PDF generation script that creates beautiful menus with random design styles. Uses ReportLab library and the bundled fonts.

### assets/fonts/
Collection of 36+ fonts used for different design styles, including Poppins, Montserrat, PlayfairDisplay, FredokaOne, Satisfy, Lora, and DejaVu font families.

## User Location

Default zip code: 20136 (Centreville, Virginia)
- Use this for restaurant searches
- 25-mile radius for restaurant recommendations
