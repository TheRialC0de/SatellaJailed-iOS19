AppSelector
=================

SwiftUI app that lets you select an installed app. **Works out of the box** - no developer options, no jailbreak, no manual configuration needed.

## Features

- **Zero configuration** - all settings are pre-configured
- **Auto-detects popular apps** using URL schemes
- **Manual bundle ID entry** for any app
- **Onboarding flow** guides users through setup
- **Remembers selection** between launches

## Just Build & Run

1. Create a new iOS App project in Xcode (SwiftUI, iOS target)
2. Add all files from `Sources/` into the project (including Info.plist)
3. Build and run - that's it!

The included `Info.plist` has all required URL schemes pre-configured. No manual setup needed.

## How It Works

- First launch shows a welcome screen
- App automatically scans for installed apps
- If apps aren't detected, shows popular bundle IDs to tap
- User can always manually enter any bundle ID
- Selection is saved locally and persists

## Storage Location

- **Regular devices**: App's Documents folder
- **Jailbroken devices**: `/var/mobile/Library/Preferences/com.satella.selected.plist`
