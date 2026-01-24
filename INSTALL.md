# How to Install AppSelector

## Download the IPA

1. Go to the **Releases** page on GitHub
2. Download `AppSelector.ipa` from the latest release

---

## Installation Methods

### Option 1: AltStore (Recommended - No Jailbreak)

1. **Install AltStore** on your iPhone:
   - Download AltServer on your PC/Mac from [altstore.io](https://altstore.io)
   - Connect your iPhone via USB
   - Install AltStore to your device

2. **Install the IPA**:
   - Transfer `AppSelector.ipa` to your iPhone (AirDrop, iCloud, email)
   - Open the file and select "Open in AltStore"
   - AltStore will install the app

3. **Refresh Weekly**: AltStore apps expire after 7 days. Open AltStore weekly to refresh.

---

### Option 2: Sideloadly (No Jailbreak)

1. Download [Sideloadly](https://sideloadly.io) on your PC/Mac
2. Connect your iPhone via USB
3. Drag `AppSelector.ipa` into Sideloadly
4. Enter your Apple ID (creates a free signing certificate)
5. Click "Start" to install

**Note**: Refresh every 7 days with free Apple ID, or use a paid Developer account for 1 year.

---

### Option 3: TrollStore (Permanent - Specific iOS Versions)

Works on iOS 14.0 - 16.6.1 (and some iOS 17 versions). **No refreshing needed!**

1. Check if your iOS version supports TrollStore: [TrollStore Compatibility](https://ios.cfw.guide/installing-trollstore/)
2. Install TrollStore using the guide for your iOS version
3. Transfer `AppSelector.ipa` to your iPhone
4. Open in TrollStore → Install

---

### Option 4: Scarlet / Esign (No Computer)

1. Install Scarlet or Esign from their official sources
2. Import the IPA file
3. Sign and install directly on device

---

## After Installation

1. Open **AppSelector**
2. Follow the welcome screen
3. Select an app from the list or enter a bundle ID manually
4. Tap **Save**

That's it! The app selection is saved and ready to use.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Unable to Install" | Your device may need to trust the developer profile. Go to Settings → General → VPN & Device Management → Trust |
| App crashes on open | Make sure you're on iOS 14.0 or later |
| "App Not Available" | The signing certificate expired. Reinstall using AltStore/Sideloadly |
| No apps detected | Use the manual entry option to type the bundle ID |

---

## Building From Source

If you prefer to build yourself:

1. Clone this repository
2. Open `AppSelector/` folder in Xcode
3. Create a new iOS App project and add the source files
4. Build and run on your device
