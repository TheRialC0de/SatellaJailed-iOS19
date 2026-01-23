import Foundation
import Jinx
import UIKit

// MARK: - Advanced Server Bypass System
// Comprehensive bypass for server-side validation, feature flags, and consumables

// ============================================================================
// SECTION 1: Feature Flags & Premium Status Bypass
// ============================================================================

/// Intercept ALL network responses and modify premium/feature-related data
struct NetworkResponseInterceptor {
    
    /// Keywords indicating premium/subscription status in JSON responses
    static let premiumKeywords: Set<String> = [
        "is_premium", "isPremium", "is_pro", "isPro",
        "is_subscribed", "isSubscribed", "has_subscription", "hasSubscription",
        "subscription_active", "subscriptionActive", "subscription_status",
        "is_entitled", "isEntitled", "has_entitlement", "hasEntitlement",
        "premium_user", "premiumUser", "pro_user", "proUser",
        "is_vip", "isVip", "vip_status", "vipStatus",
        "is_unlocked", "isUnlocked", "unlocked",
        "has_access", "hasAccess", "access_level", "accessLevel",
        "is_paid", "isPaid", "paid_user", "paidUser",
        "feature_unlocked", "featureUnlocked",
        "subscription_type", "subscriptionType",
        "trial_active", "trialActive", "in_trial", "inTrial",
        "is_active", "isActive", "active",
        "premium", "pro", "vip", "gold", "platinum"
    ]
    
    /// Keywords indicating feature flags
    static let featureFlagKeywords: Set<String> = [
        "features", "feature_flags", "featureFlags",
        "enabled_features", "enabledFeatures",
        "premium_features", "premiumFeatures",
        "locked_features", "lockedFeatures",
        "available_features", "availableFeatures",
        "permissions", "entitlements", "capabilities",
        "flags", "config", "configuration",
        "remote_config", "remoteConfig",
        "ab_test", "abTest", "experiments"
    ]
    
    /// Keywords indicating consumables (coins, gems, etc.)
    static let consumableKeywords: Set<String> = [
        "coins", "gems", "diamonds", "crystals", "gold",
        "credits", "tokens", "points", "stars", "hearts",
        "energy", "lives", "stamina", "fuel",
        "currency", "balance", "wallet",
        "coins_balance", "coinsBalance",
        "gems_balance", "gemsBalance",
        "virtual_currency", "virtualCurrency",
        "in_game_currency", "inGameCurrency"
    ]
    
    /// Modify JSON response to enable premium features
    static func modifyResponse(_ data: Data, for url: URL) -> Data {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
            return data
        }
        
        var modified = false
        let modifiedObject = modifyJSONObject(jsonObject, modified: &modified)
        
        if modified, let newData = try? JSONSerialization.data(withJSONObject: modifiedObject, options: []) {
            NSLog("[SatellaJailed] Modified server response for: \(url.host ?? "unknown")")
            return newData
        }
        
        return data
    }
    
    private static func modifyJSONObject(_ object: Any, modified: inout Bool) -> Any {
        if var dict = object as? [String: Any] {
            for (key, value) in dict {
                let lowercaseKey = key.lowercased()
                
                // Modify premium/subscription status to true
                if premiumKeywords.contains(where: { lowercaseKey.contains($0.lowercased()) }) {
                    if value is Bool {
                        dict[key] = true
                        modified = true
                    } else if value is String {
                        let strValue = (value as! String).lowercased()
                        if strValue == "false" || strValue == "inactive" || strValue == "expired" || strValue == "free" {
                            dict[key] = "active"
                            modified = true
                        }
                    } else if value is Int {
                        dict[key] = 1
                        modified = true
                    }
                }
                
                // Modify consumable values to maximum
                if consumableKeywords.contains(where: { lowercaseKey.contains($0.lowercased()) }) {
                    if value is Int {
                        dict[key] = 999999999
                        modified = true
                    } else if value is Double {
                        dict[key] = 999999999.0
                        modified = true
                    } else if value is String, let _ = Int(value as! String) {
                        dict[key] = "999999999"
                        modified = true
                    }
                }
                
                // Handle expiry dates - set to far future
                if lowercaseKey.contains("expir") || lowercaseKey.contains("expire") || 
                   lowercaseKey.contains("valid_until") || lowercaseKey.contains("end_date") {
                    let futureDate = Int(Date().timeIntervalSince1970) + (10 * 365 * 24 * 60 * 60) // 10 years
                    if value is Int {
                        dict[key] = futureDate
                        modified = true
                    } else if value is String {
                        dict[key] = "\(futureDate)"
                        modified = true
                    }
                }
                
                // Recursively process nested objects
                dict[key] = modifyJSONObject(value, modified: &modified)
            }
            return dict
        } else if var array = object as? [Any] {
            for i in 0..<array.count {
                array[i] = modifyJSONObject(array[i], modified: &modified)
            }
            return array
        }
        
        return object
    }
}

