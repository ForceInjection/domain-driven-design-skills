---
name: create-bap-identity
description: Create new BAP (Bitcoin Attestation Protocol) identities using the bap CLI. Supports Type42 (modern) and Legacy identity formats. Creates encrypted .bep backup files stored in Flow's /.flow/.bsv/backups/ directory.
allowed-tools: "Bash(bun:*)"
---

# Create BAP Identity

Create new BAP (Bitcoin Attestation Protocol) identities using the `bap` CLI.

## When to Use

- Create a new Bitcoin identity for signing attestations
- Generate Type42 identity (recommended, modern format)
- Generate Legacy identity (compatibility with older systems)
- Create master identity that can derive member identities
- Establish on-chain reputation and identity

## BAP Identity Types

**Type42** (Recommended):
- Modern format using BIP32 derivation
- More secure and flexible
- Can derive multiple member identities
- Full BIP39 mnemonic support

**Legacy**:
- Original BAP format
- Compatibility with older systems
- Simpler structure

## Usage

Run the create script:

```bash
# Create Type42 identity (recommended)
bun run /path/to/skills/create-bap-identity/scripts/create.ts "Alice Smith" type42

# Create Legacy identity
bun run /path/to/skills/create-bap-identity/scripts/create.ts "Bob Jones" legacy

# Specify custom output file
bun run /path/to/skills/create-bap-identity/scripts/create.ts "Carol" type42 my-identity.bep
```

## Flow's BSV Convention

This skill follows Flow's BSV backup convention:

**Storage Location**: `/.flow/.bsv/backups/`
- Identity backups saved as `<name>-identity.bep`
- Encrypted with `FLOW_BACKUP_PASSPHRASE`
- Registered in `/.flow/.bsv/config.json`

**Registry**: Updates config.json with:
```json
{
  "identityBackup": "alice-smith-identity.bep",
  "backups": {
    "alice-smith-identity.bep": {
      "created": "2025-12-26T...",
      "type": "BapMasterBackup",
      "identityType": "type42",
      "name": "Alice Smith"
    }
  }
}
```

## Requirements

- `FLOW_BACKUP_PASSPHRASE` environment variable must be set
- `bap` CLI installed globally:
  ```bash
  git clone https://github.com/b-open-io/bap-cli.git
  cd bap-cli && bun install && bun run build && bun link
  ```

## CLI Reference

The bap CLI `new` command creates identities:

```bash
bap new --type type42 --password <pass> --name "Name" --output identity.bep
bap new --type legacy --password <pass> --name "Name" --output identity.bep
```

## What Gets Created

The `.bep` backup contains:
- Root key (encrypted)
- BIP39 mnemonic (Type42 only)
- Identity name and metadata
- Signing keys for attestations
- Derivation path info (Type42)

## Next Steps

After creating an identity:
1. Use `manage-bap-backup` skill to list members
2. Use `manage-bap-backup` skill to export member identities
3. Use identity for signing attestations
4. Publish identity to blockchain for on-chain reputation
