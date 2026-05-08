---
name: atl-cli
description: >
  Atlassian Server CLI (Jira/Confluence/Bitbucket). This skill should be used
  when working with Jira issues, Confluence page operations, Bitbucket pull
  requests, or any Atlassian Server tasks. Triggers on: issue tracking, wiki
  pages, PR management, CQL queries.
---

# ATL CLI

```
atl
├── init                              # Setup config
├── issue (jira)
│   ├── list (ls, search) [text]      # -t -s[] -y -a -r -e -C -l[] -p -q --order-by --reverse --limit
│   ├── view [key]
│   ├── comment [key] [text]
│   ├── comments [key]
│   ├── transition [key] [name?]      # Omit name to list available
│   └── prs [key]                     # Linked pull requests
├── page (confluence)
│   ├── list [space]                  # --type --limit
│   ├── search (find, query) [text]   # -s -t --title --creator --contributor --created --modified -q --order-by --reverse --limit
│   ├── view [id]                     # --format --info -o --with-images --with-toc
│   ├── create                        # -s -t -c -f -p
│   ├── edit [id]                     # -t -c -f
│   ├── delete (rm, del) [id|title|url]  # -s --cascade -y
│   ├── children [id]                 # --limit
│   └── spaces                        # --limit
└── pr
    ├── list [proj/repo]              # --state --author --base --head --limit
    ├── view [proj/repo] [id]
    ├── diff [proj/repo] [id]
    ├── comment [proj/repo] [id] [text]
    ├── merge [proj/repo] [id]        # --force --delete-branch
    └── status                        # Your PRs & reviews
```

Global: `--config`, `--username`

## Jira Issue List

```bash
atl issue list -a me -t Bug -s Open   # My open bugs
atl issue list -s '~Done' -e 123      # Not Done, epic auto-prefixed
atl issue list -q "created >= -7d"    # Raw JQL
```

| Flag | Values |
|------|--------|
| `-t` | Bug, Story, Task, Epic |
| `-s` | Status (multi, `~` negates) |
| `-y` | Blocker, Critical, Major, Minor, Trivial |
| `-a` | me, none, x, username |
| `-e` | Epic key (auto-prefixes project) |
| `--order-by` | created, updated, priority, status, key, assignee, reporter, summary |

## Confluence Page Search

```bash
atl page search "notes" -s '~john.doe'
atl page search --title "CLI" --creator john.doe --modified month
atl page search -q 'type=page AND title~"API"'
```

| Flag | Values |
|------|--------|
| `-t` | page, blogpost, comment, attachment |
| `--modified` | today, yesterday, week, month, year |
| `--order-by` | created, lastmodified, title |

## Confluence Page View/Create/Edit

```bash
atl page view 12345 --format storage -o page.html  # Fetch before edit
atl page create -s SPACE -t "Title" -f content.html -p "Parent"
atl page edit 12345 -f updated.html
atl page delete 12345 --cascade -y
```

`-p/--parent`: ID, title (needs space), or URL

## Bitbucket PR

```bash
atl pr list PROJ/repo --state ALL --author @me
atl pr merge PROJ/repo 140 --force --delete-branch
atl pr status
```

| `--state` | OPEN, MERGED, DECLINED, ALL |

## Pitfalls

```bash
# Quote tilde - shell expansion
atl page list '~john.doe'      # RIGHT
atl page list ~john.doe        # WRONG

# Positional arg, not --space
atl page list '~john.doe'      # RIGHT
atl page list --space SPACE    # WRONG

# No CDATA in Confluence storage
<pre>code</pre>                # RIGHT
<![CDATA[code]]>               # WRONG
```

Read `references/confluence-guidelines.md` before editing pages.
