---
name: email-templates
description: Create branded transactional email templates using React Email and Resend. Use when implementing features that send user notifications, confirmations, or updates. Ensures consistent styling, proper structure, and integration with the project's email system.
---

# Email Templates

Create branded, responsive email templates using React Email that integrate seamlessly with Resend.

## When to Create Email Templates

Create email templates for:

- **User onboarding** - Welcome emails, verification
- **Account management** - Password resets, account deletion confirmations
- **Notifications** - Order confirmations, booking updates, status changes
- **Reminders** - Upcoming appointments, expiring items
- **Transactional** - Receipts, invoices, confirmations

## Email Template Structure

### 1. Create Template File

**Location**: `transactional/emails/[template-name].tsx`

**Basic Structure**:

```tsx
import {
  Body,
  Button,
  Container,
  Head,
  Heading,
  Hr,
  Html,
  Img,
  Link,
  Preview,
  Section,
  Text,
} from "@react-email/components";
import {
  baseStyles,
  sectionStyles,
  textStyles,
  buttonStyles,
  colors,
} from "./utils/styles";
import { baseUrl, getLogoDimensions } from "./utils";
import { companyConfig } from "../../lib/brand";

interface TemplateEmailProps {
  userName?: string;
  // Add your props
}

export const TemplateEmail = ({ userName = "User" }: TemplateEmailProps) => {
  const previewText = `Subject line preview text`;
  const { width, height } = getLogoDimensions();

  return (
    <Html>
      <Head />
      <Preview>{previewText}</Preview>
      <Body style={main}>
        <Container style={container}>
          {/* Logo */}
          <Section style={logoContainer}>
            <Img
              src={`${baseUrl}/logo-email.png`}
              width={width}
              height={height}
              alt={companyConfig.name}
              style={logo}
            />
          </Section>

          {/* Main heading */}
          <Heading style={heading}>Email Title</Heading>

          {/* Content sections */}
          <Text style={paragraph}>Main email content here.</Text>

          {/* CTA Button */}
          <Section style={ctaSection}>
            <Button style={button} href={`${baseUrl}/action`}>
              Call to Action
            </Button>
          </Section>

          <Hr style={hr} />

          {/* Footer */}
          <Text style={footer}>
            <Link href={baseUrl} style={footerLink}>
              {companyConfig.domain}
            </Link>
          </Text>
        </Container>
      </Body>
    </Html>
  );
};

// Preview props for development
TemplateEmail.PreviewProps = {
  userName: "John Doe",
} as TemplateEmailProps;

export default TemplateEmail;

// Styles
const main = baseStyles.main;
const container = baseStyles.container;
const logoContainer = baseStyles.logoContainer;
const logo = baseStyles.logo;
const heading = baseStyles.heading;
const paragraph = baseStyles.paragraph;
const hr = baseStyles.hr;
const footer = baseStyles.footer;
const footerLink = baseStyles.link;

const ctaSection = sectionStyles.actionSection;
const button = buttonStyles.primary;
```

### 2. Send Email from Server Action

**Location**: `server/[feature].actions.ts`

```typescript
"use server";

import { sendEmail } from "@/lib/resend-utils";
import { TemplateEmail } from "@/transactional/emails/template";
import { companyConfig } from "@/lib/brand";

export async function sendTemplateEmail({
  email,
  userName,
}: {
  email: string;
  userName?: string;
}) {
  try {
    if (!process.env.RESEND_API_KEY) {
      console.error("[TEMPLATE_EMAIL] RESEND_API_KEY not configured");
      return { error: "Email service not configured", success: false };
    }

    const { error } = await sendEmail({
      to: [email],
      subject: `Email Subject - ${companyConfig.name}`,
      react: TemplateEmail({
        userName: userName || "User",
      }),
      sendAdminCopy: false, // Set true to CC admin
    });

    if (error) {
      console.error("[TEMPLATE_EMAIL] Failed:", error);
      return { error: "Failed to send email", success: false };
    }

    return { success: true };
  } catch (error) {
    console.error("[TEMPLATE_EMAIL] Error:", error);
    return { error: "Error sending email", success: false };
  }
}
```

## Shared Styles Reference

### Available Style Objects

**Base Styles** (`baseStyles`):

