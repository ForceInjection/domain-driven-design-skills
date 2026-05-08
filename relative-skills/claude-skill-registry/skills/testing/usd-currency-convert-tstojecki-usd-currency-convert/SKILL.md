---
name: usd-currency-convert
description: Convert USD amounts to foreign currencies (EUR, PLN, AUD) using historical exchange rates. Use this skill when users ask to convert dollar amounts to other currencies for a specific date, or when they need historical currency exchange rates.
license: Apache-2.0
---

# USD Currency Converter

Convert US Dollar amounts to foreign currencies using historical exchange rate data from official central banks.

## When to use this skill

Use this skill whenever the user asks to:
- Convert a USD amount to another currency
- Get the exchange rate for a specific date
- Convert multiple USD amounts with different dates
- Check what currencies are supported
- Find out the available date range for exchange rates

**Trigger keywords**: currency conversion, convert dollars, USD to EUR, USD to PLN, USD to AUD, exchange rate, convert USD, foreign currency

## Supported Currencies

- **EUR** (Euro) - from ECB (2010-present)
- **PLN** (Polish Zloty) - from NBP (2012-present)
- **AUD** (Australian Dollar) - from RBA (2010-present)

## How to use this skill

### Step 1: Validate the Request

Check if the request includes:
- **Amount in USD** (e.g., $1500, 1500 USD, or just 1500)
- **Target currency** (EUR, PLN or AUD)
- **Date** (any common format - will be normalized to YYYY-MM-DD)

If any information is missing, ask the user for clarification.

### Step 2: Run the Conversion Script

Execute the conversion script with the appropriate arguments:

```bash
python scripts/convert.py <amount> <currency> <date>
```

**Examples:**
```bash
# Convert $250 to EUR on March 20, 2024
python scripts/convert.py 250 EUR 2024-03-20

# Convert $1500 to PLN on January 15, 2025
python scripts/convert.py 1500 PLN 2025-01-15

# Convert $1000 to AUD on December 1, 2024
python scripts/convert.py 1000 AUD 2024-12-01
```

### Step 3: Interpret the Response

The script returns JSON with either a successful conversion or an error:

**Success Response:**
```json
{
  "status": "success",
  "amount_usd": 1500.0,
  "converted_amount": 5896.85,
  "currency": "PLN",
  "rate": 3.9312,
  "rate_date": "2025-01-14",
  "requested_date": "2025-01-15"
}
```

**Error Response:**
```json
{
  "status": "error",
  "error": "Currency XYZ not supported. Available currencies: EUR, PLN, AUD",
  "available_currencies": ["EUR", "PLN", "AUD"]
}
```

### Step 4: Present Results to User

Format the successful conversion in a clear, user-friendly way:

**Good presentation:**
> **$1,500 USD = 5,896.85 PLN**
>
> Exchange rate: 3.9312 (as of January 14, 2025)
>
> Note: The exact date you requested (January 15) wasn't available, so I used the most recent rate from January 14.

**For errors**, explain the issue and suggest alternatives:
> I couldn't complete the conversion because the currency "XYZ" is not supported yet.
>
> Currently supported currencies:
> - PLN (Polish Złoty)
> - EUR (Euro)
> - AUD (Australian Dollar)

## Checking Available Currencies

To see what currencies are available and their date ranges:

```bash
python scripts/convert.py --list
```

This returns:
```json
{
  "status": "success",
  "currencies": {
    "PLN": {
      "earliest_date": "2012-01-02",
      "latest_date": "2025-10-24",
      "total_days": 3301
    },
    "EUR": {
      "earliest_date": "2010-01-04",
      "latest_date": "2025-10-24",
      "total_days": 3969
    },
    "AUD": {
      "earliest_date": "2010-01-04",
      "latest_date": "2025-10-24",
      "total_days": 3969
    }
  }
}
```

## Handling Edge Cases

### Missing Exact Date

If the exact date isn't available, the script automatically searches backwards to find the most recent rate. Always inform the user when the rate date differs from their requested date.

### Date Out of Range

If the date is too early or too late:
```json
{
  "status": "error",
  "error": "No exchange rate found for PLN on 2010-01-01. Earliest available rate: 2012-01-02",
  "requested_date": "2010-01-01",
  "earliest_date": "2012-01-02",
  "currency": "PLN"
}
```

Tell the user the available date range and ask if they want to use a different date.

### Unsupported Currency

If the currency isn't supported, list the available currencies and ask if they meant one of those.

## Multiple Conversions

For multiple conversions, run the script multiple times and present the results in a table format:

| Amount (USD) | Currency | Date | Converted Amount | Rate |
|-------------|----------|------|------------------|------|
| $250 | EUR | 2025-01-15 | 232.50 EUR | 0.9300 |
| $1,500 | PLN | 2025-01-15 | 5,896.85 PLN | 3.9312 |
| $1,000 | AUD | 2025-01-15 | 1,450.00 AUD | 1.4500 |

## Technical Details

### Rate Data Organization

Exchange rates are stored in CSV files organized by central bank and year:
- `rates/ECB/` - EUR rates from European Central Bank
- `rates/NBP/` - PLN rates from Narodowy Bank Polski (Polish Central Bank)
- `rates/RBA/` - AUD rates from Reserve Bank of Australia

Directory names use central bank codes (NBP, ECB, RBA) to indicate the authoritative source.

### Backwards Date Search

When an exact date isn't found, the script searches backwards up to 30 days to find the most recent available rate. This ensures:
- Weekend dates use Friday's rate
- Holiday dates use the most recent trading day
- Gaps in data don't cause failures

## Error Recovery

If you encounter an error:

1. **Check the error message** for specific guidance
2. **Verify the inputs** (amount, currency, date)
3. **Use `--list` flag** to see available currencies and dates
4. **Try a different date** if the requested date is out of range
5. **Ask the user** for clarification if the error is unclear
