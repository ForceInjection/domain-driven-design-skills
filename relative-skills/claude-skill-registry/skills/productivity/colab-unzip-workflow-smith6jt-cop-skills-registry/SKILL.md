---
name: colab-unzip-workflow
description: "Colab file paths after unzipping repo. Trigger when: (1) API key file not found, (2) file path errors in Colab, (3) configuring notebook paths, (4) 'yfinance fallback' despite keys existing."
author: Claude Code
date: 2024-12-28
---

# Colab Unzip Workflow - File Paths

## Critical Information

**When you unzip Alpaca_trading.zip in Colab, the files are at:**
```
/content/Alpaca_trading/
```

**NOT** on Google Drive. **NOT** at `/content/drive/MyDrive/`.

## API Key Files in This Repo

The repo contains these API key files:
```
/content/Alpaca_trading/API_key_500Paper.txt   # 500 paper account
/content/Alpaca_trading/API_key_100kPaper.txt  # 100k paper account
```

**NOT** `API_key.txt`. The files have specific names.

## Correct Default in training.ipynb

```python
# Cell 15 - CORRECT
API_KEYS_FILE = '/content/Alpaca_trading/API_key_500Paper.txt'

# WRONG - file doesn't exist at this path
API_KEYS_FILE = '/content/drive/MyDrive/API_key.txt'

# WRONG - file name is wrong
API_KEYS_FILE = '/content/Alpaca_trading/API_key.txt'
```

## Failed Attempts (Critical)

| Attempt | Why it Failed | Lesson Learned |
|---------|---------------|----------------|
| `API_KEYS_FILE = None` | No keys loaded, yfinance used | Always set explicit path |
| `/content/drive/MyDrive/API_key.txt` | File not on Drive after unzip | Unzip goes to /content/, not Drive |
| `API_key.txt` (relative) | Wrong working directory in Colab | Use absolute paths |
| `API_key.txt` (wrong name) | File is `API_key_500Paper.txt` | Check actual filenames in repo |

## Colab Directory Structure After Unzip

```
/content/
├── Alpaca_trading/              # Unzipped repo
│   ├── API_key_500Paper.txt     # API keys (500 paper)
│   ├── API_key_100kPaper.txt    # API keys (100k paper)
│   ├── notebooks/
│   │   └── training.ipynb
│   ├── alpaca_trading/
│   │   └── ...
│   └── ...
├── drive/                       # Google Drive (if mounted)
│   └── MyDrive/
│       └── ...                  # User's Drive files
└── sample_data/                 # Colab default
```

## How to Verify in Colab

```python
import os

# Check what's in /content/
print(os.listdir('/content/'))
# Should show: ['Alpaca_trading', 'drive', 'sample_data']

# Check API key files
print(os.listdir('/content/Alpaca_trading/'))
# Should show: API_key_500Paper.txt, API_key_100kPaper.txt, etc.

# Verify file exists
api_path = '/content/Alpaca_trading/API_key_500Paper.txt'
print(f"File exists: {os.path.exists(api_path)}")
```

## Key Rules

1. **After unzip: `/content/Alpaca_trading/`** - not Drive
2. **Check actual filenames** - don't assume `API_key.txt`
3. **Use absolute paths** - relative paths break in Colab
4. **Verify before assuming** - `os.path.exists()` is your friend

## Files Modified

```
notebooks/training.ipynb:
  - Cell 15: API_KEYS_FILE = '/content/Alpaca_trading/API_key_500Paper.txt'
```

## References
- Skill: `data-source-priority` - Why Alpaca API matters
- `alpaca_trading/data/fetcher.py` - Key loading logic with logging