- `main` - Email body background
- `container` - Main content container
- `logoContainer` - Logo wrapper
- `logo` - Logo image
- `heading` - Main heading (28px)
- `subHeading` - Section headings (20px)
- `paragraph` - Body text (16px)
- `hr` - Horizontal rule divider
- `footer` - Footer text
- `link` - Text links

**Section Styles** (`sectionStyles`):

- `infoSection` - Muted background section
- `detailsSection` - Secondary color section
- `messageSection` - Bordered message box
- `actionSection` - CTA button section
- `customerSection` - Accent color section
- `tipsSection` - Tips with left border
- `reminderSection` - Warning yellow section
- `settingsSection` - Light settings section

**Button Styles** (`buttonStyles`):

- `primary` - Main action button (purple)
- `accept` - Accept/confirm button (green)
- `decline` - Decline/delete button (red)
- `view` - View details button (purple)

**Text Styles** (`textStyles`):

- `sectionHeader` - Section titles (18px)
- `detailLabel`, `detailValue` - Key-value pairs
- `tipsHeader`, `tipsText` - Tip sections
- `reminderHeader`, `reminderText` - Warning text
- `settingsText`, `settingsLink` - Footer settings

### Color Variables

```typescript
colors.primary;
colors.secondary;
colors.accent;
colors.foreground;
colors.mutedForeground;
colors.destructive;
colors.white;
```

## Common Patterns

### Info Section with Details

```tsx
<Section style={sectionStyles.infoSection}>
  <Text style={textStyles.sectionHeader}>Details</Text>
  <div style={layoutStyles.detailRow}>
    <Text style={textStyles.detailLabel}>Order ID:</Text>
    <Text style={textStyles.detailValue}>12345</Text>
  </div>
  <div style={layoutStyles.detailRow}>
    <Text style={textStyles.detailLabel}>Date:</Text>
    <Text style={textStyles.detailValue}>Jan 15, 2025</Text>
  </div>
</Section>
```

### Warning/Reminder Section

```tsx
<Section style={sectionStyles.reminderSection}>
  <Text style={textStyles.reminderHeader}>Important Reminder</Text>
  <Text style={textStyles.reminderText}>This action expires in 24 hours.</Text>
</Section>
```

### Multiple Action Buttons

```tsx
<Section style={sectionStyles.actionSection}>
  <div style={layoutStyles.buttonGroup}>
    <Button style={buttonStyles.accept} href={`${baseUrl}/accept`}>
      Accept
    </Button>
    <Button style={buttonStyles.decline} href={`${baseUrl}/decline`}>
      Decline
    </Button>
  </div>
</Section>
```

### Tips Section

```tsx
<Section style={sectionStyles.tipsSection}>
  <Text style={textStyles.tipsHeader}>Pro Tip</Text>
  <Text style={textStyles.tipsText}>
    You can update your preferences in settings.
  </Text>
</Section>
```

## Testing Emails Locally

### Development Setup

Environment variables automatically route emails in development:

```bash
# .env.local
DEV_EMAIL_FROM=dev@yourdomain.com
DEV_EMAIL_TO=your-test@email.com

# Production
PROD_EMAIL_FROM=noreply@yourdomain.com
```

### Preview in React Email Dev Server

```bash
bun run email:dev

# Opens at http://localhost:3001
```

Navigate to your template to see live preview with `PreviewProps`.

## Best Practices

1. **Always include Preview text** - Shows in email inbox preview
2. **Use semantic sections** - `infoSection`, `actionSection`, etc.
3. **Responsive by default** - Shared styles handle mobile
4. **Brand consistency** - Use `companyConfig` and `colors`
5. **Add preview props** - Makes development easier
6. **Log email sends** - Use console tags like `[EMAIL_TYPE]`
7. **Handle errors gracefully** - Return `{ success, error }` structure
8. **CC admin when needed** - Use `sendAdminCopy: true` for critical emails

## Related Files

- Shared styles: `transactional/emails/utils/styles.ts`
- Utilities: `transactional/emails/utils/index.ts`
- Send utility: `lib/resend-utils.ts`
- Brand config: `lib/brand.ts`
- Example templates: `transactional/emails/*.tsx`
- React Email docs: <https://react.email/docs/introduction>
