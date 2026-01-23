import Jinx
import StoreKit

struct TransactionHook: HookGroup {
    typealias T0 = @convention(c) (AnyObject, Selector) -> SKPaymentTransactionState
    typealias T1 = @convention(c) (AnyObject, Selector) -> String
    typealias T2 = @convention(c) (AnyObject, Selector) -> String
    typealias T3 = @convention(c) (AnyObject, Selector) -> Error?
    typealias T4 = @convention(c) (AnyObject, Selector) -> Date
    typealias T5 = @convention(c) (AnyObject, Selector) -> SKPaymentTransaction?

    let cls: AnyClass? = SKPaymentTransaction.self

    let sel0: Selector = #selector(getter: SKPaymentTransaction.transactionState)
    let sel1: Selector = sel_registerName("matchingIdentifier")
    let sel2: Selector = #selector(getter: SKPaymentTransaction.transactionIdentifier)
    let sel3: Selector = #selector(getter: SKPaymentTransaction.error)
    let sel4: Selector = #selector(getter: SKPaymentTransaction.transactionDate)
    let sel5: Selector = #selector(getter: SKPaymentTransaction.original)

    // Return purchased state for successful transaction simulation
    let replace0: T0 = { obj, sel in
        // Check if this is a restore transaction
        if let payment = (obj as? SKPaymentTransaction)?.payment,
           payment.productIdentifier.isEmpty == false {
            return .purchased
        }
        return .purchased
    }
    
    // Generate consistent transaction identifiers
    let replace1: T1 = { obj, _ in
        // Use product identifier as seed for consistent ID
        if let transaction = obj as? SKPaymentTransaction {
            return "satella_\(transaction.payment.productIdentifier.hashValue)_\(Int(Date().timeIntervalSince1970))"
        }
        return UUID().uuidString
    }
    
    let replace2: T2 = { obj, _ in
        if let transaction = obj as? SKPaymentTransaction {
            return "satella_\(transaction.payment.productIdentifier.hashValue)_\(Int(Date().timeIntervalSince1970))"
        }
        return UUID().uuidString
    }
    
    // Return nil error for successful transaction
    let replace3: T3 = { _, _ in nil }
    
    // Return current date
    let replace4: T4 = { _, _ in Date() }
    
    // Return nil for original transaction (not a restore)
    let replace5: T5 = { _, _ in nil }
}
