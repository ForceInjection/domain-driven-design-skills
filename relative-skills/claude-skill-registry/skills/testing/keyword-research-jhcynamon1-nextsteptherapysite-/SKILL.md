---
name: keyword-research
description: Identify high-value, low-competition keywords for Ontario therapy practice. Analyzes Ahrefs/GSC data to find opportunities, calculates priority scores (volume + difficulty + intent), identifies quick wins under difficulty 40, detects cannibalization risks, maps keywords to content types, and suggests topic clusters. Use when user asks "what keywords should I target", mentions "keyword research", provides Ahrefs data, or when planning content strategy.
---

# Keyword Research & Opportunity Finder

## Purpose
Identify high-value keyword opportunities for NextStep Therapy that balance search volume, difficulty, and business value, with focus on Ontario therapy market.

## When to Use This Skill
- User asks "what keywords should I target?"
- User mentions "keyword research" or "keyword opportunities"
- User provides Ahrefs or GSC data
- Planning new content or pages
- Prioritizing SEO efforts for quarter/month

## Research Foundation

### 2024 Therapy Keyword Insights

**Key Statistics:**
- 3+ million monthly searches for therapy-related terms in North America
- 70% of new patients find therapists via internet search
- Keywords with difficulty < 40 are achievable for newer sites
- Long-tail keywords (4+ words) have higher conversion rates
- Location-based keywords are critical for local practices

**Optimal Difficulty Ranges:**
| Site Authority | Target Difficulty | Notes |
|----------------|-------------------|-------|
| New (< 1 year) | 0-30 | Focus on long-tail, local |
| Growing (1-3 years) | 20-45 | Mix of quick wins and stretch goals |
| Established (3+ years) | 30-60 | Can target competitive terms |

