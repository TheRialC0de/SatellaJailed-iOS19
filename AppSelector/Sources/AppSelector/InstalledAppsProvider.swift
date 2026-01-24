import Foundation

final class InstalledAppsProvider {
    /// Returns an array of InstalledApp by calling private API LSApplicationWorkspace.
    /// This uses runtime selectors and will only work on devices where the private API exists (iOS, jailbroken or with private frameworks available).
    static func fetchInstalledApps() -> [InstalledApp] {
        var results: [InstalledApp] = []

        guard let workspaceClass = NSClassFromString("LSApplicationWorkspace") else {
            return []
        }

        let selDefault = NSSelectorFromString("defaultWorkspace")
        guard let workspaceUnk = (workspaceClass as AnyObject).perform(selDefault)?.takeUnretainedValue() else {
            return []
        }

        let selAll = NSSelectorFromString("allApplications")
        guard let appsObj = (workspaceUnk as AnyObject).perform(selAll)?.takeUnretainedValue() as? [AnyObject] else {
            return []
        }

        for appProxy in appsObj {
            let bundleId = (appProxy as AnyObject).perform(NSSelectorFromString("applicationIdentifier"))?.takeUnretainedValue() as? String
                ?? (appProxy as AnyObject).perform(NSSelectorFromString("bundleIdentifier"))?.takeUnretainedValue() as? String
                ?? ""

            let name = (appProxy as AnyObject).perform(NSSelectorFromString("localizedName"))?.takeUnretainedValue() as? String
                ?? (appProxy as AnyObject).perform(NSSelectorFromString("localizedDisplayName"))?.takeUnretainedValue() as? String
                ?? bundleId

            if !bundleId.isEmpty {
                results.append(InstalledApp(bundleId: bundleId, name: name))
            }
        }

        // Sort by name
        results.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        return results
    }

    /// Persist selected bundle identifier to a preferences plist that your tweak can read.
    /// On jailbroken devices this path is commonly readable by tweaks: /var/mobile/Library/Preferences/
    static func saveSelected(bundleId: String) throws {
        let dict: [String: Any] = ["selectedBundleId": bundleId]
        let data = try PropertyListSerialization.data(fromPropertyList: dict, format: .xml, options: 0)
        let prefsPath = "/var/mobile/Library/Preferences/com.satella.selected.plist"
        try data.write(to: URL(fileURLWithPath: prefsPath))
    }
}
