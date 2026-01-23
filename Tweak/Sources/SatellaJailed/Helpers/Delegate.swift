import StoreKit

final class SatellaDelegate: NSObject, SKProductsRequestDelegate {
    static let shared: SatellaDelegate = .init()
    var delegates: [SKProductsRequestDelegate] = []
    var products: [SKProduct] = []
    private let lock = NSLock()
    
    func productsRequest(
        _ request: SKProductsRequest,
        didReceive response: SKProductsResponse
    ) {
        var delegatesCopy: [SKProductsRequestDelegate] = []
        var responseToSend: SKProductsResponse = response
        
        lock.lock()
        
        // If the app is not sideloaded, pass orig values
        guard response.products.isEmpty else {
            delegatesCopy = delegates
            lock.unlock()
            
            for delegate in delegatesCopy {
                autoreleasepool {
                    delegate.productsRequest(request, didReceive: response)
                }
            }
            return
        }
        
        // We only need to set the products list once
        if products.isEmpty {
            // Safe value extraction with error handling for iOS 19 compatibility
            let _request: AnyObject? = try? request.value(forKey: "_productsRequestInternal") as? AnyObject
            let _identifiers: Set<String>? = try? _request?.value(forKey: "_productIdentifiers") as? Set<String>
            let identifiers: [String] = .init(_identifiers ?? [])
            
            products = identifiers.compactMap { identifier in
                autoreleasepool {
                    let product: SKProduct = .init()
                    
                    // Use try? to safely set values, avoiding crashes on iOS 19
                    if ObjCExceptionCatcher.tryExecute({
                        product.setValue(0.01 as NSDecimalNumber, forKey: "price")
                        product.setValue(Locale(identifier: "da_DK"), forKey: "priceLocale")
                        product.setValue(identifier, forKey: "productIdentifier")
                        product.setValue(identifier, forKey: "localizedDescription")
                        product.setValue(identifier, forKey: "localizedTitle")
                    }) {
                        return product
                    } else {
                        // Fallback: try individual setValue calls
                        product.setValue(0.01 as NSDecimalNumber, forKey: "price")
                        product.setValue(identifier, forKey: "productIdentifier")
                        return product
                    }
                }
            }
        }
        
        // Send a fake response so the app recognises products without App Store connection
        guard let fakeResponse = SKProductsResponse() as SKProductsResponse? else {
            lock.unlock()
            return
        }
        
        if !ObjCExceptionCatcher.tryExecute({
            fakeResponse.setValue(self.products, forKey: "products")
        }) {
            NSLog("[SatellaJailed] Failed to set fake products")
            lock.unlock()
            return
        }
        
        responseToSend = fakeResponse
        delegatesCopy = delegates
        lock.unlock()
        
        for delegate in delegatesCopy {
            autoreleasepool {
                delegate.productsRequest(request, didReceive: responseToSend)
            }
        }
    }
    
    // SKRequestDelegate method for error handling
    func request(_ request: SKRequest, didFailWithError error: Error) {
        delegates.forEach { delegate in
            if let requestDelegate = delegate as? SKRequestDelegate {
                requestDelegate.request?(request, didFailWithError: error)
            }
        }
    }
    
    func requestDidFinish(_ request: SKRequest) {
        delegates.forEach { delegate in
            if let requestDelegate = delegate as? SKRequestDelegate {
                requestDelegate.requestDidFinish?(request)
            }
        }
    }
}
