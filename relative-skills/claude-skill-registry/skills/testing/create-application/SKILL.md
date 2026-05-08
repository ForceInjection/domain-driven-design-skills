---
name: create-application
description: Orchestrates the creation of a full job application package. Triggers whenever the user shares a new job posting, provides a link/URL, pastes a job description or specification, or uses phrases like "apply for this job", "create application package", or "draft application". Generates CV, cover letter, and tracking files using the Candidate Profile.
---

# Create Application Package

<instructions>

This skill orchestrates multi-step application creation. The agent MUST follow each phase sequentially and MUST NOT skip steps without user approval.

</instructions>

<workflow>

## Step 1: Preparation

1. **Read Inputs:**
   - Job Offer (from arguments)
   - `Candidate-Profile.md` (Source of Truth)
2. **Deep Analysis:** Analyze the job post to understand requirements and fit.
3. **Company Research:** If deep research is missing, the agent SHOULD request the **Researcher Agent** to build a dossier.

## Step 2: Strategy Definition

Decide on the application strategy based on analysis:
- **Technical/Expert:** Emphasize hard skills and projects.
- **Business/Growth:** Focus on ROI and results.
- **Hybrid:** Combine technical depth with business impact.
- **Mission:** Align with company values (for NGOs/Nonprofits).

## Step 3: Material Generation

### A. CV Generation
1. **Load Guide:** Read `references/guide-tailor-cv.md`.
2. **Execute:** Follow the workflow in the guide to generate `CV-tailored.md`.
   - Use `references/cv-master-pattern.md` as the template.

### B. Cover Letter Generation
1. **Load Guide:** Read `references/guide-generate-cover-letter.md`.
2. **Execute:** Follow the workflow in the guide to generate `Cover-letter.md`.
   - Use `references/cover-letter-templates.md` for templates.

## Step 4: Package Assembly

1. **Structure:** Files MUST be saved to `/02-Applications/YYYY-MM/Company-Name/`.
2. **Consistency Check:** Verify tone, formatting, and facts across all documents.
3. **Additional Assets:** MAY create `Portfolio.md` or `Case-Study.md` using data from the Profile if relevant.

## Step 5: Finalization

1. **Tracking:** Run `track-application` to initialize the log.
   - **CRITICAL:** Set status to **"Ready to Apply"**.
   - **CRITICAL:** Set Applied Date to **"Pending"**.
   - Do NOT mark as "Applied" or "Sent" until the user explicitly confirms submission.
2. **Email Draft:** Create a submission email using the template in `references/templates.md`.
3. **Checklist:** Verify completeness using the checklist in `references/templates.md`.

## Step 6: Follow-up Plan

Schedule the first follow-up action (typically 1 week post-application) in the tracker.

</workflow>
