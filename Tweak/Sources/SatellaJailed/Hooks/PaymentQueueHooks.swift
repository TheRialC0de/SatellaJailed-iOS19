import Jinx
import StoreKit

// MARK: - Restore Purchases Hook
// Intercept restore purchases to make them always succeed

struct RestorePurchasesHook: Hook {
    typealias T = @convention(c) (SKPaymentQueue, Selector) -> Void
    
    let cls: AnyClass? = SKPaymentQueue.self
    let sel: Selector = #selector(SKPaymentQueue.restoreCompletedTransactions)
    let replace: T = { obj, sel in
        // Call original to trigger the flow
        orig(obj, sel)
        
        // Notify observers of successful restore after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // The transaction observer will handle the success state
            NotificationCenter.default.post(
                name: NSNotification.Name("SatellaRestoreComplete"),
                object: nil
            )
        }
    }
}

// MARK: - Finish Transaction Hook
// Ensure transactions can always be finished

struct FinishTransactionHook: Hook {
    typealias T = @convention(c) (SKPaymentQueue, Selector, SKPaymentTransaction) -> Void
    
    let cls: AnyClass? = SKPaymentQueue.self
    let sel: Selector = #selector(SKPaymentQueue.finishTransaction(_:))
    let replace: T = { obj, sel, transaction in
        // Always allow finishing
        orig(obj, sel, transaction)
    }
}

// MARK: - Add Payment Hook
// Intercept when payments are added to the queue

struct AddPaymentHook: Hook {
    typealias T = @convention(c) (SKPaymentQueue, Selector, SKPayment) -> Void
    
    let cls: AnyClass? = SKPaymentQueue.self
    let sel: Selector = #selector(SKPaymentQueue.add(_:) as (SKPaymentQueue) -> (SKPayment) -> Void)
    let replace: T = { obj, sel, payment in
        // Store the payment for receipt generation
        if !payment.productIdentifier.isEmpty {
            SatellaPaymentTracker.shared.trackPayment(payment)
        }
        
        // Call original - our transaction hooks will make it succeed
        orig(obj, sel, payment)
    }
}

// MARK: - Payment Tracker
// Track payments for accurate receipt generation

final class SatellaPaymentTracker {
    static let shared = SatellaPaymentTracker()
    
    private let lock = NSLock()
    private var payments: [SKPayment] = []
    private var productIdentifiers: Set<String> = []
    
    private init() {}
    
    func trackPayment(_ payment: SKPayment) {
        lock.lock()
        defer { lock.unlock() }
        
        payments.append(payment)
        productIdentifiers.insert(payment.productIdentifier)
        
        // Keep only last 50 payments to prevent memory bloat
        if payments.count > 50 {
            payments.removeFirst()
        }
    }
    
    func getTrackedIdentifiers() -> Set<String> {
        lock.lock()
        defer { lock.unlock() }
        return productIdentifiers
    }
    
    func getLastPayment() -> SKPayment? {
        lock.lock()
        defer { lock.unlock() }
        return payments.last
    }
    
    func hasPayment(for productId: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return productIdentifiers.contains(productId)
    }
}

// MARK: - Deferred Transaction Hook
// Some apps use deferred transactions (Ask to Buy)

struct DeferredTransactionHook: Hook {
    typealias T = @convention(c) (AnyObject, Selector) -> Bool
    
    let cls: AnyClass? = SKPaymentTransaction.self
    let sel: Selector = sel_registerName("isDeferred")
    let replace: T = { _, _ in
        // Never deferred - always immediate
        return false
    }
}

// MARK: - Transaction Queue Hook
// Hook the transactions property of SKPaymentQueue

struct QueueTransactionsHook: Hook {
    typealias T = @convention(c) (SKPaymentQueue, Selector) -> [SKPaymentTransaction]
    
    let cls: AnyClass? = SKPaymentQueue.self
    let sel: Selector = #selector(getter: SKPaymentQueue.transactions)
    let replace: T = { obj, sel in
        let original = orig(obj, sel)
        
        // Return original transactions - our other hooks modify their state
        return original
    }
}
