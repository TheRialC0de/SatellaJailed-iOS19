import Jinx
import StoreKit

struct ReceiptHook: Hook {
    typealias T = @convention(c) (SKPaymentTransaction, Selector) -> Data

    let cls: AnyClass? = SKPaymentTransaction.self
    let sel: Selector = sel_registerName("transactionReceipt")
    let replace: T = { obj, _ in
        autoreleasepool {
            // Safely get product identifier with fallback
            let productId: String
            if let payment = obj.payment as SKPayment?,
               !payment.productIdentifier.isEmpty {
                productId = payment.productIdentifier
            } else {
                productId = "com.satella.default.product"
            }
            
            // Generate receipt with error handling
            let receipt: OldReceipt = ReceiptGenerator.old(for: productId)
            
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .sortedKeys  // Consistent output
                let data = try encoder.encode(receipt)
                return data
            } catch {
                NSLog("[SatellaJailed] Receipt encoding failed: \(error)")
                // Return minimal valid receipt data as fallback
                return Data("{\"status\":0}".utf8)
            }
        }
    }
}

