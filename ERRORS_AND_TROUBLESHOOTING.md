# Satella Jailed - Errors & Troubleshooting Guide

> Complete guide to all potential errors, issues, and their solutions for Satella Jailed v2.0.0

---

## Table of Contents
- [Runtime Errors](#-runtime-errors)
- [Bypass Failures](#-bypass-failures)
- [Detection Risks](#-detection-risks)
- [Configuration Errors](#-configuration-errors)
- [Known Limitations](#-known-limitations)
- [Device-Specific Issues](#-device-specific-issues)
- [Debugging Guide](#-debugging-guide)

---

## 🔴 Runtime Errors

### App Crashes on Launch

| Symptom | Cause | Solution |
|---------|-------|----------|
| App crashes immediately after opening | Hook conflicts with app's internal code | Disable hooks one-by-one in settings to find the culprit |
| Crash after enabling Nuclear options | UserDefaults/Storage bypass interfering with app initialization | Disable **Storage Bypass** option |
| Crash on iOS 19 only | Deprecated API usage | Update to latest Satella version (v2.0.0+) |

### Initialization Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `[SatellaJailed] Initialization error: ...` | Tweak failed to load hooks | Check full error in Console.app |
| `[SatellaJailed] Failed to set value for key` | KVO exception on iOS 19 | Already handled gracefully, ignore |
| No `[SatellaJailed]` logs at all | Dylib not injected properly | Re-patch the IPA and reinstall |

### UI Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Floating button doesn't appear | Window scene not in foreground | Wait 2 seconds, or restart app |
| Button appears but can't be tapped | Safe area/Dynamic Island overlap | Drag button to different position |
| Settings panel doesn't open | SwiftUI hosting controller issue | Try 3-finger tap gesture instead |
| Button invisible on iOS 19 | View hierarchy changes | Update to v2.0.0+ |

---

## 🟠 Bypass Failures

### Purchase Not Working

| Symptom | Cause | Solution |
|---------|-------|----------|
| IAP not unlocked after "purchase" | App uses server-side validation | Enable **Server Bypass** + **Receipt** |
| Still prompted to pay | Core hooks not active | Ensure **Enabled** is ON |
| "Purchase failed" error | App validates receipt cryptographically | Try **Receipt** + **Observer** |
| Purchase works but reverts | App re-validates on next launch | Enable **Storage Bypass** |

### Subscription Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Subscription shows expired | Server response not intercepted | Enable **Server Bypass** |
| "Subscription not found" | App uses RevenueCat/Adapty | Nuclear options should handle this |
| Trial still showing | Date-based checks | Make purchase to bypass trial |
| Auto-renew status incorrect | Missing response fields | Already fixed in v2.0.0 |

### Consumables (Coins/Gems)

| Issue | Cause | Solution |
|-------|-------|----------|
| Coins not added | Game stores currency on their servers only | ❌ **Cannot bypass** - server authoritative |
| Gems show 999M but reset | App syncs with server on launch | Enable airplane mode, use offline |
| Energy/lives not refilled | Server-tracked consumables | Same as above - may not work |
| Currency added but can't spend | Server validates each transaction | ❌ **Cannot bypass** |

### Server-Side Validation

| Issue | Cause | Solution |
|-------|-------|----------|
| RevenueCat still blocking | API endpoint not in list | Already added in v2.0.0 |
| Adapty validation fails | Response format mismatch | Nuclear mode generates correct format |
| Custom server still validates | Unknown endpoint pattern | May need app-specific patching |
| Feature flags not unlocked | Encrypted response body | ❌ **Cannot bypass** without decryption |

---

## 🟡 Detection Risks

### Tweak Detection

| Risk | When It Happens | Mitigation |
|------|-----------------|------------|
| App detects Satella dylib | App scans `/Library/MobileSubstrate` or loaded dylibs | Enable **Stealth** mode |
| "Jailbreak detected" message | App has jailbreak detection | Satella Jailed is for non-jailbroken devices, shouldn't trigger |
| App refuses to launch | Sideload/TrollStore detection | Use different signing method |
| Features disabled due to "tampering" | App integrity checks | Try **Stealth** + reinstall app |

### Account Risks

| Risk | Severity | Recommendation |
|------|----------|----------------|
| Account banned from game | 🔴 **HIGH** for online games | **Never use on multiplayer/competitive games** |
| Apple ID flagged | 🟡 Medium | Cancel payment dialog, don't complete fake purchases |
| App-specific account ban | 🟠 Medium-High | Don't use on apps with anti-cheat |
| Data loss | 🟢 Low | Backup before using |

---

## 🔧 Configuration Errors

### Settings Not Working

| Problem | Cause | Fix |
|---------|-------|-----|
| Changes don't take effect | Settings require app restart | **Kill and relaunch the app** |
| Toggle reverts to OFF | UserDefaults conflict | Clear app data and retry |
| Can't find settings panel | Button hidden | Use 3-finger tap or reinstall |

### Option Conflicts

| Conflict | Result | Solution |
|----------|--------|----------|
| Storage Bypass + some apps | App crashes or misbehaves | Disable **Storage Bypass** |
| Auth Bypass + real login apps | Login fails | Disable **Auth Bypass** |
| All Nuclear options at once | May cause instability | Enable one-by-one to test |

### Recommended Configurations

**For Subscription Apps (Netflix, Spotify-like):**
```
✅ Enabled
✅ Receipt  
✅ Server Bypass
✅ Stealth
```

**For Games with IAP:**
```
✅ Enabled
✅ Observer
✅ Receipt
✅ Server Bypass
✅ Infinite Consumables (if offline game)
```

**For Stubborn Apps:**
```
✅ ALL options enabled
📴 Airplane mode ON
🔄 Restart app after enabling
```

---

## ⛔ Known Limitations

### Cannot Bypass (Even with Nuclear Mode)

| Type | Reason | Example Apps |
|------|--------|--------------|
| **MMO/Online games** | Items exist only on game servers | Genshin Impact, Clash of Clans |
| **Certificate pinning** | App validates server certificates | Banking apps, some games |
| **Binary encryption** | Responses encrypted with app-specific keys | Some enterprise apps |
| **Real Apple ID auth** | Requires actual Apple authentication | Apple Music, iCloud features |
| **Cloud-synced purchases** | Verified through iCloud Keychain | Some Apple first-party apps |
| **Hardware-bound licenses** | Tied to device secure enclave | Some professional apps |

### Partially Working

| Type | What Works | What Doesn't |
|------|------------|--------------|
| RevenueCat apps | Subscription status | Server-synced entitlements |
| Games with dual currency | Offline currency | Online-verified currency |
| Freemium apps | Premium unlock | Cloud-synced features |

---

## 📱 Device-Specific Issues

### iPhone 17 Pro Max

| Issue | Status | Notes |
|-------|--------|-------|
| Jailbreak required? | ✅ **NO** | Works on stock iOS 19 |
| Dynamic Island overlap | ✅ Fixed in v2.0.0 | Safe area handled |
| Button too small | ✅ Fixed | Enlarged to 40pt |

### Other Devices

| Device/iOS | Compatibility | Notes |
|------------|---------------|-------|
| iOS 19.x | ✅ Full | Primary target |
| iOS 15-18 | ✅ Full | Well tested |
| iOS 12-14 | ⚠️ Partial | Some features may not work |
| iOS < 12 | ❌ Not supported | Too old |
| iPad | ✅ Works | UI may need adjustment |
| Simulator | ⚠️ Limited | Some hooks don't work |

---

## 🔍 Debugging Guide

### How to View Logs

**On Mac:**
1. Open **Console.app**
2. Select your device
3. Filter for `[SatellaJailed]`
4. Watch real-time logs

**On Windows:**
1. Install **3uTools** or **iMazing**
2. Connect device
3. View system logs
4. Filter for `SatellaJailed`

### Important Log Messages

| Log Message | Meaning |
|-------------|---------|
| `Starting on iPhone 17 Pro Max (No Jailbreak Required!)` | Successfully initialized |
| `✅ No jailbreak required for this device!` | Device compatibility confirmed |
| `Advanced server bypass enabled!` | Nuclear options active |
| `Modified server response for: api.revenuecat.com` | Successfully intercepted API |
| `Intercepted UserDefaults key: isPremium -> true` | Storage bypass working |
| `Failed to set value for key` | Non-critical, handled gracefully |

### Diagnostic Checklist

```
□ Is the dylib properly injected? (Check with class-dump)
□ Are there [SatellaJailed] logs appearing?
□ Is the floating button visible?
□ Can you open the settings panel?
□ Are the desired options enabled?
□ Did you restart the app after changing settings?
□ Is the app one that CAN be bypassed? (Check limitations)
```

---

## 🆘 Still Not Working?

1. **Enable ALL options** including Nuclear modes
2. **Enable airplane mode** before making purchase
3. **Restart the app** after changing any settings
4. **Try different combinations** of options
5. **Check the logs** for specific error messages
6. **Accept that some apps cannot be bypassed** - server-authoritative systems are unbreakable without actual server access

---

## � Alternative Methods & Tools

### When Satella Fails - Try These Alternatives

| Failure Type | Alternative Method | Tools/Instructions |
|--------------|-------------------|-------------------|
| **Server validation still blocking** | Proxy interception | Use **Charles Proxy** or **mitmproxy** to manually modify API responses |
| **App detects Satella dylib** | Rename dylib | Rename `SatellaJailed.dylib` to match app's existing libraries |
| **Consumables reset on sync** | DNS blocking | Block `api.revenuecat.com`, `api.adapty.io` using **NextDNS** or Pi-hole |
| **Binary verification** | Memory editing | Use **GameGem** or **iGameGuardian** (jailbreak required) |
| **Custom encryption** | Binary patching | Use **Hopper Disassembler** or **IDA Pro** to patch checks |
| **Certificate pinning** | SSL bypass | Apply **SSL Kill Switch 2** methodology |

### Proxy Interception Setup

```
1. Install Charles Proxy or mitmproxy on your computer
2. Install SSL certificate on your iOS device
3. Configure device to use proxy
4. Intercept and modify these endpoints:
   - api.revenuecat.com/v1/subscribers/*
   - api.adapty.io/*
   - buy.itunes.apple.com/verifyReceipt
5. Replace response with success JSON
```

### DNS-Level Blocking

```
Block these domains to prevent server validation:
- api.revenuecat.com
- api.adapty.io
- api.qonversion.io
- api.glassfy.io
- buy.itunes.apple.com (caution: breaks real purchases)
```

### Recommended Tool Combinations

**For Subscription Apps:**
```
Satella (Receipt + Server Bypass + Stealth)
   ↓ If fails
Charles Proxy (intercept /subscriber endpoints)
   ↓ If fails
DNS blocking + Airplane mode
```

**For Games with Currency:**
```
Satella (Consumables + Server Bypass)
   ↓ If fails
Airplane mode (prevent sync)
   ↓ If fails
Memory editors (requires jailbreak)
   ↓ If fails
Look for modded IPA with offline mode
```

---

## 🐛 Code Bugs Fixed in v2.0.1

The following bugs were identified and fixed in the latest patch:

| Bug | File | Fix Applied |
|-----|------|-------------|
| **Deadlock in payment observer** | Observer.swift | Fixed lock/unlock sequence to prevent deadlocks |
| **Memory leak with dangling pointer** | DyldHook.swift | Changed to static buffer for crane path |
| **Force unwrap crash** | ServerVerificationHooks.swift | Added safe fallback for HTTPURLResponse creation |
| **Wrong date format in receipt** | ReceiptGenerator.swift | Fixed `originalPurchaseDateMs` type |
| **Duplicate transaction IDs** | TransactionHook.swift | Made matching ID and transaction ID unique |
| **Race condition in delegates** | Delegate.swift | Fixed lock handling for thread safety |
| **Exception handler not working** | ObjCExceptionCatcher.swift | Added proper tryExecute method |

---

## 📞 Getting Help

- Check the GitHub Issues page
- Include your device model and iOS version
- Include relevant log messages
- Specify which app you're trying to use
- List which options you've tried

---

## 🔄 Quick Decision Tree

```
App not working with Satella?
│
├─► Crashes on launch?
│   ├─► Check Console.app for [SatellaJailed] logs
│   ├─► Disable hooks one-by-one → Find culprit
│   └─► Try: Storage Bypass OFF first
│
├─► Purchase fails?
│   ├─► Online game? → ❌ Cannot bypass (server-authoritative)
│   ├─► Subscription app? → Enable Server Bypass + Receipt
│   ├─► Still fails? → Try Charles Proxy method
│   └─► RevenueCat app? → Nuclear mode + DNS blocking
│
├─► Works but reverts?
│   ├─► Enable Storage Bypass
│   ├─► Use Airplane mode permanently
│   └─► Block sync endpoints via DNS
│
├─► Detected/banned?
│   ├─► Enable Stealth mode
│   ├─► Rename dylib file
│   ├─► Use secondary account
│   └─► Consider: App may have anti-tamper
│
└─► Button not showing?
    ├─► Wait 2 seconds after app launch
    ├─► Use 3-finger tap gesture
    └─► Check if Preferences.isHidden = false
```

---

*Last updated: January 2026 - Satella Jailed v2.0.1*
