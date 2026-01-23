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
        lock.lock()
        defer { lock.unlock() }
        
        // If the app is not sideloaded, pass orig values
        guard response.products.isEmpty else {
            let delegatesCopy = delegates
            lock.unlock()
            for delegate in delegatesCopy {
                autoreleasepool {
                    delegate.productsRequest(request, didReceive: response)
                }
            }
            lock.lock()
            return
        }
        
        // We only need to set the products list once
        if products.isEmpty {
            do {
                // Safe value extraction with error handling for iOS 19 compatibility
                let _request: AnyObject? = try? request.value(forKey: "_productsRequestInternal") as? AnyObject
                let _identifiers: Set<String>? = try? _request?.value(forKey: "_productIdentifiers") as? Set<String>
                let identifiers: [String] = .init(_identifiers ?? [])
                
                products = identifiers.compactMap { identifier in
                    autoreleasepool {
                        let product: SKProduct = .init()
                        
                        // Use try? to safely set values, avoiding crashes on iOS 19
                        do {
                            try ObjCExceptionCatcher.catchException {
                                product.setValue(0.01 as NSDecimalNumber, forKey: "price")
                                product.setValue(Locale(identifier: "da_DK"), forKey: "priceLocale")
                                product.setValue(identifier, forKey: "productIdentifier")
                                product.setValue(identifier, forKey: "localizedDescription")
                                product.setValue(identifier, forKey: "localizedTitle")
                            }
                        } catch {
                            // Fallback: try individual setValue calls
                            product.setValue(0.01 as NSDecimalNumber, forKey: "price")
                            product.setValue(identifier, forKey: "productIdentifier")
                        }
                        
                        return product
                    }
                }
            }
        }
        
        // Send a fake response so the app recognises products without App Store connection
        guard let fakeResponse = SKProductsResponse() as SKProductsResponse? else { return }
        
        do {
            try ObjCExceptionCatcher.catchException {
                fakeResponse.setValue(self.products, forKey: "products")
            }
        } catch {
            NSLog("[SatellaJailed] Failed to set fake products: \(error)")
            return
        }
        
        let delegatesCopy = delegates
        lock.unlock()
        
        for delegate in delegatesCopy {
            autoreleasepool {
                delegate.productsRequest(request, didReceive: fakeResponse)
            }
        }
        
        lock.lock()
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
