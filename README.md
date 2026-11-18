# Munfordville Sports App

iOS app wrapper for munfordvillesports.com/app built with Capacitor.

## Build

This project is built via Codemagic CI/CD. The `codemagic.yaml` configures:
- Bundle ID: com.munfordvillesports.app
- Team ID: 7482Q28KY4
- App Store App ID: 6836411892

## Local development

```bash
npm install
npx cap add ios
npx cap sync ios
npx cap open ios  # Opens in Xcode
```