// ============================================================================
// SECTION 2: Universal Network Interceptor
// ============================================================================

/// Hook URLSession to intercept ALL responses, not just verification endpoints
struct UniversalURLSessionHook: Hook {
    typealias URLHandler = @Sendable (Data?, URLResponse?, Error?) -> Void
    typealias T = @convention(c) (URLSession, Selector, URLRequest, @escaping URLHandler) -> URLSessionDataTask
    
    let cls: AnyClass? = URLSession.self
    let sel: Selector = sel_registerName("dataTaskWithRequest:completionHandler:")
    let replace: T = { obj, sel, request, handler in
        // Check if this is a verification endpoint (handle as before)
        if ServerVerificationHooks.isVerificationURL(request.url) {
            let newHandler: URLHandler = { (_, response, error) in
                autoreleasepool {
                    let url = request.url ?? URL(string: "https://buy.itunes.apple.com/verifyReceipt")!
                    let (data, httpResponse) = ServerVerificationHooks.generateSuccessResponse(for: url)
                    handler(data, httpResponse, nil)
                }
            }
            return orig(obj, sel, request, newHandler)
        }
        
        // For all other requests, intercept and modify the response
        let newHandler: URLHandler = { (data, response, error) in
            autoreleasepool {
                guard let data = data, let url = request.url else {
                    handler(data, response, error)
                    return
                }
                
                // Check if response might contain premium/feature data
                if AdvancedBypassConfig.isServerBypassEnabled {
                    let modifiedData = NetworkResponseInterceptor.modifyResponse(data, for: url)
                    handler(modifiedData, response, error)
                } else {
                    handler(data, response, error)
                }
            }
        }
        
        return orig(obj, sel, request, newHandler)
    }
}

// ============================================================================
// SECTION 3: UserDefaults & Keychain Bypass
// ============================================================================

/// Hook UserDefaults to always return premium values for known keys
struct UserDefaultsPremiumHook: Hook {
    typealias T = @convention(c) (UserDefaults, Selector, String) -> Any?
    
    let cls: AnyClass? = UserDefaults.self
    let sel: Selector = #selector(UserDefaults.object(forKey:))
    let replace: T = { obj, sel, key in
        let lowercaseKey = key.lowercased()
        
        // Check for Satella's own keys first - don't modify those
        if key.hasPrefix("tella_") {
            return orig(obj, sel, key)
        }
        
        // Check for premium/subscription keys
        if NetworkResponseInterceptor.premiumKeywords.contains(where: { lowercaseKey.contains($0.lowercased()) }) {
            NSLog("[SatellaJailed] Intercepted UserDefaults key: \(key) -> true")
            return true
        }
        
        // Check for consumable keys
        if NetworkResponseInterceptor.consumableKeywords.contains(where: { lowercaseKey.contains($0.lowercased()) }) {
            NSLog("[SatellaJailed] Intercepted consumable key: \(key) -> 999999999")
            return 999999999
        }
        
        return orig(obj, sel, key)
    }
}

