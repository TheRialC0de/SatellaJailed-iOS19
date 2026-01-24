AppSelector
=================

Small SwiftUI app source you can add to an Xcode iOS project. It lists installed apps (uses private API) and lets you select one app. The selected app's bundle identifier is written to `/var/mobile/Library/Preferences/com.satella.selected.plist`.

Requirements & notes
- Build on macOS with Xcode targeting an iPhone device.
- This app uses private APIs (LSApplicationWorkspace) to enumerate installed apps; it will not be App-Store compliant.
- On a non-jailbroken device the app may not be able to write to `/var/mobile/Library/Preferences/` due to sandboxing/permissions. On a jailbroken device the file is useful for your tweak to read.

How to use
1. Create a new iOS App project in Xcode (SwiftUI, iOS target).
2. Add the Swift files from `Sources/` into the project.
3. Build and run on a device (preferably jailbroken for full functionality).
4. Open the app, select an installed app, then tap "Save Selection".

Tweak integration
- Configure your tweak to read `/var/mobile/Library/Preferences/com.satella.selected.plist` and apply behavior to the chosen bundle identifier.

If you want, I can also scaffold an `.xcodeproj` / entitlements and adjust the app to use an App Group or alternative storage method.
