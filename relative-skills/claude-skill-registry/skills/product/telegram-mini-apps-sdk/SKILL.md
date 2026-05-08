---
name: telegram-mini-apps-sdk
description: Comprehensive manual for Telegram Mini Apps SDK. Use when developers need guidance on creating web applications inside Telegram, working with WebApp API, managing user data, handling authentication via initData, implementing buttons and events, working with storage, and integrating with Telegram ecosystem features.
license: MIT
---

# Telegram Mini Apps SDK Manual

Complete guide for building Telegram Mini Apps with JavaScript SDK. Covers initialization, WebApp parameters, button management, events, themes, user authentication, data storage, and practical code examples.

## Quick Start

```javascript
const tg = window.Telegram.WebApp;
tg.ready();
tg.expand();

// Configure buttons
tg.BackButton.show();
tg.MainButton.setText('Send').show();
tg.MainButton.onClick(() => {
  tg.showAlert('Button pressed!');
});
```

## Core Concepts

### 1. Initialization

Add SDK script before any other scripts:

```html
<script src="https://telegram.org/js/telegram-web-app.js?59"></script>
```

Then initialize:

```javascript
const tg = window.Telegram.WebApp;
tg.ready();    // Notify Telegram app is ready
tg.expand();   // Expand to full screen
```

### 2. User Data (initData)

Access user information:

```javascript
const user = tg.initDataUnsafe.user;
console.log(user.id, user.first_name, user.username);

// ⚠️ SECURITY: Always validate initData on server!
// Use tg.initData string for server-side validation
```

### 3. Main Button

```javascript
const mainBtn = tg.MainButton;
mainBtn.setText('Send');
mainBtn.show();
mainBtn.onClick(() => {
  mainBtn.showProgress();
  // Your action here
  mainBtn.hideProgress();
});
```

### 4. Back Button

```javascript
tg.BackButton.show();
tg.BackButton.onClick(() => {
  // Navigate back or close
  tg.close();
});
```

### 5. Data Storage

```javascript
// Cloud storage
tg.CloudStorage.setItem('key', 'value', (error) => {
  if (!error) console.log('Saved');
});

tg.CloudStorage.getItem('key', (error, value) => {
  console.log('Value:', value);
});
```

### 6. Themes

```javascript
console.log(tg.colorScheme);      // "light" or "dark"
console.log(tg.themeParams);      // Color theme object

tg.onEvent('themeChanged', () => {
  console.log('Theme updated');
});
```

### 7. Events

```javascript
// Lifecycle
tg.onEvent('activated', () => {});
tg.onEvent('deactivated', () => {});

// UI
tg.onEvent('mainButtonClicked', () => {});
tg.onEvent('backButtonClicked', () => {});
tg.onEvent('themeChanged', () => {});
```

### 8. Haptic Feedback

```javascript
const haptic = tg.HapticFeedback;
haptic.impactOccurred('light');
haptic.notificationOccurred('success');
haptic.selectionChanged();
```

## Security Best Practices

1. **Validate initData on server** - Never trust `initDataUnsafe` for sensitive operations
2. **Use HTTPS only** - All communication must be encrypted
3. **Check data freshness** - Verify `auth_date` is recent
4. **Store secrets securely** - Use `SecureStorage` for tokens
5. **Expose minimal API** - Only provide necessary endpoints to frontend

## Further Resources

See the `references/` directory for complete API documentation.
See the `scripts/` directory for ready-to-use utilities.
See the `assets/` directory for HTML/React templates.

## Official Links

- **Documentation**: https://core.telegram.org/bots/webapps
- **Bot API**: https://core.telegram.org/bots/api
- **BotFather**: https://t.me/BotFather
