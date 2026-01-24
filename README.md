# Satella Jailed
*Free in-app purchases for jailed devices on iOS 12-19*

**Version 2.0.0** - Now with iOS 19 and iPhone 17 Pro Max support!

> ⚠️ **iPhone 17 Pro Max users: NO JAILBREAK REQUIRED!** This tweak works on stock iOS 19 - just sideload and go.

[![Build IPA](https://github.com/Paisseon/SatellaJailed/actions/workflows/build-ipa.yml/badge.svg)](https://github.com/Paisseon/SatellaJailed/actions/workflows/build-ipa.yml)

## 📲 Quick Install

**[Download the latest IPA from Releases](../../releases/latest)** and install using one of these methods:

| Method | Computer Required | Refresh Needed | Best For |
|--------|------------------|----------------|----------|
| **TrollStore** | No | Never | iOS 14.0-16.6.1 |
| **AltStore** | Yes (first time) | Every 7 days | All iOS versions |
| **Sideloadly** | Yes | Every 7 days | All iOS versions |

👉 **[Full Installation Guide](INSTALL.md)**

---

Satella Jailed is provided for educational purposes only and I am not responsible for any illegal actions taken with the use of this tool. No copyright material is distributed on this repo. Lawyer with a DMCA can stick it up their ass.

## Compatibility
- **iOS**: 12.2 - 19.x
- **Devices**: All iPhones including iPhone 17 Pro Max (with Dynamic Island support)
- **Architecture**: arm64
- **Jailbreak**: ❌ **NOT required for iPhone 17 Pro Max** - works on stock iOS 19!

## What's New in v2.0.0
- ✅ iOS 19 full compatibility
- ✅ **iPhone 17 Pro Max support - NO JAILBREAK NEEDED**
- ✅ iPhone 17 Pro Max Dynamic Island support
- ✅ Fixed crash issues with thread-safe transaction handling
- ✅ Modern window scene API (no deprecated UIApplication.windows)
- ✅ Improved memory management with autoreleasepool
- ✅ Better receipt verification URL handling
- ✅ Enhanced UI with safe area support
- ✅ Larger touch targets for modern displays
- ✅ Graceful error handling throughout

# Installation
There are currently three official methods of installing Satella Jailed, but it should work with other patching tools.

## Script (Computer Required)
1. Run `git clone https://github.com/Paisseon/SatellaJailed.git && cd SatellaJailed` in terminal
2. Move the IPA file to the resultant SatellaJailed folder
3. `sh patch-mac.sh` for macOS *or* `sh patch-linux.sh` for Linux and WSL
4. Sideload the patched IPA to your jailed device

## Azula (Mac *or* On-Device)
If you use TrollStore, make sure that the URL scheme is enabled, and turn on code signature slicing. Or just jailbreak with Dopamine and use the tweak version 🙃

1. Download SatellaJailed.dylib from this repo
2. Move SatellaJailed.dylib and the target IPA to the Azula folder in files app
3. Select them in Azula
4. Tap the Patch button

## Esign (On-Device)
1. Download SatellaJailed.dylib from this repo
2. In Signature -\> More Settings, import SatellaJailed.dylib
3. Make sure to use “@executable\_path” and “Frameworks”
4. Sign and install the patched IPA

# Usage
Just attempt to make a purchase, then cancel the confirmation popup (the one with your Apple ID on it) so you don't pay.

By default, core functionality is enabled. If it doesn't work, and you are on iOS 15+, you can try enabling advanced features by tapping the purple star.

## Settings Explained
- **Enabled**: Core IAP bypass functionality
- **3-Finger Gesture**: Use 3-finger tap to show/hide the Satella button
- **Hide Permanently**: Remove the floating button completely
- **Observer**: Hook the payment transaction observer (try if default doesn't work)
- **Zero Price**: Display prices as 0.00
- **Receipt**: Generate fake purchase receipts (try for subscription apps)
- **Stealth**: Hide Satella from dylib detection

### 🔥 Server Bypass (Nuclear Options)
These options are for stubborn apps that use server-side validation:

- **Server Bypass**: Intercepts and modifies ALL API responses from subscription services (RevenueCat, Adapty, Qonversion, Glassfy, etc.) to return premium status
- **Storage Bypass**: Hooks UserDefaults to always return `true` for premium checks and max values for consumables
- **Infinite Consumables**: Sets coins/gems/credits/energy to 999,999,999 in server responses
- **Auth Bypass**: Generates fake authentication tokens for apps requiring login

#### What the Nuclear options can bypass:
✅ RevenueCat, Adapty, Qonversion, Glassfy, Superwall, Purchasely, Nami ML  
✅ Custom receipt verification servers  
✅ Server-side feature flags  
✅ Premium status checks from API responses  
✅ UserDefaults-based subscription status  
✅ Basic consumables (coins/gems stored in responses)  

#### What still might NOT work:
❌ Games with server-authoritative consumables (currency stored only on their servers)  
❌ Apps with certificate pinning that block response modification  
❌ Apps with custom binary encryption  
❌ MMO games where all items exist only on game servers  

**Pro tip**: Enable ALL nuclear options + Receipt + Stealth for maximum compatibility. Disconnect from internet if the app allows offline use.

Please note that Satella Jailed doesn't work on every app. If various combinations of settings fail to crack the purchase, you're out of luck.

# Building from Source
Requirements:
- macOS with Xcode 16+ or Theos
- iOS 19.0 SDK

```bash
# Clone the repo
git clone https://github.com/Paisseon/SatellaJailed.git
cd SatellaJailed

# Build with Theos
make package
```

---

# AppSelector - Companion App

A SwiftUI iOS app that lists all installed apps on your iPhone and lets you select which app to apply Satella on. The selection is saved so the tweak knows which app to target.

## AppSelector Installation

### Requirements
- macOS with Xcode 15+ (to build the app)
- iPhone (jailbroken recommended for full functionality)
- iOS 14.0 or later

### Method 1: Build from Source (Recommended)

1. **Clone the repository**
   ```bash
   git clone https://github.com/Paisseon/SatellaJailed.git
   cd SatellaJailed/AppSelector
   ```

2. **Open in Xcode**
   - Open Xcode and create a new iOS App project (SwiftUI)
   - Copy all files from `Sources/AppSelector/` into your project
   - Set your Team for code signing

3. **Build and Install**
   - Connect your iPhone
   - Select your device as the build target
   - Press `Cmd + R` to build and run

4. **Trust the Developer**
   - On your iPhone: Settings → General → VPN & Device Management
   - Tap your developer certificate and trust it

### Method 2: Sideload with AltStore/Sideloadly

1. Download the pre-built IPA from [Releases](../../releases)
2. Use AltStore, Sideloadly, or similar to install the IPA
3. Trust the app in Settings → General → VPN & Device Management

### Method 3: TrollStore (No Revokes)

1. Download the IPA from [Releases](../../releases)
2. Open in TrollStore
3. Tap Install - done!

## How to Use AppSelector

1. **Open AppSelector** on your iPhone
2. **Browse the list** of all installed apps
3. **Tap an app** to select it (checkmark appears)
4. **Tap "Save Selection"** to save your choice
5. The selected app's bundle ID is saved to `/var/mobile/Library/Preferences/com.satella.selected.plist`
6. Now patch that app with Satella and the tweak will apply!

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "No apps found" | The private API may be blocked on stock iOS. Use on jailbroken device or check entitlements |
| "Save failed" | On non-jailbroken devices, the app can't write to system paths. The selection still works in-memory |
| App crashes | Ensure you're running iOS 14.0+ and the app is properly signed |

## For Developers

The AppSelector uses `LSApplicationWorkspace` (private API) to enumerate installed apps. This won't pass App Store review but works perfectly for sideloaded/jailbroken usage.

Key files:
- `AppSelectorApp.swift` - App entry point
- `ContentView.swift` - Main UI and ViewModel
- `InstalledApp.swift` - Data model
- `InstalledAppsProvider.swift` - Private API calls and plist saving

---

# Support
If you have issues, check [ERRORS_AND_TROUBLESHOOTING.md](ERRORS_AND_TROUBLESHOOTING.md) first.

# License
See [LICENSE](LICENSE) for details.