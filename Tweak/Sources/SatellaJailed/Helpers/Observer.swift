import StoreKit

final class SatellaObserver: NSObject, SKPaymentTransactionObserver {
    static let shared: SatellaObserver = .init()
    var observers: [SKPaymentTransactionObserver] = []
    private let lock = NSLock()

    func paymentQueue(
        _ queue: SKPaymentQueue,
        updatedTransactions transactions: [SKPaymentTransaction]
    ) {
        var current: [SKPaymentTransaction] = []
        var observersCopy: [SKPaymentTransactionObserver] = []
        
        lock.lock()
        
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
        
        // Copy observers while holding lock
        observersCopy = observers
        
        lock.unlock()
        
        guard !current.isEmpty else { return }
        
        // Safely notify observers (outside lock to prevent deadlock)
        for observer in observersCopy {
            autoreleasepool {
                observer.paymentQueue(queue, updatedTransactions: current)
            }
        }
    }
    
    // iOS 19 compatibility - implement required protocol methods
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        lock.lock()
        let observersCopy = observers
        lock.unlock()
        
        observersCopy.forEach { observer in
            autoreleasepool {
                if observer.responds(to: #selector(SKPaymentTransactionObserver.paymentQueueRestoreCompletedTransactionsFinished(_:))) {
                    observer.paymentQueueRestoreCompletedTransactionsFinished?(queue)
                }
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        lock.lock()
        let observersCopy = observers
        lock.unlock()
        
        observersCopy.forEach { observer in
            autoreleasepool {
                if observer.responds(to: #selector(SKPaymentTransactionObserver.paymentQueue(_:restoreCompletedTransactionsFailedWithError:))) {
                    observer.paymentQueue?(queue, restoreCompletedTransactionsFailedWithError: error)
                }
            }
        }
    }

    private var purchases: [SKPaymentTransaction] = []
}
