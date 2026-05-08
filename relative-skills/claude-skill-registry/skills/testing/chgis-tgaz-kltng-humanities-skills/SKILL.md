---
name: chgis-tgaz
description: Query the China Historical GIS (CHGIS) Temporal Gazetteer (TGAZ) API to search for historical Chinese placenames from 222 BCE to 1911 CE. Use this skill when searching for information about historical Chinese places, administrative units, or geographic locations during the dynastic period. Applicable for queries about historical place names, administrative hierarchies, or when users mention specific Chinese locations with historical context.
version: 1.0.0
license: MIT
creator: AI
author: Kwok-leong Tang
contributors:
  - Claude (AI Assistant)
  - Z.ai (AI Platform)
---

# CHGIS TGAZ

## Overview

The CHGIS Temporal Gazetteer (TGAZ) skill enables querying the China Historical GIS database to search for historical Chinese placenames and administrative units from 222 BCE to 1911 CE. The API accepts UTF-8 encoded Chinese characters and Romanized transcriptions, making it accessible for searches in multiple languages.

## When to Use This Skill

Apply this skill when users:
- Search for historical Chinese placenames or locations
- Ask about administrative units during China's dynastic period
- Need to verify historical place names or their spellings
- Request information about administrative hierarchies (provinces, prefectures, counties)
- Inquire about places that existed during specific historical years
- Need to identify modern equivalents of historical placenames
- Research geographic locations mentioned in historical texts

## Core Capabilities

### 1. Placename Search by Name

Search for places using Chinese characters or Romanized names.

**When to use:** User provides a place name and wants to find matching records.

**Basic approach:**
```python
import requests

# Basic search
url = "https://chgis.hudci.org/tgaz/placename"
params = {
    "n": "beijing",      # or "北京"
    "fmt": "json"
}
response = requests.get(url, params=params)
data = response.json()
```

**Example user requests:**
- "Find information about Beijing in the CHGIS database"
- "Search for the place called 苏州 in Chinese history"
- "What records exist for Hangzhou?"

### 2. Historical Year-Specific Searches

Search for places as they existed in a specific historical year.

**When to use:** User specifies or implies a particular time period.

**Approach:**
```python
# Search with specific year
params = {
    "n": "suzhou",
    "yr": "1820",       # Use negative for BCE: "-100"
    "fmt": "json"
}
response = requests.get(url, params=params)
```

**Example user requests:**
- "What was the administrative status of Nanjing in 1750?"
- "Find counties in Zhejiang province in the year 1850"
- "Search for places named Chang'an during the Tang dynasty" (would need approximate year like 750)

**Important:** The valid year range is -222 to 1911 (222 BCE to 1911 CE).

### 3. Feature Type Filtering

Search for specific types of administrative units.

**When to use:** User asks about a specific administrative level or type.

**Approach:**
```python
# Search for a specific administrative type
params = {
    "n": "suzhou",
    "yr": "1820",
    "ftyp": "fu",      # Superior prefecture
    "fmt": "json"
}
response = requests.get(url, params=params)
```

**Common feature types:**
- `xian` (县) - County
- `zhou` (州) - Prefecture
- `fu` (府) - Superior prefecture
- `sheng` (省) - Province
- `dao` (道) - Circuit
- `lu` (路) - Route
- `jun` (郡) - Commandery

**Example user requests:**
- "Find all counties (xian) named Anqing"
- "What prefectures existed in 1650?"
- "Search for superior prefectures (fu) in Jiangsu"

### 4. Hierarchical Searches

Search for places within a specific parent administrative unit.

**When to use:** User specifies a place within a broader geographic region.

**Approach:**
```python
# Search within a parent unit
params = {
    "n": "ningbo",
    "ipar": "zhejiang",  # Immediate parent
    "yr": "1850",
    "fmt": "json"
}
response = requests.get(url, params=params)
```

**Example user requests:**
- "Find places named Xiaoshan in Zhejiang province"
- "What counties were in Yunnan in 1800?"
- "Search for administrative units under Jiangnan"

### 5. Retrieve Specific Records by ID

Fetch a complete record when the unique TGAZ ID is known.

**When to use:** User provides or you've discovered a specific TGAZ ID.

**Approach:**
```python
# Retrieve specific record
tgaz_id = "hvd_32180"
url = f"https://chgis.hudci.org/tgaz/placename/{tgaz_id}"
params = {"fmt": "json"}
response = requests.get(url, params=params)
```

**ID format:** TGAZ IDs use the prefix `hvd_` (e.g., CHGIS ID 32180 becomes TGAZ ID hvd_32180)

## Search Strategy Best Practices

### Start Broad, Then Narrow

Begin with simple queries and add parameters progressively:

1. **First attempt:** Basic placename only
   ```python
   params = {"n": "guangzhou", "fmt": "json"}
   ```

