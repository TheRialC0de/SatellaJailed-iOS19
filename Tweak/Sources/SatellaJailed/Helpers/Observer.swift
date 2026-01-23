import StoreKit

final class SatellaObserver: NSObject, SKPaymentTransactionObserver {
    static let shared: SatellaObserver = .init()
    var observers: [SKPaymentTransactionObserver] = []
    private let lock = NSLock()

    func paymentQueue(
        _ queue: SKPaymentQueue,
        updatedTransactions transactions: [SKPaymentTransaction]
    ) {
        lock.lock()
        defer { lock.unlock() }
        
        var current: [SKPaymentTransaction] = []
        
        // Prevent multiple purchases from occupying the same memory (fix some crash)
        // Use thread-safe check with identity comparison
        for transaction in transactions {
            let isDuplicate = purchases.contains(where: { ObjectIdentifier($0) == ObjectIdentifier(transaction) })
            guard !isDuplicate else { continue }  // Use continue instead of return to process remaining
            current.append(transaction)
            purchases.append(transaction)
        }
        
        // Clean up old purchases to prevent memory leak (keep last 100)
        if purchases.count > 100 {
            purchases.removeFirst(purchases.count - 100)
        }
        
        guard !current.isEmpty else { return }
        
        // Safely notify observers
        let observersCopy = observers
        lock.unlock()
        
        for observer in observersCopy {
            autoreleasepool {
                observer.paymentQueue(queue, updatedTransactions: current)
            }
        }
        
        lock.lock()
    }
    
    // iOS 19 compatibility - implement required protocol methods
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        observers.forEach { observer in
            if observer.responds(to: #selector(SKPaymentTransactionObserver.paymentQueueRestoreCompletedTransactionsFinished(_:))) {
                observer.paymentQueueRestoreCompletedTransactionsFinished?(queue)
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        observers.forEach { observer in
            if observer.responds(to: #selector(SKPaymentTransactionObserver.paymentQueue(_:restoreCompletedTransactionsFailedWithError:))) {
                observer.paymentQueue?(queue, restoreCompletedTransactionsFailedWithError: error)
            }
        }
    }

    private var purchases: [SKPaymentTransaction] = []
}