/// Hook UserDefaults bool method specifically
struct UserDefaultsBoolHook: Hook {
    typealias T = @convention(c) (UserDefaults, Selector, String) -> Bool
    
    let cls: AnyClass? = UserDefaults.self
    let sel: Selector = #selector(UserDefaults.bool(forKey:))
    let replace: T = { obj, sel, key in
        let lowercaseKey = key.lowercased()
        
        // Don't modify Satella's keys
        if key.hasPrefix("tella_") {
            return orig(obj, sel, key)
        }
        
        // Premium status keys should return true
        if NetworkResponseInterceptor.premiumKeywords.contains(where: { lowercaseKey.contains($0.lowercased()) }) {
            NSLog("[SatellaJailed] Intercepted bool key: \(key) -> true")
            return true
        }
        
        // Locked/disabled keys should return false (unlocked)
        if lowercaseKey.contains("locked") || lowercaseKey.contains("disabled") || 
           lowercaseKey.contains("restricted") || lowercaseKey.contains("limit") {
            return false
        }
        
        return orig(obj, sel, key)
    }
}

// ============================================================================
// SECTION 4: Date/Time Manipulation for Trial Bypass
// ============================================================================

/// Hook Date() to return older dates for trial checks
struct DateHook {
    static var dateOffset: TimeInterval = 0
    
    /// Set time offset to extend trials
    static func extendTrial(by days: Int) {
        dateOffset = -Double(days * 24 * 60 * 60)
    }
}

// ============================================================================
// SECTION 5: Authentication Token Bypass
// ============================================================================

/// Common authentication response generator
struct AuthBypass {
    
    /// Generate a fake successful auth response
    static func generateAuthSuccess() -> Data {
        let now = Int(Date().timeIntervalSince1970)
        let expiry = now + (365 * 24 * 60 * 60)
        
        return Data("""
        {
            "success": true,
            "authenticated": true,
            "token": "satella_token_\(UUID().uuidString)",
            "access_token": "satella_access_\(UUID().uuidString)",
            "refresh_token": "satella_refresh_\(UUID().uuidString)",
            "user": {
                "id": "\(UUID().uuidString)",
                "premium": true,
                "is_premium": true,
                "subscription_status": "active",
                "subscription_type": "lifetime",
                "entitlements": ["premium", "pro", "unlimited"],
                "coins": 999999999,
                "gems": 999999999
            },
            "expires_at": \(expiry),
            "expires_in": 31536000
        }
        """.utf8)
    }
    
    /// Check if URL is an auth endpoint
    static func isAuthEndpoint(_ url: URL?) -> Bool {
        guard let url = url,
              let urlString = url.absoluteString.lowercased() as String? else { 
            return false 
        }
        
        let authPatterns = [
            "/auth", "/login", "/signin", "/sign-in",
            "/oauth", "/token", "/session",
            "/api/auth", "/api/login", "/api/user",
            "/v1/auth", "/v2/auth",
            "auth.", "login.", "api."
        ]
        
        return authPatterns.contains { urlString.contains($0) }
    }
}

// ============================================================================
// SECTION 6: SDK-Specific Bypasses
// ============================================================================

/// RevenueCat SDK Bypass
struct RevenueCatBypass {
    
    /// Check if class is from RevenueCat
    static func isRevenueCatClass(_ className: String) -> Bool {
        return className.hasPrefix("RC") || className.contains("RevenueCat") || className.contains("Purchases")
    }
    
    /// RevenueCat API endpoints
    static let revenueCatEndpoints = [
        "api.revenuecat.com",
        "api.rc-backup.com"
    ]
    
    static func isRevenueCatURL(_ url: URL?) -> Bool {
        guard let host = url?.host?.lowercased() else { return false }
        return revenueCatEndpoints.contains { host.contains($0) }
    }
    