**Sources:**
- [Keyword Research 2024](https://content-whale.com/us/blog/keyword-research-2024-hidden-gems/)
- [Keyword Difficulty Guide](https://www.semrush.com/blog/keyword-difficulty/)
- [SEO Keywords for Therapists](https://mytherapyflow.com/seo-keywords-for-therapists/)

---

## Data Request Template

**Always ask user for this data:**

```
To provide expert-level keyword recommendations, I need:

1. AHREFS DATA (if available):
   - Keyword Explorer export for seed keywords
   - Keyword difficulty scores
   - Search volume (monthly)
   - Parent topic data
   - SERP features present

2. GSC DATA (if available):
   - Queries report (last 3-6 months)
   - Pages report with avg position
   - Impressions, clicks, CTR by query

3. COMPETITOR DATA:
   - Top 3-5 competitor domains
   - Ahrefs organic keywords report for competitors

4. BUSINESS CONTEXT:
   - Primary services to promote
   - Target cities/regions
   - Existing top-performing pages
   - Seasonal considerations
```

---

## Quick Start Workflow

### Step 1: Gather & Categorize Seed Keywords

**Therapy Practice Keyword Categories:**

| Category | Examples | Volume Range | Difficulty Range |
|----------|----------|--------------|------------------|
| **Condition + Service** | "anxiety therapy", "depression treatment" | High (1000+) | High (50+) |
| **Condition + Location** | "anxiety therapy toronto" | Medium (100-500) | Medium (30-50) |
| **Treatment Modality** | "ACT therapy", "CBT counseling" | Medium (100-500) | Medium-High (40-60) |
| **Audience Specific** | "university student anxiety", "executive stress" | Low-Medium (50-200) | Low (10-30) |
| **Question/Long-tail** | "how to find a therapist in ontario" | Low (10-100) | Very Low (0-20) |
| **Local Intent** | "therapist near me", "virtual therapy ontario" | High (500+) | Medium-High (40-55) |

### Step 2: Priority Score Calculation

**Formula:**
```
Priority Score = (Volume Score × 0.30) + (Difficulty Score × 0.35) +
                 (Intent Score × 0.20) + (Business Value × 0.15)

Where:
- Volume Score: 0-100 (normalized from search volume)
- Difficulty Score: 100 - keyword_difficulty (inverted, lower KD = higher score)
- Intent Score: 0-100 (transactional = 100, informational = 50)
- Business Value: 0-100 (core service = 100, tangential = 50)
```

**Score Interpretation:**
| Score | Priority | Action |
|-------|----------|--------|
| 80-100 | Highest | Target immediately |
| 60-79 | High | Target in next 30 days |
| 40-59 | Medium | Build topic cluster around |
| 20-39 | Low | Long-term roadmap |
| 0-19 | Lowest | Deprioritize or ignore |

### Step 3: Identify Quick Wins

**Quick Win Criteria:**
- Difficulty < 40
- Volume > 50/month
- Clear commercial/transactional intent
- Relevant to core services
- No cannibalization with existing pages

**Quick Win Template:**
```
QUICK WIN OPPORTUNITY:
Keyword: [keyword]
Volume: [monthly searches]
Difficulty: [KD score]
Priority Score: [calculated score]
Current Ranking: [if any]
Recommended Page Type: [service/location/blog]
Estimated Time to Rank: [30/60/90 days]
```

### Step 4: Cannibalization Check

**Critical for therapy sites with multiple location pages:**

Before targeting any keyword:
1. Search GSC for query matches
2. Check if multiple pages rank for same term
3. Identify which page has highest authority
4. Consolidate or differentiate

**Cannibalization Detection:**
```
Search: site:nextsteptherapy.ca "target keyword"

If 2+ pages appear:
- Analyze which ranks higher
- Check search intent alignment
- Decide: consolidate or differentiate
```

**Common Cannibalization Issues:**
| Issue | Solution |
|-------|----------|
| Multiple city pages ranking for provincial keyword | Strengthen pillar page, adjust city page focus |
| Blog post competing with service page | Consolidate or adjust blog focus |
| Old page competing with new page | 301 redirect old to new if new is better |

### Step 5: Map Keywords to Content

**Keyword-to-Content Mapping:**

| Intent Type | Page Type | Example |
|-------------|-----------|---------|
| **Commercial** (high intent) | Service page | "anxiety therapy toronto" |
| **Navigational** | Homepage or About | "nextstep therapy" |
| **Informational** | Blog post | "how to cope with anxiety" |
| **Transactional** | Booking/Contact | "book therapy appointment online" |

**Topic Cluster Assignment:**
```
PILLAR: anxiety-therapy-ontario.html
  ├── CLUSTER: anxiety-therapy-toronto.html (location)
  ├── CLUSTER: anxiety-therapy-burlington.html (location)
  ├── CLUSTER: students/university-anxiety.html (audience)
  ├── CLUSTER: professionals/work-anxiety.html (audience)
  └── CLUSTER: blog/5-ways-manage-anxiety.html (informational)
```

---

## Ontario Therapy Keyword Database

### Condition Keywords (High Value)

**Anxiety:**
| Keyword | Est. Volume | Difficulty | Notes |
|---------|-------------|------------|-------|
| anxiety therapy ontario | 500+ | 45-55 | Main pillar target |
| anxiety therapist near me | 300+ | 50-60 | Local intent |
| anxiety treatment toronto | 200+ | 40-50 | City-specific |
| therapy for anxiety and depression | 400+ | 45-55 | Dual condition |
| virtual anxiety therapy | 150+ | 30-40 | Service format |

**Depression:**
| Keyword | Est. Volume | Difficulty | Notes |
|---------|-------------|------------|-------|
| depression therapy ontario | 400+ | 45-55 | Main pillar target |
| therapist for depression | 250+ | 50-60 | General query |
| depression counseling near me | 200+ | 45-55 | Local intent |
| online depression therapy | 100+ | 30-40 | Service format |

**Trauma/PTSD:**
| Keyword | Est. Volume | Difficulty | Notes |
|---------|-------------|------------|-------|
| trauma therapy ontario | 150+ | 35-45 | Lower competition |
| ptsd therapist | 100+ | 40-50 | Specific condition |
| trauma-informed therapy | 100+ | 30-40 | Approach-focused |

### Audience Keywords (Lower Competition)

**Students:**
| Keyword | Est. Volume | Difficulty | Notes |
|---------|-------------|------------|-------|
| university student anxiety | 50-100 | 15-25 | Quick win |
| college student counseling | 50-100 | 20-30 | Quick win |
| academic stress therapy | 30-50 | 10-20 | Quick win |
| first year university anxiety | 20-50 | 10-20 | Very low comp |

**Professionals:**
| Keyword | Est. Volume | Difficulty | Notes |
|---------|-------------|------------|-------|
| executive stress therapy | 30-50 | 15-25 | Quick win |
| work anxiety therapy | 50-100 | 20-30 | Quick win |
| burnout therapist | 50-100 | 25-35 | Quick win |
| career anxiety counseling | 20-50 | 15-25 | Quick win |

### Location Keywords

**Major Cities:**
| Location | Format | Est. Difficulty |
|----------|--------|-----------------|
| Toronto | [condition] therapy toronto | 45-55 |
| Ottawa | [condition] therapist ottawa | 35-45 |
| Mississauga | therapy [condition] mississauga | 30-40 |
| Hamilton | [condition] counseling hamilton | 25-35 |
| London | therapist [condition] london ontario | 25-35 |

**Smaller Cities (Quick Wins):**
| Location | Format | Est. Difficulty |
|----------|--------|-----------------|
| Burlington | anxiety therapy burlington | 20-30 |
| Oshawa | depression therapist oshawa | 15-25 |
| Kitchener | anxiety counseling kitchener | 20-30 |
| Sudbury | therapy sudbury ontario | 15-25 |
| Barrie | therapist barrie ontario | 15-25 |

---

## Analysis Output Template

```markdown
# Keyword Research Analysis
Date: [Today's date]
Data Sources: [Ahrefs, GSC, etc.]

## Executive Summary
- Total keywords analyzed: [X]
- Quick wins identified: [X]
- Highest priority opportunities: [X]
- Cannibalization issues found: [X]

## Priority Opportunities

### Tier 1: Quick Wins (Target Now)
| Keyword | Volume | Difficulty | Priority Score | Page Type |
|---------|--------|------------|----------------|-----------|
| [keyword] | [vol] | [KD] | [score] | [type] |

### Tier 2: High Value (Next 30 Days)
| Keyword | Volume | Difficulty | Priority Score | Page Type |
|---------|--------|------------|----------------|-----------|
| [keyword] | [vol] | [KD] | [score] | [type] |

### Tier 3: Build Clusters (60-90 Days)
| Pillar Keyword | Cluster Keywords | Total Opportunity |
|----------------|------------------|-------------------|
| [pillar] | [clusters] | [combined volume] |

## Cannibalization Issues

| Keyword | Competing Pages | Recommended Action |
|---------|-----------------|-------------------|
| [keyword] | [pages] | [action] |

## Topic Cluster Recommendations

### Cluster 1: [Topic]
- Pillar: [page]
- Clusters: [list]
- Internal linking plan: [brief]

## Content Calendar Recommendations

### Month 1:
1. [Page type]: "[Title]" targeting [keyword]
2. [Page type]: "[Title]" targeting [keyword]

### Month 2:
1. [Page type]: "[Title]" targeting [keyword]
2. [Page type]: "[Title]" targeting [keyword]

## Next Steps
1. [Action item]
2. [Action item]
3. [Action item]
```

---

## Cannibalization Deep Dive

### How to Detect

**Method 1: GSC Query Analysis**
1. Export Queries report
2. Filter by query containing target keyword
3. If multiple pages appear for same query = cannibalization

**Method 2: Site Search**
```
site:nextsteptherapy.ca "anxiety therapy"
```
If 5+ results, you may have cannibalization.

**Method 3: Ahrefs Keywords Report**
1. Run site audit
2. Check "cannibalization" report
3. Review overlapping keywords

### How to Fix

| Scenario | Fix |
|----------|-----|
| Two strong pages | Keep both, differentiate intent |
| One strong, one weak | 301 redirect weak → strong |
| Multiple location pages cannibalize pillar | Add unique local content, strengthen pillar |
| Blog post vs service page | Consolidate or add canonical |

---

## Special Considerations for Therapy Keywords

### YMYL Implications
- Therapy keywords are YMYL (Your Money Your Life)
- Google applies higher scrutiny
- E-E-A-T signals critical for ranking
- New sites need stronger authority signals

### Seasonal Trends
| Season | Trending Keywords |
|--------|-------------------|
| Jan-Feb | New year anxiety, SAD, motivation |
| Mar-Apr | Spring anxiety, academic stress (finals) |
| Aug-Sep | Back to school, university anxiety |
| Nov-Dec | Holiday stress, seasonal depression, loneliness |

### Competitor Intelligence
Request from user:
```
Can you export Ahrefs organic keywords for these competitors:
1. [competitor 1]
2. [competitor 2]
3. [competitor 3]

I'll analyze which keywords they rank for that we don't.
```

---

## Sources

**Keyword Research:**
- [Keyword Research 2024 Hidden Gems](https://content-whale.com/us/blog/keyword-research-2024-hidden-gems/)
- [SEO Keywords for Therapists](https://mytherapyflow.com/seo-keywords-for-therapists/)
- [Keyword Difficulty Explained](https://www.semrush.com/blog/keyword-difficulty/)

**Cannibalization:**
- [Keyword Cannibalization Guide (SEMrush)](https://www.semrush.com/blog/keyword-cannibalization-guide/)
- [How to Fix Cannibalization (Backlinko)](https://backlinko.com/keyword-cannibalization)

**Therapy SEO:**
- [SEO for Therapists 2024](https://mytherapyflow.com/seo-for-therapists/)
- [Local SEO for Therapy Practices](https://mytherapyflow.com/local-seo-for-therapy-practices/)
