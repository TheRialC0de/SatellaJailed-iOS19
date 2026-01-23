import Jinx
import StoreKit

// MARK: - StoreKit 2 Support for iOS 15+
// Many modern apps use the new async StoreKit 2 API

@available(iOS 15, *)
struct StoreKit2Hooks {
    
    /// Hook for Product.purchase() result
    static func setupHooks() {
        // StoreKit 2 uses Swift concurrency, harder to hook directly
        // We intercept at the Transaction verification level instead
        
        // Start a background task to auto-finish unfinished transactions
        Task {
            await finishAllTransactions()
        }
    }
    
    /// Finish all unfinished transactions to simulate successful purchases
    static func finishAllTransactions() async {
        for await result in Transaction.unfinished {
            if case .verified(let transaction) = result {
                await transaction.finish()
            } else if case .unverified(let transaction, _) = result {
                // Finish even unverified transactions
                await transaction.finish()
            }
        }
    }
    
    /// Check entitlement for a product (always return true)
    static func hasEntitlement(for productID: String) async -> Bool {
        return true
    }
}

// MARK: - App Receipt Hook
// Some apps check the main bundle receipt directly

struct AppReceiptHook: Hook {
    typealias T = @convention(c) (AnyObject, Selector) -> URL?
    
    let cls: AnyClass? = Bundle.self
    let sel: Selector = #selector(getter: Bundle.appStoreReceiptURL)
    let replace: T = { obj, sel in
        // Return a valid-looking receipt URL
        // The actual receipt data is handled by ReceiptHook
        let originalURL = orig(obj, sel)
        return originalURL
    }
}

// MARK: - SKReceiptRefreshRequest Hook
// Some apps force refresh receipt from Apple

struct ReceiptRefreshHook: Hook {
    typealias T = @convention(c) (AnyObject, Selector) -> Void
    
    let cls: AnyClass? = NSClassFromString("SKReceiptRefreshRequest")
    let sel: Selector = #selector(SKRequest.start)
    let replace: T = { obj, sel in
        // Don't actually refresh from Apple, just notify delegate of success
        if let request = obj as? SKRequest,
           let delegate = request.delegate {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                delegate.requestDidFinish?(request)
            }
        }
    }
}

// MARK: - SKPayment applicationUsername Hook
// Some apps use this for user verification

struct PaymentUserHook: Hook {
    typealias T = @convention(c) (AnyObject, Selector) -> String?
    
    let cls: AnyClass? = SKPayment.self
    let sel: Selector = #selector(getter: SKPayment.applicationUsername)
    let replace: T = { obj, _ in
        // Return a consistent fake username
        return "satella_user_\(UUID().uuidString.prefix(8))"
    }
}

// MARK: - SKStorefront Hook (for region checks)
// Some apps check the storefront/region

@available(iOS 13, *)
struct StorefrontHook: Hook {
    typealias T = @convention(c) (AnyObject, Selector) -> String
    
    let cls: AnyClass? = SKPaymentQueue.self
    let sel: Selector = sel_registerName("storefront")
    let replace: T = { obj, sel in
        // Return US storefront
        return "USA"
    }
}

// MARK: - Additional Transaction Properties

struct TransactionDownloadsHook: Hook {
    typealias T = @convention(c) (AnyObject, Selector) -> [Any]
    
    let cls: AnyClass? = SKPaymentTransaction.self
    let sel: Selector = #selector(getter: SKPaymentTransaction.downloads)
    let replace: T = { _, _ in
        // Return empty downloads array (no hosted content to download)
        return []
    }
}

// MARK: - SKProduct Subscription Period Hook

@available(iOS 11.2, *)
struct SubscriptionPeriodHook: Hook {
    typealias T = @convention(c) (AnyObject, Selector) -> AnyObject?
    
    let cls: AnyClass? = SKProduct.self
    let sel: Selector = #selector(getter: SKProduct.subscriptionPeriod)
    let replace: T = { obj, sel in
        // Return original or create a yearly period
        if let original = orig(obj, sel) {
            return original
        }
        // Some apps check this for subscription status
        return nil
    }
}

// MARK: - SKProduct Introductory Price Hook

@available(iOS 11.2, *)
struct IntroductoryPriceHook: Hook {
    typealias T = @convention(c) (AnyObject, Selector) -> AnyObject?
    
    let cls: AnyClass? = SKProduct.self
    let sel: Selector = #selector(getter: SKProduct.introductoryPrice)
    let replace: T = { _, _ in
        // Return nil - no introductory price needed
        return nil
    }
}

// MARK: - Subscription Status Check Hook
// Many apps check subscription status via this

@available(iOS 13, *)
struct SubscriptionStatusHook {
    static func hook() {
        // Hook entitlement verification methods commonly used
        hookEntitlementManager()
    }
    
    private static func hookEntitlementManager() {
        // Common patterns apps use for checking purchases
        // RevenueCat: Purchases.shared.getCustomerInfo
        // SwiftyStoreKit: SwiftyStoreKit.verifyReceipt
        // These are app-specific and harder to hook generically
    }
}