    /// Generate RevenueCat-style success response
    static func generateSuccessResponse(for productId: String) -> Data {
        let now = ISO8601DateFormatter().string(from: Date())
        let future = ISO8601DateFormatter().string(from: Date().addingTimeInterval(10 * 365 * 24 * 60 * 60))
        
        return Data("""
        {
            "request_date": "\(now)",
            "request_date_ms": \(Int(Date().timeIntervalSince1970 * 1000)),
            "subscriber": {
                "entitlements": {
                    "premium": {
                        "expires_date": "\(future)",
                        "product_identifier": "\(productId)",
                        "purchase_date": "\(now)"
                    },
                    "pro": {
                        "expires_date": "\(future)",
                        "product_identifier": "\(productId)",
                        "purchase_date": "\(now)"
                    }
                },
                "first_seen": "\(now)",
                "original_app_user_id": "satella_user",
                "subscriptions": {
                    "\(productId)": {
                        "expires_date": "\(future)",
                        "is_sandbox": false,
                        "original_purchase_date": "\(now)",
                        "purchase_date": "\(now)",
                        "store": "app_store",
                        "unsubscribe_detected_at": null
                    }
                },
                "non_subscriptions": {}
            }
        }
        """.utf8)
    }
}

/// Adapty SDK Bypass
struct AdaptyBypass {
    static let adaptyEndpoints = ["api.adapty.io", "api-backup.adapty.io"]
    
    static func isAdaptyURL(_ url: URL?) -> Bool {
        guard let host = url?.host?.lowercased() else { return false }
        return adaptyEndpoints.contains { host.contains($0) }
    }
    
    static func generateSuccessResponse() -> Data {
        return Data("""
        {
            "data": {
                "type": "adapty_profile",
                "attributes": {
                    "paid_access_levels": {
                        "premium": {
                            "is_active": true,
                            "is_lifetime": true,
                            "will_renew": true,
                            "is_in_grace_period": false
                        }
                    },
                    "subscriptions": {},
                    "non_subscriptions": {}
                }
            }
        }
        """.utf8)
    }
}

/// Qonversion SDK Bypass  
struct QonversionBypass {
    static let qonversionEndpoints = ["api.qonversion.io"]
    
    static func isQonversionURL(_ url: URL?) -> Bool {
        guard let host = url?.host?.lowercased() else { return false }
        return qonversionEndpoints.contains { host.contains($0) }
    }
    
    static func generateSuccessResponse() -> Data {
        let future = Int(Date().timeIntervalSince1970 * 1000) + (10 * 365 * 24 * 60 * 60 * 1000)
        return Data("""
        {
            "data": {
                "uid": "satella_user",
                "entitlements": {
                    "premium": {
                        "is_active": true,
                        "expires": \(future)
                    }
                },
                "products": {},
                "permissions": {
                    "premium": {
                        "is_active": true,
                        "renew_state": "will_renew"
                    }
                }
            },
            "success": true
        }
        """.utf8)
    }
}

// ============================================================================
// SECTION 7: Configuration
// ============================================================================

/// Advanced bypass configuration
struct AdvancedBypassConfig {
    /// Enable server response modification
    static var isServerBypassEnabled: Bool {
        UserDefaults.standard.bool(forKey: "tella_isServerBypass")
    }
    
    /// Enable UserDefaults interception
    static var isDefaultsBypassEnabled: Bool {
        UserDefaults.standard.bool(forKey: "tella_isDefaultsBypass")
    }
    
    /// Enable consumables modification (coins/gems)
    static var isConsumablesBypassEnabled: Bool {
        UserDefaults.standard.bool(forKey: "tella_isConsumables")
    }
}

// ============================================================================
// SECTION 8: Setup All Advanced Hooks
// ============================================================================

struct AdvancedServerBypass {
    
    static func setupAllHooks() {
        NSLog("[SatellaJailed] Setting up advanced server bypass hooks...")
        
        // Network interception is enabled via URLHook already
        // Additional hooks for specific SDKs
        
        if AdvancedBypassConfig.isDefaultsBypassEnabled {
            UserDefaultsPremiumHook().hook()
            UserDefaultsBoolHook().hook()
        }
        
        NSLog("[SatellaJailed] Advanced bypass hooks initialized")
    }
}
