---
name: calculator-helper
description: Performs mathematical calculations and conversions. Use when user asks to "calculate", "compute", "what is the result of", "convert units", or needs math help.
allowed-tools: [Read]
---

# Calculator Helper Skill

Automatically performs mathematical calculations, unit conversions, and numeric computations.

## When to Use

This skill activates when the user needs mathematical help:
- "Calculate 25% of 1500"
- "What is 145 * 23?"
- "Convert 100 kilometers to miles"
- "What's the compound interest on $1000 at 5% for 3 years?"

## Instructions

### Step 1: Identify the Calculation Type

Determine what kind of calculation is needed:
- **Arithmetic**: Basic operations (+, -, *, /)
- **Percentages**: Finding percentages, percentage change
- **Unit Conversions**: Length, weight, temperature, time
- **Financial**: Interest, currency, profit margins
- **Scientific**: Powers, roots, logarithms
- **Date/Time**: Time differences, date calculations

### Step 2: Perform the Calculation

**Basic Arithmetic:**
```
150 + 75 = 225
1000 - 234 = 766
45 * 12 = 540
100 / 4 = 25
```

**Percentages:**
```
25% of 200 = 50
200 increased by 15% = 230
Change from 50 to 75 = 50% increase
15 is what % of 60? = 25%
```

**Unit Conversions:**
```
Common conversions:
- 1 mile = 1.60934 kilometers
- 1 pound = 0.453592 kilograms
- 1 inch = 2.54 centimeters
- Celsius to Fahrenheit: (C × 9/5) + 32
- Fahrenheit to Celsius: (F - 32) × 5/9
```

**Financial Calculations:**
```
Simple Interest: Principal × Rate × Time
Compound Interest: Principal × (1 + Rate)^Time
Percentage Profit: (Profit / Cost) × 100
```

### Step 3: Show Clear Working

Always show:
1. **Understanding**: Restate the problem
2. **Formula**: Show the formula used (if applicable)
3. **Calculation**: Step-by-step working
4. **Result**: Clear final answer with units

### Step 4: Verify and Format

- Round to appropriate decimal places (usually 2 for money, 2-4 for measurements)
- Include units in the answer
- Double-check the math
- Provide context if helpful

## Examples

### Example 1: Basic Calculation

**User:** "What is 15% of 850?"

**Response:**
```
Calculating 15% of 850:

Method: (15/100) × 850
= 0.15 × 850
= 127.50

Answer: 127.50
```

### Example 2: Unit Conversion

**User:** "Convert 75 degrees Fahrenheit to Celsius"

**Response:**
```
Converting 75°F to Celsius:

Formula: (F - 32) × 5/9
= (75 - 32) × 5/9
= 43 × 5/9
= 215/9
= 23.89°C

Answer: 75°F = 23.89°C (approximately 24°C)
```

### Example 3: Financial Calculation

**User:** "If I invest $5000 at 6% compound interest for 3 years, how much will I have?"

**Response:**
```
Calculating compound interest:

Given:
- Principal (P) = $5,000
- Annual Rate (r) = 6% = 0.06
- Time (t) = 3 years

Formula: A = P(1 + r)^t
= 5000(1 + 0.06)^3
= 5000(1.06)^3
= 5000 × 1.191016
= $5,955.08

Answer: After 3 years, you'll have $5,955.08
Interest earned: $955.08
```

### Example 4: Complex Calculation

**User:** "My recipe serves 4 but I need it for 7 people. It calls for 2.5 cups of flour. How much do I need?"

**Response:**
```
Scaling recipe from 4 to 7 people:

Scale factor: 7 ÷ 4 = 1.75

Original flour: 2.5 cups
Scaled flour: 2.5 × 1.75 = 4.375 cups

Answer: You need 4.375 cups of flour (approximately 4⅜ cups)

Tip: This is closest to 4.5 cups (4½ cups) for easier measuring.
```

### Example 5: Percentage Change

**User:** "Sales went from 1,200 to 1,650. What's the percentage increase?"

**Response:**
```
Calculating percentage change:

Original: 1,200
New: 1,650
Change: 1,650 - 1,200 = 450

Formula: (Change / Original) × 100
= (450 / 1,200) × 100
= 0.375 × 100
= 37.5%

Answer: 37.5% increase in sales
```

## Common Conversions Reference

### Length
- 1 inch = 2.54 cm
- 1 foot = 30.48 cm
- 1 yard = 0.9144 m
- 1 mile = 1.60934 km

### Weight
- 1 ounce = 28.3495 g
- 1 pound = 453.592 g
- 1 ton (US) = 907.185 kg

### Volume
- 1 fluid oz (US) = 29.5735 ml
- 1 cup = 236.588 ml
- 1 pint (US) = 473.176 ml
- 1 gallon (US) = 3.78541 L

### Temperature
- C to F: (C × 9/5) + 32
- F to C: (F - 32) × 5/9
- C to K: C + 273.15

## Tips

### For Accuracy
- Use enough decimal places during calculation
- Round only the final answer
- State assumptions (e.g., "assuming 365 days/year")

### For Clarity
- Show your working
- Label all values with units
- Explain the formula if it's not obvious
- Provide context for the result

### For Usefulness
- Suggest rounded practical values when appropriate
- Point out if the result seems unusual
- Offer related calculations if helpful

## Common Calculation Types

### Business/Finance
- Profit margins
- Discounts and markups
- ROI (Return on Investment)
- Break-even analysis
- Percentage of total

### Science/Engineering
- Scientific notation
- Unit conversions
- Area and volume
- Speed and velocity
- Density calculations

### Everyday Math
- Tips and splitting bills
- Recipe scaling
- Time zone conversions
- Age calculations
- Date differences

## Remember

- **Double-check**: Math errors are easy to make
- **Show working**: Help users understand the process
- **Use appropriate precision**: Don't over-specify (e.g., $5.00 not $5.0000000)
- **Include units**: Always show what you're measuring
- **Provide context**: Explain if a result is unusually high/low
