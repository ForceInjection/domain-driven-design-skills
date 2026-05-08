---
name: opal-frontend-cypress-component
description: Cypress component testing guidance for opal-frontend. Use when adding or updating component specs, configuring component test setup, or choosing selectors, mocks, and POM Actions or Flows.
---

# Opal Frontend Cypress Component Testing

## Overview
Use these rules when writing or updating Cypress component specs in opal-frontend.

## Structure and Setup
- Component specs live in `cypress/component/**` and are grouped by capability (for example, `manualAccountCreation`, `fineAccountEnquiry`, shared `pages/`).
- Prefer the shared router-outlet setup in `cypress/component/fineAccountEnquiry/accountEnquiry/setup` so specs can register routes, provide shared services, intercept APIs, and navigate to the component under test.
- Extend the shared setup rather than creating a new mount helper, unless it causes regressions.

## Page Object Model Usage
- Do not call `cy.get` directly when a POM exists.
- Import Actions or Flows from `cypress/e2e/functional/opal/actions/**` or `cypress/e2e/functional/opal/flows/**` and use their methods against the mounted component.

## Selectors and Hooks
- Use stable selectors from `cypress/shared/common.locators.ts` and `cypress/shared/selectors/**`.
- If a component lacks a hook, add a semantic ID or data attribute in `src/app` first, then expose it via the selector modules so component and E2E tests stay in sync.

## Mocks, Intercepts, and Tags
- Store API intercept fixtures beside each spec in `<spec-folder>/mocks/**`.
- Copy or extend existing mock files so scenarios stay isolated.
- Use local intercept helpers in `<spec-folder>/intercept/**` with the router-outlet setup.
- Tag tests with Jira IDs when scoping to acceptance criteria (example: `{ tags: ['@PO-604'] }`).

## Running a Spec
- Run a single component spec with:
  `yarn cypress run --browser chrome --component --spec 'cypress/component/fineAccountEnquiry/accountEnquiry/AccountEnquiry.cy.ts'`

## Handling Real Product Bugs
- If a component spec fails due to a real product bug, do not change application code to force a pass.
- Skip or mark the test pending and explain the failure in the task update.
