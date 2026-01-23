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
}

// MARK: - Known Limitations
/*
 Apps that Satella may NOT work with:
 
 1. Server-Side Validation with Custom Encryption
    - Apps that use their own encryption for receipt validation
    - Apps that require online authentication for features
 
 2. Feature Flags from Server
    - Apps that fetch premium features list from their server
    - The app code checks server response, not local purchase status
 
 3. Obfuscated StoreKit Calls
    - Apps that use heavy obfuscation on IAP code
    - Apps that use custom IAP wrappers with anti-tampering
 
 4. Cloud-Synced Purchases
    - Apps that verify purchases through iCloud
    - Apps requiring Apple ID sign-in for features
 
 5. Consumable IAPs with Server Tracking
    - Games that track currency/items on their server
    - Purchases must be verified server-side before granting items
 
 Workarounds to try:
 1. Enable ALL options (Observer, Receipt, Stealth)
 2. Disconnect from internet before purchasing
 3. Try different combinations of settings
 4. Some apps may need a restart after changing settings
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
        "EntitlementManager"
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
        "validatePurchase"
    ]
}
