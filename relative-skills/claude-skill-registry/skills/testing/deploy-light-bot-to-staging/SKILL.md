---
name: Deploy Light Bot to Staging
description: Deploy the Light Bot application to the staging server using SSH and Docker Compose.
---

# Deploy Light Bot to Staging

Deploy the Light Bot application to the staging server using SSH and Docker Compose.

## Server Configuration
- **SSH Key**: `~/.ssh/personal`
- **SSH Host**: `root@rmn.pp.ua`
- **Project Directory**: `services/light-bot-staging`
- **Service Name**: `light-bot-staging`
- **Telegram Channels**: `@power_po2_test` (for both status and schedule notifications in staging)
- **Docker Compose File**: `/root/services/docker-compose.yml`

## Task
Execute the deployment process to update the Light Bot on the staging server:

### Step 1: Check and Sync Environment Variables
Before deployment, check if there are new environment variables in `.env.example` that need to be added to `.env`:

1. Fetch both files (use server configuration from above):
   - `.env.example` from local project
   - `.env` from the server
2. Compare them to find any new variables in `.env.example` that are missing in `.env`
3. If new variables are found:
   - Add them to `.env` with the default values from `.env.example`
   - **Important**: Do NOT modify existing values in `.env` - they may be intentionally different
   - **Note**: Ensure `TELEGRAM_CHANNEL_ID` and `TELEGRAM_SCHEDULE_CHANNEL_ID` are set to `@power_po2_test` in staging
   - Ask the user if unsure about any changes
4. If changes were made, upload the updated `.env` back to the server

### Step 2: Run Deployment Script
Once .env is synced, run the deployment script with the server configuration:
```bash
./.claude/skills/deploy-staging/deploy.sh ~/.ssh/personal root@rmn.pp.ua services/light-bot-staging light-bot-staging
```

The script will:
1. SSH into the staging server (root@rmn.pp.ua)
2. Navigate to project directory
3. Pull latest changes from git
4. Rebuild the Docker image
5. Restart the service with docker-compose
