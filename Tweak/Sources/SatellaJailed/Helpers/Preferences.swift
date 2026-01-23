import Foundation

private struct _Preferences {
    func get<T>(
        for key: String,
        default val: T
    ) -> T {
        UserDefaults.standard.object(forKey: key) as? T ?? val
    }
}

private let prefs = _Preferences()

struct Preferences {
    static let isEnabled: Bool   = prefs.get(for: "tella_isEnabled",   default: true)
    static let isGesture: Bool   = prefs.get(for: "tella_isGesture",   default: true)
    static let isHidden: Bool    = prefs.get(for: "tella_isHidden",    default: false)
    static let isObserver: Bool  = prefs.get(for: "tella_isObserver",  default: false)
    static let isPriceZero: Bool = prefs.get(for: "tella_isPriceZero", default: false)
    static let isReceipt: Bool   = prefs.get(for: "tella_isReceipt",   default: false)
    static let isStealth: Bool   = prefs.get(for: "tella_isStealth",   default: false)
    
    // Advanced Server Bypass Options (for stubborn apps)
    static let isServerBypass: Bool    = prefs.get(for: "tella_isServerBypass",    default: false)
    static let isDefaultsBypass: Bool  = prefs.get(for: "tella_isDefaultsBypass",  default: false)
    static let isConsumables: Bool     = prefs.get(for: "tella_isConsumables",     default: false)
    static let isAuthBypass: Bool      = prefs.get(for: "tella_isAuthBypass",      default: false)
}
