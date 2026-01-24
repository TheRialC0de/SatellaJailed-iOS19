import Foundation

struct InstalledApp: Identifiable, Hashable {
    let id: String
    let bundleId: String
    let name: String

    init(bundleId: String, name: String) {
        self.bundleId = bundleId
        self.name = name
        self.id = bundleId
    }
}
