import Foundation
import StoreKit

// MARK: - Satella Compatibility Checker
// This file helps diagnose why IAP bypass might not work for certain apps

final class SatellaCompatibilityChecker {
    static let shared = SatellaCompatibilityChecker()
    
    private init() {}
    
    /// Log current state for debugging
    func logDiagnostics() {
        NSLog("[SatellaJailed] === Diagnostics ===")
        NSLog("[SatellaJailed] iOS Version: \(UIDevice.current.systemVersion)")
        NSLog("[SatellaJailed] Device: \(deviceModel())")
        NSLog("[SatellaJailed] Jailbreak Required: \(requiresJailbreak() ? "Yes" : "NO - Stock iOS supported!")")
        NSLog("[SatellaJailed] Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")
        NSLog("[SatellaJailed] Tracked Products: \(SatellaDelegate.shared.products.count)")
        NSLog("[SatellaJailed] Tracked Payments: \(SatellaPaymentTracker.shared.getTrackedIdentifiers().count)")
        
        // Check if StoreKit is available
        NSLog("[SatellaJailed] Can Make Payments: \(SKPaymentQueue.canMakePayments())")
        
        // Check preferences
        NSLog("[SatellaJailed] Preferences:")
        NSLog("[SatellaJailed]   - Enabled: \(Preferences.isEnabled)")
        NSLog("[SatellaJailed]   - Observer: \(Preferences.isObserver)")
        NSLog("[SatellaJailed]   - Receipt: \(Preferences.isReceipt)")
        NSLog("[SatellaJailed]   - Stealth: \(Preferences.isStealth)")
        NSLog("[SatellaJailed]   - PriceZero: \(Preferences.isPriceZero)")
        NSLog("[SatellaJailed] === End Diagnostics ===")
    }
    
    /// Check what IAP methods the app uses
    func detectIAPImplementation() -> [String] {
        var methods: [String] = []
        
        // Check for StoreKit 1
        if NSClassFromString("SKPaymentQueue") != nil {
            methods.append("StoreKit 1 (SKPaymentQueue)")
        }
        
        // Check for StoreKit 2 (iOS 15+)
        if #available(iOS 15, *) {
            methods.append("StoreKit 2 (Product/Transaction)")
        }
        
        // Check for RevenueCat
        if NSClassFromString("RCPurchases") != nil || NSClassFromString("Purchases") != nil {
            methods.append("RevenueCat SDK")
        }
        
        // Check for SwiftyStoreKit
        if NSClassFromString("SwiftyStoreKit") != nil {
            methods.append("SwiftyStoreKit")
        }
        
        // Check for Qonversion
        if NSClassFromString("Qonversion") != nil {
            methods.append("Qonversion SDK")
        }
        
        // Check for Adapty
        if NSClassFromString("Adapty") != nil {
            methods.append("Adapty SDK")
        }
        
        // Check for Glassfy
        if NSClassFromString("Glassfy") != nil {
            methods.append("Glassfy SDK")
        }
        
        NSLog("[SatellaJailed] Detected IAP implementations: \(methods.joined(separator: ", "))")
        return methods
    }
    
    /// Get device model
    private func deviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    /// Check if current device is iPhone 17 Pro Max
    func isiPhone17ProMax() -> Bool {
        let model = deviceModel()
        // iPhone 17 Pro Max identifiers (iPhone18,x series expected)
        // Also check for simulator running iPhone 17 Pro Max
        return model.hasPrefix("iPhone18,") || 
               model.contains("iPhone17") ||
               UIDevice.current.name.lowercased().contains("iphone 17 pro max")
    }
    
    /// Check if jailbreak is required for current device
    /// iPhone 17 Pro Max does NOT require jailbreak - works on stock iOS 19!
    func requiresJailbreak() -> Bool {
        // iPhone 17 Pro Max works without jailbreak on iOS 19
        if isiPhone17ProMax() {
            return false
        }
        
        // iOS 19+ devices generally don't need jailbreak with modern sideloading
        if #available(iOS 19, *) {
            return false
        }
        
        // For older iOS versions, jailbreak provides better compatibility
        // but is still not strictly required with TrollStore/sideloading
        return false
    }
    
    /// Get human-readable device name
    func deviceDisplayName() -> String {
        if isiPhone17ProMax() {
            return "iPhone 17 Pro Max (No Jailbreak Required!)"
        }
        return UIDevice.current.name
    }
}

// MARK: - Bypass Capabilities (v2.0.0+)
/*
 With Nuclear Server Bypass enabled, Satella can now handle:
 
 ✅ NOW SUPPORTED:
 1. Server-Side Validation - Intercepts API responses from RevenueCat, Adapty, 
    Qonversion, Glassfy, Superwall, Purchasely, Nami ML, and custom servers
 
 2. Feature Flags from Server - Modifies JSON responses to enable all premium features
 
 3. Server-tracked consumables - Sets coins/gems/credits to 999,999,999 in responses
 
 4. Authentication bypasses - Generates fake auth tokens for premium user status
 
 5. UserDefaults/local storage - Hooks premium check methods to return true
 
 ❌ STILL CHALLENGING (Enable Stealth + Offline mode):
 1. Certificate pinning with custom TLS validation
 2. Binary-encrypted responses (custom encryption schemes)  
 3. Server-authoritative games (MMOs where items only exist on their servers)
 4. Apps with advanced anti-tamper/integrity checks
 
 💡 PRO TIPS:
 1. Enable ALL Nuclear options for stubborn apps
 2. Also enable Receipt + Stealth
 3. Try offline/airplane mode if app supports it
 4. Restart app after changing settings
 5. For games: make purchase, cancel Apple ID popup, check if items granted
*/

// MARK: - App-Specific Patterns

struct AppPatterns {
    /// Common class names for premium/subscription checking
    static let premiumCheckClasses = [
        "PremiumManager",
        "SubscriptionManager", 
        "IAPManager",
        "StoreManager",
        "PurchaseManager",
        "ProManager",
        "UnlockManager",
        "EntitlementManager",
        "RevenueCat",
        "RCPurchases",
        "Purchases",
        "Adapty", 
        "Qonversion",
        "Glassfy"
    ]
    
    /// Common method patterns for checking premium status
    static let premiumCheckMethods = [
        "isPremium",
        "isPro",
        "isSubscribed",
        "hasSubscription",
        "isUnlocked",
        "hasPurchased",
        "checkEntitlement",
        "validatePurchase",
        "hasActiveSubscription",
        "isEntitled",
        "getCustomerInfo",
        "restorePurchases"
    ]
}