2. **If too many results:** Add year
   ```python
   params = {"n": "guangzhou", "yr": "1820", "fmt": "json"}
   ```

3. **If still ambiguous:** Add feature type or parent
   ```python
   params = {"n": "guangzhou", "yr": "1820", "ftyp": "fu", "fmt": "json"}
   ```

### Handling Chinese Characters

**Always use UTF-8 encoding directly:**
- ✅ Correct: `"n": "北京"`
- ❌ Wrong: URL-encoding Chinese characters

**The API accepts both Chinese and Romanized names:**
- `"n": "beijing"` and `"n": "北京"` both work
- Try both if one doesn't return expected results

### Format Preferences

**Always request JSON format** for easier parsing:
```python
params = {"n": "place_name", "fmt": "json"}
```

Without `fmt=json`, the API returns XML by default.

## Interpreting Results

### Multiple Results

Faceted searches often return multiple records because:
- Places had the same name in different locations
- Administrative status changed over time
- Names were reused across different periods

**Approach:** Present all relevant results to the user or ask for clarification.

### Understanding Historical Context

Records include:
- **Begin/end dates** showing when the placename was valid
- **Administrative hierarchy** showing parent-child relationships
- **Multiple spellings** in different languages/transcriptions
- **Geographic coordinates** for mapping

### No Results

If a search returns no results, try:
1. Alternative spellings or transcriptions
2. Broader search (remove year or feature type constraints)
3. Search in Chinese characters if using Romanization (or vice versa)
4. Verify the year is within valid range (-222 to 1911)

## Common Patterns

### Pattern 1: Historical Research Query

User asks about a place in a historical context.

```python
# Example: "What was Yangzhou during the Qing dynasty?"
params = {
    "n": "yangzhou",
    "yr": "1750",  # Mid-Qing approximate year
    "fmt": "json"
}
```

### Pattern 2: Administrative Hierarchy Query

User wants to understand administrative structure.

```python
# Example: "What were the counties in Jiangsu in 1850?"
# First get Jiangsu, then search with it as parent
params = {
    "n": "jiangsu",
    "yr": "1850",
    "ftyp": "sheng",
    "fmt": "json"
}

# Then search for counties
params = {
    "ipar": "jiangsu",
    "yr": "1850",
    "ftyp": "xian",
    "fmt": "json"
}
```

### Pattern 3: Verification Query

User wants to verify a place name or identification.

```python
# Example: "Is this the correct ID for Beijing?"
tgaz_id = "hvd_12345"
url = f"https://chgis.hudci.org/tgaz/placename/{tgaz_id}"
params = {"fmt": "json"}
```

## Resources

### API Reference Documentation

Detailed API specifications, query parameters, and examples are available in:
- `references/api_reference.md` - Complete API documentation

**When to read the reference:** 
- When encountering unfamiliar query patterns
- For complete list of feature types
- When needing detailed parameter specifications
- For troubleshooting response formats

## Example Code Template

```python
import requests

def search_tgaz(placename, year=None, feature_type=None, parent=None):
    """
    Search CHGIS TGAZ for historical placenames.
    
    Args:
        placename: Name of place (Chinese or Romanized)
        year: Historical year (-222 to 1911)
        feature_type: Admin type (xian, fu, zhou, etc.)
        parent: Parent administrative unit
    
    Returns:
        JSON response from API
    """
    url = "https://chgis.hudci.org/tgaz/placename"
    
    params = {"n": placename, "fmt": "json"}
    
    if year:
        params["yr"] = str(year)
    if feature_type:
        params["ftyp"] = feature_type
    if parent:
        params["ipar"] = parent
    
    response = requests.get(url, params=params)
    response.raise_for_status()
    
    return response.json()

def get_placename_by_id(tgaz_id):
    """
    Retrieve specific placename record by TGAZ ID.
    
    Args:
        tgaz_id: TGAZ unique identifier (format: hvd_XXXXX)
    
    Returns:
        JSON response from API
    """
    url = f"https://chgis.hudci.org/tgaz/placename/{tgaz_id}"
    params = {"fmt": "json"}
    
    response = requests.get(url, params=params)
    response.raise_for_status()
    
    return response.json()

# Example usage
results = search_tgaz("beijing", year=1800)
specific_record = get_placename_by_id("hvd_32180")
```

## Tips for Effective Use

1. **Default to JSON format** - Always include `"fmt": "json"` for easier parsing
2. **Start simple** - Begin with just the placename, add filters if needed
3. **Consider time period** - Historical names changed; try different years
4. **Try both scripts** - Search in both Chinese characters and Romanization
5. **Check valid years** - Ensure years are within -222 to 1911
6. **Present options** - When multiple results exist, show them to the user
7. **Explain context** - Help users understand why multiple records exist
8. **Handle errors gracefully** - No results doesn't mean wrong query; try variations
