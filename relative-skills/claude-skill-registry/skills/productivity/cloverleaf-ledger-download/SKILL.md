---
name: cloverleaf-ledger-download
description: Download ledger transactions from Cloverleaf property management portal using Playwright browser automation when user says "get ledger transactions", "download from cloverleaf", "fetch property transactions"
metadata:
  version: 1.0.0
---

# Cloverleaf Ledger Download

This skill downloads ledger transactions from the Cloverleaf property management portal using Playwright browser automation.

## When to use

Use this skill when the user wants to:
- Get ledger transactions from Cloverleaf
- Download transaction data from cloverleaf portal
- Fetch property transactions from the management system

## Instructions

1. Navigate to the ledger page: https://cloverleafpm.rentvine.com/portals/owner/ledger
2. If date range specified, append parameters like ?datePostedMax=2026-01-01&amp;datePostedMin=2026-01-01&amp;page=1&amp;pageSize=15
3. Wait for the table to load
4. Run the extraction script to convert HTML table to CSV
5. Save the CSV file with dated filename format

## Constraints

- Never store or prompt for credentials
- Never navigate outside the cloverleafpm.rentvine.com domain
- Never attempt to handle login or MFA - user must be already logged in

## Inputs

- URL to navigate to (with optional date parameters)
- HTML table with transaction data

## Outputs

- CSV file named "cloverleaf-{earliest_date}-to-{latest_date}-ledger.csv"

## Examples

### Example 1: Download all current transactions

User: "get my ledger transactions from cloverleaf"

Agent: Navigate to https://cloverleafpm.rentvine.com/portals/owner/ledger, run extraction script, save as cloverleaf-2025-12-01-to-2026-01-01-ledger.csv

### Example 2: Download transactions for specific date

User: "get ledger transactions for January 2026 from cloverleaf"

Agent: Navigate to https://cloverleafpm.rentvine.com/portals/owner/ledger?datePostedMax=2026-01-31&amp;datePostedMin=2026-01-01&amp;page=1&amp;pageSize=15, extract and save

### Example 3: Handle empty results

User: "download transactions for February 2024"

Agent: Navigate with date parameters, if table is empty or only starting balance, create CSV with headers only, save with appropriate date range

## Anti-patterns &amp; Warnings

- Do not attempt to automate login process
- Do not store any authentication credentials
- Do not navigate to other domains or pages
- Do not modify or interact with page elements beyond reading the table
- Be careful with date parsing - use the datetime attribute for accurate dates
