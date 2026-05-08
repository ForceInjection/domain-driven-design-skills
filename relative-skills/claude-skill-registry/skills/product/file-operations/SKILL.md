---
name: file-operations
description: Production-grade file operations - permissions, find, archives, rsync
sasmp_version: "1.3.0"
bonded_agent: 03-file-operations
bond_type: PRIMARY_BOND
version: "2.0.0"
difficulty: intermediate
estimated_time: "5-7 hours"
---

# File Operations Skill

> Master file system operations with production-ready patterns

## Learning Objectives

After completing this skill, you will be able to:
- [ ] Manage file permissions (chmod, chown)
- [ ] Search files efficiently with find and fd
- [ ] Create and extract archives (tar, zip)
- [ ] Synchronize files with rsync
- [ ] Work with symbolic and hard links

## Prerequisites

- Bash basics
- Understanding of file systems
- Command line navigation

## Core Concepts

### 1. Permission Management
```bash
# Numeric notation
chmod 755 script.sh       # rwxr-xr-x
chmod 644 file.txt        # rw-r--r--
chmod 600 secret.key      # rw-------

# Symbolic notation
chmod u+x script.sh       # Add execute for owner
chmod g-w file.txt        # Remove write for group
chmod a+r public.txt      # Add read for all

# Ownership
chown user:group file
chown -R user:group dir/

# Common patterns
chmod 600 ~/.ssh/id_rsa   # SSH private key
chmod 755 /var/www/html/  # Web directory
```

### 2. Find Command
```bash
# By name
find . -name "*.txt"
find . -iname "*.TXT"     # Case insensitive

# By type
find . -type f            # Files
find . -type d            # Directories
find . -type l            # Symlinks

# By size/time
find . -size +100M        # Larger than 100MB
find . -mtime -7          # Modified in 7 days

# Actions
find . -name "*.tmp" -delete
find . -type f -exec chmod 644 {} +
```

### 3. Archive Operations
```bash
# Create archives
tar -cvf archive.tar dir/
tar -czvf archive.tar.gz dir/   # gzip
tar -cjvf archive.tar.bz2 dir/  # bzip2

# Extract archives
tar -xvf archive.tar
tar -xzvf archive.tar.gz -C /dest/

# ZIP
zip -r archive.zip dir/
unzip archive.zip
```

### 4. Rsync
```bash
# Local sync
rsync -avz source/ dest/

# Remote sync
rsync -avz local/ user@host:/remote/

# With delete (mirror)
rsync -avz --delete source/ dest/

# Dry run
rsync -avzn source/ dest/
```

## Common Patterns

### Safe Delete Pattern
```bash
# With confirmation
rm -i file.txt

# With variable check
rm -rf "${DIR:?}/"   # Fails if DIR empty
```

### Backup Pattern
```bash
# Timestamped backup
backup() {
    local src="$1"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    cp -a "$src" "${src}.${timestamp}.bak"
}
```

### Find and Process
```bash
# Fix permissions
find /var/www -type d -exec chmod 755 {} +
find /var/www -type f -exec chmod 644 {} +

# Delete old files
find /tmp -type f -mtime +7 -delete
```

## Anti-Patterns

| Don't | Do | Why |
|-------|-----|-----|
| `rm -rf $VAR/` | `rm -rf "${VAR:?}/"` | Empty VAR = delete / |
| `find \| xargs rm` | `find -delete` | Handles spaces |
| `cp -r` for sync | `rsync -a` | rsync is smarter |

## Practice Exercises

1. **Permission Fixer**: Script to fix web dir permissions
2. **Old File Cleaner**: Remove files older than N days
3. **Backup Script**: Timestamped backup with rotation
4. **Sync Tool**: Two-way directory sync

## Troubleshooting

### Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `Permission denied` | Wrong permissions | Check with `ls -la` |
| `No such file` | Path typo | Verify path exists |
| `Directory not empty` | rm without -r | Add `-r` flag |
| `Cross-device link` | Hard link across fs | Use symlink |

### Debug Techniques
```bash
# Check permissions
stat file.txt
ls -la file.txt

# Trace find
find . -name "*.txt" -print

# Dry-run rsync
rsync -avzn source/ dest/
```

## Safety Guidelines

1. **Always dry-run** rsync with `--delete` first
2. **Quote paths** with spaces: `"$path"`
3. **Verify paths** before `rm -rf`
4. **Use trash** instead of rm when possible
5. **Backup** before bulk operations

## Resources

- [GNU Coreutils](https://www.gnu.org/software/coreutils/manual/)
- [find Manual](https://www.gnu.org/software/findutils/manual/)
- [rsync Manual](https://rsync.samba.org/documentation.html)
- [fd - modern find](https://github.com/sharkdp/fd)
