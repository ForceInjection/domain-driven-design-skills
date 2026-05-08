---
name: app-sharing
description: |
  Manage Glide app access, privacy, authentication, and publishing.
  Use when configuring who can access an app, setting up sign-in methods,
  publishing apps, inviting users, or configuring Row Owners for data security.
---

# Glide App Sharing

## Accessing Access Settings

1. Go to **Settings** tab (top navigation)
2. Click **Access** in the settings menu
3. URL: `go.glideapps.com/app/{appId}/settings/privacy`

## Privacy Modes

### Private App
- **Only users you choose can access**
- Users must be in the Users table or meet specific criteria
- Best for: Internal tools, member-only apps

### Public App
- **Anyone with link can access**
- No sign-in required (optional sign-in available)
- Best for: Public directories, info apps

## User Access Options

When app is Private, choose who can sign in:

| Option | Description |
|--------|-------------|
| **Users table** | Only users in the Users table can sign in |
| **Team members** | Members of your Glide team can sign in |
| **Allowed email domains** | Users with specific email domains (e.g., @company.com) |
| **All emails in table** | Any email found in a specified table column |

### Users Table Access
- Select which table serves as the Users table
- Users with emails in that table can sign in
- Common for: Employee apps, member portals

### Team Access
- All members of your Glide team can sign in
- No need to add them to a table
- Common for: Internal team tools

### Domain-Based Access
- Allow anyone with email from specific domains
- Example: Allow all @acme.com emails
- Common for: Company-wide apps

## Authentication Methods

Configure how users prove their identity:

| Method | Description | Setup |
|--------|-------------|-------|
| **Pin emails from Glide** | Glide sends PIN code via email | Default, no setup |
| **Magic link** | One-click sign-in link in email | Enable checkbox |
| **Sign in with Google** | OAuth via Google account | Automatic |
| **Single sign-on (SSO)** | Enterprise SSO integration | Enterprise plan |
| **Pin texts from Twilio** | SMS PIN codes | Connect Twilio |
| **Pin emails from Gmail** | Send from your Gmail | Connect Gmail |
| **Pin emails from Microsoft** | Send from Microsoft account | Connect Microsoft |

### Magic Link Option
Under "Pin emails from Glide", enable:
- **Include magic link to sign in without PIN**
- Users can click link instead of entering PIN

## Access Requests

Allow new users to request access:
- Enable "Allow visitors to request access"
- New users see "Request Access" on sign-in screen
- Team reviewers approve/deny requests
- Manage reviewers in Team Members settings

## Publishing Your App

### Publish Button
- Click **Publish** (top right, green button)
- Makes app available at its URL

### App URL
- Format: `{app-name}.glideapp.io`
- Custom domains available on paid plans

### Before Publishing Checklist
1. Set appropriate privacy mode
2. Configure authentication
3. Test as different user types
4. Review data access (Row Owners)
5. Set up branding (name, icon)

## Inviting Users

### Method 1: Add to Users Table
1. Go to Data Editor
2. Open Users table
3. Add rows with user emails
4. Share app URL with users

### Method 2: Share Link
1. Publish the app
2. Copy app URL
3. Share with users
4. They sign in with configured auth method

### Method 3: Team Invitation
1. Enable "Team members" access
2. Invite users to your Glide team
3. They automatically get app access

## Row Owners (Data Security)

**Critical**: Access settings control who can enter the app. Row Owners control what data they see.

### Setting Up Row Owners
1. Add email column to your table
2. Make it a Row Owner column
3. Users only see rows where their email matches

### Important Notes
- Visibility conditions are NOT security (data still downloads)
- Row Owners provide true data-level security
- Use for sensitive data protection

## Testing Access

### Test as Different Users
1. Use "Viewing as" dropdown (top of preview)
2. Select different users from Users table
3. Verify they see correct data/screens

### Test Sign-In Flow
1. Open app in incognito/private window
2. Go through sign-in as new user
3. Verify authentication works

## Common Access Patterns

### Employee Directory (Private)
```
Privacy: Private
Users: Team members OR Users table
Auth: Sign in with Google + Pin emails
Row Owners: None (all employees see all)
```

### Customer Portal (Private)
```
Privacy: Private
Users: Users table (customers)
Auth: Pin emails from Glide + Magic link
Row Owners: Customer email column
```

### Public Information App
```
Privacy: Public
Users: Optional sign-in
Auth: N/A or Sign in with Google
Row Owners: None
```

### Internal Tool (Restricted)
```
Privacy: Private
Users: Allowed email domains (@company.com)
Auth: SSO or Google
Row Owners: Department-based
```

## After Building: User Invitation Flow

After building an app, ask the user:
1. "Who should have access to this app?"
2. "Should it be private or public?"
3. "Do you want to invite specific users now?"

Then:
1. Configure privacy settings
2. Add users to Users table if needed
3. Set up appropriate authentication
4. Publish the app
5. Share the app URL

## Troubleshooting

### Users Can't Sign In
- Check they're in Users table (if using)
- Verify email matches exactly
- Check authentication method is enabled

### Users See Wrong Data
- Review Row Owner settings
- Check visibility conditions
- Test as that specific user

### Access Request Not Working
- Ensure feature is enabled
- Check team has reviewers assigned
- Verify email deliverability

## Documentation

- [Users & Privacy](https://www.glideapps.com/docs/users)
- [Row Owners](https://www.glideapps.com/docs/reference/security/row-owners)
- [Publishing](https://www.glideapps.com/docs/publishing)
- [Authentication](https://www.glideapps.com/docs/users#authentication)
